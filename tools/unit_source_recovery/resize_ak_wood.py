from pathlib import Path
R=Path(__file__).parent
p=R/'src/weapons/ak_rifle.svg';s=p.read_text()
old='M29 1 Q34 -1 40 1 Q42 2 41 5 Q36 8 29 7 Q27 4 29 1Z'
new='M30 1.6 Q34 .1 39.2 1.6 Q40.8 2.4 40 4.8 Q36 7.1 30 6.4 Q28.5 4 30 1.6Z'
assert old in s
s=s.replace(old,new).replace('M30 2 Q35 1 39 2','M31 2.4 Q35 1.6 38.5 2.4').replace('M30 5 Q35 6 39 4','M31 4.8 Q35 5.6 38.5 4')
p.write_text(s)
source=(R/'export_review.py').read_text().replace("for variant in manifest['variants']:","for variant in [v for v in manifest['variants'] if v.endswith('_ak_rifle')]:")
exec(compile(source,str(R/'export_review.py'),'exec'),{'__file__':str(R/'export_review.py'),'__name__':'__main__'})
