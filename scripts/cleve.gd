extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var target = get_node("/root/Node2D/CharacterBody2D")

var speed = 1000
var pos : Vector2

func _ready() -> void:
	var rand = randi()
	animated_sprite_2d.rotation = rand
	global_position = pos
	animated_sprite_2d.play("cleve")
	$AudioStreamPlayer2D.play()
func _physics_process(delta: float) -> void:
	var range1 = global_position.distance_to(pos)
	velocity.x = speed
	if speed == 1000:
		animated_sprite_2d.flip_h == false
	else:
		animated_sprite_2d.flip_h == true
	move_and_slide()
	
	
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	target.slice()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
