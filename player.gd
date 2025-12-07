extends CharacterBody2D

const speed_cap: int = 1000
const accel_rate: float = 500.
const decel_rate: float = 900.

const coyote_time: float = .2

var current_coyote_time: float

func _process(delta) -> void:
	var input := Vector2(Input.get_axis("left", "right"), 0)
	if is_on_floor():
		velocity = velocity.move_toward(input*speed_cap, (accel_rate if (input.dot(velocity) > 0) else decel_rate)*delta)
		current_coyote_time = coyote_time
	else:
		current_coyote_time = max(0, current_coyote_time-delta)
		velocity.y += get_gravity().y * delta
	if velocity.length_squared() > speed_cap**2:
		velocity = velocity.normalized()*speed_cap
	$Label.text = "%s" % velocity
	move_and_slide()
