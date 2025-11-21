extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer_2: Timer = $Timer2
@onready var target = get_node("/root/Node2D/enemy")
@onready var player = get_node("/root/Node2D/CharacterBody2D")

var pos:Vector2
var dir:float
var speed = 1200

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	global_position = pos
	timer.start()
func _physics_process(_delta: float) -> void:
	if not $AnimatedSprite2D.is_playing():
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * speed
	move_and_slide()

	
	


func _on_timer_timeout() -> void:
	if velocity.x:
		queue_free()


func _on_timer_2_timeout() -> void:
		queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	$Sprite2D.visible = true
	if $AnimatedSprite2D.animation == "finished":
		player.pur = false
		queue_free()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	rotation = 0.0
	$AnimatedSprite2D.play("finished")
	$AnimationPlayer.play("explosion")
	target.damage_received(100)
	velocity.x = 0
