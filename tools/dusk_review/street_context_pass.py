from pathlib import Path
p=Path('gameplay/harold_street_art.gd')
s=p.read_text()
s=s.replace('const BRICK =','var apartment_font: SystemFont\nvar shop_font: SystemFont\nvar gang_font: SystemFont\nconst BRICK =',1)
s=s.replace('\tsuper._ready()','''	super._ready()
	apartment_font=SystemFont.new()
	apartment_font.font_names=PackedStringArray(["Georgia","Times New Roman"])
	shop_font=SystemFont.new()
	shop_font.font_names=PackedStringArray(["Arial","Liberation Sans"])
	shop_font.font_weight=700
	gang_font=SystemFont.new()
	gang_font.font_names=PackedStringArray(["Old English Text MT"])
''',1)
a=s.index('\t# Litter collects');b=s.index('\tfor x in [7,19,41,60]:',a)
s=s[:a]+'''	# Small, irregular accumulations by bins and deliveries; no dotted curb border.
	for cluster in [Vector2(29,107),Vector2(127,105),Vector2(274,108),Vector2(310,119),Vector2(456,106)]:
		for i in range(10):
			var q=cluster+Vector2(rng.randfn(0,5),rng.randfn(0,2.5))
			var c=[Color("#999078"),Color("#686e5e"),Color("#655342")][i%3]
			draw_colored_polygon(PackedVector2Array([q,q+Vector2(1.6,-.4),q+Vector2(2,.5),q+Vector2(.4,1)]),c)
''' + s[b:]
s=s.replace('rect(Rect2(q.x+5,base-61,sz.x-10,13),Color("#283b35"))','''# Small individual metal letters mounted directly on the masonry.
			painted_text(Vector2(door_x-43,base-51),"Harold Apartments",86,9,apartment_font,Color("#c9b48c"),true)''')
s=s.replace('\t\t\tsign_letters(Vector2(q.x+5,base-58),H.OBJECTIVE,sz.x-10,Color("#eee0b8"))\n','')
s=s.replace('sign_letters(Vector2(x+6,y-47),H.STORE,w-12,Color("#f0e0b8"))','painted_text(Vector2(x+7,y-40),H.STORE,w-14,11,shop_font,Color("#453a2f"))')
s=s.replace('Color("#28463c")','Color("#c2b48f")')
s=s.replace('label(Vector2(q.x+22,base-5),"MERCER",35,7,Color("#9c967c"))','''painted_text(Vector2(q.x+43,base-7),"M",30,33,gang_font,Color("#a13c35"))
		for drip in [Vector2(52,-9),Vector2(62,-8)]:
			line(Vector2(q.x,base)+drip,Vector2(q.x,base)+drip+Vector2(.3,3),Color("#82352e"),.65)''')
a=s.index('func sign_letters(')
s=s[:a]
p.write_text(s)

