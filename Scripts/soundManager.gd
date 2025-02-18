#------------------------------------------------------
# MP3 Simple SoundManager by Ryn (c) 2024 Version 1.7.5
# MIT License - Last Updated - 13-12-2024
#------------------------------------------------------
extends Node

@onready var soundNodeNames: Array[String] = []
@onready var soundDefaultVolume: float = 0.5
@onready var soundEnabled: bool = true
@onready var soundAutoPause: bool = false
@onready var soundAllowPolyphony: bool = false
@onready var soundMaxPolyphony: int = 2
@onready var soundFilesPath: String = "res://Audio/" # Change if needed
@onready var soundGroupName: String = "sounds" # Change if needed

# For playing an audio file by name.  If the stream is not loaded
# it will load and play the sound.
func play_sound_by_name(filename: String, pitch_shift: bool) -> void:
	var soundID: int = get_sound_id_by_name(filename)
	if soundID > -1: # Sound Stream found
		play_sound(soundID, pitch_shift)
	else: # Sound stream not loaded
		soundID = add_sound(filename)
		if soundID > -1:
			play_sound(soundID, pitch_shift)


# Play a loaded stream with a given ID, note the pitch shift
# and additional functions if the stream is playing or paused
func play_sound(soundID: int, pitch_shift: bool) -> void:
	if soundID not in range(soundNodeNames.size()): return
	if not soundEnabled: return # check for disabled sound state
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		if soundAutoPause: # Auto pause and resume if flag is set
			if soundNode.playing: 
				soundNode.stream_paused = true
				return
			if soundNode.stream_paused:
				soundNode.stream_paused = false
				return
		if not soundNode.playing or soundAllowPolyphony: # Check for playing and polyphony
			if pitch_shift:
				soundNode.pitch_scale = randf_range(0.6, 1.4)
				soundNode.play()
			else:
				soundNode.pitch_scale = 1
				soundNode.play()


#Pauses a sound playing with a given file name
func pause_sound_by_name(filename: String) -> void:
	var soundID: int = get_sound_id_by_name(filename)
	if soundID > -1: # Sound Stream found
		pause_sound(soundID)


# Pauses a loaded audio stream
func pause_sound(soundID: int) -> void:
	if soundID not in range(soundNodeNames.size()): return
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		soundNode.stream_paused = true


#Resume a sound playing with a given file name
func resume_sound_by_name(filename: String) -> void:
	var soundID: int = get_sound_id_by_name(filename)
	if soundID > -1: # Sound Stream found
		resume_sound(soundID)


# Resumes playing a loaded audio stream
func resume_sound(soundID: int) -> void:
	if soundID not in range(soundNodeNames.size()): return
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		soundNode.stream_paused = false


#Stops a sound playing with a given file name
func stop_sound_by_name(filename: String) -> void:
	var soundID: int = get_sound_id_by_name(filename)
	if soundID > -1: # Sound Stream found
		stop_sound(soundID)


# Stops a loaded audio stream from playing
func stop_sound(soundID: int) -> void:
	if soundID not in range(soundNodeNames.size()): return
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode: 
		soundNode.stop()


# Used to set the  volume level of all loaded streams.
# Also corrects and adjusts the volume level to linear DB
func set_volume(vol_level: int) -> void:
	# Check / Correct / Calc volume for liner_to_db
	if vol_level not in range(0,101):
		vol_level = 50
	soundDefaultVolume = 0.01 * vol_level
	# Set volume or all audio nodes
	for i: int in soundNodeNames.size():
		var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[i])
		if soundNode:
			soundNode.volume_db = linear_to_db(soundDefaultVolume)


# Used to set the auto pause state
func set_sound_autopause(enabled_state: bool) -> void:
	soundAutoPause = enabled_state


# Used to set if Polyphony is enabled
func set_sound_allow_polyphony(enabled_state: bool) -> void:
	if enabled_state and soundMaxPolyphony > 1:
		soundAllowPolyphony = true
		set_sound_max_polyphony(soundMaxPolyphony) # Update ployphony if true
	else:
		soundAllowPolyphony = false
		set_sound_max_polyphony(1) # Reset 1 if false


# Used to set the max PolyPhony per audio stream
func set_sound_max_polyphony(polyphony_max: int) -> void:
	if polyphony_max not in [1,2,3,4,5]: return
	soundMaxPolyphony = polyphony_max
	if soundMaxPolyphony == 1: soundAllowPolyphony = false # No point if only one stream channel
	# Change the max polyphony on all nodes
	for i: int in soundNodeNames.size():
		var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[i])
		if soundNode:
			soundNode.max_polyphony = soundMaxPolyphony


# Used to Enable / disable all audio
func set_sound_enabled(enabled_state: bool) -> void:
	soundEnabled = enabled_state
	if not soundEnabled:
		stop_all_sounds() # Stop all sounds if audio set to false 


# Used to stop all sounds when sound is disabled
# Without unloading all the audio streams	
func stop_all_sounds() -> void:
	for i: int in soundNodeNames.size():
		var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[i])
		if soundNode:
			soundNode.stop()


# Adds a sound stream to the database check for prior existance
# and loading if required.
func add_sound(filename: String) -> int: # Returns the unique ID of the loaded sound -1 is an error
	if not filename.ends_with("mp3"):
		return -1

	var soundNodeName: String = filename.replacen(".","_")
	if soundNodeNames.has(soundNodeName):
		return soundNodeNames.find(soundNodeName)
	
	if ResourceLoader.exists(soundFilesPath + filename):
		var soundNode: AudioStreamPlayer = AudioStreamPlayer.new()
		soundNode.stream = ResourceLoader.load(soundFilesPath + filename)
		
		#_load_mp3_audio_stream(filename);
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


# Reset to defaults, with flag to also clear path and loaded sounds
func reset(complete: bool) -> void:
	if complete:
		soundFilesPath = "res://Audio/"
		clear_all_sounds()
		
	set_sound_allow_polyphony(false)
	set_sound_max_polyphony(2)
	set_sound_autopause(false)
	set_sound_enabled(true)
	set_volume(50)


# For clearing all streams and the database when needed
func clear_all_sounds() -> void:
	if is_inside_tree(): get_tree().call_group(soundGroupName, "queue_free")
	soundNodeNames.clear()


# For returning the unique ID of a loaded Sound
# Improved using array search method
func get_sound_id_by_name(filename: String) -> int:
	var soundNodeName: String = filename.replacen(".","_")
	return soundNodeNames.find(soundNodeName)


#Gets the status of sound playing with a given file name
func get_sound_status_by_name(filename: String) -> int:
	var soundID: int = get_sound_id_by_name(filename)
	if soundID > -1: # Sound Stream found
		return get_sound_status(soundID)
	return -1


# For getting the play status of a loaded stream
func get_sound_status(soundID: int) -> int:
	if soundID not in range(soundNodeNames.size()): return -1
	var soundNode: AudioStreamPlayer = get_node_or_null(soundNodeNames[soundID])
	if soundNode:
		if soundNode.playing: return 1
		if soundNode.stream_paused: return 2
		if not soundNode.playing : return 0
		return -1
	else:
		return -1
