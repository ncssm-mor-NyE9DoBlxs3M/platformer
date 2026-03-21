class_name Door extends StaticBody2D

@export var sound: AudioStreamPlayer2D
@export var collision: CollisionShape2D

func _ready() -> void:
	Events.player_died.connect(lock)

func unlock() -> void:
	sound.play()
	collision.disabled = true

func lock() -> void:
	collision.disabled = false
