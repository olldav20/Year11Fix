extends Camera2D

# Properties
var label = Label
var time = Timer
var zoom_start = 3.0  # Starting zoom level
var zoom_min = 1.0    # Minimum zoom level
var zoom_max = 3.0    # Maximum zoom level (optional, adjust as needed)
var zoom_speed = 0.5  # Zoom speed factor
var zoom_level = Vector2.ZERO
# Reference to the player node (adjust this according to your scene setup)
func _ready() -> void:
	label = $Camera2D/Label
	time = $Camera2D/Timer
	


@onready var player = get_parent()
var max_zoom = Vector2(2,2)
var min_zoom = Vector2(3,3)
func _process(delta):
	# Get the player's velocity

	var velocity = abs(player.velocity.x)
	
	# Calculate zoom based on velocity
	if Input.get_axis("left","right"):
		zoom = zoom.move_toward(max_zoom, zoom_speed * delta)
	else:
		zoom = zoom.move_toward(min_zoom, zoom_speed * 3 * delta)
