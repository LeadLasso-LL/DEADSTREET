from pathlib import Path
import json,subprocess,shutil
import imageio_ffmpeg
r=Path(__file__).resolve().parents[2];out=r/'tools/battle_finish/results';ref=r/'docs/references/battle_finish'
v=json.loads((out/'video_integrity.json').read_text());video=out/v['filename']
subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-hide_banner','-loglevel','error','-y','-ss',str(v['duration_seconds']-9),'-i',str(video),'-frames:v','1',str(out/'video_aftermath.png')],check=True)
shutil.copy2(out/'video_aftermath.png',ref/'video_aftermath.png')
shutil.copy2(video,Path.home()/'OneDrive/Desktop'/video.name)
print('Final aftermath frame and desktop recording saved')
