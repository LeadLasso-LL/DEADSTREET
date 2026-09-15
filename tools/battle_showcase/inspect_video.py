from pathlib import Path
import subprocess,imageio_ffmpeg
r=Path(__file__).parent/'results'
p=subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-hide_banner','-i',str(r/'harold_4v4_raw.avi')],capture_output=True,text=True)
print(p.stderr)
