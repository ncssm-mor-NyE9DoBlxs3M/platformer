class_name Level extends Node2D

## The time limit for the level in seconds.
@export var level_time: float
@export var player: Player

var timer: Timer
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = level_time
	timer.start()
	timer.timeout.connect(Events.reset_level.emit)
