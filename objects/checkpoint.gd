class_name Checkpoint extends Area2D

func _ready() -> void:
	Events.reset_level.connect(deactivate)

func activate() -> void:
	set_deferred("monitorable", false)
	$Sound.play()
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.)

func deactivate() -> void:
	monitorable = true
	modulate = Color.WHITE
