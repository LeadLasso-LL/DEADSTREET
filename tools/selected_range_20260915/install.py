from pathlib import Path
import subprocess, json, hashlib, shutil
ROOT = Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
OUT = ROOT/'tools/selected_range_20260915'
view = ROOT/'gameplay/tactical_battle_view.gd'
original = view.read_bytes()
if b'var selection_range_layer:' in original:
    raise SystemExit('Range layer already exists; inspect current scope before another install.')
assert not subprocess.check_output(['git','diff','HEAD','--','gameplay/tactical_battle_view.gd'],cwd=ROOT)
baseline = OUT/'before_tactical_battle_view.gd'
assert not baseline.exists(), 'Preserve existing baseline.'
baseline.write_bytes(original)
source = original.decode('utf-8')
source = source.replace('var static_surface_root: Node2D = null', 'var selection_range_layer: Node2D = null\nvar static_surface_root: Node2D = null', 1)
anchor = '\tif static_building_root == null:\n'
addition = '\tif selection_range_layer == null:\n\t\tselection_range_layer = preload("res://gameplay/tactical_selection_range.gd").new()\n\t\tselection_range_layer.name = "SelectedUnitRange"\n\t\tselection_range_layer.host = self\n\t\tselection_range_layer.z_index = 0\n\t\tadd_child(selection_range_layer)\n'
assert source.count(anchor) == 1
source = source.replace(anchor, addition + anchor, 1)
anchor = '\t\tstatic_composite_root,\n\t\tstatic_building_root,'
assert source.count(anchor) == 1
source = source.replace(anchor, '\t\tstatic_composite_root,\n\t\tselection_range_layer,\n\t\tstatic_building_root,', 1)
for name in ['tactical_selection_range.gd','tactical_selection_range.gdshader']:
    dest = ROOT/'gameplay'/name
    assert not dest.exists(), f'Preserve unexpected existing file: {dest}'
    shutil.copyfile(OUT/name, dest)
assert view.read_bytes() == original, 'Concurrent edit detected.'
view.write_bytes(source.encode('utf-8'))
receipt = {'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(), 'branch':subprocess.check_output(['git','branch','--show-current'],cwd=ROOT,text=True).strip(), 'baseline_sha256':hashlib.sha256(original).hexdigest(), 'owned_paths':['gameplay/tactical_battle_view.gd','gameplay/tactical_selection_range.gd','gameplay/tactical_selection_range.gdshader'], 'git_publication':'NOT ATTEMPTED'}
(OUT/'install_receipt.json').write_text(json.dumps(receipt,indent=2))
print(json.dumps(receipt),flush=True)
