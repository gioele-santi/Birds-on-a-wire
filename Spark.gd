extends Area2D
class_name Spark

signal Explosion(position)

var direction := 1 #or -1 according to pressed button
export (float) var speed = 200.0

func _ready() -> void:
	pass # Replace with function body.

func initialize(start_position) -> void:
	position = start_position

func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_Spark_area_entered(area: Area2D) -> void:
	#check for collision with other sparks
	pass # Replace with function body.
