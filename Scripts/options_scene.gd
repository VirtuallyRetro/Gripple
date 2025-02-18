#----------------------------------------------------
# Gripple by RYN for Godot 4.3.
# Options Script
#----------------------------------------------------
extends Node2D

@onready var audio_enabled_image: Sprite2D = $EnableAudioButton/AudioEnabledImage
@onready var easy_image: Sprite2D = $EasyButton/EasyDifficulityDisabledImage
@onready var medium_image: Sprite2D = $MediumButton/MediumDifficulityDisabledImage
@onready var hard_image: Sprite2D = $HardButton/HardDifficulityDisabledImage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_audio_enabled_button()
	set_difficulity_image()


func _on_enable_audio_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		Game_Globals.audio_enabled = not Game_Globals.audio_enabled
		SoundManager.set_sound_enabled(Game_Globals.audio_enabled)
		set_audio_enabled_button()
		SoundManager.play_sound_by_name("mouse-click.mp3", true)


func _on_easy_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		if Game_Globals.game_difficulty != 1:
			set_difficulty(1)


func _on_medium_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		if Game_Globals.game_difficulty != 2:
			set_difficulty(2)


func _on_hard_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		if Game_Globals.game_difficulty != 3:
			set_difficulty(3)


func set_audio_enabled_button() -> void:
	if Game_Globals.audio_enabled:
		audio_enabled_image.texture = load("res://Graphics/Audio_Enabled.png")
	else:
		audio_enabled_image.texture = load("res://Graphics/Audio_Disabled.png")


func set_difficulty(difficulty: int) -> void:
	SoundManager.play_sound_by_name("mouse-click.mp3", true)
	clear_difficulity_image()
	Game_Globals.game_difficulty = difficulty
	set_difficulity_image()	

	
func clear_difficulity_image() -> void:
	match Game_Globals.game_difficulty:
		1:
			easy_image.texture = load("res://Graphics/Easy_Difficulity_Disabled_Image.png")	
		2:
			medium_image.texture = load("res://Graphics/Medium_Difficulity_Disabled_Image.png")	
		3:
			hard_image.texture = load("res://Graphics/Hard_Difficulity_Disabled_image.png")

func set_difficulity_image() -> void:
	match Game_Globals.game_difficulty:
		1:
			easy_image.texture = load("res://Graphics/Easy_Diff_Enabled_Image.png")
		2:
			medium_image.texture = load("res://Graphics/Medium_Diff_Enabled_Image.png")
		3:
			hard_image.texture = load("res://Graphics/Hard_Diff_Enabled_Image.png")


func _on_enable_audio_button_mouse_entered() -> void:
	$EnableAudioButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_enable_audio_button_mouse_exited() -> void:
	$EnableAudioButton.set_modulate(Color(1,1,1,1))


func _on_easy_button_mouse_entered() -> void:
	$EasyButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_easy_button_mouse_exited() -> void:
	$EasyButton.set_modulate(Color(1,1,1,1))


func _on_medium_button_mouse_entered() -> void:
	$MediumButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_medium_button_mouse_exited() -> void:
	$MediumButton.set_modulate(Color(1,1,1,1))


func _on_hard_button_mouse_entered() -> void:
	$HardButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_hard_button_mouse_exited() -> void:
	$HardButton.set_modulate(Color(1,1,1,1))
