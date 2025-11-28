extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var target = get_node("/root/Node2D/CharacterBody2D")
@onready var enemy = get_node("/root/Node2D/enemy")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt: Area2D = $hurt

var pos:Vector2
var dir:float
var speed = 0.0
var start = false

func _ready() -> void:
	global_position=pos
	timer.start()
func _physics_process(_delta: float) -> void:
	var dis = global_position.distance_to(pos)
	velocity.x = speed
	if dis > 1500 and velocity.x:
		queue_free()
	move_and_slide()
	
	


func _on_timer_timeout() -> void:
	if velocity.x:
		#queue_free()
		pass

func delete():
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("explo")


func _on_delete_timeout() -> void:
	queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.visible = false
	queue_free()


func _on_hurt_body_entered(_body: Node2D) -> void:
	if hurt.overlaps_body(enemy):
		target.camera_2d.shake(0.5)
		delete()
