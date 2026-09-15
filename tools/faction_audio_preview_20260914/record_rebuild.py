from pathlib import Path
import re
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
p=r/'docs/DEAD_STREET_HIVE_MIND.md';s=p.read_text(encoding='utf-8')
s=re.sub(r'\*\*Active objective:\*\* All 18 remaining faction audio audition sketches[^\n]*','**Active objective:** Owner REJECTED all 18 audition-01 music tracks for upbeat/happy energy. BUILD is remaking every composition with dark, threatening, heavy DEAD STREET energy at approximately 80% of prior BPM. Preview-only scope tools/faction_audio_preview_20260914/rebuild02/; see journal faction-audio-rebuild-01. Existing game audio/vocals decision preserved.',s)
s=re.sub(r'\*\*Immediate next task:\*\* Brandon hears the labeled all-18 audition reel[^\n]*','**Immediate next task:** Recompose and deliver all 18 dark rebuild previews; a mere playback slowdown is insufficient. Owner must hear revision 2 before approval. Preserve rejected v1, staged tutorial records and all concurrent work; do not rerun blocked source-publication script.',s)
p.write_text(s,encoding='utf-8')
print('Recorded rejection and full remake as active objective')
