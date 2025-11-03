extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var pos: Vector2

func _ready() -> void:
	global_position = pos
	animation_player.play("wheel rotation")
	$Timer.start()
	


func _on_timer_timeout() -> void:
	queue_free()
