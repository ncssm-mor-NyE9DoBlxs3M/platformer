extends CharacterBody2D

@export_group("Movement")
@export var speed_cap: float = 1000.
@export var accel_rate: float = 500.
@export var decel_rate: float = 900.
@export var min_jump_strength: float = 150
@export var max_jump_strength: float = 300
@export var coyote_time: float = .2
@export var jump_conversion: float = .5
@export_group("Animation")
@export var max_run_anim_speed: float = 50.
@export var air_control_coefficient: float = 1.

var current_coyote_time: float

const max_run_anim_speed: float = 50.

func _process(delta) -> void:
	var input := Input.get_axis("left", "right")
	var horiz_delta: float = (
		(accel_rate if is_on_floor() else 
		air_control_coefficient * accel_rate) 
		if (Vector2(input, 0).dot(velocity) > 0) 
		else (decel_rate if is_on_floor() 
		else decel_rate * air_control_coefficient))*delta
	var target := input * speed_cap
	
	velocity.x = target if (abs(target-velocity.x) <= horiz_delta) else (velocity.x + sign(target-velocity.x) * horiz_delta)
	
	if is_on_floor():
		current_coyote_time = coyote_time
	else:
		current_coyote_time = max(0, current_coyote_time-delta)
		velocity.y += get_gravity().y * delta
	if is_on_floor() or current_coyote_time > 0.:
		if Input.is_action_just_pressed("jump"):
			current_coyote_time = 0
			var jump_strength = min(jump_conversion*abs(velocity.x), max_jump_strength-min_jump_strength)
			velocity.y -= jump_strength+min_jump_strength
			velocity.x -= jump_strength*sign(velocity.x)
			
	#if velocity.length_squared() > speed_cap**2:
	#	velocity = velocity.normalized()*speed_cap
		
	$Sprite.speed_scale = (velocity.x/speed_cap)*max_run_anim_speed
	
	if position.y > 1000: # placeholder for death condition
		position = Vector2.ZERO
		velocity = Vector2.ZERO
		$Animations.play("death")
	move_and_slide()
	


### Boost pad ###
func _on_area_2d_player_in_boostpad(_velocity: Vector2) -> void:
	velocity += _velocity
