from pathlib import Path
import subprocess
root=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=root/'tools/soundtrack_import_20260914'
r=subprocess.run(['git','diff','--cached','--check','--','.',':(exclude)tools/soundtrack_import_20260914/music_playlist.patch'],cwd=root,capture_output=True,text=True)
print(r.stdout,flush=True)
p=out/'build_assets.py';s=p.read_text(encoding='utf-8')
p.write_text('\n'.join(line.rstrip() for line in s.splitlines())+'\n',encoding='utf-8',newline='\n')
subprocess.run(['git','add','--','tools/soundtrack_import_20260914/build_assets.py'],cwd=root,check=True)
script=(out/'approved_publish.py').read_text(encoding='utf-8')
prefix="from pathlib import Path\nimport json,hashlib,subprocess,re\nroot=Path(r'C:\\Users\\brand\\OneDrive\\Documents\\dead-street');out=root/'tools/soundtrack_import_20260914'\ndef git(*args,input=None):return subprocess.check_output(['git',*args],cwd=root,input=input).decode('utf-8').strip()\nbranch='build/arsenal-checkpoint-20260911'\npaths=['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md']\n"
owned=script[script.index("owned="):script.index("\ngit('apply'")]
tail=script[script.index("git('diff','--cached','--check'"):]
code=prefix+owned+"\nassert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(paths)\nassert git('rev-parse','HEAD')=='ec7a60edaaa7d25493bdae523a6ab44d42148391'\n"+tail
exec(compile(code,'approved_publish_resume','exec'))
