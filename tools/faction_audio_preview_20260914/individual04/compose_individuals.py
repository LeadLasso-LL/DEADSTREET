"""Individually authored faction scores. Helpers place notes; none create music."""
import json, shutil, hashlib
from pathlib import Path
import engine as E
import instruments

def notes(track, events):
    for event in events: track.n(*event)
    return track

def chords(track, events):
    for event in events: track.chord(*event)
    return track

def calle_ocho():
    s=E.Song(2,'calle_ocho','Calle Ocho','Lowrider menace / bent bass / muted guitar',70.4,4,7)
    notes(s.track('Calle heavy pocket',-12,.96,hp=29,lp=3900,room=0),[(0,36,.4,113),(1.7,36,.3,91),(3.5,36,.3,106),(4.2,36,.3,113),(6.8,36,.3,110),(8,36,.4,117),(9.7,36,.3,103),(11.8,36,.3,109),(12.2,36,.4,117),(15.5,36,.3,101),(16,36,.4,119),(17.8,36,.3,93),(19.5,36,.3,108),(20.2,36,.4,114),(23.1,36,.3,101),(24,36,.4,119),(26.7,36,.3,107)])
    rim=s.track('Calle rim and loose closed hat',0,.62,hp=160,lp=5800,room=.35,drum=True)
    for b in [1.08,3.12,5.09,7.16,9.11,11.08,13.14,15.12,17.09,19.16,21.13,23.1,25.08,27.13]:rim.n(b,37,.13,109)
    for b in [0,.67,1.25,1.75,2.6,3.7,4,4.7,5.6,6.25,6.75,7.75,8.65,9.7,10.2,10.75,11.6,12.65,13.25,13.7,14.65,15.7,16.2,16.75,17.7,18.6,19.75,20.65,21.25,21.75,22.6,23.7,24.6,25.7,26.2,26.7,27.75]:rim.n(b,42,.08,51)
    notes(s.track('Calle bass finger articulation',33,1.65,hp=30,lp=1250,drive=2.6),[(0,28,1.4,113),(1.7,40,.3,97),(2.4,39,.65,102),(3.5,35,.4,99),(4.2,28,1.8,116),(6.8,31,.6,110),(8,28,1.5,116),(9.7,40,.2,97),(10.3,38,.6,104),(11.8,35,.25,95),(12.2,27,2.4,119),(15.5,35,.35,101),(16,28,1.5,119),(17.8,40,.4,102),(18.7,39,.35,95),(19.5,35,.3,100),(20.2,28,2.1,117),(23.1,31,.45,106),(24,28,2.4,119),(26.7,28,.9,105)])
    g=s.track('Calle muted lowrider guitar',28,.98,pan=-.28,hp=165,lp=2400,room=.8,delay=.24)
    notes(g,[(.7,64,.32,89),(1.4,63,.42,83),(2.5,59,.8,101),(5.1,64,.3,87),(5.8,63,.3,81),(7.2,58,.45,90),(8.7,64,.25,86),(9.4,63,.3,80),(10.7,59,.9,99),(13.1,62,.45,91),(14.2,58,1.1,96),(17,64,.4,86),(18.2,59,.65,94),(21.1,63,.4,88),(22.1,58,.75,93),(25.1,59,.6,94),(26.2,52,1.3,99)])
    chords(s.track('Calle low electric haze',4,.41,pan=.3,hp=190,lp=1800,room=1.5),[(0,[52,55,59,65],2.8,63),(8,[52,55,59,65],2.7,65),(12,[51,54,58,64],3,68),(20,[52,55,58,64],3.2,68),(24,[52,55,59,65],3.3,65)])
    return s

def ventresca():
    s=E.Song(3,'ventresca','Ventresca Family','Back-room noir / wounded trumpet / uneven pulse',78.4,5,6)
    # An uneven five-beat stalk. Trumpet breaths define the form.
    notes(s.track('Ventresca acoustic bass',32,1.36,hp=34,lp=1400),[(0,36,2.4,111),(3.25,43,.9,99),(5,35,2.4,108),(8.5,41,.7,103),(10,32,2.6,114),(13.3,39,1,103),(15,34,2.5,112),(18.6,40,.6,97),(20,36,2.4,115),(23.4,42,.7,101),(25,31,1.6,110),(27.3,36,2.3,117)])
    chords(s.track('Ventresca black organ',16,.53,pan=-.3,hp=150,lp=2250,room=1.8),[(.1,[48,55,62],3.7,65),(5.1,[47,53,60],3.8,69),(10.1,[44,51,58],3.8,72),(15.1,[46,53,59],3.8,74),(20.1,[48,54,63],3.6,77),(25.1,[43,50,56],1.4,67),(27.4,[48,55,61],2.3,74)])
    notes(s.track('Ventresca muted trumpet statement',59,.78,pan=.17,hp=290,lp=3500,room=2),[(1.5,67,1.6,72),(3.4,66,.55,78),(6.3,63,1.5,85),(8.2,60,1.2,80),(11.4,62,2.4,87),(14.1,58,.6,70),(16.2,65,1.5,87),(18.1,63,.7,83),(19.1,59,.55,78),(21.3,60,2.2,89),(24.1,54,.6,76),(27.5,55,1.8,83)])
    kit=s.track('Ventresca brushed noir kit',0,.57,hp=45,lp=3600,room=.6,drum=True)
    for b in [0,5,10,15,20,25,27.3]:kit.n(b,35,.2,86)
    for b in [2.8,7.8,12.8,17.8,22.8,28.4]:kit.n(b,37,.16,87)
    for b in [1.1,3.25,4.1,6.1,8.5,9.2,11.1,13.3,14.3,16.1,18.6,19.4,21.1,23.4,24.2,26.1,28.1,29.3]:kit.n(b,44,.15,51)
    return s

