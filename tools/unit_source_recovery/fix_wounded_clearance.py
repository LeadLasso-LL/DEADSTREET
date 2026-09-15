from pathlib import Path
R=Path(__file__).parents[2]
def edit(rel,a,b):
 p=R/rel;s=p.read_text();assert a in s,rel;p.write_text(s.replace(a,b))
edit('tools/unit_source_recovery/src/build.py',"angle+=22*wounded","angle+=22*wounded\n # Carry the weapon outside the abdomen hand; wrists follow its anchors.\n origin+=np.array([12.,-3.])*wounded")
edit('tools/unit_source_recovery/src/directions.py',"theta+=25*wounded","theta+=25*wounded\n # Clear the free hand without moving it away from the abdomen.\n origin+=np.array([11. if side else -12.,-3.])*wounded")
edit('assets/art/street_detail/unit_finish.gdshader','vec2(4.2,3.3)','vec2(5.4,4.2)')
edit('assets/art/street_detail/unit_finish.gdshader','vec2(2.1,2.5)','vec2(2.6,3.1)')
edit('gameplay/tactical_blood_layer.gd','"size":2.4','"size":3.1')
edit('gameplay/tactical_blood_layer.gd','range(4 if size>1.0 else 2)','range(6 if size>1.0 else 2)')
print('Wounded clearance and blood sizing patched')
