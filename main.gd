extends Control

@export var start_level: PackedScene
var level: Level

func _ready() -> void:
	$UI/MainMenu/Menu/Play.grab_focus()

func _on_button_hover(node: NodePath) -> void:
	get_node(node).grab_focus()

func _ready() -> void:
	$Game.add_child(level)

func _process(_delta: float) -> void:
	if level:
		$UI/Timer.text = "%1d:%05.2f" % [level.timer.time_left/60., fmod(level.timer.time_left,60.)]

func _on_play_pressed() -> void:
	$UI/MainMenu.hide()
	level = load_level(start_level)

func _on_quit_pressed() -> void:
	get_tree().quit()
