class_name Level extends Node2D

## The time limit for the level in seconds.
@export var level_time: float
@export var player: Player
@export_category("Scoring")
## The level ID used to store best times.
@export var level_id: String
## The minimum time left in seconds to receive a P rank.
@export var p_rank: int
## The minimum time left in seconds to receive an S rank.
@export var s_rank: int
## The minimum time left in seconds to receive an A rank.
@export var a_rank: int
## The minimum time left in seconds to receive a B rank.
@export var b_rank: int
## The minimum time left in seconds to receive a C rank.
@export var c_rank: int

var timer: Timer
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = level_time
	timer.start()
	timer.timeout.connect(Events.reset_level.emit)
