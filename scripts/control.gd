extends Control

@onready var button: Button = $VBoxContainer/Button
@onready var button_2: Button = $VBoxContainer/Button2
@onready var video_stream_player: VideoStreamPlayer = $VBoxContainer2/VideoStreamPlayer
@onready var panel: Panel = $Panel

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_video_stream_player_finished() -> void:
	$VBoxContainer.visible = true
	panel.visible = true
