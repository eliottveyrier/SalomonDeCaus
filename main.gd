extends Node2D

@onready var osc_sender = %OscSender

func _ready() -> void:
	Commands.register(
		"hide-sceno", 
		func (...args): 
			if !args.is_empty():
				Commands.error("this command doesn't take arguments")
			$"Scénographie".hide()
	)
	Commands.register(
		"show-sceno", 
		func (...args): 
			if !args.is_empty():
				Commands.error("this command doesn't take arguments")
			$"Scénographie".show()
	)
	
