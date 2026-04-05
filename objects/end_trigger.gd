## Needs to have a CollisionShape2D added manually per level.
## Ends the level when the player enters.
class_name EndTrigger extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.velocity = Vector2.ZERO
		body.has_control = false
		get_tree().create_tween().tween_property(body, "global_position", global_position, 0.25)
		get_tree().current_scene.end_level()
