from pathlib import Path
R=Path(__file__).parent
p=R/'src/gait.py';s=p.read_text().replace('return base-1.4*','return base+2.0-1.1*').replace('lift=15*','lift=11*');p.write_text(s)
print('Refined hip height and recovery lift')
