from pathlib import Path
import subprocess,json
out=Path(__file__).resolve().parent;root=out.parents[1]
checks=json.loads((out/'validation.json').read_text());assert all(checks.values())
godot=Path(r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe')
assert godot.exists()
desktop=Path(subprocess.check_output(['powershell','-NoProfile','-Command',"[Environment]::GetFolderPath('Desktop')"],text=True).strip())
launch='@echo off\nstart "" "'+str(godot)+'" --path "'+str(root)+'" --script res://tools/faction_music_picker_20260915/picker.gd\n'
(out/'Open-Faction-Music-Assignments.cmd').write_text(launch,encoding='utf-8')
(desktop/'Faction Music Assignments.cmd').write_text(launch,encoding='utf-8')
readme='# Faction music assignment screen\n\nLocal owner review tool. Run Open-Faction-Music-Assignments.cmd or the Desktop Faction Music Assignments shortcut.\n\nAll 21 non-authority factions use canonical names/emblems. Each row offers all 21 existing battle snippets, one-at-a-time looping playback, and pause. Choosing a track autosaves a draft to assignments.json; clearing it removes the draft mapping. Reopening restores choices. Save screenshot captures every row to the Desktop as Dead-Street-Faction-Music-Assignments.png. Duplicate choices are allowed. TRC and NBPD are excluded and retain sirens.\n\nThis screen does not change the runtime music catalogue or apply faction audio. Once the owner returns assignments, read assignments.json/screenshot and wire approved mappings. Native validation: 10 checks passed; screenshot visually reviewed; all rows fit at 1000 x 750. Existing audio files, consumers and concurrent game changes untouched. Local review utility; no GitHub publication required to use it.\n'
(out/'README.md').write_text(readme,encoding='utf-8')
entry='\n\n## 20260915-faction-music-picker-01 - Owner assignment screen ready\n\nOwner requested quick one-screen faction/snippet matching with canonical emblems, playable titled snippets, assignment controls and screenshot capture. Explicit latest rule: TRC and NBPD KEEP EXISTING SIRENS and are excluded. Built tools/faction_music_picker_20260915/picker.gd as an isolated native review tool using all 21 eligible factions and all 21 existing 30-second loops. Each row has an emblem/name, track selector and play/pause; selecting assigns and auditions; one loop plays at a time. Autosaved draft: tools/faction_music_picker_20260915/assignments.json. Save screenshot writes Desktop/Dead-Street-Faction-Music-Assignments.png; every row fits on a 1000x750 screen. Desktop launcher: Faction Music Assignments.cmd. All 10 native checks passed and screenshot inspected. No runtime catalogue or gameplay changes, no speculative assignments. Next: owner selects snippets and returns screenshot; read draft/confirm owner choices, then implement approved faction mapping while preserving both authority sirens. Concurrent BUILD range/portrait work untouched. Utility is ready locally; no push needed for immediate use.\n'
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md','DEAD_STREET_PROJECT_CONTROL.md']:
    path=root/'docs'/name
    if '## 20260915-faction-music-picker-01' not in path.read_text(encoding='utf-8'):
        with path.open('a',encoding='utf-8') as f:f.write(entry)
    assert entry in path.read_text(encoding='utf-8')
log=(out/'owner_session.log').open('w',encoding='utf-8')
p=subprocess.Popen([str(godot),'--path',str(root),'--script','res://tools/faction_music_picker_20260915/picker.gd'],stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
print('OPENED',p.pid,'DESKTOP',str(desktop/'Faction Music Assignments.cmd'),flush=True)
