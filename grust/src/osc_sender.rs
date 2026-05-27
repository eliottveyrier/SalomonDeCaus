use godot::prelude::*;
use rosc::{OscMessage, OscPacket, encoder};
use std::net::{Ipv4Addr, SocketAddr, UdpSocket};


/// A Godot node for sending OSC (Open Sound Control) messages over UDP.
///
/// This class provides a simple interface to send OSC messages to a network target
/// using the rosc library. It uses UDP sockets to transmit encoded OSC packets.
#[derive(GodotClass)]
#[class(base=Node, init)]
pub struct OscSender {
    /// ip address and port of the target.
    /// e.g. 127.0.0.1:5000
    #[export]
    target: GString,
    socket: Option<UdpSocket>,
    base: Base<Node>,
}

#[godot_api]
impl OscSender {
    /// Clears the target connection.
    #[func]
    fn clear_target(&mut self) {
        self.target = GString::new();
        self.socket = None;
    }

    /// Gets the socket, creating one if needed.
    fn get_or_create_socket(&mut self) -> Option<&UdpSocket> {
        // If socket doesn't exist, create a new one
        if self.socket.is_none() {
            // bind socket
            let addr = SocketAddr::from((Ipv4Addr::UNSPECIFIED, 0)); // 0 lets the OS pick a free port
            match UdpSocket::bind(addr) {
                Ok(socket) => {
                    self.socket = Some(socket);
                }
                Err(e) => {
                    godot_error!("Error creating UDP socket: {}", e);
                    return None;
                }
            }
        }

        self.socket.as_ref()
    }

    /// Internal helper to send an OSC message with the given arguments.
    fn _send_message(&mut self, addr: String, args: Vec<rosc::OscType>) -> bool {
        godot_print!("{}", &addr);
        if self.target.is_empty() {
            godot_print!("Error: No target configured");
            return false;
        }

        let target = self.target.to_string();

        // Get or create the persistent socket
        let socket = match self.get_or_create_socket() {
            Some(s) => s,
            None => return false,
        };

        // Create debug string before moving args
        let _args_debug = args
            .iter()
            .map(|arg| format!("{:?}", arg))
            .collect::<Vec<_>>()
            .join(", ");

        // Build and send OSC message
        let msg = OscMessage {
            addr: addr.clone(),
            args,
        };

        let packet = OscPacket::Message(msg);
        let bytes = match encoder::encode(&packet) {
            Ok(b) => b,
            Err(e) => {
                godot_print!("Error encoding OSC message: {}", e);
                return false;
            }
        };

        // Send to target
        match socket.send_to(&bytes, &target) {
            Ok(_) => {
                #[cfg(feature = "verbose")]
                godot_print!("OSC message sent to {}: {} [{}]", target, addr, args_debug);
                true
            }
            Err(e) => {
                godot_print!("failed to send to {}", &target);
                godot_error!("Error sending OSC message: {}", e);
                // Invalidate socket on send error
                self.socket = None;
                false
            }
        }
    }

    /// Sends an OSC message to the configured target.
    ///
    /// Uses a persistent UDP socket connection, creating one on first use
    /// and recreating it if the connection becomes invalid.
    ///
    /// # Arguments
    /// * `addr` - The OSC address path (e.g., "/mixer/volume")
    /// * `args` - An array of string arguments to include in the message
    ///
    /// # Returns
    /// `true` if the message was sent successfully, `false` otherwise.
    #[func]
    fn send_packed_str(&mut self, addr: String, args: PackedStringArray) -> bool {
        let osc_args: Vec<rosc::OscType> = args
            .as_slice()
            .iter()
            .map(|s| rosc::OscType::String(s.to_string()))
            .collect();
        self._send_message(addr, osc_args)
    }

    /// Sends a Vector2 position as two float values in an OSC message.
    ///
    /// # Arguments
    /// * `addr` - The OSC address path (e.g., "/player/position")
    /// * `pos` - The Vector2 position to send
    ///
    /// # Returns
    /// `true` if the message was sent successfully, `false` otherwise.
    #[func]
    fn send_pos(&mut self, addr: String, pos: Vector2) -> bool {
        let osc_args = vec![rosc::OscType::Float(pos.x), rosc::OscType::Float(pos.y)];
        self._send_message(addr, osc_args)
    }

    /// Sends a boolean value in an OSC message.
    ///
    /// # Arguments
    /// * `addr` - The OSC address path (e.g., "/switch/enabled")
    /// * `value` - The boolean value to send
    ///
    /// # Returns
    /// `true` if the message was sent successfully, `false` otherwise.
    #[func]
    fn send_bool(&mut self, addr: String, value: bool) -> bool {
        let osc_args = vec![rosc::OscType::Bool(value)];
        self._send_message(addr, osc_args)
    }

    /// Sends a float value in an OSC message.
    ///
    /// # Arguments
    /// * `addr` - The OSC address path (e.g., "/slider/value")
    /// * `value` - The float value to send
    ///
    /// # Returns
    /// `true` if the message was sent successfully, `false` otherwise.
    #[func]
    fn send_float(&mut self, addr: String, value: f32) -> bool {
        let osc_args = vec![rosc::OscType::Float(value)];
        self._send_message(addr, osc_args)
    }
}
