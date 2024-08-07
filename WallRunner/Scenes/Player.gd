extends CharacterBody2D

@export var speed = 1000
@export var jump_velocity = -1
@export var acceleration : float = 3
@export var deceleration : float = 20
@export var jumps = 1

enum state {IDLE, RUNNING, JUMPUP, JUMPDOWN, HURT}

var anim_state = state.IDLE

@onready var camera = $Camera2D
@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Coyote timer variables
var coyote_time = 0.1  # Adjust this value as needed (in seconds)
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
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
				# Decrease coyote timer while on the ground
		coyote_timer -= delta
		if coyote_timer < 0:
			coyote_timer = 0
		# Reset coyote timer when leaving the ground
		
	else:
		coyote_timer = coyote_time

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0):
		velocity.y = clampf(jump_velocity * abs(velocity.x), -600, -250)
		coyote_timer = 0  # Reset coyote timer when jumping

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	if direction:
		#if (velocity.x < 0 and direction > 0) or (velocity.x > 0 and direction < 0):
			#acceleration = acceleration * 2
		#else:
			#acceleration = 2.5
			 
		velocity.x = move_toward(velocity.x, direction * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		
	#camera.zoom = Vector2(3.5/(abs(velocity.x/500)+1),3.5/(abs(velocity.x/500)+1))
	#var zoom = clamp(abs(velocity.x)/100,1,3)
	#camera.zoom = Vector2(zoom,zoom)
	#camera.zoom = Vector2(clampf(1, abs(velocity.x)), min)
	animation_player.speed_scale = abs(velocity.x) / 300
	animation_player.speed_scale = clampf(animation_player.speed_scale, 0.5, 7)
	
	
	update_state()
	update_animation(direction)
	move_and_slide()


func _on_death_box_body_entered(body):
	get_tree().reload_current_scene()

