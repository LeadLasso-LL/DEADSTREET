from pathlib import Path
import subprocess,json,zipfile,io,base64
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/whittaker_estate/resume_20260914';o.mkdir(exist_ok=True)
files=['gameplay/tactical_battle_view.gd','gameplay/tactical_actor_presenter.gd','gameplay/tactical_battle_presentation.gd','gameplay/tactical_battle_outro.gd','gameplay/tactical_battle_audio.gd','gameplay/estate_architecture.gd','gameplay/whittaker_estate_art.gd','battle/geometry/whittaker_estate_catalog.gd','tools/tactical_controls/estate_geometry.gd','tools/tactical_controls/estate_record.gd','tools/whittaker_estate/record_worker.py','tools/whittaker_estate/encode.py','tools/tactical_controls/estate_preview.gd','gameplay/estate_battle_setup.gd','gameplay/tactical_convoy_audio.gd','tools/tactical_controls/estate_director.gd']
files += [str(p.relative_to(r)).replace('\\','/') for p in (r/'gameplay').glob('*hud*.gd')]
buf=io.BytesIO()
with zipfile.ZipFile(buf,'w',zipfile.ZIP_DEFLATED) as z:
 for f in files:
  if (r/f).exists():z.write(r/f,f)
(o/'inherited_sources.zip').write_bytes(buf.getvalue())
(o/'sources.b64').write_text(base64.b64encode(buf.getvalue()).decode(),encoding='ascii')
(o/'inherited_status.txt').write_bytes(subprocess.check_output(['git','status','--porcelain=v1'],cwd=r))
(o/'inherited_diff.patch').write_bytes(subprocess.check_output(['git','diff','--binary'],cwd=r))
h=r/'docs/DEAD_STREET_HIVE_MIND.md';s=h.read_text(encoding='utf-8');start=s.index('**Active objective:**');end=s.index('**Latest estate evidence:**',start)
s=s[:start]+"""**Active objective:** Finish the owner-directed second estate correction. The latest journal supersedes the earlier review-next status: dead-left larger mansion and forecourt; full intro faction names; quiet mansion-spatial music; approved pack-07 vocals; no HUD-obscured units; continuous coherent aftermath.

| Work | Owner | State / scope |
| --- | --- | --- |
| Estate correction, HUD safety, ending continuity and vocals | Active continuation chat, 2026-09-14 | Taking over inherited dirty revision at HEAD 2cf7e4a; no build/capture process observed. Preserve inherited edits and unrelated work. |
| Runtime optimization | Parked | Reopen only for a demonstrated current-scale regression. |
| Records and delivery | Active continuation chat | Reconcile latest journal, verify changes, capture complete mobile MP4; visual/listening acceptance pending. |

"""+s[end:]
a=s.index('**Immediate next task:**');b=s.index('**Known gaps:**',a)
s=s[:a]+"**Immediate next task:** Fix measured HUD framing and ending handoff; resolve inherited front-steps geometry failure, then integrate approved vocals and validate the corrected capture. Prior estate report describes a rejected earlier version.\n\n"+s[b:]
h.write_text(s,encoding='utf-8')
j=r/'docs/DEAD_STREET_JOURNAL.md'
with j.open('a',encoding='utf-8') as f:f.write("\n\n## 20260914-active-resume-01 - Second estate correction resumed\n\nSource: Brandon requested active-build continuation and minute-by-minute updates. Live branch build/arsenal-checkpoint-20260911, HEAD 2cf7e4af5e4335683263004560127df7a08bcded; mixed dirty tree preserved. Latest journal authorizes vocals pack 07 and second mansion correction, superseding stale Hive Mind/Project Control review-next text. Owner also reported disappearing/repositioned sprites and aimless movement at the ending; investigate continuity without changing battle outcome. No worker/capture was running when checked. Inherited v3 geometry result fails front steps because start is inside hedge_85_78; no new successful validation is claimed. HUD protection is a hard owner rule. Snapshot: tools/whittaker_estate/resume_20260914/inherited_sources.zip plus status/diff. Next: finish HUD and ending fixes, geometry, vocals and corrected native recording. No new commit/push yet.\n")
print(json.dumps({'bytes':len(buf.getvalue()),'files':files,'records':'saved'}))