def orlov():
    s=E.Song(5,'orlov','Orlov Bratva','Cold post-punk / driving bass / corroded guitar',102.4,4,12)
    bass=s.track('Orlov relentless picked bass',34,1.45,hp=30,lp=1950,drive=3.8)
    # Two eight-beat bass phrases developed across a 48-beat score.
    p=[30,30,42,30,30,37,30,37,30,30,42,30,33,33,32,32]
    q=[30,30,42,30,30,37,37,30,29,29,41,29,29,36,32,29]
    for start,seq in [(0,p),(8,q),(16,p),(24,[26,26,38,26,26,33,26,33,26,26,38,26,29,29,28,28]),(32,q),(40,[30,30,42,30,30,37,30,37,30,30,42,30,30,30,30,30])]:
        for i,n in enumerate(seq):bass.n(start+i*.5,n,.41,110 if i%4==0 else 96)
    g=s.track('Orlov corroded clean guitar',27,.7,pan=-.4,hp=270,lp=3100,drive=3.7,room=1.2,delay=.26)
    chords(g,[(0,[54,61,65],3.2,94),(4.5,[54,60,65],2.8,93),(8,[53,60,64],3.2,96),(12.5,[53,59,64],2.8,89),(16,[54,61,65],3.6,99),(21,[61,65,66],1.9,92),(24,[50,57,61],3.6,95),(29,[50,56,61],1.7,91),(32,[53,60,64],3.7,99),(37,[53,59,64],2,94),(40,[54,61,65],6.7,102)])
    kit=s.track('Orlov dry straight drum kit',0,.84,hp=36,lp=6300,room=.45,drum=True)
    for start in range(0,48,4):
        for b in [0,1.5,2.5]:kit.n(start+b,36,.13,109 if b==0 else 91)
        kit.n(start+2,38,.21,115)
        for b in [0,.5,1,1.5,2,2.5,3,3.5]:kit.n(start+b,42,.06,67 if b%1==0 else 48)
    for b,k in [(15.25,45),(15.75,43),(31.25,45),(31.75,41),(46.7,43),(47.2,41)]:kit.n(b,k,.2,103)
    for b in [0,16,32,40]:kit.n(b,49,.9,79)
    return s

def zangyaku():
    s=E.Song(6,'zangyaku','Zangyaku','Fractured industrial / abrupt cuts / covert tension',113.6,7,8)
    g=s.track('Zangyaku clipped physical guitar',-11,1.05,pan=-.33,hp=90,lp=3400,room=0)
    score=[(0,38,.55),(1,38,.35),(1.75,38,.23),(3.5,39,.55),(5,38,.45),(6.25,32,.25),(7,38,.8),(9,44,.35),(9.75,44,.23),(11.5,39,.75),(13.25,38,.25),(14,38,.6),(15.5,38,.25),(17,41,.45),(19.25,32,.4),(21,37,1.1),(23,37,.25),(24.5,43,.5),(26,38,.3),(28,38,.6),(29,38,.2),(29.75,38,.2),(31.5,39,.5),(33,38,.4),(34.25,32,.25),(35,38,1),(37,44,.35),(38.75,39,.25),(40.25,32,.45),(42,35,.8),(44,41,.5),(46.5,32,.4),(49,38,1.2),(51.5,38,.3),(53,38,.6),(54.5,32,.6)]
    notes(g,[(b,n,d,115) for b,n,d in score])
    notes(s.track('Zangyaku cut sub',-10,.95,hp=27,lp=680,room=0),[(b,n-12,d,107) for b,n,d in score if d>=.4])
    kit=s.track('Zangyaku broken percussion',0,.84,hp=43,lp=7900,drive=2,room=.1,drum=True)
    for b,n,d in score:kit.n(b,36,.14,115)
    for b in [2.5,6,10.5,13.5,16.5,20,24,27.5,30.5,34,38,41,45,48.5,52.5,55]:kit.n(b,40,.18,118)
    for b in [2,2.25,3,4.25,4.5,6.5,8.5,9.25,10,12,12.25,14.5,15.25,18,18.25,18.5,20.5,22.25,23.75,25.5,26.5,28.5,30,32.25,32.5,34.5,36.5,37.5,39.5,40.75,43.5,44.75,47,47.25,49.5,50.75,51,54]:kit.n(b,42,.045,60)
    pluck=s.track('Zangyaku solitary string accents',107,.45,pan=.55,hp=400,lp=4200,room=1.4,delay=.18)
    notes(pluck,[(4.4,74,.25,90),(12.2,68,.35,92),(18.3,73,.2,88),(25.1,66,.4,94),(32.5,74,.2,94),(39.8,68,.3,95),(47.4,65,.5,89),(54.8,62,.45,97)])
    return s

