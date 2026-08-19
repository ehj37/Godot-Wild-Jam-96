extends Node


func add_self_freeing_audio_stream_player(node: Node, stream: AudioStreamOggVorbis) -> void:
	var audio_stream_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_stream_player.stream = stream
	audio_stream_player.bus = "SoundEffects"
	audio_stream_player.max_distance = 320.0
	node.add_child(audio_stream_player)
	audio_stream_player.play()
	audio_stream_player.finished.connect(func() -> void: audio_stream_player.queue_free())
