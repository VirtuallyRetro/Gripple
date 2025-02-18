#----------------------------------------------------
# Gripple by RYN for Godot 4.3.
# Play Script
#----------------------------------------------------
extends Node2D

var pattern_id: int #Holds the current random pattern

#grid patterns
var patterns: Array[String] = [ "0011001122332233", "0000111122223333", "2112300330032112", 
	"0123012301230123", "0021002112331233", "0101232301012323" ]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Reset the game counters
	Game_Globals.current_game_move_count = 0
	Game_Globals.current_game_time = 0  
	Game_Globals.current_game_timer_bonus = 100
	Game_Globals.achievement_type = 0
	Game_Globals.current_game_score = 0
	
	#Do the tutorial stuff
	if Game_Globals.tutorial_enabled:
		$LabelTutorial.visible = true
		$TimerTutorial.start()
	
	#Setup the game
	set_difficulty()
	set_random_pattern()
	$GameVideoTimer.play() #Do this after everything else is setup


func _process(_delta: float) -> void:
	#Handle showing and hiding the spinner highlight
	display_spinner_highlight()


func display_spinner_highlight() -> void:
	var pad_id: int = get_closest_spinner()
	var spinners: Array[Node] = []
	spinners = get_tree().get_nodes_in_group("spinners")
		
	if pad_id > -1:
		$SpinnerImage.position = spinners[pad_id].position
		$SpinnerImage.visible = true
		return
			
	if $SpinnerImage.visible == true:
		$SpinnerImage.visible = false


func set_difficulty() -> void:
	match Game_Globals.game_difficulty:
		1:
			$GameVideoTimer.speed_scale = 0.017	#2:03.99
		2:
			$GameVideoTimer.speed_scale = 0.03	#1:10.38
		3:
			$GameVideoTimer.speed_scale = 0.05	#42.21


func set_random_pattern() -> void:
	pattern_id = randi_range(0,patterns.size())
		
	#Easy pattern for debugging when in Godot editor
	if OS.is_debug_build():
		pattern_id = 0
		Game_Globals.tutorial_enabled = true
	
	$DestinationPattern.texture = load("res://Graphics/Pattern" + str(pattern_id) + ".png")
	generate_random_grid()


func generate_random_grid() -> void:
	var values: Array[int] = [0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3]
	var tiles: Array[Node] = []
	tiles = get_tree().get_nodes_in_group("tiles")

	for i: int in range(16):
		tiles[i].frame = values[randi_range(0, values.size()) - 1]
		values.erase(tiles[i].frame)


func check_grid_match() -> void:
	var tiles: Array[Node] = []
	tiles = get_tree().get_nodes_in_group("tiles")
	var test_pattern: String = ""
	
	for i: int in range(16):
		test_pattern = test_pattern + str(tiles[i].frame)
		
	if test_pattern == patterns[pattern_id]:
		$GameVideoTimer.stop()
		$GameTimer.stop()
		calc_score()
		calc_achievement()
		
		if Game_Globals.achievement_type != 0:
			get_tree().change_scene_to_file("res://Scenes/achievement_scene.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/winner_scene.tscn")


func calc_achievement() -> void:
	Game_Globals.achievement_type = 0
	
	#No achievement if the timer has expired
	if Game_Globals.current_game_timer_bonus == 0:
		return
	
	#Score achievement
	if Game_Globals.current_game_score > Game_Globals.high_score:
		Game_Globals.high_score = Game_Globals.current_game_score
		Game_Globals.achievement_type = 1
		Game_Globals.high_score_type = Game_Globals.game_difficulty
		
	#Fewest moves achievement		
	if Game_Globals.current_game_move_count < Game_Globals.fewest_moves:
		Game_Globals.fewest_moves = Game_Globals.current_game_move_count
		
		if Game_Globals.achievement_type == 0:
			Game_Globals.achievement_type = 2
	
	#Best Time achievment		
	if Game_Globals.current_game_time < Game_Globals.best_time:
		Game_Globals.best_time = Game_Globals.current_game_time
		
		if Game_Globals.achievement_type == 0:
			Game_Globals.achievement_type = 3


