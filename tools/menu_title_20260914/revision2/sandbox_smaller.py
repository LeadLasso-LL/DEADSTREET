"""Design-preview overlay on the real sandbox recording; not runtime UI code."""
import math, subprocess
from PIL import Image, ImageDraw, ImageFont
from compose_revision2 import ROOT
from pathlib import Path

def run(args,log):
    import subprocess
    result=subprocess.run(args[:1]+['-nostdin','-xerror']+args[1:],capture_output=True)
    (ROOT/log).write_bytes(result.stderr)
    if result.returncode:raise RuntimeError(result.stderr.decode(errors='replace'))
    return result

SOURCE='/workspace/scratch/3ca0ac6a33c3/sandbox_ui_review/Dead_Street_Bridge_5v5_Sandbox_UI_Review.mp4'
if not Path(SOURCE).exists():
    SOURCE=str(ROOT.parents[1]/'sandbox_ui_review_20260914/Dead_Street_Bridge_5v5_Sandbox_UI_Review.mp4')
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
def ease(x):
    x=max(0,min(1,x));return x*x*(3-2*x)

def render():
    target=ROOT/'music_overlay.mkv'
    err=open(ROOT/'music_overlay.log','wb')
    p=subprocess.Popen(['ffmpeg','-v','warning','-nostdin','-xerror','-f','rawvideo','-pixel_format','rgba',
       '-video_size','1280x720','-framerate','30','-i','-','-frames:v','360','-an',
       '-c:v','ffv1','-pix_fmt','bgra','-y',str(target)],stdin=subprocess.PIPE,stderr=err)
    fonts={n:ImageFont.truetype(FONT,n) for n in [11,12,13,14,15,16,18]}
    bold={n:ImageFont.truetype(BOLD,n) for n in [14,16,20,22]}
    for n in range(360):
        t=n/30;im=Image.new('RGBA',(1280,720));d=ImageDraw.Draw(im)
        def text(x,y,s,size=14,color=(236,238,235,255),heavy=False):
            d.text((x,y),s,font=bold[size] if heavy else fonts[size],fill=color)
        def box(rect,fill=(12,17,20,250),line=(135,145,147,255)):
            d.rectangle(rect,fill=fill,outline=line,width=1)
        # A single moving surface contracts and settles lower into its Music dock.
        entering=ease(t/.35);collapse=ease((t-3)/.75)
        x=int(934+collapse*180+(1-entering)*350);y=int(551+collapse*113)
        w=int(318-collapse*180);h=int(104-collapse*64)
        box((x,y,x+w,y+h))
        if collapse<.55:
            text(x+16,y+12,'NOW PLAYING',11,(155,165,169,255))
            text(x+16,y+32,'Dead Street',20,heavy=True)
            text(x+16,y+65,'B-22',14,(191,198,197,255))
            for k in range(4):
                bh=4+int(13*abs(math.sin(t*5+k*.85)))
                d.rectangle((x+w-40+k*5,y+55-bh,x+w-38+k*5,y+55),fill=(210,216,213,255))
        else:
            for k in range(3):
                bh=3+int(10*abs(math.sin(t*5+k*.85)))
                d.rectangle((x+14+k*5,y+26-bh,x+16+k*5,y+26),fill=(210,216,213,255))
            text(x+43,y+10,'Music',16,heavy=True)
            d.line((x+w-20,y+18,x+w-16,y+22,x+w-12,y+18),fill=(210,216,213,255),width=1)
        # Preview pointer opens Music; only the supplied real track is listed.
        if 5.0<=t<6.1:
            progress=ease((t-5)/.8);cx=int(1255-67*progress);cy=int(611+75*progress)
            d.polygon([(cx,cy),(cx,cy+20),(cx+5,cy+15),(cx+9,cy+23),(cx+13,cy+21),(cx+8,cy+13),(cx+17,cy+13)],fill='white',outline='black')
            if 5.8<t<6.05:d.ellipse((cx-8,cy-8,cx+8,cy+8),outline=(234,239,238,180),width=1)
        if t>=6:
            py=int(365+(1-ease((t-6)/.3))*30);px=932;pw=320
            box((px,py,px+pw,651))
            text(px+18,py+16,'Music',20,heavy=True);text(px+pw-30,py+19,'×',18)
            d.line((px+16,py+54,px+pw-16,py+54),fill=(66,76,80,255))
            text(px+18,py+68,'NOW PLAYING',11,(159,170,175,255))
            text(px+18,py+87,'Dead Street',20,heavy=True);text(px+18,py+115,'B-22',14,(192,199,201,255))
            elapsed=45+int(t);text(px+18,py+142,f'0:{elapsed:02d}',11,(157,169,173,255));text(px+pw-47,py+142,'2:35',11,(157,169,173,255))
            d.rectangle((px+57,py+147,px+259,py+149),fill=(58,69,73,255))
            d.rectangle((px+57,py+147,px+57+int(202*elapsed/155.3),py+149),fill=(198,207,206,255))
            text(px+18,py+177,'SHUFFLE ORDER',11,(157,169,173,255));text(px+pw-60,py+177,'1 track',11,(157,169,173,255))
            box((px+16,py+202,px+pw-16,py+240),(34,44,47,255),(65,80,83,255))
            d.rectangle((px+29,py+214,px+41,py+226),outline=(212,220,217,255),width=1)
            d.line((px+31,py+220,px+34,py+223,px+39,py+216),fill='white',width=1)
            text(px+53,py+212,'Dead Street — B-22',14)
            # One catalogue track means no other next track is available yet.
            text(px+18,py+253,'M  Playlist',11,(153,168,173,255));text(px+155,py+253,'N  Next track',11,(101,114,119,255))
        if n in [30,90,108,135,205,290]: im.save(ROOT/'qa'/f'music_overlay_{n}.png')
        # Reduce the whole Music treatment 12% about its bottom-right anchor.
        small=im.resize((1126,634),Image.Resampling.LANCZOS)
        reduced=Image.new('RGBA',(1280,720));reduced.paste(small,(150,84))
        p.stdin.write(reduced.tobytes())
    p.stdin.close();assert p.wait()==0;err.close()
    # Preserve the existing sandbox proportions and layout in the review.
    run(['ffmpeg','-v','warning','-ss','3','-i',SOURCE,'-frames:v','1','-vf',
         'scale=-2:720:flags=lanczos,pad=1280:720:(ow-iw)/2:0:color=0x10191e','-y',str(ROOT/'sandbox_backdrop.png')],'sandbox_backdrop.log')
    run(['ffmpeg','-v','warning','-loop','1','-framerate','30','-i',str(ROOT/'sandbox_backdrop.png'),
         '-i',str(target),'-filter_complex','[0:v][1:v]overlay=0:0:shortest=1,fade=t=in:st=0:d=0.25,fade=t=out:st=10.7:d=1.3,format=yuv420p[v]',
         '-map','[v]','-frames:v','360','-an','-c:v','libx264','-crf','18','-preset','fast','-threads','2','-y',str(ROOT/'sandbox_smaller.mkv')],'sandbox_handoff.log')
    from compose_revision2 import frames
    frames(ROOT/'sandbox_smaller.mkv',360)
    print('SANDBOX_SMALLER_READY',flush=True)

if __name__=='__main__':render()