def bitian():
    s=E.Song(7,'bitian','Bìtiān','Nocturnal trip-hop / hollow keys / suspended threat',65.6,4,7)
    notes(s.track('Bitian staggered deep kick',-12,.83,hp=28,lp=3200,room=0),[(.5,36,.4,114),(2.75,36,.3,92),(4.75,36,.3,115),(7.5,36,.3,97),(8.5,36,.4,117),(11.25,36,.3,106),(13.5,36,.4,113),(16.5,36,.4,119),(18.75,36,.3,95),(20.75,36,.4,117),(23.5,36,.3,106),(24.5,36,.4,119),(26.75,36,.3,103)])
    kit=s.track('Bitian soft-edge heavy snare',0,.66,hp=155,lp=4200,room=1.5,drum=True)
    for b in [3,7,11,15,19,23,27]:kit.n(b,38,.2,115)
    for b in [1.25,2,3.5,5.25,6,7.75,9.25,10,11.5,13,14.25,15.75,17.25,18,19.5,21.25,22,23.75,25.25,26,27.5]:kit.n(b,44,.12,56)
    chords(s.track('Bitian hollow electric piano',4,.94,pan=-.15,hp=130,lp=2800,room=1.7,delay=.19),[(0,[51,58,61,68],2.5,84),(3.65,[58,61,68],.6,69),(5.2,[50,57,61,65],2.4,82),(9,[47,54,61,65],3,85),(13,[49,56,60,65],2,87),(16,[51,58,61,68],2.8,89),(20.2,[50,57,61,65],2.7,86),(24,[47,54,61,63],3.2,91)])
    notes(s.track('Bitian submerged bass',38,1.30,hp=27,lp=840,room=.1),[(.5,27,2.5,117),(4.75,26,2.2,114),(8.5,23,2.9,119),(12.75,25,2.1,114),(16.5,27,2.4,117),(19.5,34,.65,94),(20.75,26,2.1,116),(24.5,23,2.8,119)])
    notes(s.track('Bitian metallic afterimage',11,.42,pan=.52,hp=390,lp=2900,room=2,delay=.37),[(2.1,80,.5,79),(6.4,77,.4,85),(10.4,73,.65,86),(14.2,72,.8,80),(18.2,80,.4,85),(22.4,77,.4,86),(26,70,1.1,82)])
    return s

def sierra_roja():
    s=E.Song(8,'sierra_roja','Cártel de Sierra Roja','Grim guitar procession / low brass / cartel pressure',83.2,3,12)
    g=s.track('Sierra low steel strings',25,1.00,pan=-.32,hp=110,lp=3300,room=.55)
    # Compound guitar pulse; unhurried, downward phrases and ominous b2 tension.
    for start,root,third,fifth in [(0,45,48,52),(6,44,47,51),(12,41,44,48),(18,40,44,47),(24,45,48,52),(30,44,47,51)]:
        notes(g,[(start,root,1,109),(start+.8,fifth,.4,80),(start+1.5,third,.4,91),(start+2.3,fifth,.4,77),(start+3,root,.8,108),(start+3.75,third,.4,86),(start+4.5,fifth,.4,92),(start+5.2,third,.6,83)])
    lead=s.track('Sierra nylon reply',24,.91,pan=.30,hp=200,lp=3200,room=1)
    notes(lead,[(1.2,64,.7,101),(2.2,65,.35,87),(3.7,60,1.2,108),(6.6,63,.7,99),(7.8,59,.9,105),(9.5,56,1.6,101),(12.8,60,.8,99),(14,56,.7,106),(15.5,53,1.7,105),(18.8,59,.6,101),(19.7,56,.5,96),(21,52,2,109),(25.1,65,.55,106),(26.1,64,.9,110),(28,60,1.1,105),(31.2,59,.8,104),(33,56,.6,104),(34.1,52,1.5,111)])
    notes(s.track('Sierra low brass threat',58,.74,hp=50,lp=1900,room=.7),[(0,33,2.2,91),(6,32,2.1,93),(12,29,2.3,95),(18,28,2.3,101),(24,33,2.3,100),(30,32,2,99),(33,28,2.6,108)])
    kit=s.track('Sierra floor drum and dry rattle',0,.62,hp=38,lp=4400,room=.45,drum=True)
    for b in [0,3,6,9,12,15,18,21,24,27,30,33]:kit.n(b,41,.35,108)
    for b in [2,5,8,11,14,17,20,23,26,29,32,35]:kit.n(b,37,.16,91)
    for b in [1.5,4.5,7.5,10.5,13.5,16.5,19.5,22.5,25.5,28.5,31.5,34.5]:kit.n(b,69,.19,49)
    return s

