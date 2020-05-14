extends Node

# Scenes
export (PackedScene) var Bird_scene
export (PackedScene) var Spark_scene

# Level logic
onready var spawn_timer := $Spawn_timer
export (int) var level := 1
var alive_bird_count := 0 # use separate count as queue free is completed after game check

# Game status
var connection_strength := 100.0
export (float) var MAX_CONNECTION_STRENGTH := 100.0
export (float) var SIGNAL_DECREASE := 15.0
export (float) var ANTENNA_DAMAGE := 25.0

func _ready() -> void:
	randomize()
	connection_strength = MAX_CONNECTION_STRENGTH
	spawn_timer.wait_time = rand_range(0.2, 1.5)
	spawn_timer.start()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("button_1"):
		shot_spark(1)
	elif event.is_action_pressed("button_2"):
		shot_spark(-1)

func shot_spark(direction: int) -> void:
	var start_position := Vector2(120.0, 402.0)
	if direction < 0:
		start_position.x = 912.0
	var new_spark : Spark = Spark_scene.instance()
	$Sparks.add_child(new_spark)
	new_spark.initialize(start_position, direction)

func spawn_bird() -> void:
	var start_point = Vector2(rand_range(0.0, 1024.0), 0.0)
	var new_bird: Bird = Bird_scene.instance()
	$Birds.add_child(new_bird)
	alive_bird_count += 1
	new_bird.initialize(start_point, level)
	new_bird.connect("Die", self, "_on_Bird_die")
	new_bird.connect("Landed", self, "_on_Bird_land")
	new_bird.connect("Fly_away", self, "_on_Bird_fly_away")
	#connect die, land fly_away signals

func _on_Spawn_timer_timeout() -> void:
	spawn_bird()
	if alive_bird_count >= level:
		return
	#spawn as many birds as in level number
	spawn_timer.wait_time = rand_range(0.2, 1.5)
	spawn_timer.start()

func _on_bird_land() -> void:
	print("Bird landed")
	connection_strength -= SIGNAL_DECREASE
	check_game()

func _on_bird_fly_away() -> void:
	print("Bird fly away")
	connection_strength = min(connection_strength + SIGNAL_DECREASE, MAX_CONNECTION_STRENGTH) 
	check_game()

func _on_Bird_die() -> void:
	print("Bird dead")
	connection_strength = min(connection_strength + SIGNAL_DECREASE, MAX_CONNECTION_STRENGTH)
	alive_bird_count -= 1
	check_game() 

func check_game() -> void:
	print("Connection: %s" % [connection_strength])
	#gameover_check
	if connection_strength <= 0.0:
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

func gameover() -> void:
	print("GAME OVER")
	#present elapsed time, removed birds and restart option
	pass
