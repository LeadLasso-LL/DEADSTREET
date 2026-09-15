from pathlib import Path
R=Path(__file__).parents[2]
def edit(rel,a,b):
 p=R/rel;s=p.read_text(encoding='utf-8');assert a in s,rel;p.write_text(s.replace(a,b),encoding='utf-8')
(R/'battle/geometry/dusk_street_catalog.gd').write_text('extends "res://battle/geometry/harold_street_catalog.gd"\n# Compatibility entry point; authored Harold Ave. data lives in its own catalog.\n')
edit('gameplay/tactical_battle_view.gd','preload("res://gameplay/dusk_street_art.gd")','preload("res://gameplay/harold_street_art.gd")')
edit('gameplay/tactical_battle_view.gd','for spot in [Vector2(11,23),Vector2(38,23)]:','for spot in [Vector2(6,23),Vector2(29,23),Vector2(54,23),Vector2(17,35),Vector2(45,35)]:')
edit('gameplay/tactical_battle_view.gd','\t\t_dusk_nodes.append(lamp)\n','\t\t_dusk_nodes.append(lamp)\n\tvar street_sign = art.new()\n\tstreet_sign.prop = ["harold_sign",Rect2(),"street_sign"]\n\tstreet_sign.position = Vector2(60*8,22*6)\n\tdynamic_unit_root.add_child(street_sign)\n\t_dusk_nodes.append(street_sign)\n')
p=R/'battle/identity/tactical_identity_factory.gd';s=p.read_text()
a='\tif battle_state == null:\n\t\treturn\n\t_apply_side('
b='\tif battle_state == null:\n\t\treturn\n\tif battle_state.battlefield_geometry != null and battle_state.battlefield_geometry.authored_layout_id == "dead_street_dusk_v1":\n\t\t_apply_side(battle_state, battle_state.attacker_side_id, GangArchetypeCatalog.ARCHETYPE_RUSSIAN_ORGANIZED_CRIME)\n\t\t_apply_side(battle_state, battle_state.defender_side_id, GangArchetypeCatalog.ARCHETYPE_LOCAL_STREET_GANG)\n\t\treturn\n\t_apply_side('
assert a in s;s=s.replace(a,b);p.write_text(s)
# A new location review must not depend on old club/threshold prop IDs.
s=(R/'tools/dusk_review/runtime_review.gd').read_text()
s=s.replace('res://tools/dusk_review/results','res://tools/dusk_review/harold_results')
s=s.replace('Vector2(32 + occupied.size()*3,42)','Vector2(44 + occupied.size()*3,30)')
s=s.replace('Vector2(35,42)','Vector2(49,30)')
s=s.replace('cover_threshold_sedan_1','cover_north_car_3_1').replace('cover_club_wall_w_0','cover_stoop_west_2')
s=s[:s.index('func capture(second: int)')]+'''func capture(second: int) -> void:
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out_dir + "/battle_%02d.png" % second)
 if second == 2:
  comparing=true
  var view=runtime.get_node("TacticalBattleView")
  view._dusk_zoom=1.65
  view._dusk_pan=Vector2(-65,-10)
  view._frame_camera()
  await process_frame
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(out_dir+"/harold_close.png")
  view._dusk_zoom=1.1
  view._dusk_pan=Vector2.ZERO
  view._frame_camera()
  comparing=false

func fail(reason: String) -> void:
 push_error("HAROLD_REVIEW_FAILED "+reason)
 quit(1)
'''
(R/'tools/dusk_review/harold_review.gd').write_text(s)
print('Harold map installed; separate review fixture prepared')
