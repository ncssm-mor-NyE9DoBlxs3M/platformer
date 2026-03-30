extends Node2D

@export var initial_impulse := Vector2.ZERO
@export var player_thrown := false

@onready var last_position: Vector2 = global_position

func _ready() -> void:
	reset()
	Events.player_died.connect(queue_free if player_thrown else reset)

@onready var lanyard := PackedVector2Array($Lanyard.points)
@onready var lanyard_old := PackedVector2Array($Lanyard.points)

func _physics_process(delta: float) -> void:
	# Key door check
	var result := KinematicCollision2D.new()
	if $Key.test_move($Key.global_transform, $Key.linear_velocity*delta, result) and result.get_collider() is Door:
		result.get_collider().unlock()
	# Verlet integration
	for i in lanyard.size():
		var temp := lanyard[i]
		lanyard[i] += (lanyard[i] - lanyard_old[i]) + $Key.get_gravity() * delta*delta
		lanyard_old[i] = temp
	# Physics adjustments
	for i in range(1, lanyard.size()-1):
		var ray := PhysicsRayQueryParameters2D.create(lanyard_old[i]+global_position, lanyard[i]+global_position, $Key.collision_mask)
		var hit = get_world_2d().direct_space_state.intersect_ray(ray)
		if hit.get("position") != null:
			lanyard[i] = hit.position - global_position + hit.normal*0.01
	# Distance constraints
	lanyard[0] = $Key.position
	lanyard[lanyard.size()-1] = $Key.position
	for iteration in 10:
		for i in lanyard.size()-1:
			var dist := lanyard[i].distance_to(lanyard[i+1])
			if dist > 5.:
				var move := (lanyard[i]-lanyard[i+1])*.5*((5.-dist)/dist)
				lanyard[i] += move
				lanyard[i+1] -= move
	# Make extra sure it's attached to the key
	lanyard[0] = $Key.position
	lanyard[lanyard.size()-1] = $Key.position
	$Lanyard.points = lanyard

func _on_collection_body_entered(body: Node2D) -> void:
	if visible and $DeadTime.is_stopped() and body is Player and !body.has_keys:
		disable()
		$Key/PickupSound.play()
		body.has_keys = true

func reset() -> void:
	$Key.position = Vector2.ZERO
	$Key.linear_velocity = Vector2.ZERO
	for i in range(1, lanyard.size()-1):
		lanyard[i] = Vector2.from_angle(randf_range(0.,TAU))*0.5
		lanyard_old[i] = Vector2.ZERO
	$Lanyard.points = lanyard
	enable()
	$DeadTime.start()
	$Key.linear_velocity = initial_impulse

func _on_destroy_body_entered(_body: Node2D) -> void:
	if !visible: return
	disable()
	$DestroyEffect.interp_to_end = 0.
	$DestroyEffect.position = $Key.position
	$DestroyEffect.restart()
	$Key/DestroySound.play()

func disable() -> void:
	$Lanyard.hide()
	$Key.hide()
	call_deferred("set_physics_process", false)
	$Key.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)

func enable() -> void:
	$Lanyard.show()
	$Key.show()
	$Key.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	call_deferred("set_physics_process", true)
	$DestroyEffect.interp_to_end = 1.
