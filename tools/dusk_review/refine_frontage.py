from pathlib import Path
p=Path('gameplay/harold_street_art.gd')
s=p.read_text()
a=s.index('\tfor patch in ')
b=s.index('\tfor i in range(50):',a)
s=s[:a]+s[b:]
s=s.replace('aggregate, repaired utility cuts, cracks','aggregate and cracks')
a=s.index('func stairs(');b=s.index('func object_art()',a)
s=s[:a]+'''func stairs(start: Vector2,w: float,depth: float) -> void:
	var q=p(start);var width=w*8
	var step_depth=(depth*6-3)/5.
	for n in range(5):
		var y=q.y+3+n*step_depth
		rect(Rect2(q.x,y,width,step_depth-1.6),Color("#8a8270").darkened(n*.025))
		rect(Rect2(q.x,y+step_depth-1.6,width,1.6),Color("#514e43"))
		line(Vector2(q.x+1,y),Vector2(q.x+width-1,y),Color("#b0a28a"),.7)
		if n==2:line(Vector2(q.x+4,y+1),Vector2(q.x+7,y+2),Color("#676351"),.5)
''' + s[b:]
s=s.replace('rect(Rect2(q.x+20,base-57,sz.x-40,9),Color("#373e35"))','rect(Rect2(q.x+5,base-61,sz.x-10,13),Color("#283b35"))')
s=s.replace('label(Vector2(q.x+21,base-50),H.OBJECTIVE,sz.x-42,6,Color("#d7c4a0"))','sign_letters(Vector2(q.x+5,base-58),H.OBJECTIVE,sz.x-10,Color("#eee0b8"))')
a=s.index('\t\tfor x in [q.x+10,q.x+sz.x-27]:')
b=s.index('\t\tlabel(Vector2(q.x+5,base-3)',a)
s=s[:a]+'''		# A continuous stone landing reaches the bottom of the door.
		var landing_width=32.8 if seed_id==1 else 28.8
		rect(Rect2(door_x-landing_width/2,base-8,landing_width,11),Color("#8a8270"))
		line(Vector2(door_x-landing_width/2,base-8),Vector2(door_x-landing_width/2,base+3),Color("#b0a28a"),.7)
		for x in [q.x+10,q.x+sz.x-28]:
			window(Vector2(x,base-32),seed_id==1,seed_id)
''' + s[b:]
s=s.replace('rect(Rect2(x+4,y-48,w-8,11),Color("#3c5549"))','rect(Rect2(x+4,y-50,w-8,13),Color("#28463c"))')
s=s.replace('label(Vector2(x+6,y-39),H.STORE.to_upper(),w-12,8,Color("#e7d6a9"))','sign_letters(Vector2(x+6,y-47),H.STORE,w-12,Color("#f0e0b8"))')
p.write_text(s)
print('Street, steps, windows and sign layout updated')

with p.open('a') as f:f.write("\nfunc sign_letters(q: Vector2,words: String,width: float,c: Color) -> void:\n\t# Explicit pixels keep the principal storefront names legible at battle zoom.\n\tvar glyphs={\"A\":[\"01110\",\"10001\",\"10001\",\"11111\",\"10001\",\"10001\",\"10001\"],\"D\":[\"11110\",\"10001\",\"10001\",\"10001\",\"10001\",\"10001\",\"11110\"],\"E\":[\"11111\",\"10000\",\"10000\",\"11110\",\"10000\",\"10000\",\"11111\"],\"H\":[\"10001\",\"10001\",\"10001\",\"11111\",\"10001\",\"10001\",\"10001\"],\"I\":[\"11111\",\"00100\",\"00100\",\"00100\",\"00100\",\"00100\",\"11111\"],\"L\":[\"10000\",\"10000\",\"10000\",\"10000\",\"10000\",\"10000\",\"11111\"],\"M\":[\"10001\",\"11011\",\"10101\",\"10101\",\"10001\",\"10001\",\"10001\"],\"N\":[\"10001\",\"11001\",\"11001\",\"10101\",\"10011\",\"10011\",\"10001\"],\"O\":[\"01110\",\"10001\",\"10001\",\"10001\",\"10001\",\"10001\",\"01110\"],\"P\":[\"11110\",\"10001\",\"10001\",\"11110\",\"10000\",\"10000\",\"10000\"],\"R\":[\"11110\",\"10001\",\"10001\",\"11110\",\"10100\",\"10010\",\"10001\"],\"S\":[\"01111\",\"10000\",\"10000\",\"01110\",\"00001\",\"00001\",\"11110\"],\"T\":[\"11111\",\"00100\",\"00100\",\"00100\",\"00100\",\"00100\",\"00100\"],\"C\":[\"01111\",\"10000\",\"10000\",\"10000\",\"10000\",\"10000\",\"01111\"],\"-\":[\"00000\",\"00000\",\"00000\",\"11111\",\"00000\",\"00000\",\"00000\"]}\n\tvar title=words.to_upper()\n\tvar origin=Vector2(roundf(q.x+(width-(title.length()*6-1))/2),roundf(q.y))\n\tfor i in range(title.length()):\n\t\tif not glyphs.has(title[i]):continue\n\t\tvar rows=glyphs[title[i]]\n\t\tfor y in range(7):\n\t\t\tfor x in range(5):\n\t\t\t\tif rows[y][x]==\"1\":rect(Rect2(origin+Vector2(i*6+x,y),Vector2.ONE),c)\n")
