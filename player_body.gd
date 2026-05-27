extends CharacterBody2D
class_name Player

@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

func _physics_process(delta):
    # Get input vector (built-in helper uses ui actions)
    var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if input_vector != Vector2.ZERO:
        input_vector = input_vector.normalized()
        velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

    move_and_slide()
