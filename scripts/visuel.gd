extends Area2D
class_name EventArea
@export var target : Node2D 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !target:
		return
	target.hide()
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	target.modulate.a = 0
	if target.has_method("_disable"):
		target._disable()

func _on_body_entered(body):
	if !target:
		return
	if !(body is CharacterBody2D):
		return
	if target.has_method("_activate"):
		target._activate()
	#print(body, "entered")
	target.show()
	create_tween().tween_property(target,"modulate:a", 1, 0.2)
	

func _on_body_exited(body):
	if !target:
		return
	if !(body is CharacterBody2D):
		return
	if target.has_method("_disable"):
		target._disable()
	#print(body, "exited")
	create_tween().tween_property(target, "modulate:a",0,0.2)	
