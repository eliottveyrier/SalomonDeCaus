extends CharacterBody2D
class_name Game6Player

@export var input_left : StringName
@export var input_right : StringName
@export var input_up : StringName
@export var input_down : StringName

@export var coordinate_system : Node2D

@export var player_number : int = 1

@export var speed : float = 200.0

var current_index := -1

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO

	input_dir.x = Input.get_axis(input_left, input_right)
	input_dir.y = Input.get_axis(input_up, input_down)

	velocity = input_dir * speed

	move_and_slide()

	
	
