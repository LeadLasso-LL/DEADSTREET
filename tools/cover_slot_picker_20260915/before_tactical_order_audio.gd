extends Node
# A single issue/reply cue per group, independent of simulation pause and combat RNG.
var view: Node
var player: AudioStreamPlayer
var seen: int = 0
var streams: Dictionary = {}
func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = -13.0
	for command in ["hold", "push", "fall_back", "clear", "failed"]:
		streams[command] = make_cue(command)
func _process(_delta: float) -> void:
	if view == null or view.orders_controller == null:
		return
	var c = view.orders_controller
	if c.last_command_feedback.is_empty():
		seen = c.feedback_sequence
		return
	var enabled = view.visible and view.battle_presentation != null and view.battle_presentation.audio_enabled
	if not enabled:
		player.stop()
	if c.feedback_sequence == seen:
		return
	seen = c.feedback_sequence
	if not enabled:
		return
	var event: Dictionary = c.last_command_feedback
	var key = event.command if int(event.accepted) > 0 else "failed"
	player.stop()
	player.stream = streams.get(key, streams.failed)
	player.play()
static func make_cue(command: String) -> AudioStreamWAV:
	var wave = AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = 22050
	var bytes = PackedByteArray()
	var tones = {"push":[520.0,780.0], "fall_back":[660.0,440.0], "hold":[540.0,540.0], "clear":[780.0,660.0], "failed":[230.0,180.0]}[command]
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
