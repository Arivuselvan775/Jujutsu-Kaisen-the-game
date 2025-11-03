extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


@onready var target = get_node("/root/Node2D/CharacterBody2D")

var slash = preload("res://scenes/mahoraga_slash.tscn")

var speed = 250
var pos: Vector2
var attack = false

func _ready() -> void:
	animated_sprite_2d.play("summon")
	global_position = pos
func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(target.global_position)
	var stop = global_position.distance_to(target.global_position) 
	velocity += get_gravity() * delta
	if is_on_floor() and visible:
		velocity = direction * speed
		if velocity.x < 0:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
	move_and_slide()
	if animated_sprite_2d.animation == "summon":
		animated_sprite_2d.position.y = -14.0
	elif animated_sprite_2d.animation == "attack two":
		animated_sprite_2d.position.y = 19.0
	else:
		animated_sprite_2d.position.y = 12.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	animated_sprite_2d.play("attack one")
	attack = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	animated_sprite_2d.play("attack two")
	attack = false




func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite_2d.animation == "attack two":
		var slash1 = slash.instantiate()
		slash1.pos = $Node2D.global_position
		if animated_sprite_2d.flip_h == true:
			slash1.speed = -1000
		else:
			slash1.speed = 1000
		get_parent().add_child(slash1)
