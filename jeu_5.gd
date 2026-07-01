extends Node2D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rotation_ext = Input.get_axis("ui_down", "ui_up")
	var rotation_int = Input.get_axis("ui_left", "ui_right")
	$RoueExterieure.rotate(rotation_ext * 0.5 * delta)
	$RoueInterieure.rotate(rotation_int * 0.5 * delta)
	
	
