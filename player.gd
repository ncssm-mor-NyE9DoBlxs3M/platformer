extends CharacterBody2D

@export_group("Movement")
@export var speed_cap: float = 1000.
@export var accel_rate: float = 500.
@export var decel_rate: float = 900.
@export var air_accel_rate: float = 100.
@export var air_decel_rate: float = 250.
@export var min_jump_strength: float = 150
@export var max_jump_strength: float = 300
@export var coyote_time: float = .2
@export var jump_conversion: float = .5
@export_group("Animation")
@export var max_run_anim_speed: float = 50.
@export var max_step_height: float = 10

var current_coyote_time: float
var facing_left: bool = false

func _physics_process(delta) -> void:
	var input := Input.get_axis("left", "right")
	var horiz_delta: float = ((accel_rate if is_on_floor() else air_accel_rate) if (Vector2(input, 0).dot(velocity) > 0) else (decel_rate if is_on_floor() else air_decel_rate))*delta
	var target := input*speed_cap
	velocity.x = target if (abs(target-velocity.x) <= horiz_delta) else (velocity.x + sign(target-velocity.x) * horiz_delta)
	if is_on_floor():
		current_coyote_time = coyote_time
	else:
		current_coyote_time = max(0, current_coyote_time-delta)
		velocity.y += get_gravity().y * delta
	if is_on_floor() or current_coyote_time > 0.:
		if Input.is_action_pressed("jump"):
			current_coyote_time = 0
			var jump_strength = min(jump_conversion*abs(velocity.x), max_jump_strength-min_jump_strength)
			velocity.y -= jump_strength+min_jump_strength
			velocity.x -= jump_strength*sign(velocity.x)
			$JumpEffect.restart()
	if velocity.length_squared() > speed_cap**2:
		velocity = velocity.normalized()*speed_cap
	if velocity.y <= 0:
		var stair_check := KinematicCollision2D.new()
		var horizontal_movement := Vector2(velocity.x*delta, 0)
		if test_move(transform, horizontal_movement, stair_check):
			var ray := PhysicsRayQueryParameters2D.create(
				Vector2(stair_check.get_position().x, position.y) + stair_check.get_remainder() - Vector2(0, max_step_height),
				Vector2(stair_check.get_position().x, position.y) + stair_check.get_remainder(),
			collision_mask, [self])
			var step = get_world_2d().direct_space_state.intersect_ray(ray).get("position")
			if step != null:
				var step_height: float = step.y - position.y - safe_margin
				if !test_move(transform.translated(Vector2(0, step_height)), horizontal_movement):
					position.y += step_height
	if velocity.x != 0:
		$Sprite.play("run" if sign(input)==sign(velocity.x) else "stop")
		$Sprite.speed_scale = max(10,abs(velocity.x)/15.)
		facing_left = sign(velocity.x) == -1
		$Sprite.flip_h = facing_left
	else:
		$Sprite.play("idle")
		$Sprite.speed_scale = 5
	if position.y > 1000: # placeholder for death condition
		die()
	move_and_slide()
	$SpeedSFX.pitch_scale = clamp(velocity.length()/500., 0.21, 2) # 0.21 roughly matches up with the idle animation

func _on_hurtbox_body_entered(_body: Node2D) -> void:
	die()

func die() -> void:
	position = Vector2.ZERO
	velocity = Vector2.ZERO
	$Animations.play("death")
