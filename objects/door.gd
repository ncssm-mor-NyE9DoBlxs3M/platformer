class_name Door extends StaticBody2D

@export var sound: AudioStreamPlayer2D
@export var collision: CollisionShape2D
@export var sprite: AnimatedSprite2D

@onready var fobs := get_children().filter(func(c): return c is FobReader)
@onready var active_fobs: Array[FobReader] = []

func _ready() -> void:
	Events.player_died.connect(lock)
	for fob in fobs:
		if fob is not FobReader: continue
		fob.scan.connect(_fob_scan.bind(fob))

func _fob_scan(fob: FobReader) -> void:
	active_fobs.append(fob)
	if active_fobs.size() == fobs.size(): unlock(false)
		

func activate() -> void:
	if fobs.size() == 0: unlock(true)

func unlock(instant: bool) -> void:
	sound.play()
	sprite.play("open")
	if instant:
		collision.disabled = true
	else:
		collision.set_deferred("disabled", true)

const RED := Color.DARK_RED
const GREEN := Color.GREEN

func _draw() -> void:
	for fob in fobs:
		draw_line(fob.position, Vector2(0, fob.position.y), GREEN if fob in active_fobs else RED, 2.)
		draw_line(Vector2(0, fob.position.y), Vector2.ZERO, GREEN if fob in active_fobs else RED, 2.)
	
func _process(_delta: float): queue_redraw()

func lock() -> void:
	collision.set_deferred("disabled", false)
	sprite.play("default")
	active_fobs = []
