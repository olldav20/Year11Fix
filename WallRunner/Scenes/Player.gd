extends CharacterBody2D

@export var base_speed = 500
@export var max_speed = 1000
@export var jump_velocity = -1
@export var base_acceleration : float = 3
@export var deceleration : float = 20
@export var jumps = 1

enum state {IDLE, RUNNING, JUMPUP, JUMPDOWN, HURT}

var anim_state = state.IDLE
var speed = base_speed
var acceleration = base_acceleration

@onready var camera = $Camera2D
@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Coyote timer variables
var coyote_time = 0.1
var coyote_timer = 0.0

func update_state():
	if anim_state == state.HURT:
		return
	if is_on_floor():
		if velocity == Vector2.ZERO:
			anim_state = state.IDLE
		elif velocity.x != 0:
			anim_state = state.RUNNING
	else:
		if velocity.y < 0:
			anim_state = state.JUMPUP
		else:
			anim_state = state.JUMPDOWN

func update_animation(direction):
	if velocity.x > 0:
		animator.flip_h = false 
	elif velocity.x < 0:
		animator.flip_h = true
	match anim_state:
		state.IDLE:
			animation_player.play("idle")
		state.RUNNING:
			animation_player.play("run")
		state.JUMPUP:
			animation_player.play("jump_up")
		state.JUMPDOWN:
			animation_player.play("jump_down")
		state.HURT:
			animation_player.play("hurt")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
		if coyote_timer < 0:
			coyote_timer = 0
	else:
		coyote_timer = coyote_time

	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0):
		velocity.y = clampf(jump_velocity * abs(velocity.x), -600, -250)
		coyote_timer = 0
		
	if Input.is_action_just_pressed("poopemoj"):
		pass

	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")

	if direction != 0:
		# Check if the player has changed direction
		if sign(direction) != sign(velocity.x) and velocity.x != 0:
			# Reduce the current velocity more smoothly to prevent crash or abrupt changes
			velocity.x = velocity.x * 0.5  # Half the current speed to smooth out the change
			acceleration = base_acceleration  # Reset acceleration for a smoother transition

		# Continue normal acceleration
		acceleration += delta * 2
		speed = clamp(base_speed + acceleration, base_speed, max_speed)
		velocity.x = move_toward(velocity.x, direction * speed, acceleration)
	else:
		acceleration = base_acceleration  # Reset acceleration when not moving
		speed = base_speed
		velocity.x = move_toward(velocity.x, 0, deceleration)
		
	animation_player.speed_scale = abs(velocity.x) / 300
	animation_player.speed_scale = clampf(animation_player.speed_scale, 0.5, 7)
	
	if randi_range(1,1000) == 69:
		get_tree().crash
		
	update_state()
	update_animation(direction)
	move_and_slide()

func _on_death_box_area_entered(area):
	if area.is_in_group("Death"):
		get_tree().reload_current_scene()