def mcallister():
    s=E.Song(9,'mcallister','McAllister Holdings, Inc.','Railroad wealth / baritone blues / cold control',80,4,8)
    g=s.track('McAllister low clean blues',27,1.1,pan=-.32,hp=75,lp=2350,drive=2.8,room=.7)
    # Railroad rhythm in the accompaniment; lead takes slow, irregular breaths.
    notes(g,[(0,40,1.6,114),(2,43,.45,97),(2.7,46,.6,106),(4,45,1.7,111),(6.4,43,.65,101),(8,40,1.5,114),(10.4,47,.4,107),(11,46,.6,103),(12.2,43,2.1,110),(15,40,.6,109),(16,38,1.6,115),(18.2,41,.7,101),(19.2,44,.5,107),(20,40,2.3,117),(23,43,.6,108),(24,47,1.8,118),(26.3,46,.5,109),(27,43,.6,109),(28,40,3.4,121)])
    p=s.track('McAllister cold piano',0,.68,pan=.29,hp=140,lp=2850,room=1.3)
    chords(p,[(.3,[52,58,62],1.2,85),(3.4,[55,58,64],.55,77),(5,[57,60,64],1.6,91),(8.3,[52,58,62],1.4,89),(13,[55,58,62],1.7,94),(16.3,[50,56,60],1.5,95),(20.3,[52,58,62],2,93),(24.3,[59,62,65],1.8,99),(28.3,[52,58,62],2.8,94)])
    bass=s.track('McAllister rail bass',34,1.35,hp=29,lp=1500,drive=1.8)
    for st,n in [(0,28),(4,33),(8,28),(12,31),(16,26),(20,28),(24,35),(28,28)]:
        notes(bass,[(st,n,.75,109),(st+1.5,n,.6,94),(st+3,n,.7,105)])
    kit=s.track('McAllister lurching rail kit',0,.75,hp=35,lp=4800,room=.55,drum=True)
    for st in range(0,32,4):
        notes(kit,[(st,36,.2,111),(st+.25,44,.1,58),(st+1.5,36,.2,91),(st+1.75,44,.1,62),(st+2.8,37,.18,108),(st+3,36,.2,102),(st+3.25,44,.1,57)])
    for b in [7.6,15.65,23.55,31.5]:kit.n(b,45,.25,94)
    return s

def mercer44():
    s=E.Song(10,'mercer44','Mercer 44’s','United street weight / interlocking bass / hostile brass',68.8,4,7)
    # Two bass voices answer each other; they converge in the final section.
    notes(s.track('M44 sustained sub voice',-10,1.35,hp=25,lp=1100,room=0),[(0,24,1.4,119),(3.25,24,.5,103),(5,31,.8,114),(8,24,1.3,121),(11,27,.7,110),(13.25,24,.9,116),(16,22,1.7,120),(19.5,29,.8,110),(21,24,1.4,119),(24,24,1.2,123),(26,24,1.3,117)])
    notes(s.track('M44 gritty upper bass response',34,.81,pan=.13,hp=80,lp=1900,drive=4),[(1.75,48,.3,114),(2.4,43,.4,107),(4,46,.55,111),(6.3,43,.4,112),(7.2,36,.4,109),(9.75,48,.35,117),(10.4,43,.25,105),(12,39,.55,110),(14.7,43,.4,112),(15.4,36,.3,106),(18.2,46,.4,118),(18.9,41,.35,111),(20.5,34,.35,109),(22.8,43,.35,114),(23.5,36,.35,110),(24,36,1.1,121),(26,36,1.2,117)])
    chords(s.track('M44 black brass interruptions',61,.64,pan=-.17,hp=130,lp=2600,room=.8),[(.1,[48,51,58],.6,97),(4,[46,49,56],.5,95),(7.25,[48,51,58],.4,95),(9.5,[48,51,58],.7,102),(12,[39,46,51],.8,106),(16,[46,49,56],1.1,110),(20,[48,51,57],.6,107),(24,[36,43,48,51],2.1,111),(26.5,[36,43,48,50],1.2,106)])
    k=s.track('M44 heavy kick',-12,1.1,hp=26,lp=4100,room=0)
    for b in [0,1.75,3.25,4,5,7.2,8,9.75,11,12,13.25,15.4,16,18.2,19.5,21,22.8,24,25.5,26,27.4]:k.n(b,36,.36,116)
    kit=s.track('M44 hard snare and sparse hats',0,.68,hp=160,lp=6500,room=.7,drum=True)
    for b in [1.5,5.5,9.5,13.5,17.5,21.5,25.5]:kit.n(b,40,.2,117)
    for b in [0.75,2.5,3,4.75,6.5,7.75,8.75,10.5,11.75,12.75,14.5,15.75,16.75,18.5,19,20.75,22.5,23.75,24.75,26.5,27,27.5]:kit.n(b,42,.06,63)
    return s

