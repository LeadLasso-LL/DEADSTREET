extends SceneTree
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
var checks=0
var errors=[]
func verify(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message)
func _initialize():call_deferred("run")
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 for id: String in Weapons.model_data().models:
  var d=Weapons.get_model(id)
  for faction in ["local_street_gang","russian_organized_crime","italian_mob"]:
   var variant=Anim.variant_for(faction,d.weapon_type_id,id)
   verify(not variant.is_empty(),"variant "+id)
   if not id in ["glock_17","uzi","ak47","rem870"]:
    verify(variant.begins_with("arsenal_") and variant.ends_with("_"+id),"model-specific atlas "+id)
   verify(FileAccess.file_exists(Anim.atlas_path(variant,"portraits")),"portrait "+variant)
   var frames=Anim.frames_for(variant)
   verify(frames!=null,"frames "+variant)
   if frames==null:continue
   for direction: String in Anim.IMPLEMENTED_DIRECTION_IDS:
    for clip: String in Anim.bound_clip_ids():
     var name=clip+"_"+direction
     verify(frames.has_animation(name) and frames.get_frame_count(name)==Anim.clip_frame_count(clip),"clip "+variant+" "+name)
   verify(Anim.frames_cache_size()<=12,"bounded atlas cache")
  verify(FileAccess.file_exists("res://assets/art/weapons/arsenal/icons/"+id+".png"),"icon "+id)
  for i in range(3):verify(ResourceLoader.exists("res://assets/audio/weapons/"+id+"_"+str(i)+".wav"),"audio "+id+str(i))
 scene.choose("awm");scene.clip="aim";scene.refresh()
 verify(scene.name_label.text.contains("AWM"),"review model label")
 verify(scene.stats.text.contains("-21%"),"review movement label")
 await process_frame
 var report={"checks":checks,"errors":errors,"cached_variants":Anim.frames_cache_size()}
 FileAccess.open("res://tools/arsenal_production/presentation_validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ARSENAL_PRESENTATION ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
