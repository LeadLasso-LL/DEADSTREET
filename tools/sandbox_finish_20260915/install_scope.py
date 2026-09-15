from pathlib import Path
import json,hashlib,shutil,sys,subprocess,xml.etree.ElementTree as E
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent;A=R/'tools/portrait_audit_20260914'
sys.path.insert(0,str(R/'tools/arsenal_production'))
from weapon_pricing import PRICES
backup=O/'before';backup.mkdir(exist_ok=True);changed=[];before={}
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(path,content):
    p=R/path;old=p.read_bytes() if p.exists() else None
    raw=content.encode('utf-8') if isinstance(content,str) else content
    if old==raw:return
    if old is not None:
        dst=backup/path;dst.parent.mkdir(parents=True,exist_ok=True)
        if not dst.exists():dst.write_bytes(old)
        before[path]=hashlib.sha256(old).hexdigest()
    p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(raw);changed.append(path)
def patch(path,pairs):
    p=R/path;text=p.read_text(encoding='utf-8-sig')
    for old,new in pairs:
        assert text.count(old)==1,(path,old,text.count(old))
        text=text.replace(old,new)
    save(path,text)
assert not (O/'installed.json').exists(),'Already installed: inspect receipt before rerunning.'
models=json.loads((R/'assets/data/weapon_models.json').read_text(encoding='utf-8-sig'))
assert set(PRICES)==set(models['models'])
combat_before={k:{x:y for x,y in v.items() if x!='price'} for k,v in models['models'].items()}
for id,row in models['models'].items():row['price']=PRICES[id]
save('assets/data/weapon_models.json',json.dumps(models,ensure_ascii=False,indent=2)+'\n')
patch('tools/arsenal_production/build_catalog.py',[
    ('from pathlib import Path','from pathlib import Path\nfrom weapon_pricing import PRICES'),
    ('MODELS[id]=dict(id=id,name=name,weapon_class=kind,tier=tier,','MODELS[id]=dict(id=id,name=name,weapon_class=kind,tier=tier,price=PRICES[id],')])
patch('battle/combat/battle_weapon_catalog.gd',[
    ('static func default_model(weapon_class: String) -> String:',
     '# Canonical acquisition value per firearm; excludes unit training and ammunition.\n# Unknown equipment has no valid quote and must never become a free purchase.\nstatic func purchase_price(model_id: String) -> int:\n\tvar row: Dictionary = model_data().get("models", {}).get(model_id, {})\n\treturn int(row.get("price", -1))\n\nstatic func default_model(weapon_class: String) -> String:')])
leaders=json.loads((O/'leader_manifest.json').read_text(encoding='utf-8'))
glossary=json.loads((R/'assets/data/faction_glossary.json').read_text(encoding='utf-8-sig'))
for row in leaders['leaders']:
    assert digest(R/row['path'])==row['sha256']
    glossary['factions'][row['faction']]['leader_photo']='res://'+row['path']
