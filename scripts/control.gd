extends Control

@onready var button: Button = $VBoxContainer/Button
@onready var button_2: Button = $VBoxContainer/Button2
@onready var panel: Panel = $Panel

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("resume"):
		$VBoxContainer.visible = true
		panel.visible = true
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()
