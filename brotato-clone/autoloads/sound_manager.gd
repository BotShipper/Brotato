extends Node

enum Sound {
	ENEMY_HIT,
	FIRE,
	UI
}

var sound_dictionary: Dictionary[Sound, Resource] = {
	Sound.ENEMY_HIT: preload("uid://blonjlaa37md0"),
	Sound.FIRE: preload("uid://g72hyxdnaath"),
	Sound.UI: preload("uid://6nolwqlami52"),
}

@export var stream_players: Array[AudioStreamPlayer]

func play_sound(type: int) -> void:
	var stream := get_free_stream_player()
	if not stream:
		return
	
	var audio := sound_dictionary[type]
	stream.stream = audio
	stream.pitch_scale = randf_range(0.8, 1.3)
	stream.play()


func get_free_stream_player() -> AudioStreamPlayer:
	for stream: AudioStreamPlayer in stream_players:
		if not stream.playing:
			return stream
	
	return null
