extends Node

class_name Game

enum State {PLAY, START, GAMEOVER}

signal update_connection_strength(value)
signal level_changed(level)
signal points_changed(points)

# Scenes
export (PackedScene) var Bird_scene
export (PackedScene) var Spark_scene

var state = -1 setget set_state

# Level logic
onready var spawn_timer := $Spawn_timer
var level := 1 setget set_level
var points := 0 setget set_points
var alive_bird_count := 0 # use separate count as queue free is completed after game check
var landed_bird_count := 0 #used to check in connection strength update


# Game status
var connection_strength := 100.0 setget set_connection_strength
export (int, 0, 1000) var MAX_CONNECTION_STRENGTH := 100
export (int, 5, 25) var BIRD_SIGNAL_DECREASE := 8
export (int, 1, 5) var TIME_SIGNAL_DECREASE := 3


func _ready() -> void:
	randomize()
	$GUI/Title.visible = true #visible only at start
	$GameLayer/AntennaL.connect("update_charge", $GUI/HUD/LeftAntennaPowerBar, "_on_Antenna_update_power")
	$GameLayer/AntennaR.connect("update_charge", $GUI/HUD/RightAntennaPowerBar, "_on_Antenna_update_power")
	start_game()

func start_game() -> void:
	self.state = State.START

func _process(delta: float) -> void:
	if connection_strength < MAX_CONNECTION_STRENGTH:
		self.connection_strength += 3 * TIME_SIGNAL_DECREASE * delta if landed_bird_count <= 0 else (-1 *landed_bird_count * TIME_SIGNAL_DECREASE * delta)
		if connection_strength < 0:
			check_game()

func _unhandled_input(event: InputEvent) -> void:
	if state == State.PLAY:
		if event.is_action_pressed("button_1"):
			shot_spark(1)
		elif event.is_action_pressed("button_2"):
			shot_spark(-1)
	elif state == State.START:
		if event.is_action_pressed("button_1") or event.is_action_pressed("button_2"):
			self.state = State.PLAY

func shot_spark(direction: int) -> void:
	var antenna : Antenna = $GameLayer/AntennaL if direction > 0 else $GameLayer/AntennaR 
	if not antenna.can_shoot:
		$DisabledSfx.play()
		return
	antenna.shoot() #discharge
	var new_spark : Spark = Spark_scene.instance()
	$Sparks.add_child(new_spark)
	new_spark.initialize(direction)

func spawn_bird() -> void:
	var start_point = Vector2(rand_range(0.0, 1024.0), 0.0)
	var new_bird: Bird = Bird_scene.instance()
	$Birds.add_child(new_bird)
	alive_bird_count += 1
	new_bird.initialize(start_point, level)
	new_bird.connect("Die", self, "_on_Bird_die")
	new_bird.connect("Landed", self, "_on_Bird_land")
	new_bird.connect("Fly_away", self, "_on_Bird_fly_away")

func _on_Spawn_timer_timeout() -> void:
	spawn_bird()
	if alive_bird_count >= level:
		return
	#spawn as many birds as in level number
	spawn_timer.wait_time = rand_range(0.2, 1.5)
	spawn_timer.start()

func _on_Bird_land() -> void:
	landed_bird_count += 1
	connection_strength -= BIRD_SIGNAL_DECREASE
	check_game()

func _on_Bird_fly_away() -> void:
	landed_bird_count -= 1
	#connection_strength = min(connection_strength + BIRD_SIGNAL_DECREASE, MAX_CONNECTION_STRENGTH) 
	check_game()

func _on_Bird_die() -> void:
	#connection_strength = min(connection_strength + BIRD_SIGNAL_DECREASE, MAX_CONNECTION_STRENGTH)
	alive_bird_count -= 1
	landed_bird_count -= 1
	self.points += 100
	check_game() 

func check_game() -> void:
	#gameover_check
	if connection_strength <= 0:
		self.state = State.GAMEOVER
	#level check
	if alive_bird_count <= 0:
		next_level()

func next_level() -> void:
	self.level += 1
	spawn_timer.wait_time = rand_range(0.2, 1.5) #time according to visual feed back
	spawn_timer.start() #timer will take care of bird count

func set_connection_strength(value) -> void:
	if value == connection_strength:
		return
	connection_strength = min(value, MAX_CONNECTION_STRENGTH)
	emit_signal("update_connection_strength", connection_strength) #connected using GUI

func set_state(value) -> void:
	if state == value:
		return
	state = value
	
	match state:
		State.START:
			set_process(false)
			$GUI/HUD.visible = false
			$GUI/Start.visible = true
		State.PLAY:
			$GUI/HUD.visible = true
			#add level and tower GUIs
			$GUI/Title.visible = false
			$GUI/Start.visible = false
			$GUI/Gameover.visible = false
			set_process(true)
			$BGMusic.next()
			self.level = 1
			self.points = 0
			landed_bird_count = 0
			alive_bird_count = 0
			self.connection_strength = MAX_CONNECTION_STRENGTH
			spawn_timer.wait_time = rand_range(0.2, 1.5)
			spawn_timer.start()
		State.GAMEOVER:
			$BGMusic.next()
			set_process(false)
			for bird in $Birds.get_children():
				bird.queue_free()
			$GUI/HUD.visible = false
			$GUI/Title.visible = false
			$GUI/Start.visible = false #show with timer
			$GUI/Gameover.visible = true
			$RestartTimer.start()

func set_level(value) -> void:
	level = value
	emit_signal("level_changed", level)

func set_points(value) -> void:
	points = value
	emit_signal("points_changed", points)
