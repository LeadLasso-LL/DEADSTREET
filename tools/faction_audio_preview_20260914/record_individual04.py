from pathlib import Path
import re
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
p=r/'docs/DEAD_STREET_HIVE_MIND.md'
s=p.read_text(encoding='utf-8')
s=re.sub(r'\*\*Active objective:\*\*[^\n]*','**Active objective:** Owner accepted contrast03 musical direction. Preserve Eastex, Ravicci and Blacktop audio; compose the other 15 individually from faction backgrounds. New scope tools/faction_audio_preview_20260914/individual04. No runtime integration. See journal faction-audio-individual-01.',s,count=1)
s=re.sub(r'\*\*Immediate next task:\*\*[^\n]*','**Immediate next task:** Complete 15 distinct dark faction compositions and deliver all 18 for owner listening. No common backing/riff/drum templates. Read current faction glossary plus original faction sheets; preserve concurrent menu/glossary work and five existing audio identities.',s,count=1)
p.write_text(s,encoding='utf-8')
p=r/'docs/FACTION_AUDIO_DIRECTION_2026-09-14.md'
s=p.read_text(encoding='utf-8').replace('CONTRAST03 three independent prototypes saved; owner listening pending.','CONTRAST03 approach accepted; INDIVIDUAL04 remaining 15 authorized from faction backgrounds.')
s+='\n\n## Current expansion / individual04\n\nOwner likes the three contrasting pieces and authorized extending that direction to all remaining factions, heavily considering background and description. Preserve those three exact audio files. Individually compose the other 15; prepare a full 18-track audition. No new runtime audio or vocals. See journal 20260914-faction-audio-individual-01. Prior instruction to wait before expanding is superseded.\n'
p.write_text(s,encoding='utf-8')
print('Recorded current owner direction and active scope.')
