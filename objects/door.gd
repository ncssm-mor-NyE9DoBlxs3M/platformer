class_name Door extends StaticBody2D

@export var sound: AudioStreamPlayer2D
@export var collision: CollisionShape2D
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	Events.player_died.connect(lock)

func unlock() -> void:
	sound.play()
	sprite.play("open")
	collision.disabled = true

func lock() -> void:
	collision.set_deferred("disabled", false)
