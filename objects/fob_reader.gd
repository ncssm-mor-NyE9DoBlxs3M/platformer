class_name FobReader extends Area2D

signal scan

func _ready() -> void:
	Events.player_died.connect(reset)

func reset() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitorable", false)
	$Sprite.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body is Player and !body.has_keys: return
	scan.emit()
	$Sprite.play("activate")
	$Sound.play()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
