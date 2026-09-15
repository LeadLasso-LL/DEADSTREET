from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
baseline=json.loads((O/'baseline.json').read_text())
for rel,expected in baseline.items():assert hashlib.sha256((R/rel).read_bytes()).hexdigest()==expected,('Concurrent edit',rel)
def patch(rel,pairs):
 p=R/rel;s=p.read_text(encoding='utf-8-sig')
 for old,new in pairs:
  assert s.count(old)==1,(rel,old,s.count(old));s=s.replace(old,new)
 p.write_text(s,encoding='utf-8')
patch('gameplay/sandbox_menu_music.gd',[
 ('var user_paused = false','var user_paused = false\nvar preview_paused = false'),
 ('func _ready():','func _ready():\n\tadd_to_group("dead_street_menu_music")'),
 ('player.stream_paused = user_paused or not menu_visible','player.stream_paused = user_paused or preview_paused or not menu_visible'),
 ('player.stream_paused = user_paused or (in_sandbox','player.stream_paused = user_paused or preview_paused or (in_sandbox'),
 ('\tplayer.stream_paused = user_paused\n','\tplayer.stream_paused = user_paused or preview_paused\n'),
 ('func save_settings():','func set_preview_paused(on: bool):\n\tpreview_paused=on\n\tvar hidden=in_sandbox and (not is_instance_valid(sandbox) or not sandbox.ui.visible)\n\tplayer.stream_paused=user_paused or preview_paused or hidden\n\nfunc save_settings():')])
patch('gameplay/sandbox_glossary_panel.gd',[
 ('const MenuEmblem =','const FactionPreview = preload("res://gameplay/faction_audio_preview.gd")\nconst MenuEmblem ='),
 ('var leader_image: TextureRect','var leader_image: TextureRect\nvar faction_audio: Node\nvar audio_button: Button'),
 ('\t\tbuild_factions()','\t\tfaction_audio=FactionPreview.new();add_child(faction_audio)\n\t\tfaction_audio.playback_changed.connect(update_audio_button)\n\t\tvisibility_changed.connect(func():\n\t\t\tif not is_visible_in_tree():faction_audio.stop())\n\t\ttree_exiting.connect(faction_audio.stop)\n\t\tbuild_factions()'),
 ('func show_faction(id: String):','func toggle_faction_audio():\n\tif faction_audio.current_faction==selected_id:faction_audio.stop()\n\telse:faction_audio.play_faction(selected_id)\n\nfunc update_audio_button():\n\tif not is_instance_valid(audio_button):return\n\tvar playing=faction_audio.current_faction==selected_id\n\taudio_button.icon=faction_audio.icon(playing)\n\taudio_button.tooltip_text="Stop faction audio" if playing else "Play faction audio"\n\taudio_button.set_meta("playing",playing)\n\nfunc show_faction(id: String):\n\tfaction_audio.stop()'),
 ('\tlabel(detail,Vector2(0,296)', '\tlabel(detail,Vector2(630,260),Vector2(150,27),"Faction Audio",13,TAN)\n\taudio_button=button(detail,"",Vector2(794,257),Vector2(34,32),toggle_faction_audio)\n\taudio_button.name="FactionAudioToggle";audio_button.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER\n\taudio_button.disabled=not faction_audio.available(id)\n\tupdate_audio_button()\n\tif audio_button.disabled:audio_button.tooltip_text="Faction audio unavailable"\n\tlabel(detail,Vector2(0,296)')])
print('FACTION PREVIEW INSTALLED',flush=True)
