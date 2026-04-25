class_name Player extends CharacterBody2D

@export var start_with_keys: bool = true
@export_group("Movement")
@export var speed_cap: float = 600.
@export var accel_rate: float = 800.
@export var decel_rate: float = 900.
@export var air_accel_rate: float = 100.
@export var air_decel_rate: float = 250.
@export var min_jump_strength: float = 200
@export var max_jump_strength: float = 300
@export var coyote_time: float = .2
@export var jump_conversion: float = .25
@export_group("Animation")
@export var max_run_anim_speed: float = 50.
@export var max_step_height: float = 10
@export_group("Keys")
@export var key_throw_speed: float = 250.
@export var key_bonus_upward: float = 200.

var current_coyote_time: float
var facing_left: bool = false
var has_control := true
@onready var has_keys := start_with_keys

@onready var initial_pos: Vector2 = position
@onready var respawn_pos: Vector2 = initial_pos

func _ready() -> void:
	Events.reset_level.connect(reset)

func _physics_process(delta) -> void:
	var input := Input.get_axis("left", "right") if has_control else 0.
	var horiz_delta: float = ((accel_rate if is_on_floor() else air_accel_rate) if (Vector2(input, 0).dot(velocity) > 0) else (decel_rate if is_on_floor() else air_decel_rate))*delta
	var target := input*speed_cap
	var old_horiz_speed := velocity.x
	velocity.x = target if (abs(target-velocity.x) <= horiz_delta) else (velocity.x + sign(target-velocity.x) * horiz_delta)
	if old_horiz_speed < speed_cap: velocity.x = min(speed_cap,abs(velocity.x))*sign(velocity.x)
	if is_on_floor():
		current_coyote_time = coyote_time
	else:
		current_coyote_time = max(0, current_coyote_time-delta)
		velocity.y += get_gravity().y * delta
	if is_on_floor() or current_coyote_time > 0.:
		if Input.is_action_pressed("jump") and has_control:
			current_coyote_time = 0
			var jump_strength = min(jump_conversion*abs(velocity.x), max_jump_strength-min_jump_strength)
			velocity.y -= jump_strength+min_jump_strength
			velocity.x -= jump_strength*sign(velocity.x)
			$JumpEffect.restart()
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
		$Sprite.play(("run" if sign(input)==sign(velocity.x) else "stop")+("_keys" if has_keys else ""))
		$Sprite.speed_scale = max(10,abs(velocity.x)/15.)
		facing_left = sign(velocity.x) == -1
		$Sprite.flip_h = facing_left
		$Sparkles.position.x = 2.*sign(velocity.x)
	else:
		$Sprite.play("idle"+("_keys" if has_keys else ""))
		$Sprite.speed_scale = 5
	if position.y > 1000:
		die(true)
	if has_keys:
		door_check(delta)
		if Input.is_action_just_pressed("throw") and has_control:
			var direction: Vector2 = Input.get_vector("left", "right", "up", "down")*max(key_throw_speed, velocity.length())
			if direction.y == 0: direction -= Vector2(0, key_bonus_upward)
			has_keys = false
			var keys := preload("res://objects/Key.tscn").instantiate()
			keys.global_position = global_position - Vector2(0., 10.)
			keys.initial_impulse = direction
			velocity = -direction
			keys.player_thrown = true
			add_sibling(keys)
			$KeyThrow.play()
	move_and_slide()
	$SpeedSFX.pitch_scale = clamp(velocity.length()/500., 0.21, 2) # 0.21 roughly matches up with the idle animation
	$Sparkles.amount_ratio = (0.25+clamp(velocity.length()/1500., 0., .75))*int(has_keys)

func _on_hurtbox_body_entered(_body: Node2D) -> void:
	die()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Checkpoint:
		respawn_pos = area.position
		area.activate()

func die(alt: bool = false) -> void:
	position = respawn_pos
	has_keys = false if respawn_pos != initial_pos else start_with_keys
	velocity = Vector2.ZERO
	$Animations.play("death")
	($Camera/AltDeathSound if alt else $Camera/DeathSound).play()
	Events.player_died.emit()

func reset() -> void:
	respawn_pos = initial_pos
	has_keys = start_with_keys
	die()

func door_check(delta: float) -> void:
	var result := KinematicCollision2D.new()
	if test_move(transform, velocity*delta, result) and result.get_collider() is Door:
		result.get_collider().activate()
# Admin Keys!
# F1 to KYS
func _process(_delta):
	if Input.is_action_just_pressed("kill"):  # Remap "kill" to F1 in Project Settings > Input Map
		die()
