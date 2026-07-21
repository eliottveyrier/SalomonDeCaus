extends Node2D

var active = true
var elapsed := 0.

@export var polygon : Polygon2D
var inverse_affine : Transform2D
@export var players : Array[Game26Player]

func _activate():
	active = true
	for player in players:
		player.activate()
	

func _disable():
	active = false
	for player in players:
		player.disable()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var d = to_global(polygon.polygon[3])
	var a = to_global(polygon.polygon[0])
	var c = to_global(polygon.polygon[2])
	var da = a - d
	var dc = c - d
	# Forward transform: (u,v) -> world
	var affine = Transform2D(da, dc, d)
	# Inverse: world -> (u,v)
	inverse_affine = affine.affine_inverse()
	$P1.inverse_affine = inverse_affine
	$P2.inverse_affine = inverse_affine
	$P3.inverse_affine = inverse_affine
	$P1.inverse_ready = true
	$P2.inverse_ready = true
	$P3.inverse_ready = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return
	pass
