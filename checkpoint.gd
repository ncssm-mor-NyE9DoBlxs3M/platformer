class_name Checkpoint extends Area2D

func activate() -> void:
	set_deferred("monitorable", false)
	$Sound.play()
	var tween := get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.TRANSPARENT, 1.)
	await tween.finished
	queue_free()
