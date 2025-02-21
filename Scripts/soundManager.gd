#------------------------------------------------------------
# Godot 4.x Simple Sound Manager (c) 2025
# Version 1.5.3 Ryn / Trig (MIT License)
#------------------------------------------------------------
extends Node

#------------------------------------------------------------
# Global Variables
#------------------------------------------------------------
@onready var soundNodeNames: Array[String] = []
@onready var soundDefaultVolume: float = 0.5
@onready var soundEnabled: bool = true
@onready var soundAutoPause: bool = false
@onready var soundAllowPolyphony: bool = false
@onready var soundMaxPolyphony: int = 2
@onready var soundFilesPath: String = "res://Audio/"
@onready var soundGroupName: String = "sounds"

#------------------------------------------------------------
# Callable Functions
#------------------------------------------------------------
func clear_all_sounds() -> void:
	if is_inside_tree(): get_tree().call_group(soundGroupName, "queue_free")
	soundNodeNames.clear()


func get_sound_status(filename: String) -> int:
	var soundID: int = _get_sound_id_by_name(filename)
	if soundID > -1:
		return _get_sound_status(soundID)
	return -1


func pause_sound(filename: String) -> void:
	var soundID: int = _get_sound_id_by_name(filename)
	if soundID > -1:
		_pause_sound(soundID)


func play_sound(filename: String, pitch_shift: bool) -> void:
	var soundID: int = _get_sound_id_by_name(filename)
	if soundID > -1:
		_play_sound(soundID, pitch_shift)
	else:
		soundID = _add_sound(filename)
		if soundID > -1:
			_play_sound(soundID, pitch_shift)


func reset() -> void:
	soundFilesPath = "res://Audio/"
	clear_all_sounds()
	set_sound_allow_polyphony(false)
	set_sound_max_polyphony(2)
	set_sound_autopause(false)
	set_sound_enabled(true)
	set_volume(50)


func resume_sound(filename: String) -> void:
	var soundID: int = _get_sound_id_by_name(filename)
	if soundID > -1:
		_resume_sound(soundID)


func set_sound_allow_polyphony(enabled_state: bool) -> void:
	if enabled_state and soundMaxPolyphony > 1:
		soundAllowPolyphony = true
		set_sound_max_polyphony(soundMaxPolyphony)
	else:
		soundAllowPolyphony = false
		set_sound_max_polyphony(1)


func set_sound_autopause(enabled_state: bool) -> void:
	soundAutoPause = enabled_state


func set_sound_enabled(enabled_state: bool) -> void:
	soundEnabled = enabled_state
	if not soundEnabled:
		stop_all_sounds()


func set_sound_max_polyphony(polyphony_max: int) -> void:
	if polyphony_max not in [1,2,3,4,5]: return
	soundMaxPolyphony = polyphony_max
	if soundMaxPolyphony == 1: soundAllowPolyphony = false
	for i: int in soundNodeNames.size():
		var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[i])
		if soundNode:
			soundNode.max_polyphony = soundMaxPolyphony


func stop_all_sounds() -> void:
	for i: int in soundNodeNames.size():
		var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[i])
		if soundNode:
			soundNode.stop()


func set_volume(vol_level: int) -> void:
	if vol_level not in range(0,101):
		vol_level = 50
	soundDefaultVolume = 0.01 * vol_level

	for i: int in soundNodeNames.size():
		var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[i])
		if soundNode:
			soundNode.volume_db = linear_to_db(soundDefaultVolume)

#------------------------------------------------------------
# Internal Functions
#------------------------------------------------------------
func _play_sound(soundID: int, pitch_shift: bool) -> void:
	if soundID not in range(soundNodeNames.size()): return
	if not soundEnabled: return
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		if soundAutoPause:
			if soundNode.playing: 
				soundNode.stream_paused = true
				return
			if soundNode.stream_paused:
				soundNode.stream_paused = false
				return
		if not soundNode.playing or soundAllowPolyphony:
			if pitch_shift:
				soundNode.pitch_scale = randf_range(0.6, 1.4)
				soundNode.play()
			else:
				soundNode.pitch_scale = 1
				soundNode.play()


func _pause_sound(soundID: int) -> void:
	if soundID not in range(soundNodeNames.size()): return
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		soundNode.stream_paused = true


func _resume_sound(soundID: int) -> void:
	if soundID not in range(soundNodeNames.size()): return
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		soundNode.stream_paused = false

func stop_sound(filename: String) -> void:
	var soundID: int = _get_sound_id_by_name(filename)
	if soundID > -1:
		_stop_sound(soundID)


func _stop_sound(soundID: int) -> void:
	if soundID not in range(soundNodeNames.size()): return
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		soundNode.stop()


func _add_sound(filename: String) -> int:
	if not filename.ends_with("mp3"):
		return -1

	var soundNodeName: String = filename.replacen(".","_")
	if soundNodeNames.has(soundNodeName):
		return soundNodeNames.find(soundNodeName)
	
	if ResourceLoader.exists(soundFilesPath + filename):
		var soundNode: AudioStreamPlayer = AudioStreamPlayer.new()
		soundNode.stream = ResourceLoader.load(soundFilesPath + filename)

		if soundNode.stream:
			soundNode.name = soundNodeName
			
			if soundAllowPolyphony and soundMaxPolyphony > 1: 
				soundNode.max_polyphony = soundMaxPolyphony

			soundNode.volume_db = linear_to_db(soundDefaultVolume)
			soundNode.add_to_group(soundGroupName, true)
			soundNodeNames.append(soundNodeName)
			add_child(soundNode)
			return soundNodeNames.size() - 1

	return -1


func _get_sound_id_by_name(filename: String) -> int:
	var soundNodeName: String = filename.replacen(".","_")
	return soundNodeNames.find(soundNodeName)


func _get_sound_status(soundID: int) -> int:
	if soundID not in range(soundNodeNames.size()): return -1
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode:
		if soundNode.playing: return 1
		if soundNode.stream_paused: return 2
		if not soundNode.playing : return 0
		return -1
	else:
		return -1
