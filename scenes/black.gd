extends AnimatedSprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

@onready var target = get_node("/root/Node2D/CharacterBody2D")


func _physics_process(_delta: float) -> void:
	if animated_sprite_2d.flip_h == true:
		flip_v = false
	elif animated_sprite_2d.flip_h == false:
		flip_v = true


func _on_animation_finished() -> void:
	visible = false
