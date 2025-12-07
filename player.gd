extends CharacterBody2D

const speed_cap: float = 1000.
const accel_rate: float = 500.
const decel_rate: float = 900.
const min_jump_strength: float = 150.
const max_jump_strength: float = 300.
const coyote_time: float = .2
const jump_conversion: float = .5
var current_coyote_time: float

func _process(delta) -> void:
	var input := Vector2(Input.get_axis("left", "right"), 0)
	if is_on_floor():
		velocity = velocity.move_toward(input*speed_cap, (accel_rate if (input.dot(velocity) > 0) else decel_rate)*delta)
		current_coyote_time = coyote_time
		if Input.is_action_just_pressed("jump"):
			var jump_strength = min(jump_conversion*abs(velocity.x), max_jump_strength-min_jump_strength)
			velocity.y -= jump_strength+min_jump_strength
			velocity.x -= jump_strength*sign(velocity.x)
	else:
		current_coyote_time = max(0, current_coyote_time-delta)
		velocity.y += get_gravity().y * delta
	if velocity.length_squared() > speed_cap**2:
		velocity = velocity.normalized()*speed_cap
	$Label.text = "%s" % velocity
	move_and_slide()
