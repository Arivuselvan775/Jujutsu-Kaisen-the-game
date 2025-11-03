extends Area2D

@onready var gojo = get_node("/root/Node2D/CharacterBody2D")

func _on_body_entered(body: Node2D) -> void:
	gojo.restorehealth()
	print("power up")
	queue_free()
