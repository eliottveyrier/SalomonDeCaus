extends Node

@onready var senders : Dictionary[String, OscSender] = {
	"eliott" : $EliottOscSender,
	"laurent" : $LaurentOscSender
}

func _ready():
	for sender in senders:
		Commands.register(
			"set-%s" % sender, 
			func (...args): 
				if args.is_empty():
					Commands.error("please provide an ip to set %s's ip to" % sender)
					return 
				var ip = args[0];
				Commands.info("changing %s ip" % sender)
				Commands.info("setting ip to %s" % ip)
				var s = senders[sender]
				s.target = ip
	)

func broadcastf(key : String, value : float):
	for _name in senders:
		var sender: OscSender = senders[_name]
		sender.send_float(key, value)

func get_senders() -> Dictionary[String, OscSender]:
	return senders