def wm_corp():
    s=E.Song(11,'wm_corp','Whittaker–McAllister Corporation','Oil and steel / Southern industrial rock / tightening power',81.6,6,6)
    riff=[(0,35,1.3),(2,35,.5),(3.5,38,.7),(5,40,.55),(6,35,1.8),(9,33,.8),(10.5,35,.8),(12,31,1.4),(14,31,.45),(15.5,34,.8),(17,35,.6),(18,33,1.8),(21,36,.8),(22.5,35,.75),(24,35,1.8),(27,38,.9),(28.5,40,.75),(30,35,1.1),(32,35,.7),(33.5,35,2.1)]
    for pan in [-.57,.57]:
        notes(s.track('WM power guitar '+str(pan),-11,.88,pan=pan,hp=85,lp=3000,room=0),[(b+(pan>0)*.017,n,d,111) for b,n,d in riff])
    notes(s.track('WM solid bass',33,1.14,hp=29,lp=1250,drive=2.5),[(b,n-12,d+.1,113) for b,n,d in riff])
    chords(s.track('WM low Hammond authority',16,.43,pan=.12,hp=110,lp=1900,room=.8),[(0,[47,50,54],5.2,80),(6,[47,50,53],5.3,85),(12,[43,46,50],5.2,88),(18,[45,48,52],5.2,89),(24,[47,50,54],5.2,94),(30,[47,50,53],5.5,96)])
    kit=s.track('WM industrial six-beat drums',0,.88,hp=38,lp=5700,room=.65,drum=True)
    for st in [0,6,12,18,24,30]:
        notes(kit,[(st,36,.2,121),(st+.3,41,.3,86),(st+2,36,.2,111),(st+2.3,41,.3,91),(st+3,38,.2,117),(st+4.5,36,.2,115),(st+5.3,43,.3,100)])
        for b in [.75,1.5,2.25,3.75,4.5,5.25]:kit.n(st+b,51,.23,63)
    for b in [0,12,24,30]:kit.n(b,49,1.2,89)
    return s

def union_sur():
    s=E.Song(12,'union_sur','La Unión del Sur','South-side consolidation / hard drums / guitar and brass',75.2,4,8)
    # Street percussion and cartel strings enter separately and lock together late.
    g=s.track('Union descending nylon figure',24,.98,pan=-.43,hp=170,lp=3000,room=.7)
    notes(g,[(0,62,.45,113),(.75,57,.4,96),(1.5,53,.7,107),(3,56,.5,98),(4.5,57,.5,107),(5.5,53,.7,104),(7,50,.7,111),(8,61,.5,115),(9,56,.4,99),(10.5,52,.6,108),(12,55,.55,102),(13.5,56,.45,110),(15,49,.7,115),(16,62,.5,116),(16.75,57,.4,99),(17.5,53,.7,111),(19,56,.5,104),(20,61,.5,117),(21,56,.4,99),(22.5,52,.7,111),(24,62,.7,119),(25.5,57,.5,108),(27,53,.7,114),(28,61,.7,120),(29.5,56,.6,110),(31,49,.8,119)])
    brass=s.track('Union brass weight',58,.8,pan=.12,hp=52,lp=1900,room=.7)
    notes(brass,[(4,38,2.1,91),(8,37,2.3,95),(12,37,1.4,89),(16,38,2.3,104),(20,37,2.2,106),(24,38,2.6,111),(28,37,3.2,113)])
    bass=s.track('Union tight synth bass',38,1.22,hp=28,lp=1400,drive=1.6)
    notes(bass,[(0,26,1.2,112),(2.5,26,.6,103),(4,26,1.1,112),(6.5,33,.7,105),(8,25,1.3,115),(11,32,.7,108),(12,25,1.2,115),(14.5,25,.7,105),(16,26,1.5,119),(18.5,33,.8,109),(20,25,1.5,119),(22.5,32,.8,109),(24,26,1.5,121),(26.5,26,.8,112),(28,25,1.7,121),(30.5,25,1,115)])
    kit=s.track('Union dry collective drums',0,.84,hp=39,lp=6000,room=.22,drum=True)
    for b in [0,2.5,4,6.5,8,11,12,14.5,16,18.5,20,22.5,24,26.5,28,30.5]:kit.n(b,36,.18,118)
    for b in [2,6,10,14,18,22,26,30]:kit.n(b,38,.2,115)
    for b in [.75,1.5,3.25,4.75,5.5,7.25,8.75,9.5,11.75,12.75,13.5,15.25,16.75,17.5,19.25,20.75,21.5,23.25,24.75,25.5,27.25,28.75,29.5,31.25]:kit.n(b,64,.14,83)
    for b in [3.5,7.5,11.5,15.5,19.5,23.5,27.5,31.5]:kit.n(b,60,.15,75)
    return s

