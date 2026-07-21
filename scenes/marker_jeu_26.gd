extends CharacterBody2D
class_name Game26Player

@export var input_left : StringName
@export var input_right : StringName
@export var input_up : StringName
@export var input_down : StringName

@export var osc_path_x : String
@export var osc_path_y : String


var inverse_affine : Transform2D
var inverse_ready := false

var active := false

@export var player_number : int = 1

@export var speed : float = 200.0

var current_index := -1

@export var rate_limit : float = 30.
var elapsed := 0.

func activate():
	active = true

func disable():
	active=false
	

func _physics_process(delta: float) -> void:
	if !inverse_ready:
		return
	if !active:
		return 
	var input_dir := Vector2.ZERO

	input_dir.x = Input.get_axis(input_left, input_right)
	input_dir.y = Input.get_axis(input_up, input_down)

	velocity = input_dir * speed

	move_and_slide()
	var osc_pos = inverse_affine * global_position
	
	if !(elapsed > 1/rate_limit):
		elapsed += delta
		return
	elapsed = 0.
	OscSettings.broadcastf(osc_path_x,osc_pos.x)
	OscSettings.broadcastf(osc_path_y,osc_pos.y)
	
	
