from pathlib import Path
import json,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=r/'tools/whittaker_estate';o=out/'width_scenery_20260914'
old=json.loads((o/'prior_version4/record.json').read_text());new=json.loads((out/'record.json').read_text());v=json.loads((out/'transfer.json').read_text())
comparison={k:old[k]==new[k] for k in ['seed','combat_seconds','winner','commands','phases','arrival_manifest','audio_shots','result_summaries','results','frames','seconds']}
protected=json.loads((o/'protected_sources.json').read_text());changed=[p for p,h in protected.items() if hashlib.sha256((r/p).read_bytes()).hexdigest()!=h]
h=json.loads((o/'hud_layout.json').read_text());assert h['checks']==834 and not h['errors']
result={'accepted_battle_comparison':comparison,'protected_sources':len(protected),'changed_protected_sources':changed,'hud_checks':h['checks'],'camera_safety_violations':new['camera_safety_violations'],'actor_frame_checks':new['actor_frame_checks'],'presentation_errors':new['presentation_errors'],'arrival_errors':new['arrival_route_errors'],'outro_errors':new['outro_errors'],'result_camera_jump_pixels':new['result_camera_jump_pixels'],'video':{k:v[k] for k in ['bytes','sha256','seconds','decoded_to_end','audio_peak','audio_rms']},'camera_policy':'Source hash unchanged; original intro zoom/pan and subsequent camera path retained','scope':'Two live presentation sources: HUD width and estate scenery/driveway; no battle/geometry/audio/result-state edits'}
(o/'verification.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
assert all(comparison.values()) and not changed,result
assert v['decoded_to_end'] and not new['presentation_errors'] and new['camera_safety_violations']==0
print(json.dumps(result,indent=2),flush=True)