extends Area2D

@export var texture : Texture2D
@export var text_fr : String
@export var text_al : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered():
	pass

func _on_body_exited():
	pass