func calc_score() -> void:
	#Base Score
	Game_Globals.current_game_score = (500 - Game_Globals.current_game_move_count)
	Game_Globals.current_game_score += (500 - Game_Globals.current_game_time)
	
	if Game_Globals.current_game_score < 0:
		Game_Globals.current_game_score = 0
	
	#Timer Bonus	
	if Game_Globals.current_game_timer_bonus > 0:
		Game_Globals.current_game_score *= Game_Globals.current_game_timer_bonus

	#Difficulity Bonus		
	if Game_Globals.game_difficulty > 1:
		Game_Globals.current_game_score *= (Game_Globals.game_difficulty * 2)


func _spinner_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed():
		var pad_id: int = get_closest_spinner()
				
		if pad_id > -1:
			spin_pad(pad_id, event.button_index)
			check_grid_match()


func spin_pad(pad_id: int, spin_direction: int) -> void:
	var tile_ids: Array[int] = []
	var tiles: Array[Node] = []
	tiles = get_tree().get_nodes_in_group("tiles")
	
	match pad_id:
		0:
			tile_ids = [0,1,5,4]
		1:
			tile_ids = [2,3,7,6]
		2:
			tile_ids = [5,6,10,9]
		3:
			tile_ids = [8,9,13,12]
		4:
			tile_ids = [10,11,15,14]
		_:
			return
			
	match spin_direction:
		1: #left
			var tmp: int = tiles[tile_ids[0]].frame
			tiles[tile_ids[0]].frame = tiles[tile_ids[1]].frame
			tiles[tile_ids[1]].frame = tiles[tile_ids[2]].frame
			tiles[tile_ids[2]].frame = tiles[tile_ids[3]].frame
			tiles[tile_ids[3]].frame = tmp
			
		2: #right
			var tmp: int = tiles[tile_ids[3]].frame
			tiles[tile_ids[3]].frame = tiles[tile_ids[2]].frame
			tiles[tile_ids[2]].frame = tiles[tile_ids[1]].frame
			tiles[tile_ids[1]].frame = tiles[tile_ids[0]].frame
			tiles[tile_ids[0]].frame = tmp
	
		_:
			return
			
	Game_Globals.current_game_move_count += 1 #Increment movecount


func get_closest_spinner() -> int:
	var spinners: Array[Node] = []
	spinners = get_tree().get_nodes_in_group("spinners")
	
	for i: int in range(5):
		if get_global_mouse_position().distance_to(spinners[i].position) < 32:
			return i
			
	return -1


func _on_game_video_timer_frame_changed() -> void:
	if Game_Globals.audio_enabled and Game_Globals.current_game_timer_bonus > 0:
		SoundManager.play_sound_by_name("countDownTimer.mp3", true)
		
	Game_Globals.current_game_timer_bonus -= 10
	if Game_Globals.current_game_timer_bonus < 0:
		Game_Globals.current_game_timer_bonus = 0


func _on_game_video_timer_animation_finished() -> void:
	SoundManager.play_sound_by_name("timerExpired.mp3", false)
	$TimerExpiredImage.visible = true
	$TimerExpiredTimer.start()
	
	
func _on_game_timer_timeout() -> void:
	Game_Globals.current_game_time += 1


func _on_timer_expired_timer_timeout() -> void:
	$TimerExpiredImage.visible = false
	$GameVideoTimer.visible = false


func _on_timer_tutorial_timeout() -> void:
	$LabelTutorial.visible = false
	Game_Globals.tutorial_enabled = false


func _on_resume_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		SoundManager.play_sound_by_name("mouse-click.mp3", true)
		$ResumeButton.visible = false
		$DarkenLayer.visible = false
		get_tree().paused = false


func _on_pause_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		if Game_Globals.audio_enabled:
			SoundManager.play_sound_by_name("mouse-click.mp3", true)
			await get_tree().create_timer(0.25).timeout
		$ResumeButton.visible = true
		$DarkenLayer.visible = true
		get_tree().paused = true


func _on_pause_button_mouse_entered() -> void:
	$PauseButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_pause_button_mouse_exited() -> void:
	$PauseButton.set_modulate(Color(1,1,1,1))


func _on_resume_button_mouse_entered() -> void:
	$ResumeButton.set_modulate(Color(1.5,1.5,1.5,1))


func _on_resume_button_mouse_exited() -> void:
	$ResumeButton.set_modulate(Color(1,1,1,1))
