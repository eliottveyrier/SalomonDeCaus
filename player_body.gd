extends CharacterBody2D
class_name Player

@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var osc_address_x: String = ""
@export var osc_address_y: String = ""
### The target to move on the scenography
@export var target : Node2D

@onready var _old_pos : Vector2 = position 

func _process(_delta):
	if position == _old_pos:
		return
	_old_pos = position
	var x = position.x
	var y = position.y
	var senders = OscSettings.get_senders()
	for name in senders:
		var sender : OscSender = senders[name]
		sender.send_float(osc_address_x , x/1000.)
		sender.send_float(osc_address_y , y/1000.)


func _physics_process(delta):
	print(_translate_to_perspective())
	# Get input vector (built-in helper uses ui actions) 
	# this one is switched up to feel right on the final scenography
	var input_vector = Input.get_vector("ui_down", "ui_up", "ui_left", "ui_right")
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	target.global_position = _translate_to_perspective_v2()

func _translate_to_perspective() -> Vector2 :
	var x = global_position.x
	var y = global_position.y
	var grand_x = (x - 148) * 0.01156 # en cm sur le plan papier
	var grand_y = (y - 438) * 0.01151 # en cm sur le plan papier
	# Sans les terassements dans le trapèze d'en bas
	var yprime_0 = 121637.43 / (33.75 + grand_x) - 719.97
	var xprime = 1320 + ((grand_y - 2.8)/6.2) * (648+0.265006 * (yprime_0 - 1725)) - 0.760142 * (yprime_0 - 1725)
	var yprime = yprime_0
	if grand_x <= 0.8 or grand_y <= 0.7:
		yprime += 95
	elif grand_x <= 5 and grand_y >= 14.2 and grand_y <= 20.8:
		yprime += 95
	elif grand_x <= 16 and grand_y <= 2.8:
		yprime += 70
	if grand_x > 6.8 and grand_y > 9:
		yprime += -40
	return Vector2(xprime,yprime)

func _translate_to_perspective_v2() -> Vector2:
	var x = global_position.x
	var y = global_position.y
	var X = 0.01156 * (x - 148)
	var Y = 0.01156 * (y - 438)
	var y0_prime = 118222.766 / (32.9605 + X) - 687.725
	var x0_prime = (
		1413
		- 0.710872 * (y0_prime - 1749)
		+ (Y - 3.9) / 5.1 * (542 + 0.20908 * (y0_prime - 1749))
	)
	# j'ai ajouté un correctif pour les grandes abcisses
	var x_prime = x0_prime - 7 * (Y - 12.3) * float(Y > 12.3)
	var y_prime = (
		y0_prime
		- 100 * float((X <= 0.8) or (Y <= 0.7))
		- 100 * float(X > 0.8) * float(X <= 5) * float(Y >= 14.2) * float(Y <= 20.8)
		- 70 * float(X > 0.8) * float(X <= 16) * float(Y > 0.7) * float(Y <= 2.8)
		+ 50 * float(X > 6.9) * float(Y > 9)
		- 70 * (3.5 - Y) / 0.7 * float(X > 0.8) * float(X <= 16) * float(Y > 2.8) * float(Y <= 3.5)
		- 30 * (2.8 - Y) / 0.7 * float(X > 0.8) * float(X <= 16) * float(Y > 2.4) * float(Y <= 2.8)
		+ 50 * (Y - 9) / 0.4 * float(X > 6.8) * float(X <= 14.8) * float(Y > 9) * float(Y <= 9.4)
		+ 50 * (X - 6.8) / 1.8 * float(X > 6.8) * float(X <= 8.6) * float(Y > 12.5) * float(Y <= 15.4)
	)
	return Vector2(x_prime,y_prime)
