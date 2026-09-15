from pathlib import Path
import json
r=Path("C:\\Users\\brand\\OneDrive\\Documents\\dead-street")
for p in (r/'docs').glob('*STANDARD*'):print(p.name)
for p in Path(r'C:\Users\brand\OneDrive\Desktop').glob('*Sandbox*'):
 print(str(p));print(p.read_text(errors='replace')[:10000] if p.suffix in ['.cmd','.bat','.ps1'] else '')
for p in Path(r'C:\Users\brand\Desktop').glob('*Sandbox*'):
 print(str(p));print(p.read_text(errors='replace')[:10000] if p.suffix in ['.cmd','.bat','.ps1'] else '')
