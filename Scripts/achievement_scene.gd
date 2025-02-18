#----------------------------------------------------
# Gripple by RYN for Godot 4.3.
# Achievement Script
#----------------------------------------------------
extends Node2D

@onready var achievement_banner: Sprite2D = $AchievementBanner


func _ready() -> void:
	match Game_Globals.achievement_type:
		2:
			achievement_banner.texture = load("res://Graphics/Achievement_Fewest_moves.png")
		3:
			achievement_banner.texture = load("res://Graphics/Achievement_Best_Time.png")
	
	SoundManager.play_sound_by_name("achievement.mp3", false)


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/winner_scene.tscn")