s=p.read_text()
a=s.index('func stairs(');b=s.index('func object_art()',a)
s=s[:a]+'''func stairs(start: Vector2,w: float,depth: float) -> void:
	var q=p(start);var width=w*8
	var step_depth=(depth*6-3)/5.
	for n in range(5):
		var y=q.y+3+n*step_depth
		var inset=(4-n)*.35
		rect(Rect2(q.x+inset,y,width-inset*2,step_depth-1.2),Color("#777b73").darkened(n*.018))
		rect(Rect2(q.x+inset,y+step_depth-1.2,width-inset*2,1.2),Color("#4f574f"))
		line(Vector2(q.x+inset+.5,y+step_depth-1.3),Vector2(q.x+width-inset-.5,y+step_depth-1.3),Color("#96998b"),.65)
		if n==3:line(Vector2(q.x+4,y+.8),Vector2(q.x+6,y+1.3),Color("#5c665b"),.4)
''' + s[b:]
s=s.replace('Color("#8a8270")','Color("#777b73")').replace('Color("#b0a28a")','Color("#96998b")')
a=s.index('func stoop_wall(');b=s.index('func cutaway(',a)
s=s[:a]+'''func stoop_wall(q: Vector2,sz: Vector2) -> void:
	# Each shallow masonry section has its own depth anchor.
	var h=3.0
	bricks(Rect2(q-Vector2(0,h),sz+Vector2(0,h)),Color("#5b5045"))
	rect(Rect2(q-Vector2(.4,h+.5),Vector2(sz.x+.8,1.2)),Color("#969080"))
''' + s[b:]
a=s.index('func trash(');b=s.index('func _draw()',a)
s=s[:a]+'''func trash(q: Vector2) -> void:
	for i in range(3):
		var t=q+Vector2(i*3.7,-(i%2)*1.1)
		var w=3.5+(i%2)*.6
		draw_set_transform(t,0,Vector2(1,.42))
		draw_circle(Vector2(0,1),w+1,Color(0.025,.035,.03,.45))
		draw_set_transform(Vector2.ZERO)
		draw_colored_polygon(PackedVector2Array([t+Vector2(-w,0),t+Vector2(-w-.4,-2),t+Vector2(-w+.3,-4),t+Vector2(-1.1,-5.6),t+Vector2(.4,-6),t+Vector2(w,-4.4),t+Vector2(w+.5,-1.7),t+Vector2(w-.7,.5),t+Vector2(-1,.7)]),Color("#182324"))
		draw_colored_polygon(PackedVector2Array([t+Vector2(-w+.7,-1),t+Vector2(-w+1,-3.8),t+Vector2(-1,-5),t+Vector2(-1.8,-2)]),Color("#354341"))
		line(t+Vector2(.2,-5.5),t+Vector2(1.5,-2),Color("#45524d"),.5)
		line(t+Vector2(2,-1),t+Vector2(w-.3,-2.4),Color("#2e3d3a"),.55)
		draw_colored_polygon(PackedVector2Array([t+Vector2(-.8,-5.4),t+Vector2(-1.4,-7),t+Vector2(.1,-6.6),t+Vector2(1.3,-7.2),t+Vector2(1,-5.6)]),Color("#384640"))
		line(t+Vector2(-1,-5.6),t+Vector2(1,-5.7),Color("#60645a"),.5)
''' + s[b:]
s=s.replace('func _draw() -> void:\n\tif not prop.is_empty()', '''func _draw() -> void:
	if not prop.is_empty() and prop[2]=="lamp":
		# Full streetlight pole; the fixture and its base keep their previous footprint.
		draw_set_transform(Vector2.ZERO,0,Vector2(1.15,2.1))
		asset("lamp_0",Vector2(2,0),10)
		draw_set_transform(Vector2.ZERO)
	elif not prop.is_empty()''')
s+='''func painted_text(q: Vector2,words: String,width: float,height: float,font: Font,c: Color,raised: bool=false) -> void:
	var font_size=48
	var natural=font.get_string_size(words,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
	var scale_factor=minf(width/maxf(1,natural.x),height/36.)
	var pos=q+Vector2((width-natural.x*scale_factor)/2.,0)
	draw_set_transform(pos,0,Vector2.ONE*scale_factor)
	if raised:draw_string(font,Vector2(1.8,1.8),words,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("#252d29"))
	draw_string(font,Vector2.ZERO,words,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,c)
	draw_set_transform(Vector2.ZERO)
'''
p.write_text(s)
p=Path('gameplay/tactical_battle_view.gd');s=p.read_text()
needle='\t\tvar item = art.new()\n\t\titem.prop = row\n\t\tvar bounds: Rect2 = row[1]'
replacement='''		# Long stoop walls must sort by local depth, not their frontmost endpoint.
		if row[2]=="stoop_wall":
			var wall_bounds: Rect2=row[1]
			var count=int(ceil(wall_bounds.size.y/.55))
			for segment in range(count):
				var piece=art.new()
				var part=Rect2(wall_bounds.position+Vector2(0,segment*wall_bounds.size.y/count),Vector2(wall_bounds.size.x,wall_bounds.size.y/count))
				piece.prop=[str(row[0])+"_"+str(segment),part,"stoop_wall"]
				piece.position=Vector2(part.get_center().x*8,part.end.y*6)
				dynamic_unit_root.add_child(piece)
				_dusk_nodes.append(piece)
			continue
		var item = art.new()
		item.prop = row
		var bounds: Rect2 = row[1]'''
assert needle in s
s=s.replace(needle,replacement,1);p.write_text(s)
print('Context pass installed')
