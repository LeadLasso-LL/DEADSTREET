extends RefCounted
## Shared identities for full menu songs and their independently looped battle excerpts.
const PATH = "res://assets/data/music_catalog.json"

static func catalogue() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return parsed if parsed is Dictionary else {}

static func tracks() -> Array:
	return catalogue().get("tracks", [])

static func track(id: String) -> Dictionary:
	for item in tracks():
		if str(item.get("id", "")) == id:
			return item
	return {}

static func menu_stream(id: String) -> AudioStream:
	var path = str(track(id).get("menu_file", ""))
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var audio = AudioStreamMP3.new()
	audio.data = FileAccess.get_file_as_bytes(path)
	return audio

static func battle_stream(id: String) -> AudioStreamWAV:
	var loop: Dictionary = track(id).get("battle_loop", {})
	var path = str(loop.get("file", ""))
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var audio = AudioStreamWAV.load_from_file(path)
	if audio == null or audio.format != AudioStreamWAV.FORMAT_16_BITS:
		return null
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	# Loop boundaries count sample frames, not interleaved channel samples.
	audio.loop_end = audio.data.size() / (4 if audio.stereo else 2)
	return audio

static func faction_stream(faction_id: String) -> AudioStreamWAV:
	var id = str(catalogue().get("faction_tracks", {}).get(faction_id, ""))
	return battle_stream(id) if not id.is_empty() else null


static func menu_tracks() -> Array:
	var data = catalogue()
	var excluded: Array = data.get("menu_excluded_tracks", [])
	return data.get("tracks", []).filter(func(item): return str(item.get("id", "")) not in excluded)