save('assets/data/faction_glossary.json',json.dumps(glossary,ensure_ascii=False,indent=2)+'\n')
patch('gameplay/sandbox_glossary_panel.gd',[
    ('var selected_faction_rows: Dictionary = {}','var selected_faction_rows: Dictionary = {}\nvar leader_image: TextureRect'),
    ('selected_id = id; clear(detail); unit_images.clear(); detail_labels.clear(); mark_faction()',
     'selected_id = id; clear(detail); unit_images.clear(); detail_labels.clear(); leader_image=null; mark_faction()'),
    ('Vector2(114,0),Vector2(712,65)','Vector2(114,0),Vector2(498,65)'),
    ('Vector2(114,71),Vector2(712,28)','Vector2(114,71),Vector2(498,35)'),
    ('var story = panel(detail,Vector2(0,116),Vector2(832,158))',
     'var photo_path = str(row.get("leader_photo",""))\n\tif not photo_path.is_empty():\n\t\tleader_image=picture(detail,Vector2(630,0),Vector2(202,252),Anim._load_texture(photo_path))\n\t\tleader_image.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR\n\t\tleader_image.set_meta("faction",id)\n\t\tleader_image.tooltip_text=leader_for(id)\n\telse:\n\t\tvar pending=panel(detail,Vector2(630,0),Vector2(202,252))\n\t\tlabel(pending,Vector2(18,98),Vector2(166,66),"LEADERSHIP\\nUNDISCLOSED",13,MUTED)\n\tvar story = panel(detail,Vector2(0,116),Vector2(612,158))'),
    ('Vector2(790,23)','Vector2(576,23)'),('Vector2(794,102)','Vector2(576,102)'),
    ('\tfor model_id in ids:\n\t\tvisible_models.append(model_id)',
     '\tif mode=="vehicles":\n\t\tids.sort_custom(func(a,b):\n\t\t\tvar left=int(Vehicles.model(a).price)\n\t\t\tvar right=int(Vehicles.model(b).price)\n\t\t\treturn str(Vehicles.model(a).name).naturalnocasecmp_to(str(Vehicles.model(b).name))<0 if left==right else left<right)\n\tfor model_id in ids:\n\t\tvisible_models.append(model_id)'),
    ('"TIER %d"%model.tier if mode=="arsenal"','"TIER %d  /  $%s"%[model.tier,money(Weapons.purchase_price(model_id))] if mode=="arsenal"'),
    ('\t\tvar rows=[\n\t\t\t["Range"',
     '\t\tvar rows=[\n\t\t\t["Price","$"+money(Weapons.purchase_price(id)),"Purchase price per firearm. Unit recruitment and training are separate."],\n\t\t\t["Range"')])
# Install reviewed standing portraits at a fixed 90x80 canvas, preserving atlas motion.
report=json.loads((A/'build_validation.json').read_text(encoding='utf-8'))
for row in report['rows']:
    assert digest(R/row['portrait'])==row['sha256'],('Concurrent portrait edit',row['variant'])
    save(row['portrait'],(A/'candidates'/(row['variant']+'.png')).read_bytes())
# Keep the normal icon build connected to the editable detail pass.
patch('tools/arsenal_production/build_art.py',[
    ('from weapon_art import make,draw_art','from weapon_art import make,draw_art\nfrom weapon_display_art import make_display_icon'),
    ("icon=E.Element(N+'svg',{'width':'376','height':'160','viewBox':'-18 -12 94 40'});draw_art(icon,art)",
     'icon=make_display_icon(model,art)')])
import build_art
from weapon_display_art import make_display_icon
E.register_namespace('',build_art.N[1:-1])
for model in models['models'].values():
    icon_path='assets/art/weapons/arsenal/icons/'+model['id']+'.png'
    original_icon=R/icon_path;target=backup/icon_path;target.parent.mkdir(parents=True,exist_ok=True)
    if not target.exists():shutil.copy2(original_icon,target)
    before[icon_path]=digest(original_icon);changed.append(icon_path)
    art,definition=build_art.make(model,build_art.ORIGINAL)
    icon=make_display_icon(model,art)
    save('assets/art/weapons/arsenal/source/'+model['id']+'.svg',E.tostring(icon,encoding='unicode'))
patch('tools/arsenal_production/render_icons.gd',[
    ('  im.save_png(base+"icons/"+id+".png")','  var used=im.get_used_rect()\n  var padded=used.grow(6).intersection(Rect2i(Vector2i.ZERO,im.get_size()))\n  im=im.get_region(padded)\n  im.save_png(base+"icons/"+id+".png")')])
after_models=json.loads((R/'assets/data/weapon_models.json').read_text(encoding='utf-8'))
assert {k:{x:y for x,y in v.items() if x!='price'} for k,v in after_models['models'].items()}==combat_before
receipt={'changed':changed,'before':before,'after':{p:digest(R/p) for p in changed},'portraits':len(report['rows']),'photos':len(leaders['leaders']),'weapons':len(PRICES),'combat_stats_unchanged':True}
(O/'installed.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
print('INSTALLED',len(changed),'FILES',receipt['portraits'],'PORTRAITS',flush=True)
