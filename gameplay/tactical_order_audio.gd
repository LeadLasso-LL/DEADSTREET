extends Node
# One issue/reply cue per command input, independent of simulation pause and combat RNG.
var view: Node
var player: AudioStreamPlayer
var seen: int = 0
var streams: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var voice_index := 0
signal cue_played(command: String, single_unit: bool)

func _ready() -> void:
	for index in range(8):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -13.0
		add_child(voice)
		voices.append(voice)
	player = voices[0]
	for command in ["hold", "push", "fall_back", "clear", "move", "cover", "target", "failed"]:
		streams[command] = make_cue(command)

func _process(_delta: float) -> void:
	if view == null or view.orders_controller == null:
		return
	var c = view.orders_controller
	var enabled: bool = view.is_visible_in_tree() and view.battle_presentation != null and view.battle_presentation.audio_enabled
	if not enabled:
		for voice in voices:
			voice.stop()
	# Drain distinct events, not just the last event of a frame or simulation tick.
	var events: Array = c.command_feedback_events.duplicate()
	c.command_feedback_events.clear()
	for event in events:
		seen = event.sequence
		if not enabled:
			continue
		var key: String = event.command if int(event.accepted) > 0 else "failed"
		var single: bool = int(event.selection_count) == 1
		var voice := voices[voice_index]
		voice_index = (voice_index + 1) % voices.size()
		voice.stop()
		voice.stream = streams.get(key, streams.failed)
		# Same mechanical click/radio receipt; single-unit orders are slightly higher.
		voice.pitch_scale = 1.08 if single else 1.0
		voice.play()
		cue_played.emit(key, single)

static func make_cue(command: String) -> AudioStreamWAV:
	var wave = AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = 22050
	var bytes = PackedByteArray()
	var tones = {"push":[520.0,780.0], "fall_back":[660.0,440.0], "hold":[540.0,540.0], "clear":[780.0,660.0], "move":[520.0,680.0], "cover":[540.0,640.0], "target":[580.0,780.0], "failed":[230.0,180.0]}[command]
	for i in range(int(.43 * wave.mix_rate)):
		var t = float(i) / wave.mix_rate
		# Short mechanical issue click, then a two-note radio receipt.
		var signal_value = sin(t * 18000.0) * exp(-t * 180.0) * .28
		for n in range(2):
			var elapsed = t - (.12 + n * .11)
			if elapsed >= 0.0 and elapsed < .085:
				var envelope = minf(elapsed / .006, 1.0) * minf((.085-elapsed)/.02, 1.0)
				signal_value += (sin(TAU * tones[n] * elapsed) + .17*sin(TAU * tones[n] * 2.0 * elapsed)) * envelope * .38
		var value = int(clampf(signal_value, -1.0, 1.0) * 32767.0)
		bytes.append(value & 255)
		bytes.append((value >> 8) & 255)
	wave.data = bytes
	return wave
