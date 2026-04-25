extends Control

@export var start_level: PackedScene
var level: Level

func _ready() -> void:
	$UI/MainMenu/Menu/Play.grab_focus()

func _on_button_hover(node: NodePath) -> void:
	get_node(node).grab_focus()

func load_level(scene: PackedScene) -> Level:
	var new_level = scene.instantiate()
	$Game.add_child(new_level)
	return new_level

func _process(_delta: float) -> void:
	if level:
		$UI/Timer.text = "%1d:%05.2f" % [level.timer.time_left/60., fmod(level.timer.time_left,60.)]

func _on_play_pressed() -> void:
	$UI/MainMenu.hide()
	level = load_level(start_level)
	$UI/Timer.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

var scoring_timer := 0.
var rank := 0

func end_level() -> void:
	var save := ConfigFile.new()
	save.load("user://save.ini")
	level.timer.paused = true
	$UI/Timer.hide()
	scoring_timer = 0.
	rank = 0
	$UI/Scoring/Background.color = Color.BLACK
	$UI/Scoring/V/Time/Rank.text = " "
	$UI/Scoring/V/Time/Rank.modulate = Color.RED
	$UI/Scoring/V/Time/Timer.text = "0:00.00"
	$UI/Scoring/V/Time.hide()
	$UI/Scoring/V/NewBest.hide()
	$UI/Scoring/V/Message.text = ""
	$UI/Scoring.show()
	var tween := get_tree().create_tween()
	tween.tween_property($UI/Scoring/Background, "color", Color(0., 0., 0., 0.6), 0.25)
	tween.tween_callback(func(): $UI/Scoring/V/Time.show())
	tween.tween_interval(0.25)
	tween.tween_callback(func():
		$UI/Scoring/V/Time/Rank.text = "D"
		$UI/Scoring/Rank.stream = preload("uid://cjg7k6yjdumg4")
		$UI/Scoring/Rank.play()
	)
	tween.tween_method(scoring_timer_tick, 0., level.timer.time_left, level.timer.time_left/level.level_time*5.)
	var best: float = save.get_value("best_times", level.level_id, 0)
	if level.timer.time_left > best:
		tween.tween_interval(0.5)
		tween.tween_callback(func():
			$UI/Scoring/Rank.stream = preload("uid://c00ctp5qe1xxo")
			$UI/Scoring/Rank.play()
			$UI/Scoring/V/NewBest.show()
		)
		save.set_value("best_times", level.level_id, level.timer.time_left)
		print(save.save("user://save.ini"))
	tween.tween_interval(0.75)
	tween.tween_callback(func():
		$UI/Scoring/Rank.stream = preload("uid://ctgm6iq5gahxj")
		$UI/Scoring/Rank.play()
		match rank:
			0: $UI/Scoring/V/Message.text = "BARELY!" # D
			1: $UI/Scoring/V/Message.text = "CLEAR!" # C
			2: $UI/Scoring/V/Message.text = "GOOD JOB!" # B
			3: $UI/Scoring/V/Message.text = "GREAT!" # A
			4: $UI/Scoring/V/Message.text = "AMAZING!" # S
			5: $UI/Scoring/V/Message.text = "PERFECT!" # P
		$UI/Scoring/V/Message.show()
	)
	tween.tween_interval(1.5)
	await tween.finished
	$UI/Scoring.hide()
	$UI/MainMenu.show()
	$UI/MainMenu/Menu/Play.grab_focus()
	level.queue_free()

func scoring_timer_tick(time: float) -> void:
	$UI/Scoring/V/Time/Timer.text = "%1d:%05.2f" % [time/60., fmod(time,60.)]
	$UI/Scoring/Tick.play()
	if rank == 0 and time > level.c_rank:
		rank = 1
		$UI/Scoring/V/Time/Rank.text = "C"
		$UI/Scoring/V/Time/Rank.modulate = Color.ORANGE
		$UI/Scoring/Rank.stream = preload("uid://bb6tdlvsho7qp")
		$UI/Scoring/Rank.play()
	if rank == 1 and time > level.b_rank:
		rank = 2
		$UI/Scoring/V/Time/Rank.text = "B"
		$UI/Scoring/V/Time/Rank.modulate = Color.YELLOW
		$UI/Scoring/Rank.stream = preload("uid://dwqjltcoevpum")
		$UI/Scoring/Rank.play()
	if rank == 2 and time > level.a_rank:
		rank = 3
		$UI/Scoring/V/Time/Rank.text = "A"
		$UI/Scoring/V/Time/Rank.modulate = Color.GREEN
		$UI/Scoring/Rank.stream = preload("uid://c4v0uyraqpv0f")
		$UI/Scoring/Rank.play()
	if rank == 3 and time > level.s_rank:
		rank = 4
		$UI/Scoring/V/Time/Rank.text = "S"
		$UI/Scoring/V/Time/Rank.modulate = Color.CYAN
		$UI/Scoring/Rank.stream = preload("uid://dh0bny5lts3dk")
		$UI/Scoring/Rank.play()
	if rank == 4 and time > level.p_rank:
		rank = 5
		$UI/Scoring/V/Time/Rank.text = "P"
		$UI/Scoring/V/Time/Rank.modulate = Color.MAGENTA
		$UI/Scoring/Rank.stream = preload("uid://dkxjenynn3v8n")
		$UI/Scoring/Rank.play()
