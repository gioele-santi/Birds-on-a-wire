extends Node

onready var spawn_timer := $Spawn_timer

func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("button_1"):
		print("button_1")
	elif event.is_action_pressed("button_2"):
		print("button_2")

