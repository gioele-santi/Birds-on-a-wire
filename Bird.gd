extends Area2D

class_name Bird
signal Die
signal Landed
signal Fly_away

enum State {IDLE, FLY, WALK, DIE}

var state = State.FLY
var animation := "" setget set_animation

var screen_size := Vector2.ZERO
var wire_y_1 := 410.0
var wire_y_2 := 0.0 #not used

var trajectory_points := []

onready var animation_player := $AnimationPlayer
onready var timer := $Timer

var velocity := Vector2.ZERO setget set_velocity
var speed := 150.0
var threshold := 10.0

func _ready() -> void:
	screen_size = OS.get_screen_size()
	$Sprite.visible = true
	$ExplosionSprite.visible = false #make sure in case some edit was done
	#initialize(position) #test only

func initialize(start_position:Vector2 = Vector2.ZERO, speed_bump: int = 0) -> void:
	randomize()
	change_state(State.FLY)
	position = start_position
	speed += speed_bump * speed * 2 / 100 # 2% speed bump for every level
	pick_trajectory()

func _process(delta: float) -> void:
	#Fly state
	match state:
		State.FLY, State.WALK:
			if trajectory_points.size() > 0:
				self.velocity = trajectory_points[0] - position
				position += velocity.normalized() * speed * delta
				if position.distance_to(trajectory_points[0]) < threshold:
					trajectory_points.pop_front()
			else: 
				change_state(State.IDLE)

func change_state(new_state) -> void:
	if new_state == state:
		return
	
	# Exit State
	match state:
		State.IDLE:
			timer.stop()
			if new_state == State.FLY:
				emit_signal("Fly_away")
		State.FLY:
			if new_state == State.IDLE:
				emit_signal("Landed")
	
	state = new_state

	# Enter State
	match state:
		State.IDLE:
			set_process(false)
			self.animation = "idle"
			timer.wait_time = rand_range(0.5, 2.0)
			timer.start()
		State.FLY:
			pick_trajectory()
			self.animation = "fly"
			set_process(true)
		State.WALK:
			self.animation = "walk"
			set_process(true)
		State.DIE:
			set_process(false)
			#disable collision to avoid removing other sparks or bumping birds
			self.animation = "death"

func pick_trajectory() -> void:
	trajectory_points = []
	var count = randi() % 3 + 2 # random number between 2 and 4
	for i in count:
		var found := false
		var point:= Vector2.ZERO
		while not found:
			var distance = rand_range(200.0, 800.0)
			var angle = randf()
			point = Vector2(distance * cos(angle), distance * sin(angle)) 
			if point.x > 0.0 and point.x < screen_size.x and point.y > 0.0 and point.y < wire_y_1:
				found = true
		
		trajectory_points.append(point)
	
	var landing = Vector2(rand_range(120.0, 912.0), wire_y_1)
	trajectory_points.append(landing)

# Callbacks

func _on_Timer_timeout() -> void:
	if state != State.IDLE:
		return
	#walk on wire
	var x = rand_range(0.0, 1024.0)
	#random fly away
	if x < 120.0 or x > 912.0:
		change_state(State.FLY)
		return
	trajectory_points.append(Vector2(x, position.y))
	change_state(State.WALK)

func _on_Bird_area_entered(area: Area2D) -> void:
	if state == State.DIE:
		return
	if area.is_in_group("Sparks") and state != State.FLY: #it must touch the wire
		$CollisionShape2D.visible = false
		area.queue_free()
		change_state(State.DIE)
	elif area.is_in_group("Birds"):
		$Bump.play()
		# change direction if walking or pick a new route if flying
		pass

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		emit_signal("Die")
		queue_free()

# Setters

func set_velocity(value: Vector2) -> void:
	velocity = value
	match(state):
		State.FLY:
			$Sprite.flip_h = true
			if cos(velocity.angle()) < -0.2:
				$Sprite.flip_h = false
				self.animation = "fly"
			elif sin(velocity.angle()) > 0.8:
				self.animation = "fly_down"
			elif sin(velocity.angle()) < -0.8:
				self.animation = "fly_up"
			else:
				self.animation = "fly"
		State.WALK:
			animation_player.play("walk")
			$Sprite.flip_h = true
			if cos(velocity.angle()) < -0.2:
				$Sprite.flip_h = false

func set_animation(value: String) -> void:
	if value == animation:
		return
	animation = value
	animation_player.play(animation)
