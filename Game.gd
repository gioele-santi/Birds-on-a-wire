extends Node

class_name Game

signal update_connection_strength(value)

# Scenes
export (PackedScene) var Bird_scene
export (PackedScene) var Spark_scene

# Level logic
onready var spawn_timer := $Spawn_timer
var level := 1
var alive_bird_count := 0 # use separate count as queue free is completed after game check
var landed_bird_count := 0 #used to check in connection strength update

# Game status
var connection_strength := 100.0 setget set_connection_strength
export (int, 0, 1000) var MAX_CONNECTION_STRENGTH := 1000
export (int, 5, 25) var BIRD_SIGNAL_DECREASE := 10
export (int, 1, 5) var TIME_SIGNAL_DECREASE := 1


func _ready() -> void:
	randomize()
	$GUI/Gameover.visible = false
	start_game()

func _process(delta: float) -> void:
	if connection_strength < MAX_CONNECTION_STRENGTH:
		self.connection_strength += 3 * TIME_SIGNAL_DECREASE if landed_bird_count <= 0 else (-1 *landed_bird_count * TIME_SIGNAL_DECREASE)
		if connection_strength < 0:
			check_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("button_1"):
		shot_spark(1)
	elif event.is_action_pressed("button_2"):
		shot_spark(-1)

func shot_spark(direction: int) -> void:
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
	check_game() 

func check_game() -> void:
	#gameover_check
	if connection_strength <= 0:
		gameover()
	#level check
	if alive_bird_count <= 0:
		next_level()

func next_level() -> void:
	# add visual feed back
	print("Level: %s" % [level])
	level += 1
	spawn_timer.wait_time = rand_range(0.2, 1.5) #time according to visual feed back
	spawn_timer.start() #timer will take care of bird count

func start_game() -> void:
	$GUI/SignalBar.visible = true
	level = 1
	connection_strength = MAX_CONNECTION_STRENGTH
	spawn_timer.wait_time = rand_range(0.2, 1.5)
	spawn_timer.start()

func gameover() -> void:
	set_process(false)
	for bird in $Birds.get_children():
		bird.queue_free()
	$GUI/SignalBar.visible = false
	$GUI/Gameover.visible = true
	#timer to present start new game option
	#present elapsed time, removed birds and restart option
	pass

func set_connection_strength(value) -> void:
	if value == connection_strength:
		return
	connection_strength = min(value, MAX_CONNECTION_STRENGTH)
	emit_signal("update_connection_strength", connection_strength) #connected using GUI
