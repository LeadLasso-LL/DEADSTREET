from pathlib import Path
import urllib.request, hashlib
root=Path(__file__).resolve().parent/'dependencies'
root.mkdir(exist_ok=True)
p=root/'GeneralUser-GS.sf2'
expected='9575028c7a1f589f5770fccc8cff2734566af40cd26ed836944e9a5152688cfe'
if not p.exists():
    with urllib.request.urlopen('https://raw.githubusercontent.com/mrbumpy409/GeneralUser-GS/main/GeneralUser-GS.sf2',timeout=120) as r: p.write_bytes(r.read())
assert hashlib.sha256(p.read_bytes()).hexdigest()==expected, 'Upstream instrument bank changed; review/version it before using.'
print('GeneralUser GS bank verified')
