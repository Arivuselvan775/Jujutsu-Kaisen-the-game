extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var target = get_node("/root/Node2D/enemy")
@onready var player = get_node("/root/Node2D/CharacterBody2D")

var pos:Vector2
var dir:float
var speed = 1200

func _ready() -> void:
	player.animation_player.play("ured move")
	$AnimatedSprite2D.play("default")
	global_position = pos
func _physics_process(_delta: float) -> void:
	if not $AnimatedSprite2D.is_playing():
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * speed
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	$Sprite2D.visible = true
	if $AnimatedSprite2D.animation == "finished":
		player.pur = false
		player.camera_2d.enabled = true
		queue_free()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	player.camera_2d.shake(2.0)
	rotation = 0.0
	$AnimatedSprite2D.play("finished")
	$AnimationPlayer.play("explosion")
	target.damage_received(100)
	velocity.x = 0
