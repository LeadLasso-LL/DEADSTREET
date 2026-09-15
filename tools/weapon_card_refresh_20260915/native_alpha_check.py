from pathlib import Path
import subprocess
O=Path(__file__).resolve().parent;R=O.parents[1]
(O/'native_initial.log').write_bytes((O/'native.log').read_bytes())
(O/'native_initial_validation.json').write_bytes((O/'native_validation.json').read_bytes())
p=O/'check_native.gd';s=p.read_text(encoding='utf-8')
s=s.replace('func _initialize():call_deferred("run")',"""func source_image(path: String,imported: bool=false)->Image:
 var im=Image.new()
 im.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
 if imported:im.fix_alpha_edges()
 return im
func _initialize():call_deferred("run")""")
s=s.replace('Image.load_from_file(path)),"current Arsenal','source_image(path,true)),"current Arsenal')
s=s.replace('Image.load_from_file(path)','source_image(path)').replace('Image.load_from_file(expected)','source_image(expected)')
s=s.replace(' root.size=Vector2i(1152,764)',' RenderingServer.set_default_clear_color(Color("#152226"))\n root.size=Vector2i(1152,764)')
p.write_text(s,encoding='utf-8',newline='\n')
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (O/'native.log').open('w',encoding='utf-8') as f:p=subprocess.run([godot,'--path',str(R),'--rendering-method','gl_compatibility','--resolution','1152x764','--script','res://tools/weapon_card_refresh_20260915/check_native.gd'],stdout=f,stderr=subprocess.STDOUT,timeout=60)
print('NATIVE_RETURN',p.returncode,(O/'native.log').read_text(encoding='utf-8')[-2000:],flush=True)
