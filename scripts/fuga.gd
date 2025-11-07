extends CharacterBody2D
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
@onready var target = get_node("/root/Node2D/CharacterBody2D")
var pos: Vector2
var dir: float
var speed = 1000

func _ready() -> void:
	global_position = pos
	timer.start()

func _physics_process(_delta: float) -> void:
	var dis = global_position.distance_to(pos)
	velocity = Vector2(speed, 0).rotated(dir)
	if speed == -1000:
		animated_sprite_2d.position.x = sprite_2d_2.position.x 
	if speed == 1000:
		animated_sprite_2d.position.x = sprite_2d_2.position.x + 10
	if dis > 2000:
		queue_free()
	if dis < -2000:
		queue_free()
	move_and_slide()


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("fuga last")
	sprite_2d.visible = false
	target.m_hit()
	speed = 0


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
	animated_sprite_2d.visible = false
