from pathlib import Path
p=Path(r'C:\Users\brand\OneDrive\Documents\dead-street\docs\DEAD_STREET_HIVE_MIND.md')
s=p.read_text(encoding='utf-8')
old='**Active objective:** Remaining faction audio directions proposed for owner review: 18 new identities across the 23 playable factions. See docs/FACTION_AUDIO_DIRECTION_2026-09-14.md and journal faction-audio-plan-01. Pistol-card repair remains published/validated; vocals remain parked.'
new='**Active objective:** Owner authorized listening previews for all 18 remaining faction audio identities, with approval only after hearing them. BUILD owns tools/faction_audio_preview_20260914/ and scoped audio records. No runtime integration or sound acceptance yet. See docs/FACTION_AUDIO_DIRECTION_2026-09-14.md and journal faction-audio-preview-01. Existing audio, accepted battle and parked vocals are preserved.'
assert old in s
s=s.replace(old,new)
old='**Immediate next task:** Incorporate owner feedback on the 18 faction audio vibes, then plan samples and consistent faction bindings across maps. No new audio has been generated or installed. Preserve existing tested sounds, parked vocals, accepted battle and other chats\' work.'
new='**Immediate next task:** Produce all 18 private instrumental sketches, validate rendered audio and deliver a labeled audition reel plus individual previews. Owner will hear them before approving. Game integration and map-wide bindings remain held; preserve active tutorial/title scopes and existing tested sounds.'
assert old in s
p.write_text(s.replace(old,new),encoding='utf-8')
print('Saved audio preview coordination')
