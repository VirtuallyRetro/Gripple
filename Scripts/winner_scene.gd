#----------------------------------------------------
# Gripple by RYN for Godot 4.3.
# Winner Script
#----------------------------------------------------
extends Node2D


func _ready() -> void:
	if Game_Globals.achievement_type != 0 or Game_Globals.current_game_timer_bonus > 0:
		SoundManager.play_sound_by_name("winner.mp3", false)
	else:
		$WinnerBanner.texture = load("res://Graphics/Complete_Banner_Image.png")

	#Load the display fields
	$LabelMoves.text = " " + str(Game_Globals.current_game_move_count)
	$LabelTime.text = " " + str(Game_Globals.current_game_time)
	$LabelBonus.text = " " + str(Game_Globals.current_game_timer_bonus)
	$LabelScore.text = " " + str(Game_Globals.current_game_score)


func _on_next_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		SoundManager.play_sound_by_name("mouse-click.mp3", true)
		get_tree().change_scene_to_file("res://Scenes/play_scene.tscn")		


func _on_next_button_mouse_entered() -> void:
	$NextButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_next_button_mouse_exited() -> void:
	$NextButton.set_modulate(Color(1,1,1,1))
