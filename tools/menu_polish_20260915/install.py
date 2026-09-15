from pathlib import Path
import json,hashlib,shutil,sys
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
baseline=json.loads((O/'baseline.json').read_text())
for rel,digest in baseline.items():assert hashlib.sha256((R/rel).read_bytes()).hexdigest()==digest,('Concurrent edit',rel)
def patch(rel,pairs):
 p=R/rel;s=p.read_text(encoding='utf-8-sig')
 for before,after in pairs:
  assert s.count(before)==1,(rel,before,s.count(before));s=s.replace(before,after)
 p.write_text(s,encoding='utf-8')
patch('tools/arsenal_production/weapon_display_art.py',[
 ('N=\'{http://www.w3.org/2000/svg}\'','from weapon_precision_art import precision_art\nN=\'{http://www.w3.org/2000/svg}\''),
 ("if kind=='pistol':pistol(g,id)","if precision_art(g,id):pass\n    elif kind=='pistol':pistol(g,id)")])
patch('gameplay/sandbox_menu_music.gd',[
 ('var skip: Button','var skip: Button\nvar shuffle: Button'),
 ('\tvolume = HSlider.new();', '\tshuffle = Button.new(); shuffle.name = "ShuffleTracks"; shuffle.custom_minimum_size = Vector2(38,32); shuffle.icon = transport_icon("shuffle"); shuffle.pressed.connect(reshuffle_tracks); actions.add_child(shuffle)\n\tvolume = HSlider.new();'),
 ('toast.custom_minimum_size = Vector2(282,93)','toast.custom_minimum_size = Vector2(158,56)'),
 ('10 if side in ["top","bottom"] else 14','8'),
 ('toast_label.custom_minimum_size.x = 254; toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; toast_label.add_theme_font_size_override("font_size",16)', 'toast_label.custom_minimum_size = Vector2(140,34); toast_label.autowrap_mode = TextServer.AUTOWRAP_OFF; toast_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS; toast_label.clip_text = true; toast_label.add_theme_font_size_override("font_size",12)'),
 ('toast_label.text = "NOW PLAYING\\n"+label.text','toast_label.text = label.text\n\ttoast_label.tooltip_text = label.text'),
 ('toast.show(); dock.hide()','toast.show(); dock.show()'),
 ('toast.position = area-Vector2(toast.size.x+28,toast.size.y+47)','toast.position = Vector2(area.x-toast.size.x-28,dock.position.y-toast.size.y-8)'),
 ('toast.position = Vector2(panel.position.x,maxf(12,panel.position.y-toast.size.y-12))','toast.position = Vector2(panel.position.x+panel.size.x-toast.size.x,maxf(12,panel.position.y-toast.size.y-8))'),
 ('toast.scale = Vector2.ONE.lerp(Vector2(0.436,0.387),q)','toast.scale = Vector2.ONE.lerp(dock.size/toast.size,q)'),
 ('func pause_music():','func reshuffle_tracks():\n\tif not in_sandbox or not layer.visible: return\n\tvar fresh: Array[String] = []\n\tfor track in tracks:\n\t\tvar id = str(track.id)\n\t\tif enabled_tracks.get(id,false): fresh.append(id)\n\tif fresh.is_empty(): return\n\tfresh.shuffle()\n\tif fresh.size()>1 and fresh[0]==current_id:\n\t\tvar alternate = randi_range(1,fresh.size()-1)\n\t\tfresh[0]=fresh[alternate]; fresh[alternate]=current_id\n\tqueue.assign(fresh)\n\t# A deliberate new shuffle starts its first song immediately, including from pause.\n\tadvance(false)\n\nfunc pause_music():'),
 ('"next":\'<path d="M3 4 L16 12 L3 20 Z"/><rect x="17" y="4" width="4" height="16"/>\'}', '"next":\'<path d="M3 4 L16 12 L3 20 Z"/><rect x="17" y="4" width="4" height="16"/>\',\n\t\t"shuffle":\'<g fill="none" stroke="#dce2df" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6H6C10 6 14 18 18 18H21M17 14l4 4 -4 4M3 18H6C8 18 9 15 10.5 13M13.5 9C15 7 16 6 18 6H21M17 2l4 4 -4 4"/></g>\'}'),
 ('\tskip.disabled = queue.is_empty()', '\tvar enabled_count = 0\n\tfor track in tracks:\n\t\tif enabled_tracks.get(str(track.id),false): enabled_count += 1\n\tshuffle.disabled = enabled_count==0\n\tshuffle.tooltip_text = "Shuffle enabled songs and play the new first song" if enabled_count>0 else "Check a track to enable Shuffle."\n\tskip.disabled = queue.is_empty()')])
