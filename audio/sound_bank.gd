extends Node

var _streams: Dictionary[StringName, AudioStream] = {}
var _voices: Array[AudioStreamPlayer] = []
var _next: int = 0
var muted: bool = false

func _ready() -> void:
	for cue: StringName in [&"jump", &"swing", &"hit", &"hurt", &"destroy", &"enemy_swing", &"win"]:
		_streams[cue] = load("res://audio/%s.wav" % cue) as AudioStream
	for i in 8:
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -12.0
		add_child(voice)
		_voices.append(voice)

func play(cue: StringName) -> void:
	if muted or not _streams.has(cue):
		return
	var voice := _voices[_next]
	_next = (_next + 1) % _voices.size()
	voice.stream = _streams[cue]
	voice.play()

func _exit_tree() -> void:
	# Останавливаем звук перед освобождением ресурсов при перезапуске или выходе.
	for voice in _voices:
		voice.stop()
		voice.stream = null
	_streams.clear()
