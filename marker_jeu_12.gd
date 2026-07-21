extends Node2D

@export var alpha : float
@export var beta : float

@onready var initial_position = position

func _physics_process(delta: float) -> void:
	position = initial_position + Vector2(-beta,-alpha)
