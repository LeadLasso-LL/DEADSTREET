extends "res://tools/tactical_controls/estate_record.gd"
func _initialize():
 out="C:/Users/brand/OneDrive/Documents/dead-street/tools/whittaker_estate/width_scenery_20260914"
 super._initialize()
func _process(delta):
 super._process(delta)
 if frames>=60:
  active=false
  print("SCENERY_PREVIEW_COMPLETE")
  quit()
 return false
