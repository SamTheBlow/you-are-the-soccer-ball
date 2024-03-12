extends Node


signal play_again()

@export var music_bgm: AudioStreamPlayer
@export var music_goal: AudioStreamPlayer
@export var music_countdown: AudioStreamPlayer
@export var music_game_over: AudioStreamPlayer
@export var music_victory: AudioStreamPlayer
@export var music_fanfare: AudioStreamPlayer

@export var ball_scene: PackedScene

@export var cars: Array[SoccerCar]
@export var field: SoccerField
@export var player: SoccerBall
@export var timer_label: Label
@export var score_label: Label
@export var score_team_a_label: Label
@export var score_team_b_label: Label

@export var bgm_timer: Timer
@export var goal_timer: Timer
@export var end_timer: Timer
@export var podium: Marker3D

var _is_playing: bool = false
var _score: int = 0
var _start_time_ms: int = 0


func _ready() -> void:
	%GameOverScreen.hide()
	%WinScreen.hide()
	(%Podium as Node3D).hide()
	field.goal_scored.connect(_on_goal_scored)
	player.body.freeze = true
	music_countdown.play()


func _process(_delta: float) -> void:
	if not _is_playing:
		return
	
	# Passive score
	_score += 5
	
	var score_messages: String = ""
	
	# Score for being high in the air
	if player.body.global_position.y > 6.0:
		_score += 3
		score_messages += "Air time (+3)\n"
	
	# Score for being very high in the air
	if player.body.global_position.y >= 20.0:
		_score += 13
		score_messages += "IN THE SKY!! (+13)\n"
	
	# Score for being idle
	if (not Input.is_action_just_pressed("jump")) and Input.get_vector("move_left", "move_right", "move_up", "move_down").length() == 0.0:
		_score += 2
		score_messages += "Doing nothing (+2)\n"
	
	# Score for being immobile
	var speed: float = sqrt(player.body.linear_velocity.x ** 2.0 + player.body.linear_velocity.x ** 2.0)
	if speed <= 3.0 and player.body.global_position.y <= 7.0:
		_score += 17
		score_messages += "Immobile (+17)\n"
	
	# Score for being fast
	if speed >= 10.0:
		_score += 7
		score_messages += "High speed (+7)\n"
	
	# Score for being very fast
	if speed >= 25.0:
		_score += 11
		score_messages += "GOTTA GO FAST!! (+11)\n"
	
	# Score for being close to a goald
	if abs(player.body.global_position.x) >= 40.0 and abs(player.body.global_position.z) <= 15.0 and player.body.global_position.y <= 8.0:
		_score += 19
		score_messages += "Danger!! (+19)\n"
	
	(%ScoreLabel as Label).text = str(_score)
	(%ScoreMessages as RichTextLabel).text = score_messages
	
	var time_passed_ms: int = Time.get_ticks_msec() - _start_time_ms
	var total_seconds_left: int = 60 * 3
	var minutes_left: int = 3
	var seconds_left: int = 0
	while time_passed_ms >= 1000 and total_seconds_left > 0:
		if total_seconds_left % 60 == 0:
			minutes_left -= 1
			seconds_left = 60
		total_seconds_left -= 1
		seconds_left -= 1
		time_passed_ms -= 1000
	
	var seconds_string: String = str(seconds_left)
	if seconds_left < 10:
		seconds_string = "0" + seconds_string
	timer_label.text = str(minutes_left) + ":" + seconds_string
	
	if total_seconds_left == 0:
		_game_over_win()


func _on_goal_scored(which_goal: int) -> void:
	if which_goal == 1:
		score_team_b_label.text = "1"
	elif which_goal == 2:
		score_team_a_label.text = "1"
	
	music_bgm.stop()
	music_goal.play()
	player.explode()
	
	_is_playing = false
	_clear_score_messages()
	goal_timer.start()


func _game_over_win() -> void:
	player.body.freeze = true
	
	music_bgm.stop()
	music_fanfare.play()
	
	_is_playing = false
	_clear_score_messages()
	end_timer.start()


func _gain_score(score_gained: int) -> void:
	_score += score_gained
	score_label.text = str(_score)


func _on_goal_timer_timeout() -> void:
	move_to_podium()
	%GameOverScreen.show()
	music_game_over.play()


func _on_end_timer_timeout() -> void:
	move_to_podium()
	%WinScreen.show()
	music_victory.play()


func move_to_podium() -> void:
	player.queue_free()
	player = ball_scene.instantiate() as SoccerBall
	player.position = podium.global_position
	player.rotation = Vector3(1.4, -1.6, 0.0)
	$World.add_child(player)
	(%Podium as Node3D).show()
	(%PodiumCamera as Camera3D).current = true


func _on_play_again_pressed() -> void:
	play_again.emit()


func _on_countdown_timer_timeout() -> void:
	_is_playing = true
	for car in cars:
		car.playing = true
	player.body.freeze = false
	_start_time_ms = Time.get_ticks_msec()
	bgm_timer.start()


func _on_bgm_timer_timeout() -> void:
	music_bgm.play()


func _clear_score_messages() -> void:
	(%ScoreMessages as RichTextLabel).text = ""