def lombardia():
    s=E.Song(13,'lombardia','L’Ordine di Lombardia','Combined underworld power / low orchestra / iron ceremony',67.2,5,6)
    # Broad orchestral pillars, accumulating voices rather than piano melody.
    chords(s.track('Lombardia low brass pillars',61,.83,pan=-.18,hp=70,lp=2500,room=1.7),[(0,[36,43,48],2.8,101),(5,[34,41,46],3.5,104),(10,[31,38,43],3.2,109),(15,[33,40,45],3.9,112),(20,[36,42,48],4.2,115),(25,[31,38,43],1.4,105),(27,[36,43,47],2.8,119)])
    chords(s.track('Lombardia gathered strings',48,.73,pan=.28,hp=165,lp=3100,room=1.8),[(1.2,[55,60,62],3.2,77),(6,[53,58,61],3.2,83),(10.7,[50,55,59],3.5,90),(15.6,[52,57,60],3.7,95),(20.6,[54,60,63],3.6,102),(25.5,[50,55,58],1.1,92),(27,[55,59,60,66],2.8,108)])
    chords(s.track('Lombardia organ foundation',19,.39,pan=-.1,hp=60,lp=1850,room=1.2),[(0,[36,48],4.5,82),(5,[34,46],4.5,86),(10,[31,43],4.5,90),(15,[33,45],4.5,93),(20,[36,48],4.5,97),(25,[31,43],1.5,88),(27,[36,48],2.8,101)])
    notes(s.track('Lombardia bowed bass counterweight',43,.91,hp=35,lp=1400,room=1),[(0,36,3.2,103),(4.1,34,.7,99),(5,34,3.1,105),(9.1,31,.6,103),(10,31,3.4,108),(14.3,33,.5,104),(15,33,3.7,111),(19.5,36,.3,104),(20,36,4.4,113),(25,31,1.4,103),(27,36,2.8,118)])
    notes(s.track('Lombardia timpani',47,.78,hp=35,lp=2300,room=1.5),[(0,36,.7,119),(4.3,34,.5,102),(5,34,.7,115),(9.4,31,.4,109),(10,31,.8,121),(14.6,33,.4,106),(15,33,.9,123),(19.6,36,.3,106),(20,36,1,124),(24.5,31,.4,100),(25,31,.5,112),(26.2,36,.3,94),(26.5,36,.3,104),(26.8,36,.3,114),(27,36,1.6,126)])
    return s

def sand_raiders():
    s=E.Song(14,'sand_raiders','Raiders of the Sand','Ragged massed drums / scrap metal / scorched feedback',60.8,4,6)
    kit=s.track('Sand loose war drums',0,1.15,hp=35,lp=4800,drive=2.7,room=1.3,drum=True)
    # A ragged crowd of impacts, no backbeat or pitched bass loop.
    notes(kit,[(0,41,.5,124),(.15,45,.35,95),(.9,43,.4,109),(1.65,41,.55,118),(3.2,45,.4,101),(3.9,41,.5,121),(4.15,43,.4,93),(5.6,41,.6,120),(6.3,45,.4,106),(7.5,43,.4,115),(7.8,41,.5,123),(9.4,41,.5,121),(9.6,45,.3,91),(10.2,43,.4,110),(11.65,41,.6,124),(13.3,45,.3,107),(14.7,41,.6,126),(15,43,.4,95),(15.65,45,.3,109),(16.2,41,.5,122),(18,43,.4,117),(18.4,41,.6,126),(19.1,45,.3,109),(20.5,41,.5,126),(20.7,43,.3,98),(21.4,45,.4,113),(22.5,41,.6,127),(23.3,43,.4,113)])
    notes(s.track('Sand hanging scrap',-14,.76,pan=.41,hp=240,lp=3200,room=0),[(.5,47,1.7,99),(4.5,53,1.3,112),(8.2,44,2.1,109),(12.3,50,1.7,116),(16.8,42,1.5,116),(20.3,49,2.6,120)])
    notes(s.track('Sand abrasive drag',-15,.68,pan=-.31,hp=160,lp=1700,room=0),[(1.7,30,1.4,97),(6.2,30,1.3,103),(10.6,30,1.6,111),(15.1,30,1.7,118),(21.2,30,2.3,121)])
    notes(s.track('Sand damaged low guitar',-11,.72,pan=-.2,hp=50,lp=2000,room=0),[(0,28,2.4,117),(5.55,34,1.6,108),(9.3,27,2.2,122),(14.65,33,1.3,113),(18.35,26,1.7,123),(22.4,28,1.5,125)])
    return s

