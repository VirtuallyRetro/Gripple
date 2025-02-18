#----------------------------------------------------
# Gripple by RYN for Godot 4.3.
# Main Menu Script
#----------------------------------------------------
extends Node2D

@onready var high_score_button: Area2D = $HighScoreButton


func _ready() -> void:
	display_scores_button()


func _process(_delta: float) -> void:
	if Input.is_action_pressed("Reset"):
		reset_high_score()
		Game_Globals.tutorial_enabled = true


func reset_high_score() -> void:
		Game_Globals.high_score = 0
		Game_Globals.fewest_moves = 1000
		Game_Globals.best_time = 1000
		display_scores_button()


func display_scores_button() -> void:
	if Game_Globals.high_score > 0:
		high_score_button.visible = true
	else:
		high_score_button.visible = false


func _on_play_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		SoundManager.play_sound_by_name("mouse-click.mp3", true)
		get_tree().change_scene_to_file("res://Scenes/play_scene.tscn")


func _on_options_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		SoundManager.play_sound_by_name("mouse-click.mp3", true)
		get_tree().change_scene_to_file("res://Scenes/options_scene.tscn")


func _on_high_score_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		SoundManager.play_sound_by_name("mouse-click.mp3", true)
		get_tree().change_scene_to_file("res://Scenes/high_score_scene.tscn")


func _on_high_score_button_mouse_entered() -> void:
	high_score_button.set_modulate(Color(1.5,1.5,1.5,1))


func _on_high_score_button_mouse_exited() -> void:
	high_score_button.set_modulate(Color(1,1,1,1))


func _on_options_button_mouse_entered() -> void:
	$OptionsButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_options_button_mouse_exited() -> void:
	$OptionsButton.set_modulate(Color(1,1,1,1))


func _on_play_button_mouse_entered() -> void:
	$PlayButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_play_button_mouse_exited() -> void:
	$PlayButton.set_modulate(Color(1,1,1,1))
