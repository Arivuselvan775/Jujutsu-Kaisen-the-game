extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var progress_bar: ProgressBar = $ProgressBar


@onready var target = get_node("/root/Node2D/CharacterBody2D")

var slash = preload("res://scenes/mahoraga_slash.tscn")

var speed = 200
var pos: Vector2
var finish = false
var health = 100

func _ready() -> void:
	animated_sprite_2d.play("summon")
	global_position = pos
func _physics_process(delta: float) -> void:
	progress_bar.value = health
	var direction = global_position.direction_to(target.global_position)
	velocity += get_gravity() * delta
	if is_on_floor() and visible:
		velocity = direction * speed
		if velocity.x < 0:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
	move_and_slide()
	if animated_sprite_2d.animation == "summon" or animated_sprite_2d.animation == "finish":
		animated_sprite_2d.position.y = -14.0
	elif animated_sprite_2d.animation == "attack two":
		animated_sprite_2d.position.y = 19.0
	else:
		animated_sprite_2d.position.y = 12.0
	var arr = area_2d.get_overlapping_bodies()
	for area in arr:
		if area.is_in_group("player") and finish == false and target.is_on_floor():
			animated_sprite_2d.play("attack one")
	if target.health <= 0:
		hedied()
		finish = true
	if health <= 0:
		finish = true
		animated_sprite_2d.play("dead")



func _on_area_2d_body_exited(_body: Node2D) -> void:
	if finish == false:
		animated_sprite_2d.play("attack two")


func hedied():
	animated_sprite_2d.play("finish")

func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite_2d.animation == "attack two":
		var slash1 = slash.instantiate()
		slash1.pos = $Node2D.global_position
		if animated_sprite_2d.flip_h == true:
			slash1.speed = -1000
		else:
			slash1.speed = 1000
		get_parent().add_child(slash1)
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "finish":
		queue_free()
	elif animated_sprite_2d.animation == "attack one":
		target.maho_hit()
	elif animated_sprite_2d.animation == "dead":
		queue_free()
func damage(da):
	health -= da


func _on_hurt_box_body_entered(body: Node2D) -> void:
	damage(20)
