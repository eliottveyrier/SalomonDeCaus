extends Node2D

var active = true
@export var rate := 30.
@export var smoothing := 5.
var smoothed_rotation := 0.
var elapsed := 0.

func _activate():
	active = true

func _disable():
	active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _physics_process(delta: float) -> void:
	if !active:
		return

	# Read raw input
	var raw_rotation = Input.get_axis(
		"muses_tilt_head_left",
		"muses_tilt_head_right"
	)

	# Smooth it
	smoothed_rotation = lerp(
		smoothed_rotation,
		raw_rotation,
		smoothing * delta
	)

	# Send at the desired rate
	elapsed += delta
	if elapsed < 1.0 / rate:
		return

	elapsed = 0.0
	OscSettings.broadcastf(
		"/oscControl/miniGame/5/rotation",
		smoothed_rotation
	)
