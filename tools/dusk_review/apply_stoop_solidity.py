from pathlib import Path
p=Path('battle/geometry/harold_street_catalog.gd')
s=p.read_text().replace('Rect2(22,15.4,.9,4.1)','Rect2(22,15,.9,4.5)').replace('Rect2(27.1,15.4,.9,4.1)','Rect2(27.1,15,.9,4.5)').replace('Rect2(48.8,15.4,.8,3.5)','Rect2(48.8,15,.8,3.9)').replace('Rect2(53.2,15.4,.8,3.5)','Rect2(53.2,15,.8,3.9)')
s=s.replace('kind=="building" or kind=="utility"','kind in ["building","utility","stoop_wall"]')
p.write_text(s)
p=Path('gameplay/tactical_battle_view.gd')
s=p.read_text()
a=s.index('\t\t# Long stoop walls must sort')
b=s.index('\t\tvar item = art.new()',a)
s=s[:a]+'\t\t# Solid stoop walls use one continuous cap and their nearest ground edge.\n'+s[b:]
p.write_text(s)
print('Four full-height LOS-blocking walls installed; continuous wall rendering')
