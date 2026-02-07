extends Control

@export var start_level: PackedScene
@onready var level: Level = start_level.instantiate()

func _ready() -> void:
	$Game.add_child(level)

func _process(_delta: float) -> void:
	if level:
		$UI/Timer.text = "%1d:%2.2f" % [level.timer.time_left/60., fmod(level.timer.time_left,60.)]
