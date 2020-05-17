extends Node

enum State {INTRO, GAME, OVER}

var state = State.INTRO
var _required_next := false
onready var _intro : AudioStreamPlayer = $StartBG
onready var _game : AudioStreamPlayer = $GameBG
onready var _gameover : AudioStreamPlayer = $GameoverBG

func _ready() -> void:
	state = State.INTRO
	_intro.play()

func next() -> void:
	_required_next = true

func _process(_delta: float) -> void:
	if state == State.OVER:
		return
	if _required_next:
		var stream := current_stream()
		var playback := stream.get_playback_position()
		print(playback)
		if playback > current_stream_playback_switch():
			stream.stop()
			next_stream().play()
			state += 1
			_required_next = false

func current_stream() -> AudioStreamPlayer:
	if state == State.INTRO:
		return _intro
	elif state == State.GAME:
		return _game
	else:
		return _gameover

func next_stream() -> AudioStreamPlayer:
	if state == State.INTRO:
		return _game
	elif state == State.GAME:
		return _gameover
	else:
		return _intro

func current_stream_playback_switch() -> float:
	if state == State.INTRO:
		return 3.88
	elif state == State.GAME:
		return 0.0 #23.58
	else:
		return 4.0


func _on_GameoverBG_finished() -> void:
	state = State.INTRO
	_intro.play()