# Circular UI masks preserve original PNGs and all white elements inside each seal.
rows=json.loads((R/'assets/data/faction_units.json').read_text())['factions'];masks={}
for id,row in rows.items():
 im=np.array(Image.open(R/row['emblem'].replace('res://','')).convert('RGBA'))
 nonwhite=(np.min(im[:,:,:3],axis=2)<220)&(im[:,:,3]>128)
 ys,xs=np.where(nonwhite);x0,x1=int(xs.min()),int(xs.max())+1;y0,y1=int(ys.min()),int(ys.max())+1
 center=[(x0+x1)/2,(y0+y1)/2];radius=min(x1-x0,y1-y0)/2
 masks[id]={'center':[center[0]/im.shape[1],center[1]/im.shape[0]],'radius':radius-.45,'size':[im.shape[1],im.shape[0]]}
(R/'assets/data/sandbox_emblem_masks.json').write_text(json.dumps(masks,indent=2),encoding='utf-8')
helper='''extends RefCounted
## Menu-only circular seal masking. Canonical source images and battle rendering remain intact.
const Anim = preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Factions = preload("res://battle/identity/faction_unit_catalog.gd")
const MASK = preload("res://gameplay/sandbox_emblem.gdshader")
static var masks: Dictionary = {}
static var materials: Dictionary = {}
static func apply(picture: TextureRect, faction_id: String):
 var id=Factions.canonical_id(faction_id)
 picture.texture=Anim._load_texture(Factions.emblem_path(id))
 if masks.is_empty():masks=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/sandbox_emblem_masks.json"))
 if not masks.has(id):return
 if not materials.has(id):
  var row=masks[id];var mat=ShaderMaterial.new();mat.shader=MASK
  mat.set_shader_parameter("center",Vector2(row.center[0],row.center[1]))
  mat.set_shader_parameter("source_size",Vector2(row.size[0],row.size[1]))
  mat.set_shader_parameter("radius",float(row.radius));materials[id]=mat
 picture.material=materials[id]
'''
(R/'gameplay/sandbox_emblem.gd').write_text(helper,encoding='utf-8')
(R/'gameplay/sandbox_emblem.gdshader').write_text('''shader_type canvas_item;
uniform vec2 center=vec2(0.5);
uniform vec2 source_size=vec2(256.0);
uniform float radius=127.0;
void fragment(){
 float distance_px=length((UV-center)*source_size);
 float aa=max(fwidth(distance_px),0.6);
 COLOR.a*=1.0-smoothstep(radius-aa,radius,distance_px);
}
''',encoding='utf-8')
for rel in ['gameplay/sandbox_glossary_panel.gd','gameplay/sandbox_force_builder.gd']:
 p=R/rel;s=p.read_text(encoding='utf-8-sig');s=s.replace('extends Control','extends Control\nconst MenuEmblem = preload("res://gameplay/sandbox_emblem.gd")',1)
 if 'glossary' in rel:
  a='picture(b,Vector2(8,9),Vector2(38,38),Anim._load_texture(Factions.emblem_path(id)))';assert a in s;s=s.replace(a,'MenuEmblem.apply(picture(b,Vector2(8,9),Vector2(38,38),null),id)')
  a='picture(detail,Vector2(0,0),Vector2(96,96),Anim._load_texture(Factions.emblem_path(id)))';assert a in s;s=s.replace(a,'MenuEmblem.apply(picture(detail,Vector2(0,0),Vector2(96,96),null),id)')
 else:
  a='badge.texture=Anim._load_texture(Factions.emblem_path(config[side].faction))';assert s.count(a)==2;s=s.replace(a,'MenuEmblem.apply(badge,config[side].faction)')
 assert 'const MenuEmblem' in s;p.write_text(s,encoding='utf-8')
sys.path.insert(0,str(R/'tools/arsenal_production'))
import build_art as b
from weapon_display_art import make_display_icon
from weapon_precision_art import IDS
for m in b.MODELS:
 if m['id'] not in IDS:continue
 for rel in ['assets/art/weapons/arsenal/source/'+m['id']+'.svg','assets/art/weapons/arsenal/icons/'+m['id']+'.png']:
  dest=O/'before'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dest)
 art,_=b.make(m,b.ORIGINAL);b.save_svg(make_display_icon(m,art),R/'assets/art/weapons/arsenal/source'/(m['id']+'.svg'))
print('INSTALLED MENU POLISH: 23 emblem masks, 7 precision illustrations, compact toast, immediate shuffle',flush=True)
