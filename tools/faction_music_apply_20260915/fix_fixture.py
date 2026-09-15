from pathlib import Path
import json
out=Path(__file__).resolve().parent
p=json.loads((out/'native_payload.json').read_text(encoding='utf-8'));s=p['gd']
s=s.replace('AudioServer.set_bus_volume_db(0,-65)','AudioServer.set_bus_volume_db(0,-65)\n\troot.size=Vector2i(640,480)\n\tvar test_view=Node2D.new();root.add_child(test_view)\n\tvar listener=AudioListener2D.new();test_view.add_child(listener);listener.make_current()')
s=s.replace('var audio=Convoy.new();audio.setup(view)','scene.queue_free();await process_frame;await process_frame\n\t\tvar audio=Convoy.new();audio.setup(test_view)')
s=s.replace('var old=Before.new();old.setup(view)','var old=Before.new();old.setup(test_view)')
s=s.replace('var original_phase=b.battle_phase','var original_phase=b.battle_phase\n\t\tb.tactical_result=preload("res://battle/core/battle_victory_result.gd").new()')
s=s.replace('def.stop();atk.play(29.85);await create_timer(.38).timeout','def.stop();listener.global_position=atk.global_position;atk.play(29.85);await create_timer(.38).timeout\n\t\t\t\tprint("WRAP ",id," playing=",atk.playing," position=",atk.get_playback_position())')
s=s.replace('\t\tscene.queue_free();await process_frame;await process_frame\n\tFileAccess.open','\tFileAccess.open')
p['gd']=s
if (out/'native.log').exists():(out/'native_second_attempt.log').write_bytes((out/'native.log').read_bytes())
(out/'native_payload.json').write_text(json.dumps(p),encoding='utf-8')
print('FIXTURE_ISOLATED_AND_RESULT_CREATED',flush=True)
