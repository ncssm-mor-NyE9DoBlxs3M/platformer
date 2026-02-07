extends Control

@export var start_level: PackedScene
@onready var level: Level = load_level(start_level)

func load_level(scene: PackedScene) -> Level:
	var new_level = scene.instantiate()
	$Game.add_child(new_level)
	new_level.timeout.connect(func ():
		level.queue_free()
		level = load_level(scene)
	)
	return new_level

func _process(_delta: float) -> void:
	if level:
		$UI/Timer.text = "%1d:%05.2f" % [level.timer.time_left/60., fmod(level.timer.time_left,60.)]
