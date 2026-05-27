extends Node2D

@export var osc_address : String = "/game/example"

var player : Player = null

var _active := false :
	set(val):
		if val != _active:
			var senders = OscSettings.get_senders()
			for sender in senders:
				senders[sender].send_bool(osc_address + "/active", val)
		_active = val

var _old_position : Vector2 = Vector2.INF

 

func _on_area_2d_body_entered(body):
	if body is Player:
		_active = true
		player = body
		

func _on_area_2d_body_exited(body):
	if body is Player:
		_active = false

func _ready():
	pass


func _process(delta):
	if _active:
		var pos_in_player_space = player.to_local(global_position)
		if pos_in_player_space == _old_position:
			return
		_old_position = pos_in_player_space
		var senders = OscSettings.get_senders()
		for sender in senders:
			senders[sender].send_pos(osc_address + "pos", pos_in_player_space)
