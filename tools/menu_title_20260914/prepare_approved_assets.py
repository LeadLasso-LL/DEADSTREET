from pathlib import Path
import base64,hashlib,json,subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/menu_title_20260914'
title=base64.b64decode((o/'approved_title.transfer').read_text().strip(),validate=True);(o/'approved_title.png').write_bytes(title)
ff=r'C:\Users\brand\AppData\Local\DeadStreetTools\python\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe'
subprocess.run([ff,'-v','error','-i',str(o/'B-22_Track_22.mp3'),'-c:a','copy','-metadata','title=Dead Street','-metadata','artist=B-22','-id3v2_version','3','-y',str(o/'B-22_Dead_Street.mp3')],check=True)
subprocess.run([ff,'-v','error','-i',str(o/'B-22_Dead_Street.mp3'),'-f','null','NUL'],check=True)
m=json.loads((o/'track_22.json').read_text());m['source_title']='Track 22';m['title']='Dead Street';m['artist']='B-22';m['source_sha256']=m['sha256'];m['file']=str(o/'B-22_Dead_Street.mp3');m['sha256']=hashlib.sha256((o/'B-22_Dead_Street.mp3').read_bytes()).hexdigest();m['verified_decode']=True
(o/'signature_track.json').write_text(json.dumps(m,indent=2),encoding='utf-8')
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write('\n\n## 20260914-opening-preview-02 — Signature track title correction\n\nBrandon explicitly renamed the signature song to Dead Street by B-22 while the first opening preview was being rendered. This overrides the default preserve-SoundCloud-title rule for this one track. Original source title Track 22 remains provenance only. Game-facing audio is B-22_Dead_Street.mp3, stream-copied without recompression with ID3 title/artist and signature_track.json metadata. Full FFmpeg decode passed. The on-screen track popup and video metadata are being updated before delivery. Approved title image transferred byte-for-byte to tools/menu_title_20260914/approved_title.png. First render review caught a color-space error in screen blending; corrected composition will be monochrome-checked before delivery. No runtime changes.\n')
print(json.dumps({'title_sha256':hashlib.sha256(title).hexdigest(),'audio':m['title'],'artist':m['artist'],'decode':'PASS','audio_sha256':m['sha256']}))
