extends Area2D
class_name Spark

signal Explosion(position)

var direction := Vector2.ZERO #or -1 according to pressed button
export (float) var speed = 400.0

var LIMIT_LEFT := 143.0
var LIMIT_RIGHT := 912.0
var WIRE_HEIGHT := 392.0

func _ready() -> void:
	$Sprite.visible = true
	$ExplosionSprite.visible = false

func initialize(verse: int) -> void:
	var start_position := Vector2(LIMIT_LEFT, WIRE_HEIGHT)
	if verse < 0:
		start_position.x = LIMIT_RIGHT
	position = start_position
	direction = Vector2(verse, 0)
	$BuzzSfx.play()

func _process(delta: float) -> void:
	position += direction * speed * delta
	if position.x < LIMIT_LEFT or position.x > LIMIT_RIGHT:
		queue_free()


func _on_Spark_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sparks"):
		$CollisionShape2D.visible = false # otherwise it stays in place and destroys other sparks even if not on screen
		if direction.x > 0:
			set_process(false)
			$AnimationPlayer.play("explode")
			$ExplosionSfx.play()
		else:
			queue_free()
		


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	queue_free()
