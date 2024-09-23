extends Node2D
var canmove = false
@onready var death = $death
@onready var button = get_parent()

func _ready():
	
	
func _process(delta):
	pass

func pressed():
	canmove = true


func _on_timer_timeout():
	if canmove:
		translate(Vector2(16,0))


func _on_death_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().reload_current_scene()
