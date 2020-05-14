extends Area2D
class_name Spark

signal Explosion(position)

var direction := Vector2.ZERO #or -1 according to pressed button
export (float) var speed = 400.0

func _ready() -> void:
	pass # Replace with function body.

func initialize(start_position: Vector2, verse: int) -> void:
	position = start_position
	direction = Vector2(verse, 0)

func _process(delta: float) -> void:
	position += direction * speed * delta
	if position.x < 120.0 or position.x > 912.0:
		queue_free()


func _on_Spark_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sparks"):
		if direction.x > 0:
			set_process(false)
			$AnimationPlayer.play("explode")
		else:
			queue_free()
		


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	queue_free()
