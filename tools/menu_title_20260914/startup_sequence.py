"""Three equal startup holds and transitions; unshifted signature audio.

Build main_menu.mkv with compose_opening.py first. Logos retain original paths.
"""
from pathlib import Path
import subprocess, json, hashlib, sys
from lxml import etree
import cairosvg
from compose_opening import ROOT, W, H, FPS, run

TOTAL_FRAMES=1440
TIMELINE={
    'scene_holds': [['Gloria Systems',0,3],['Godot Engine',4,7],['Redacted caution sign',8,11]],
    'transitions': [['Gloria to Godot',3,4],['Godot to warning',7,8],['Redaction zoom / main reveal',11,12]],
    'full_black_at_seconds':11.5,
    'main_screen_settled_at_seconds':12,
    'open_sandbox_first_visible_seconds':17,
    'preview_sandbox_entry_seconds':36,
    'preview_music_card_docks_seconds':39.75,
    'preview_playlist_opens_seconds':42,
    'audio':'Dead Street â€” B-22; plays continuously from 0 and persists on sandbox entry, no offset/restart',
}

def credit_card(logo_name, label, width, y, output):
    logo=etree.fromstring((ROOT/logo_name).read_bytes())
    view=[float(x) for x in logo.get('viewBox').split()]
    logo.set('width',str(width));logo.set('height',str(width*view[3]/view[2]))
    logo.set('x',str((W-width)/2));logo.set('y',str(y))
    # Original logo is already white; no geometry or typeface substitutions.
    card=etree.fromstring(f'''<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="720" viewBox="0 0 1280 720">
      <rect width="1280" height="720" fill="black"/>
      <text x="640" y="255" text-anchor="middle" font-family="DejaVu Sans" font-size="17" letter-spacing="4" fill="white">{label}</text>
    </svg>'''.encode())
    card.append(logo)
    svg=ROOT/(output+'.svg');svg.write_bytes(etree.tostring(card))
    cairosvg.svg2png(url=str(svg),write_to=str(ROOT/(output+'.png')))

def clip(image, frames, filters, filename):
    target=ROOT/filename
    run(['ffmpeg','-v','warning','-loop','1','-framerate',str(FPS),'-i',str(ROOT/image),
         '-vf',filters+',setsar=1,format=yuv420p','-frames:v',str(frames),'-an',
         '-c:v','libx264','-preset','fast','-crf','16','-threads','2','-y',str(target)],filename+'.log')
    check=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=nb_read_frames','-of','json',str(target)]))
    assert int(check['streams'][0]['nb_read_frames'])==frames, ('incomplete clip',filename,check)
    return target

def main():
    if '--export-only' not in sys.argv:
        credit_card('gloria_logo_original.svg','A GAME DEVELOPED BY',790,317,'credit_gloria')
        credit_card('godot_logo_white.svg','POWERED BY',550,306,'credit_godot')
        clip('credit_gloria.png',105,'fade=t=out:st=3:d=0.5','startup_gloria.mkv')
        clip('credit_godot.png',120,'fade=t=in:st=0:d=0.5,fade=t=out:st=3.5:d=0.5','startup_godot.mkv')
        # 0.5s fade in + 3s readable hold + 0.5s accelerating zoom into black bar.
        clip('warning_sign_bullet_holes.png',120,
             "scale=1280:720:flags=neighbor,zoompan=z='if(lte(on,104),1,pow(25,(on-104)/15))':"
             "x='(iw-iw/zoom)*0.5':y='(ih-ih/zoom)*0.70':d=1:s=1280x720:fps=30,"
             "fade=t=in:st=0:d=0.5,fade=t=out:st=3.9666666667:d=0.0333333333",
             'startup_warning_v2.mkv')
        run(['ffmpeg','-v','error','-i',str(ROOT/'main_menu.mkv'),'-frames:v','1','-y',str(ROOT/'main_first_frame.png')],'main_first_frame.log')
        # At 11.5 the frame is black; title and real footage pull back and settle at 12.
        clip('main_first_frame.png',15,
             "zoompan=z='1+0.8*pow(1-on/14,3)':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)/2':"
             "d=1:s=1280x720:fps=30,fade=t=in:st=0:d=0.3333333333",
             'startup_reveal.mkv')
        run(['ffmpeg','-v','warning','-i',str(ROOT/'main_menu.mkv'),'-vf',
             "drawbox=x=489:y=575:w=303:h=55:color=white@0.25:t=2:enable='between(t,23,23.6)',fade=t=out:st=23.7:d=0.3",
             '-frames:v','720','-an','-c:v','libx264','-crf','18','-preset','fast','-threads','2','-y',str(ROOT/'main_for_handoff.mkv')],'main_for_handoff.log')
    parts=['startup_gloria.mkv','startup_godot.mkv','startup_warning_v2.mkv','startup_reveal.mkv','main_for_handoff.mkv','sandbox_handoff.mkv']
    for part,expected in zip(parts,[105,120,120,15,720,360]):
        check=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=nb_read_frames','-of','json',str(ROOT/part)]))
        assert int(check['streams'][0]['nb_read_frames'])==expected, ('incomplete input',part,check)
    (ROOT/'opening_parts.txt').write_text(''.join(f"file '{p}'\n" for p in parts))
    run(['ffmpeg','-v','warning','-f','concat','-safe','0','-i',str(ROOT/'opening_parts.txt'),
         '-i',str(ROOT/'B-22_Dead_Street.mp3'),'-map','0:v:0','-map','1:a:0',
         '-frames:v',str(TOTAL_FRAMES),'-t','48','-c:v','libx264','-preset','medium','-crf','20',
         '-profile:v','high','-pix_fmt','yuv420p','-threads','3',
         '-af','atrim=0:48,asetpts=PTS-STARTPTS,volume=-4dB,afade=t=in:st=0:d=0.03,afade=t=out:st=46.7:d=1.3',
         '-c:a','aac','-b:a','160k','-metadata','title=Dead Street â€” Opening Preview',
         '-metadata','artist=B-22','-metadata','comment=Godot Engine Logo copyright 2017 Andrea Calabro, CC BY 4.0 https://creativecommons.org/licenses/by/4.0/ ; logo source https://godotengine.org/press/ ; Music UI is a design preview overlay.','-movflags','+faststart','-y',str(ROOT/'Dead_Street_Opening_Preview.mp4')],'opening_export.log')
    manifest=json.loads((ROOT/'edit_manifest.json').read_text())
    manifest.update({'preview':'Dead_Street_Opening_Preview.mp4','seconds':48,'frames':1440,'timeline':TIMELINE,
        'assets':{p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in ['approved_title.png','warning_sign_bullet_holes.png','gloria_logo_original.svg','godot_logo_white.svg']},
        'gloria_source':'Owner attachment gloriasystemslogo.html, first inline SVG; original white paths preserved',
        'godot_source':'https://godotengine.org/assets/press/logo_large_monochrome_dark.svg',
        'godot_attribution':'Godot Engine logo by Andrea CalabrÃ³, CC BY 4.0; see ASSET_CREDITS.md',
        'status':'Preview for owner review; title unchanged; designed Music overlay on a still of real sandbox UI; no native menu/music controller integration'})
    (ROOT/'edit_manifest.json').write_text(json.dumps(manifest,indent=2))
    (ROOT/'timeline.json').write_text(json.dumps(TIMELINE,indent=2))
    print('48_SECOND_OPENING_RENDERED',flush=True)

if __name__=='__main__':main()
