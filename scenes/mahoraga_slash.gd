extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 0
var pos : Vector2

func _ready() -> void:
	global_position = pos
	$AnimatedSprite2D.play()
func _physics_process(delta: float) -> void:
	velocity.x = speed
	if speed == -1000:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	move_and_slide()
