extends SceneTree
const Config=preload("res://tools/yard_revision_20260915/ravicci/capture_config.gd")
var errors=[]
var checks=0
func _initialize():call_deferred("run")
func check(ok: bool,label_value: String):
 checks+=1
 if not ok:errors.append(label_value);push_error(label_value)
func run():
 var cfg=Config.config();check(preload("res://gameplay/sandbox_force_config.gd").validate(cfg).valid,"native force configuration")
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 await scene.start_battle(false,cfg);scene.set_process(false)
 check(scene.battle!=null,"actual Ravicci battle setup")
 if scene.battle==null:quit(1);return
 var b=scene.battle;var mixer=scene.runtime.get_node("TacticalBattleView").battle_presentation.convoy_audio
 mixer.sync(b,{},true,0.,0.,0.,0.)
 var radios=0
 for player in mixer.sources.values():
  if not player.get_meta("is_radio",false):continue
  radios+=1
  if player.get_meta("side_id")==b.attacker_side_id:
   check(player.get_meta("faction_id")=="ravicci","Ravicci spatial radio")
   check(player.get_meta("track_id")=="bond_ob","owner-assigned Bond track")
   check(not player.has_meta("fixed_position"),"radio travels in Ravicci vehicle")
   check(absf(player.volume_db-(-18.+linear_to_db(1.10)))<.001,"ten percent arrival boost")
  else:check(player.get_meta("faction_id")=="calle_ocho","Calle Ocho building radio")
 check(radios==2,"both faction radios")
 var result={"checks":checks,"errors":errors}
 FileAccess.open("res://tools/yard_revision_20260915/ravicci/integration_review.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"));print("RAVICCI_INTEGRATION ",JSON.stringify(result));quit(0 if errors.is_empty() else 1)
