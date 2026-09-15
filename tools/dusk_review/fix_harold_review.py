from pathlib import Path
p=Path(__file__).with_name('harold_review.gd')
s=p.read_text()
p.write_text('\n'.join('\t'*(len(x)-len(x.lstrip(' ')))+x.lstrip(' ') if x.startswith(' ') else x for x in s.splitlines())+'\n')
