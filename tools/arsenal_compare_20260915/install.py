from pathlib import Path
import json, hashlib, subprocess
R=Path(__file__).resolve().parents[2]; O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert subprocess.check_output(['git','branch','--show-current'],cwd=R,text=True).strip()=='build/arsenal-checkpoint-20260911'
sources=['gameplay/sandbox_glossary_panel.gd','gameplay/sandbox_force_builder.gd']
assert not (O/'baseline.json').exists(), 'Single-use installer: already applied'
for rel in sources:
    assert not subprocess.check_output(['git','diff','HEAD','--',rel],cwd=R), f'Concurrent edits: {rel}'
    p=O/'before'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((R/rel).read_bytes())
(O/'before'/'.gdignore').write_text('')
(O/'baseline.json').write_text(json.dumps({p:sha(R/p) for p in sources},indent=2))
event='''## 20260915-arsenal-compare-01 - Owner requested SMG casing and direct equipment comparisons

Brandon requested SMG always uppercase in the sandbox force picker and click-one/hover-another Arsenal stat comparisons, then explicitly extended the same interaction to Vehicles. Scope: glossary UI, force-builder presentation, a shared equipment stat formatter and tools/arsenal_compare_20260915/. Both affected existing sources are clean at baseline; preserve parallel Harold HQ-car, range and opening work. No combat/stat/price tuning. Vehicle comparisons include price, upkeep, seats, road movement, resources, cover and neutral dimensions/door counts, with special-role descriptions preserved. Implement a clicked baseline that persists across class tabs; show both values and signed hovered-minus-selected differences. Lower price/aim/reload/recoil/miss chance is beneficial; graze probability is a neutral tradeoff. Keep hovered details stable for scrolling. Verify actual native input, cross-class comparisons, formatting and screen fit.

Prior Faction Audio publication is complete and remotely verified at 50a000753b04c7115bfeef48cb46dea0b2ddbbd4; no prior approval blocker remains. Current work is a separate UI request.
'''
for rel in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
    p=R/rel;s=p.read_text(encoding='utf-8-sig');p.write_text(s.rstrip()+'\n\n\n'+event,encoding='utf-8')
def replace(s,a,b):
    assert a in s, a[:100]
    return s.replace(a,b)
p=R/sources[1];s=p.read_text(encoding='utf-8-sig')
s=replace(s,'kind.capitalize()','class_label(kind)')
s=replace(s,'id.capitalize()','class_label(id)')
s=replace(s,'row["class"].capitalize()','class_label(row["class"])')
s+='\nfunc class_label(id: String) -> String:\n return "SMG" if id.to_lower()=="smg" else id.capitalize()\n'
p.write_text(s,encoding='utf-8')
p=R/sources[0];s=p.read_text(encoding='utf-8-sig')
s=replace(s,'extends Control\n','extends Control\nconst Comparison = preload("res://gameplay/equipment_comparison.gd")\n')
s=replace(s,'var audio_button: Button','var audio_button: Button\nvar comparison_base = ""\nvar compared_id = ""\nvar comparison_cells = {}\nvar comparison_hint: Label')
s=replace(s,'func build_equipment():\n','func build_equipment():\n\tcomparison_hint=label(self,Vector2(205,10),Vector2(646,26),"Click to select; hover another to compare.",12,MUTED)\n\tvisibility_changed.connect(func():\n\t\tif not is_visible_in_tree() and not compared_id.is_empty():show_equipment(comparison_base,false))\n')
s=replace(s,'\t\titem_buttons[model_id]=b','\t\tb.mouse_entered.connect(hover_equipment.bind(model_id))\n\t\titem_buttons[model_id]=b')
s=replace(s,'\tif not ids.is_empty(): show_equipment(ids[0])','\tif not ids.is_empty(): show_equipment(comparison_base if not comparison_base.is_empty() else ids[0],false)')
s=replace(s,'func show_equipment(id: String):\n','func show_equipment(id: String, pin: bool = true):\n\tcompared_id="";comparison_cells.clear()\n\tif pin:comparison_base=id\n\tvar base_name = (Weapons.get_model(comparison_base).display_name if mode=="arsenal" else Vehicles.model(comparison_base).name) if not comparison_base.is_empty() else ""\n\tcomparison_hint.text="Selected: "+base_name+"  ·  Hover to compare; click to reselect." if not comparison_base.is_empty() else "Click to select; hover another to compare."\n')
start=s.index('\t\tvar rows=[',s.index('func show_equipment'))
end=s.index('\n\t\tlabel(detail,Vector2(18,275+rows.size()',start)
s=s[:start]+'\t\tvar rows=Comparison.rows(id)\n\t\tfor i in range(rows.size()): stat(rows[i].label,rows[i].text,275+i*30,rows[i].hint)'+s[end:]
s+='\n'+(O/'comparison_ui.gdpart').read_text(encoding='utf-8')
p.write_text(s,encoding='utf-8')
(R/'gameplay/equipment_comparison.gd').write_bytes((O/'equipment_comparison.gd').read_bytes())
(O/'owned_doc_deltas.json').write_text(json.dumps({'start':event},indent=2))
print('Installed SMG casing and Arsenal comparisons; baseline and ownership recorded.',flush=True)
