extends Area2D

class_name Antenna #it should have been Pole

signal update_charge(value)

var can_shoot := true

export (int) var verse := 1 # verse of emission

var SHOT_POWER := 100
var MAX_POWER := 300.0
var RECHARGE := 25.0
var current_power : float setget set_current_power

func _ready() -> void:
	$ExplosionSprite.visible = false

func _process(delta: float) -> void:
	if current_power < MAX_POWER:
		self.current_power += delta * RECHARGE

func shoot() -> void:
	#perform emission in game scene (if curved path is added, it will be easier)
	self.current_power -= SHOT_POWER

func _on_Antenna_area_entered(area: Spark) -> void:
	if area.is_in_group("Sparks") and area.direction.x * verse < 0 :
		$AnimationPlayer.play("Explosion")
		self.current_power = 0

func set_current_power(value) -> void:
	if value <= 0:
		can_shoot = false
	elif value >= MAX_POWER:
		can_shoot = true
	current_power = min(value, MAX_POWER)
	update()
