extends Node

onready var spawn_timer := $Spawn_timer
export (PackedScene) var Bird_scene

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
		print("button_1")
	elif event.is_action_pressed("button_2"):
		print("button_2")


func _on_Spawn_timer_timeout() -> void:
	spawn_bird()
	#check bird count, level and and see if necessary to restart timer
