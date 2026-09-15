from pathlib import Path
r=Path("C:\\Users\\brand\\OneDrive\\Documents\\dead-street")
s=(r/'docs/DEAD_STREET_HIVE_MIND.md').read_text(encoding='utf-8')
for line in s.splitlines():
 if line.startswith('**Active objective') or line.startswith('**Immediate next task') or line.startswith('| BUILD') or 'fourth-map' in line or 'Fourth tactical' in line:print(line)
