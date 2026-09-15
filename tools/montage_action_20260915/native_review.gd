extends SceneTree
var player: VideoStreamPlayer
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720);root.gui_disable_input=true
 player=VideoStreamPlayer.new();var stream=VideoStreamTheora.new()
 stream.file="res://tools/montage_action_20260915/montage_candidate.ogv"
 player.stream=stream;player.expand=true;player.size=Vector2(1280,720);player.loop=true;player.volume=0.
 root.add_child(player);player.play()
 var last=0.;var loops=0;var max_position=0.;var black_samples=0;var samples=0
 for n in range(810):
  await process_frame
  var at=player.stream_position
  if at<last-10.:loops+=1
  max_position=maxf(max_position,at);last=at
  if n in [45,180,330,480,630,765]:
   await RenderingServer.frame_post_draw
   var im=root.get_texture().get_image();im.resize(160,90)
   var total=0.
   for y in range(im.get_height()):
    for x in range(im.get_width()):total+=im.get_pixel(x,y).get_luminance()
   if total/(160.*90.)<.003:black_samples+=1
   samples+=1
 var report={"playing":player.is_playing(),"texture_size":str(player.get_video_texture().get_size()),"max_position":max_position,"loops":loops,"black_samples":black_samples,"samples":samples}
 var passed=report.playing and max_position>23.9 and loops>=1 and black_samples==0
 report["passed"]=passed
 FileAccess.open("res://tools/montage_action_20260915/native_validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("MONTAGE_NATIVE ",JSON.stringify(report));quit(0 if passed else 1)
