extends Node2D

@onready var osc_sender = %OscSender

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		osc_sender.set_server("127.0.0.1:57120")
		
		osc_sender.send_packed_str("/game/goodbye", PackedStringArray(["hey"]))
		osc_sender.send_pos("/game/garden/fountain/pos", Vector2(123,152))
