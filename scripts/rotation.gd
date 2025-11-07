extends Area2D

@onready var gojo = get_node("/root/Node2D/CharacterBody2D")

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node2D) -> void:
	gojo.restorehealth()
	queue_free()
