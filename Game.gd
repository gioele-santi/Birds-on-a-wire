extends Node

onready var spawn_timer := $Spawn_timer
export (PackedScene) var Bird_scene
export (PackedScene) var Spark_scene
export (int) var level := 1

func _ready() -> void:
	randomize()
	spawn_timer.wait_time = rand_range(0.2, 1.5)
	spawn_timer.start()
	pass # Replace with function body.

func spawn_bird() -> void:
	var start_point = Vector2(rand_range(0.0, 1024.0), 0.0)
	var new_bird: Bird = Bird_scene.instance()
	$Birds.add_child(new_bird)
	new_bird.initialize(start_point)
	#connect die, land fly_away signals
	

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

func _on_Spawn_timer_timeout() -> void:
	spawn_bird()
	if $Birds.get_child_count() >= level:
		return
	
	spawn_timer.wait_time = rand_range(0.2, 1.5)
	spawn_timer.start()
	
	#check bird count, level and and see if necessary to restart timer


func gameover() -> void:
	#present elapsed time, removed birds and restart option
	pass
