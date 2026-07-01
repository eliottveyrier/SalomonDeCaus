extends Area2D

@export var target : Node2D 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target.hide()
	if !target:
		return
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	target.modulate.a = 0

func _on_body_entered(body):
	if !target:
		return
	#print(body, "entered")
	target.show()
	await create_tween().tween_property(target,"modulate:a", 1, 0.2)
	

func _on_body_exited(body):
	if !target:
		return
	#print(body, "exited")
	await create_tween().tween_property(target, "modulate:a",0,0.2)	
