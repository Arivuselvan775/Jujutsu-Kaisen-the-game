extends Node2D
@onready var button: Button = $CanvasLayer/VBoxContainer/Button
@onready var button_2: Button = $CanvasLayer/VBoxContainer/Button2

func _ready() -> void:
	$instruction.play("instruction")
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("resume"):
		Engine.time_scale = 0
		$CanvasLayer/VBoxContainer.visible = true
		$CanvasLayer/TextureRect.visible = true
func _on_button_pressed() -> void:
	$CanvasLayer/VBoxContainer.visible = false
	Engine.time_scale = 1
	$CanvasLayer/TextureRect.visible = false


func _on_button_2_pressed() -> void:
	get_tree().quit()