def saffar():
    s=E.Song(15,'saffar','Majmu’at al-Saffar','Waterfront secrecy / coiled strings / concealed pressure',72,7,4)
    # A long, withheld plucked phrase; seven-beat spans never become a dance groove.
    p=s.track('Saffar close nylon strings',24,1.10,pan=-.31,hp=130,lp=3000,room=1.25)
    notes(p,[(0,50,1.1,105),(1.45,57,.7,92),(2.75,58,.55,101),(4.2,53,1.3,106),(6.1,51,.7,100),(7.35,50,1.4,110),(9.4,56,.6,100),(10.5,57,1.1,109),(12.5,53,.75,106),(14,49,1.4,113),(16.15,56,.7,104),(17.4,55,.7,109),(19.3,51,1.2,113),(21.1,50,1.3,118),(23.2,58,.6,110),(24.25,57,.8,114),(26.1,50,1.7,120)])
    notes(s.track('Saffar dulcimer distant response',15,.45,pan=.43,hp=360,lp=2900,room=2.1,delay=.26),[(3.6,74,.5,75),(6.6,69,.4,79),(11.8,73,.5,78),(15.4,68,.5,82),(20,67,.7,85),(25.3,65,.7,88)])
    notes(s.track('Saffar dock resonance',-14,.32,pan=.51,hp=220,lp=1500,room=0),[(.2,38,2,88),(7.8,40,2.1,93),(14.2,37,2.3,100),(21.2,38,2.7,106)])
    bass=s.track('Saffar concealed low pulse',38,1.03,hp=27,lp=800,room=.15)
    notes(bass,[(4.2,26,2.4,88),(10.5,25,2.3,96),(14,25,1.5,103),(17.4,25,1.3,108),(19.3,25,1.1,110),(21.1,26,1.4,114),(23.2,26,.8,110),(24.6,26,1,113),(26.1,26,1.7,119)])
    hand=s.track('Saffar restrained hand percussion',0,.59,hp=75,lp=3900,room=.7,drum=True)
    notes(hand,[(1.1,64,.2,69),(3.7,62,.15,76),(5.4,64,.25,82),(8.6,64,.22,77),(11.6,62,.16,84),(13.1,64,.22,92),(14,36,.2,97),(15.2,64,.22,87),(16.5,62,.16,91),(17.4,36,.2,99),(18.3,64,.22,95),(19.3,36,.2,105),(20.3,62,.15,94),(21.1,36,.22,110),(22.2,64,.22,99),(23.2,36,.2,108),(24.1,62,.16,99),(24.6,36,.2,111),(25.3,64,.22,106),(26.1,36,.25,117),(27,62,.2,100)])
    return s

def kurgan():
    s=E.Song(16,'kurgan','The Kurgan Group','Mercenary discipline / dry drum drill / blunt machine weight',76.8,4,8)
    kit=s.track('Kurgan measured drill',0,1.08,hp=35,lp=5700,room=.13,drum=True)
    for st in [0,8,16,24]:
        notes(kit,[(st,36,.18,124),(st+.5,41,.25,107),(st+1.5,38,.16,119),(st+2.75,36,.18,116),(st+3,45,.23,105),(st+4,36,.18,123),(st+4.5,41,.25,109),(st+5.5,38,.16,122),(st+6.25,38,.08,66),(st+6.5,38,.08,83),(st+6.75,38,.08,101),(st+7.25,41,.3,116)])
    notes(s.track('Kurgan machine steel',-14,.46,pan=.15,hp=330,lp=1800,room=0),[(0,45,1.2,101),(4,45,.9,103),(8,43,1.1,106),(12,43,.9,107),(16,42,1.1,111),(20,42,.9,113),(24,45,1.1,116),(28,45,1.4,119)])
    brass=s.track('Kurgan low brass orders',61,.79,hp=70,lp=2400,room=.35)
    chords(brass,[(.05,[38,45],1.1,110),(2.8,[38,44],.6,107),(4.05,[38,45],1.1,113),(7.25,[36,43],.5,105),(8.05,[36,43],1.1,114),(10.8,[36,42],.6,110),(12.05,[36,43],1.1,116),(15.25,[35,42],.5,108),(16.05,[35,42],1.1,117),(18.8,[35,41],.6,113),(20.05,[35,42],1.1,119),(23.25,[38,45],.5,111),(24.05,[38,45],1.1,121),(26.8,[38,44],.6,115),(28.05,[38,45],2.6,123)])
    notes(s.track('Kurgan clipped analog bass',38,1.05,hp=28,lp=1250,drive=2),[(0,26,.7,118),(.5,26,.5,110),(2.75,26,.6,111),(4,26,.7,120),(4.5,26,.5,112),(7.25,24,.45,110),(8,24,.7,121),(8.5,24,.5,111),(10.75,24,.6,115),(12,24,.7,122),(12.5,24,.5,112),(15.25,23,.45,111),(16,23,.7,123),(16.5,23,.5,114),(18.75,23,.6,115),(20,23,.7,124),(20.5,23,.5,115),(23.25,26,.45,113),(24,26,.7,124),(24.5,26,.5,117),(26.75,26,.6,118),(28,26,2.9,125)])
    return s

