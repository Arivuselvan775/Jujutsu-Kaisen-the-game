extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit: Area2D = $hit

@onready var target = get_node("/root/Node2D/CharacterBody2D")

var speed = 0
var pos : Vector2

func _ready() -> void:
	global_position = pos
	$AnimatedSprite2D.play()
func _physics_process(_delta: float) -> void:
	var dis = global_position.distance_to(pos)
	velocity.x = speed
	if speed == -1000:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	move_and_slide()
	if dis >= 1000:
		queue_free()



func _on_hit_body_entered(_body: Node2D) -> void:
	target.slice(3)
