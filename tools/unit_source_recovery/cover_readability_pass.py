from pathlib import Path
p=Path(__file__).parents[2]/'gameplay/dusk_street_art.gd';s=p.read_text()
old='\tline(top+Vector2(sz.x-3,15),top+Vector2(sz.x-3,20),INK,.6)'
new=old+'''
	# Separate steel doors, plinth and electrical warning identify street cabinets.
	line(top+Vector2(sz.x*.5,3),top+Vector2(sz.x*.5,sz.y+10),INK,.8)
	rect(Rect2(top+Vector2(1,sz.y+9),Vector2(sz.x-2,3)),Color("#303a38"))
	line(top+Vector2(sz.x*.5-2,16),top+Vector2(sz.x*.5-2,20),Color("#bac0ae"),.8)
	var warning=top+Vector2(3.8,16)
	line(warning,warning+Vector2(-.7,1.2),INK,.55)
	line(warning+Vector2(-.7,1.2),warning+Vector2(.5,1.2),INK,.55)
	line(warning+Vector2(.5,1.2),warning+Vector2(-.3,2.5),INK,.55)
	for y in [sz.y+4,sz.y+6]:
		line(top+Vector2(2,y),top+Vector2(sz.x*.5-2,y),INK,.65)'''
assert old in s;s=s.replace(old,new);p.write_text(s)
print('Utility cabinet doors, plinth, vents and warning added')