def ashford_crane():
    s=E.Song(17,'ashford_crane','The Ashford-Crane Collective','Masked chamber horror / exchanged voices / broken cadences',76.8,7,5)
    # Unequal breaths and changing lead voices; no waltz, kit or bass floor.
    pizz=s.track('Ashford plucked deception',45,.92,pan=-.40,hp=100,lp=2600,room=1.1)
    notes(pizz,[(0,48,.6,104),(.8,55,.45,92),(2.1,51,.6,99),(3.3,56,.4,96),(5.2,47,.7,106),(7.5,50,.6,104),(8.4,57,.4,94),(10.2,53,.6,105),(11.1,58,.4,96),(13,49,.7,111),(15.5,55,.4,95),(17.3,51,.5,106),(19.6,47,.8,113),(22.4,57,.45,99),(24.1,53,.65,109),(26.3,49,.9,116),(28,48,.8,120),(30.7,51,.6,109),(33.1,47,1.3,121)])
    cel=s.track('Ashford dark celeste mask',8,.64,pan=.36,hp=250,lp=2700,room=1.7,delay=.15)
    notes(cel,[(1.4,72,.55,82),(3.9,75,.4,86),(4.7,71,.65,80),(9.1,74,.45,87),(11.8,77,.5,91),(12.5,73,.4,82),(14,60,.7,106),(14.8,67,.4,91),(16.1,63,.6,101),(17.3,68,.4,98),(19.2,59,.7,108),(21,62,.7,110),(21.8,69,.4,95),(23.1,65,.6,105),(24.3,70,.4,101),(26.2,61,.7,115),(29.4,72,.45,94),(31.9,75,.6,98),(33.1,71,1.1,105)])
    chords(s.track('Ashford hidden bowed clusters',48,.39,pan=.12,hp=180,lp=2200,room=1.9),[(4,[47,54,60],2,69),(11,[49,56,62],2.1,73),(18,[47,53,60],2.5,80),(25,[49,55,62],2.4,85),(31,[47,54,60,61],3.5,91)])
    notes(s.track('Ashford bass cello reveals',42,.91,hp=45,lp=2100,room=1.3),[(0,36,2.5,95),(5.2,35,1.3,99),(7.5,38,2.1,100),(13,37,1.1,104),(14,36,2.6,106),(19.2,35,1.3,109),(21,38,2.7,113),(26.2,37,1.2,114),(28,36,2.4,117),(33.1,35,1.7,118)])
    return s

NEW=[calle_ocho,ventresca,orlov,zangyaku,bitian,sierra_roja,mcallister,mercer44,wm_corp,union_sur,lombardia,sand_raiders,saffar,kurgan,ashford_crane]

def assemble():
    source=E.ROOT.parent/'contrast03'
    preserved=[]
    for old in json.loads((source/'manifest.json').read_text()):
        new_number={'eastex':1,'ravicci':4,'blacktop':18}[old['id']]
        row=dict(old); row['number']=new_number
        row['status']='DIRECTION LIKED — PRESERVED CONTRAST03 AUDIO; FINAL APPROVAL PENDING'
        row['origin']='contrast03 byte-identical anchor'
        for ext in ['mp3','wav']:
            src=source/'previews'/old[ext]
            digest=hashlib.sha256(src.read_bytes()).hexdigest()
            if ext=='mp3':assert digest==old['sha256']
            row[ext]=f'{new_number:02d}_{row["id"]}_i4.{ext}'
            dst=E.OUT/row[ext];shutil.copyfile(src,dst)
            assert hashlib.sha256(dst.read_bytes()).hexdigest()==digest
            preserved.append({'id':row['id'],'format':ext,'sha256':digest,'source':str(src.relative_to(E.ROOT.parent)),'copy':row[ext]})
        (E.OUT/f'{new_number:02d}_{row["id"]}_i4.json').write_text(json.dumps(row,ensure_ascii=False,indent=2))
    rows=[json.loads(p.read_text()) for p in sorted(E.OUT.glob('*_i4.json'))]
    assert len(rows)==18 and len({r['id'] for r in rows})==18
    assert [r['number'] for r in rows]==list(range(1,19))
    for r in rows:
        r.setdefault('origin','individual04 new composition')
        assert hashlib.sha256((E.OUT/r['mp3']).read_bytes()).hexdigest()==r['sha256']
    (E.ROOT/'manifest.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2))
    (E.ROOT/'preserved_anchors.json').write_text(json.dumps(preserved,indent=2))
    print('18-track manifest ready; all six preserved anchor audio hashes match.',flush=True)

if __name__=='__main__':
    import sys
    if '--assemble-only' not in sys.argv:
        for fn in NEW:E.render(fn())
    assemble()
