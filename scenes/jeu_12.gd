extends Node2D

@onready var roue_ext = $RoueExterieure
@onready var roue_int = $RoueInterieure

@export var day_per_second := 0.4
@export var hour_per_second := 0.2
@export var deg_per_second := 5.
@export var use_theta1 : bool = true

var day : float = 0
var hour : float = 0
var alpha : float = 0
var beta : float = 0

@export var alpha_speed: float = 90.0
@export var beta_speed: float = 90.0

@onready var ombre_p2 : Ombre = $Ombre1
@onready var ombre_p3 : Ombre = $Ombre2

var p2_alpha: float = 0.0
var p2_beta: float = 0.0

var p3_alpha: float = 0.0
var p3_beta: float = 0.0

@onready var markerp1 = $P1
@onready var markerp2 = $P2


var _active = true

func _activate():
	_active = true
func _disable():
	_active = false
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !_active:
		return
	var rotation_ext = Input.get_axis("rotate_outside_left", "rotate_outside_right")
	var rotation_int = Input.get_axis("rotate_inside_left", "rotate_inside_right")
	day += rotation_ext * delta * 365. * day_per_second
	day = wrapf(day,0., 365.)
	hour += rotation_int * delta * 24. * hour_per_second
	hour = wrapf(hour, 0., 24.)
	var p2_alpha_diff = Input.get_axis("p2_alpha_down", "p2_alpha_up")
	var p2_beta_diff = Input.get_axis("p2_beta_down", "p2_beta_up")
	var p3_alpha_diff = Input.get_axis("p3_alpha_down", "p3_alpha_up")
	var p3_beta_diff = Input.get_axis("p3_beta_down", "p3_beta_up")
	
	p2_alpha = clamp(p2_alpha + p2_alpha_diff * alpha_speed * delta, -89.9, 89.9)
	p2_beta = clamp(p2_beta + p2_beta_diff * beta_speed * delta, -89.9, 89.9)

	p3_alpha = clamp(p3_alpha + p3_alpha_diff * alpha_speed * delta, -89.9, 89.9)
	p3_beta = clamp(p3_beta + p3_beta_diff * beta_speed * delta, -89.9, 89.9)
	# for a rotation of day/360 we can aproximate by adding the difference
	roue_ext.rotate(rotation_ext * delta * day_per_second)
	roue_int.rotate(rotation_int * delta * hour_per_second)
	markerp1.alpha = p2_alpha
	markerp1.beta = p2_beta
	markerp2.alpha = p3_alpha
	markerp2.beta = p3_beta
	var p2_tip: Vector2 = find_tip(day, hour, p2_alpha, p2_beta)
	var p3_tip: Vector2 = find_tip(day, hour, p3_alpha, p3_beta)
	ombre_p2.tip = p2_tip
	ombre_p3.tip = p3_tip
	# P2
	OscSettings.broadcastf(
		"/oscControl/miniGame/12/2/alpha",
		p2_alpha
	)
	OscSettings.broadcastf(
		"/oscControl/miniGame/12/2/beta",
		p2_beta
	)
	# P3
	OscSettings.broadcastf(
		"/oscControl/miniGame/12/3/alpha",
		p3_alpha
	)
	OscSettings.broadcastf(
		"/oscControl/miniGame/12/3/beta",
		p3_beta
	)
	OscSettings.broadcastf(
		"/oscControl/miniGame/12/day",
		day
	)
	OscSettings.broadcastf(
		"/oscControl/miniGame/12/hour",
		hour
	)

const LATITUDE_DEG := 49.4
const SHADOW_SCALE := 150.0

func _cot(x: float) -> float:
	return 1.0 / tan(x)

func find_tip(day: float, hour: float, alpha: float, beta: float) -> Vector2:
	var latitude := deg_to_rad(LATITUDE_DEG)

	# Solar declination (degrees)
	var alpha0_deg := 23.5 * sin(TAU * (day - 79.0) / 365.0)

	# Convert everything to radians
	var alpha0 := deg_to_rad(alpha0_deg)
	alpha = deg_to_rad(alpha)
	beta = deg_to_rad(beta)

	# If hour is given in [0,24]
	var h := deg_to_rad(hour * 15.0)

	var t := (
		sin(alpha0) * sin(alpha)
		+ cos(alpha0) * cos(alpha) * cos(beta)
	)

	var root := sqrt(max(0.0, 1.0 - t * t))

	var s := _cot(latitude) * root * cos(h) + t

	# Avoid division by zero
	if absf(s) < 0.000001:
		return Vector2.ZERO

	var x := (t * cos(h) * _cot(latitude) - root) / s
	var y := _cot(latitude) * sin(h) / s

	var r := sqrt(x * x + y * y)

	var theta1 := atan2(y, x) - atan2(
		cos(alpha) * sin(beta),
		sin(alpha0) * cos(alpha) * cos(beta)
		- cos(alpha0) * cos(alpha)
	)
	var theta2 := atan2(
		y,
		x
	) - atan2(
		cos(alpha) * sin(beta),
		t
	)
	var theta := 3.0 * PI / 2.0
	theta -= theta1 if use_theta1 else theta2
	return Vector2.from_angle(theta) * (r * SHADOW_SCALE)
	
