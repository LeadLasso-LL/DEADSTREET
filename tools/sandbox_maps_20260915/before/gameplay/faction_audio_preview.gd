extends Node
## Clean, one-shot glossary audition. Never modifies shared battle loops or buses.
const Catalog=preload("res://gameplay/music_catalog.gd")
signal playback_changed
var player: AudioStreamPlayer
var current_faction=""
var held_music: Node
var icons={}

func _ready():
 player=AudioStreamPlayer.new();add_child(player);player.finished.connect(stop)
 tree_exiting.connect(stop)

func source_path(faction_id: String) -> String:
 if faction_id=="trc":return "res://assets/audio/convoy/trc_siren.wav"
 if faction_id=="nbpd":return "res://assets/audio/convoy/police_siren.wav"
 var id=str(Catalog.catalogue().get("faction_tracks",{}).get(faction_id,""))
 return str(Catalog.track(id).get("battle_loop",{}).get("file","")) if not id.is_empty() else ""

func available(faction_id: String) -> bool:
 var path=source_path(faction_id)
 return not path.is_empty() and FileAccess.file_exists(path)

func play_faction(faction_id: String) -> bool:
 var path=source_path(faction_id)
 if path.is_empty() or not FileAccess.file_exists(path):return false
 var stream=AudioStreamWAV.load_from_file(path)
 if stream==null:return false
 # This fresh resource is a one-shot preview; the battle catalogue still loops.
 stream.loop_mode=AudioStreamWAV.LOOP_DISABLED
 player.stop()
 if not is_instance_valid(held_music):
  held_music=get_tree().get_first_node_in_group("dead_street_menu_music")
 if is_instance_valid(held_music):held_music.set_preview_paused(true)
 player.stream=stream;player.pitch_scale=.75 if faction_id=="trc" else 1.0
 current_faction=faction_id;_update_volume();player.play();playback_changed.emit()
 return true

func stop():
 if is_instance_valid(player):player.stop();player.stream=null
 current_faction=""
 if is_instance_valid(held_music):held_music.set_preview_paused(false)
 held_music=null;playback_changed.emit()

func _process(_delta):
 if not current_faction.is_empty():_update_volume()

func _update_volume():
 var level=float(held_music.volume_value) if is_instance_valid(held_music) else db_to_linear(-4.0)
 player.volume_db=linear_to_db(maxf(level,0.0001))-4.0

func icon(playing: bool) -> Texture2D:
 if not icons.has(playing):
  var shape='<rect x="5" y="5" width="14" height="14"/>' if playing else '<path d="M6 4L20 12L6 20Z"/>'
  var image=Image.new();image.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#dedfd1">'+shape+'</svg>')
  icons[playing]=ImageTexture.create_from_image(image)
 return icons[playing]
