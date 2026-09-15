from pathlib import Path
import json, hashlib

r = Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
o = r / 'tools/selected_range_groups_20260915'
base = json.loads((o / 'baseline_hashes.json').read_text())
for name, sha in base.items():
    assert hashlib.sha256((r / name).read_bytes()).hexdigest() == sha, name + ' changed'

def replace(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new, 1)

p = r / 'gameplay/tactical_selection_range.gd'
s = p.read_text(encoding='utf-8')
s = replace(s, 'const FADE_IN_SECONDS := 0.12', 'const FADE_IN_SECONDS := 0.12\nconst GroupShader = preload("res://gameplay/tactical_group_range.gdshader")\nconst MAX_GROUP_RANGES := 32 # Above current legal squad sizes; matches shader array.')
s = replace(s, 'var _softness := -1.0', 'var _softness := -1.0\nvar group_disc: Polygon2D\nvar group_ranges: Array = []\nvar _group_key := ""\nvar _group_bounds := Rect2()\nvar _group_rings := PackedVector4Array()\nvar _group_feathers := PackedFloat32Array()')
s = replace(s, '\tvar info := describe(host._battle_state(), host.orders_controller.selected_participant_ids)', '\tif host.orders_controller.selection_is_all:\n\t\t_clear()\n\t\treturn\n\tif host.orders_controller.selected_participant_ids.size() > 1:\n\t\t_process_group(delta, host.orders_controller.selected_participant_ids)\n\t\treturn\n\t_group_key = ""\n\tgroup_ranges.clear()\n\tif group_disc != null:\n\t\tgroup_disc.hide()\n\tdisc.show()\n\tvar info := describe(host._battle_state(), host.orders_controller.selected_participant_ids)')
s = replace(s, 'func _clear() -> void:\n\tvisible = false', 'func _clear() -> void:\n\tgroup_ranges.clear()\n\t_group_key = ""\n\tif group_disc != null:\n\t\tgroup_disc.hide()\n\tvisible = false')
s += '\n\n' + (o / 'group_methods.gd.txt').read_text()
controller = r / 'gameplay/tactical_orders_controller.gd'
c = controller.read_text(encoding='utf-8')
c = replace(c, 'var selected_participant_ids: Array[String] = []', 'var selected_participant_ids: Array[String] = []\nvar selection_is_all: bool = false # Presentation only; never changes orders.')
c = replace(c, 'func clear_selection() -> void:\n', 'func clear_selection() -> void:\n\tselection_is_all = false\n')
c = replace(c, '\tif not can_control_participant(participant_id):\n\t\treturn false', '\tif not can_control_participant(participant_id):\n\t\treturn false\n\tselection_is_all = false')
c = replace(c, '\tvar ids = b.participants.keys()\n\tids.sort()', '\tselection_is_all = weapon_type.is_empty()\n\tvar ids = b.participants.keys()\n\tids.sort()')
c = replace(c, 'func select_box(view: Node, rect: Rect2, additive: bool) -> void:\n', 'func select_box(view: Node, rect: Rect2, additive: bool) -> void:\n\tselection_is_all = false\n')
# All checks complete before source writes; preserve unrelated live source.
shader = r / 'gameplay/tactical_group_range.gdshader'
assert not shader.exists()
shader.write_bytes((o / shader.name).read_bytes())
p.write_text(s, encoding='utf-8', newline='\n')
controller.write_text(c, encoding='utf-8', newline='\n')
print('Installed group renderer and five selection-display metadata insertions; individual shader unchanged.')
