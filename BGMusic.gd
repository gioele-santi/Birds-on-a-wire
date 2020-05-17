extends Node

enum State {INTRO, GAME, OVER}

var state = State.INTRO
var _required_next := false
onready var _intro : AudioStreamPlayer = $StartBG
onready var _game : AudioStreamPlayer = $GameBG
onready var _gameover : AudioStreamPlayer = $GameoverBG

var _previous_playback_position : float = -1.0

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
		var playback_position := stream.get_playback_position()
		if playback_position < _previous_playback_position:
			stream.stop()
			next_stream().play()
			state += 1
			_required_next = false
			_previous_playback_position = -1.0
		else:
			_previous_playback_position = playback_position

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

func _on_GameoverBG_finished() -> void:
	state = State.INTRO
	_intro.play()
