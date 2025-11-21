extends RichTextLabel


@onready var target = get_node("/root/Node2D/CharacterBody2D")

func _physics_process(_delta: float) -> void:
	var ammo = target.red_ammo 
	text = str(ammo)
