extends Camera2D

# Properties
var zoom_start = 3.0  # Starting zoom level
var zoom_min = 1.0    # Minimum zoom level
var zoom_max = 3.0    # Maximum zoom level (optional, adjust as needed)
var zoom_speed = 0.5  # Zoom speed factor

# Reference to the player node (adjust this according to your scene setup)
@onready var player = get_parent()

func _process(delta):
	# Get the player's velocity
	var velocity = abs(player.velocity.x)

	# Calculate zoom based on velocity
	var zoom_level = lerp(zoom_start, zoom_min, velocity * zoom_speed * delta / 10)
	
	# Ensure zoom level stays within defined limits
	zoom_level = clamp(zoom_level, zoom_min, zoom_max)

	# Set the camera zoom
	zoom = Vector2(zoom_level, zoom_level)
