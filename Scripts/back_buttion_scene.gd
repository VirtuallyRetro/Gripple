#----------------------------------------------------
# Gripple by RYN for Godot 4.3.
# Back Button Script
#----------------------------------------------------
extends Node2D


func _on_back_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		SoundManager.play_sound_by_name("mouse-click.mp3", true)
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_back_button_mouse_entered() -> void:
	$BackButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_back_button_mouse_exited() -> void:
	$BackButton.set_modulate(Color(1,1,1,1))
