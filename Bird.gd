extends Area2D

enum State {IDLE, FLY, WALK, DIE}

var state = State.FLY

var screen_size := Vector2.ZERO
var wire_y_1 := 410.0
var wire_y_2 := 0.0

var trajectory_points := []

onready var animation := $AnimationPlayer
onready var timer := $Timer

var velocity := Vector2.ZERO setget set_velocity
var speed := 150.0
var threshold := 10.0

func _ready() -> void:
	screen_size = OS.get_screen_size()
	initialize(position) #test only

func initialize(start_position:Vector2 = Vector2.ZERO) -> void:
	randomize()
	change_state(State.FLY)
	position = start_position
	
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
	
	state = new_state

	# Enter State
	match state:
		State.IDLE:
			set_process(false)
			animation.play("idle")
			timer.wait_time = rand_range(5.0, 8.0)
			timer.start()
		State.FLY:
			pick_trajectory()
			set_process(true)
		State.WALK:
			set_process(true)
	

func set_velocity(value: Vector2) -> void:
	velocity = value
	match(state):
		State.FLY:
			animation.play("fly")
			$Sprite.flip_h = true
			if cos(velocity.angle()) < -0.2:
				$Sprite.flip_h = false
				animation.play("fly")
			elif sin(velocity.angle()) > 0.8:
				animation.play("fly_down")
			elif sin(velocity.angle()) < -0.8:
				animation.play("fly_up")
			else:
				animation.play("fly")
		State.WALK:
			animation.play("walk")
			$Sprite.flip_h = true
			if cos(velocity.angle()) < -0.2:
				$Sprite.flip_h = false

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

func _on_Timer_timeout() -> void:
	if state != State.IDLE:
		return
	#walk on wire
	var x = rand_range(0.0, 1024.0)
	if x < 120.0 or x > 912.0:
		change_state(State.FLY)
		return
	trajectory_points.append(Vector2(x, position.y))
	change_state(State.WALK)

	# or randomly fly away
