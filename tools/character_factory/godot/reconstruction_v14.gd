extends SceneTree
# Offline, opt-in SE experiment. No runtime resources or historical modes touched.
# Usage: godot --headless --script this.gd -- SOURCE_PNG NEW_OUTPUT_DIRECTORY
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if (args.size() != 2 and args.size() != 3 and args.size() != 4) or DirAccess.dir_exists_absolute(args[1]):
		printerr("Provide source PNG and a NEW output directory")
		quit(2)
		return
	if args.size() == 4 and args[3] != "graphic":
		quit(8)
		return
	var graphic: bool = args.size() == 4
	var src := Image.load_from_file(args[0])
	if src == null or src.get_size() != Vector2i(512, 512):
		quit(3)
		return
	src.convert(Image.FORMAT_RGBA8)
	var labels: Image = null
	if args.size() >= 3:
		labels = Image.load_from_file(args[2])
		if labels == null or labels.get_size() != src.get_size():
			quit(6)
			return
	DirAccess.make_dir_recursive_absolute(args[1])
	var clean := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	# Largest 8-connected alpha>=128 component is the seed, not the alpha16 AABB.
	var visited := PackedByteArray()
	visited.resize(512 * 512)
	var largest: Array[Vector2i] = []
	for y in range(512):
		for x in range(512):
			var idx := y * 512 + x
			if visited[idx] != 0 or src.get_pixel(x,y).a < 128.0/255.0:
				continue
			var queue: Array[Vector2i] = [Vector2i(x,y)]
			visited[idx] = 1
			var head := 0
			while head < queue.size():
				var p := queue[head]
				head += 1
				for dy in range(-1,2):
					for dx in range(-1,2):
						var q := p + Vector2i(dx,dy)
						if q.x < 0 or q.y < 0 or q.x >= 512 or q.y >= 512:
							continue
						var qi := q.y*512+q.x
						if visited[qi] == 0 and src.get_pixelv(q).a >= 128.0/255.0:
							visited[qi] = 1
							queue.append(q)
			if queue.size() > largest.size():
				largest = queue
	if largest.size() < 1000:
		quit(4)
		return
	var lo := Vector2i(512,512)
	var hi := Vector2i.ZERO
	for p in largest:
		lo = lo.min(p)
		hi = hi.max(p)
		# Retain original antialias coverage only within two source pixels of seed.
		for dy in range(-2,3):
			for dx in range(-2,3):
				var q := p + Vector2i(dx,dy)
				if q.x >= 0 and q.y >= 0 and q.x < 512 and q.y < 512:
					var c := src.get_pixelv(q)
					if c.a >= 32.0/255.0:
						clean.set_pixelv(q,c)
	if lo.x <= 0 or lo.y <= 0 or hi.x >= 511 or hi.y >= 511:
		printerr("Opaque core touches source boundary")
		quit(9)
		return
	clean.save_png(args[1].path_join("clean_source.png"))
	var rect := Rect2i(lo-Vector2i(4,4), hi-lo+Vector2i(9,9))
	var cropped := clean.get_region(rect)
	var rows: Array = []
	for height in [96,80,64]:
		var scale_factor := float(height) / float(hi.y-lo.y+1)
		var base: Image = cropped.duplicate()
		base.convert(Image.FORMAT_RGBAF)
		# Linear-light, premultiplied-alpha reduction prevents dark transparent fringes.
		for y in range(base.get_height()):
			for x in range(base.get_width()):
				var c := base.get_pixel(x,y)
				var l := c.srgb_to_linear()
				base.set_pixel(x,y,Color(l.r*c.a,l.g*c.a,l.b*c.a,c.a))
		base.resize(roundi(cropped.get_width()*scale_factor),roundi(cropped.get_height()*scale_factor),Image.INTERPOLATE_LANCZOS if graphic else Image.INTERPOLATE_BILINEAR)
		for y in range(base.get_height()):
			for x in range(base.get_width()):
				var c := base.get_pixel(x,y)
				if c.a > 0.0:
					var s := Color(c.r/c.a,c.g/c.a,c.b/c.a).linear_to_srgb()
					base.set_pixel(x,y,Color(s.r,s.g,s.b,c.a))
		base.convert(Image.FORMAT_RGBA8)
		var label_small: Image = null
		if labels != null:
			label_small = labels.get_region(rect)
			label_small.resize(base.get_width(),base.get_height(),Image.INTERPOLATE_NEAREST)
		for mode in ([6,7,8,9] if graphic else ([4,5] if labels != null else [0,1,2,3])):
			var out: Image = base.duplicate() if mode == 0 else ((contour_sprite(graphic_reconstruct(base,label_small,7 if mode == 8 else 9)) if mode >= 8 else graphic_reconstruct(base,label_small,mode)) if mode >= 6 else (material_reconstruct(base,label_small,mode) if mode >= 4 else reconstruct(base,mode)))
			var name := "%s_%d.png" % [["A_clean","B_planes","C_edges","D_regions","E_material_shading","F_material_edges","G_graphic","H_graphic_edges","I_contour","J_soft_contour"][mode],height]
			out.save_png(args[1].path_join(name))
			var again: Image = base.duplicate() if mode == 0 else ((contour_sprite(graphic_reconstruct(base,label_small,7 if mode == 8 else 9)) if mode >= 8 else graphic_reconstruct(base,label_small,mode)) if mode >= 6 else (material_reconstruct(base,label_small,mode) if mode >= 4 else reconstruct(base,mode)))
			if out.get_data() != again.get_data():
				quit(5)
				return
			var alpha_equal := true
			for y in range(base.get_height()):
				for x in range(base.get_width()):
					alpha_equal = alpha_equal and (out.get_pixel(x+2,y+2).a >= base.get_pixel(x,y).a if mode >= 8 else out.get_pixel(x,y).a == base.get_pixel(x,y).a)
			if not alpha_equal:
				quit(7)
				return
			rows.append({"file":name,"preview_seed_height":height,"canvas": [out.get_width(),out.get_height()],"alpha_validation_pass":alpha_equal,"alpha_policy":("1px contour; 2px canvas padding; original coverage retained" if mode >= 8 else "exact control alpha"),"repeat_identical":true})
	var report := {"graphic_mode":graphic,"reduction":("linear-premultiplied Lanczos" if graphic else "linear-premultiplied bilinear"),"source":args[0],"source_sha256":FileAccess.get_sha256(args[0]),"seed_bounds":[lo.x,lo.y,hi.x,hi.y],"seed_pixels":largest.size(),"mask_policy":"largest 8-connected alpha128 plus 2px alpha32 fringe; experimental, visually inspect thin parts","runtime_size_contract":false,"outputs":rows,"style_accepted":false,"pose":"G_NEUTRAL_FORWARD50 temporary"}
	if labels != null:
		report["label_source_sha256"] = FileAccess.get_sha256(args[2])
		report["label_source"] = args[2]
	var f := FileAccess.open(args[1].path_join("reconstruction_report.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"\t"))
	print(JSON.stringify(report))
	quit(0)

func reconstruct(src: Image, mode: int) -> Image:
	var out := src.duplicate()
	for y in range(src.get_height()):
		for x in range(src.get_width()):
			var center := src.get_pixel(x,y)
			if center.a == 0:
				continue
			var total := Vector3.ZERO
			var weight_sum := 0.0
			var cv := Vector3(center.r,center.g,center.b)
			# Edge-aware spatial averaging removes micro-gradients without crossing materials.
			for dy in range(-1,2):
				for dx in range(-1,2):
					var nx := clampi(x+dx,0,src.get_width()-1)
					var ny := clampi(y+dy,0,src.get_height()-1)
					var c := src.get_pixel(nx,ny)
					var v := Vector3(c.r,c.g,c.b)
					var w := exp(-cv.distance_squared_to(v)/0.012)*c.a
					total += v*w
					weight_sum += w
			var avg := total/maxf(weight_sum,0.00001)
			var lum := avg.dot(Vector3(0.2126,0.7152,0.0722))
			# Fixed broad luminance planes; no per-frame palette fitting or dithering.
			var tone := 0.055
			for pair in [[0.09,0.12],[0.17,0.22],[0.28,0.34],[0.41,0.48],[0.57,0.65],[0.75,0.82]]:
				if lum > pair[0]:
					tone = pair[1]
			var chroma := avg-Vector3.ONE*lum
			var result := Vector3.ONE*tone + chroma*0.60
			if mode == 2:
				# Reinforce existing material/form discontinuities, not every silhouette edge.
				var contrast := 0.0
				for d in [Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1)]:
					var q: Vector2i = Vector2i(x,y)+d
					if q.x >= 0 and q.y >= 0 and q.x < src.get_width() and q.y < src.get_height():
						var n := src.get_pixelv(q)
						if n.a > 0.8:
							contrast = maxf(contrast,Vector3(n.r,n.g,n.b).dot(Vector3(0.2126,0.7152,0.0722))-lum)
				if contrast > 0.09:
					result *= 0.72
			if mode == 3:
				# Experimental RGB-derived families, not authored material-ID masks.
				var ramp: Array = [Color("171a1a"),Color("272b2c"),Color("394144"),Color("546065"),Color("78848a"),Color("a1a9a8")]
				var thresholds: Array = [0.045,0.08,0.13,0.20,0.30]
				if avg.x > avg.y*1.12 and avg.x > avg.z*1.12:
					ramp = [Color("302724"),Color("544039"),Color("76584a"),Color("96745e"),Color("b69778"),Color("c9ad8b")]
					thresholds = [0.18,0.26,0.34,0.43,0.54]
				elif avg.y > avg.x*1.12 and avg.y > avg.z*1.10:
					ramp = [Color("171c18"),Color("262d24"),Color("3a4130"),Color("505640"),Color("687055"),Color("83886c")]
					thresholds = [0.035,0.06,0.09,0.14,0.21]
				var band := 0
				for t in thresholds:
					if lum > t:
						band += 1
				var rc: Color = ramp[band]
				result = Vector3(rc.r,rc.g,rc.b)
				var boundary := false
				var rise := 0.0
				for d in [Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1)]:
					var q: Vector2i = Vector2i(x,y)+d
					if q.x >= 0 and q.y >= 0 and q.x < src.get_width() and q.y < src.get_height():
						var n := src.get_pixelv(q)
						boundary = boundary or n.a < 0.35
						if n.a > 0.8:
							rise = maxf(rise,Vector3(n.r,n.g,n.b).dot(Vector3(0.2126,0.7152,0.0722))-lum)
				if boundary or rise > 0.11:
					result *= 0.55
			out.set_pixel(x,y,Color(clampf(result.x,0,1),clampf(result.y,0,1),clampf(result.z,0,1),center.a))
	return out

func label_role(c: Color) -> int:
	var v := Vector3(c.r,c.g,c.b).normalized()
	var refs := [Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1),Vector3(1,0,1).normalized(),Vector3(1,1,0).normalized(),Vector3(0,1,1).normalized(),Vector3.ONE.normalized()]
	var best := -1.0
	var second := -1.0
	var role := 6
	for i in range(refs.size()):
		var score: float = v.dot(refs[i])
		if score > best:
			second = best
			best = score
			role = i
		elif score > second:
			second = score
	if best-second < 0.035 or c.a < 0.25:
		return 6
	return role

func material_reconstruct(src: Image, labels: Image, mode: int) -> Image:
	var ramps := [
		["382923","594033","795a45","9b785b","b69876","ccb28c"],
		["101415","192022","252d30","343e42","495359","657077"],
		["141914","22291f","333b2a","49503a","60664b","7c8060"],
		["131819","232c30","39454a","58666b","828b8e","afb3ac"],
		["0c1010","141a19","202725","303b36","465249","636c5c"],
		["111515","1b2223","2a3436","414c4e","606b6a","87918b"]]
	var cuts := [
		[0.22,0.29,0.36,0.43,0.51],
		[0.105,0.14,0.16,0.18,0.205],
		[0.133,0.145,0.157,0.172,0.191],
		[0.12,0.16,0.19,0.23,0.30],
		[0.018,0.03,0.05,0.08,0.13],
		[0.105,0.13,0.165,0.22,0.31]]
	var out := src.duplicate()
	for y in range(src.get_height()):
		for x in range(src.get_width()):
			var c := src.get_pixel(x,y)
			if c.a == 0:
				continue
			var role := label_role(labels.get_pixel(x,y))
			if role == 6:
				continue # Unknown labels retain source; never invent semantic ownership.
			var lum_values: Array[float] = []
			for dy in range(-1,2):
				for dx in range(-1,2):
					var q := Vector2i(x+dx,y+dy)
					if q.x < 0 or q.y < 0 or q.x >= src.get_width() or q.y >= src.get_height():
						continue
					var n := src.get_pixelv(q)
					if n.a > 0.5 and label_role(labels.get_pixelv(q)) == role:
						lum_values.append(Vector3(n.r,n.g,n.b).dot(Vector3(0.2126,0.7152,0.0722)))
			lum_values.sort()
			var lum := Vector3(c.r,c.g,c.b).dot(Vector3(0.2126,0.7152,0.0722))
			if not lum_values.is_empty():
				lum = lerpf(lum,lum_values[lum_values.size()/2],0.70)
			var band := 0
			for t in cuts[role]:
				if lum > t:
					band += 1
			var color := Color(str(ramps[role][band]))
			if mode == 5:
				var boundary := false
				var rise := 0.0
				for d in [Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1)]:
					var q: Vector2i = Vector2i(x,y)+d
					if q.x < 0 or q.y < 0 or q.x >= src.get_width() or q.y >= src.get_height():
						continue
					var n := src.get_pixelv(q)
					boundary = boundary or n.a < 0.35
					if n.a > 0.8:
						rise = maxf(rise,Vector3(n.r,n.g,n.b).dot(Vector3(0.2126,0.7152,0.0722))-lum)
				if boundary or rise > 0.10:
					color = color.lerp(Color("101512"),0.72) if boundary else color.darkened(0.40)
			color.a = c.a
			out.set_pixel(x,y,color)
	return out

func graphic_reconstruct(src: Image, labels: Image, mode: int) -> Image:
	# Fixed source-light calibration; never fit ramps independently per frame.
	var ramps := [
		["130f0d","2a1e18","4a3324","6a4e35","896948","aa8b65"],
		["0b1011","121819","1c2223","262d2e","3b4242","5b6260"],
		["0b100d","151d17","232d22","35412f","49543d","63704f"],
		["0b1011","171d20","293235","414b4e","5d686a","939891"],
		["0a0d0c","101612","1c241c","2d3527","434b38","606650"],
		["0c1010","151c1d","242e30","3a4647","586463","7f8984"]]
	var cuts := [
		[0.07,0.18,0.40,0.58,0.70],
		[0.05,0.11,0.18,0.23,0.29],
		[0.025,0.075,0.14,0.23,0.31],
		[0.035,0.08,0.13,0.23,0.36],
		[0.015,0.03,0.06,0.10,0.17],
		[0.04,0.10,0.20,0.33,0.45]]
	var out := src.duplicate()
	for y in range(src.get_height()):
		for x in range(src.get_width()):
			var c := src.get_pixel(x,y)
			if c.a == 0:
				continue
			var role := label_role(labels.get_pixel(x,y))
			if role == 6:
				continue # Unknown labels retain source; never invent semantic ownership.
			var lum_values: Array[float] = []
			for dy in range(-1,2):
				for dx in range(-1,2):
					var q := Vector2i(x+dx,y+dy)
					if q.x < 0 or q.y < 0 or q.x >= src.get_width() or q.y >= src.get_height():
						continue
					var n := src.get_pixelv(q)
					if n.a > 0.5 and label_role(labels.get_pixelv(q)) == role:
						lum_values.append(Vector3(n.r,n.g,n.b).dot(Vector3(0.2126,0.7152,0.0722)))
			lum_values.sort()
			var lum := Vector3(c.r,c.g,c.b).dot(Vector3(0.2126,0.7152,0.0722))
			if not lum_values.is_empty():
				lum = lerpf(lum,lum_values[lum_values.size()/2],0.45)
			var band := 0
			for t in cuts[role]:
				if lum > t:
					band += 1
			var color := Color(str(ramps[role][band]))
			if mode == 9 and band > 0:
				var lower: float = cuts[role][band-1]
				var upper: float = cuts[role][band] if band < 5 else 1.0
				color = Color(str(ramps[role][band-1])).lerp(color,clampf((lum-lower)/maxf(upper-lower,0.001),0.0,1.0))
			if mode == 7:
				var boundary := false
				var rise := 0.0
				for d in [Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1)]:
					var q: Vector2i = Vector2i(x,y)+d
					if q.x < 0 or q.y < 0 or q.x >= src.get_width() or q.y >= src.get_height():
						continue
					var n := src.get_pixelv(q)
					boundary = boundary or n.a < 0.35
					if n.a > 0.8:
						rise = maxf(rise,Vector3(n.r,n.g,n.b).dot(Vector3(0.2126,0.7152,0.0722))-lum)
				if boundary or rise > 0.18:
					color = color.lerp(Color("101512"),0.72) if boundary else color.darkened(0.30)
			color.a = c.a
			out.set_pixel(x,y,color)
	return out

func contour_sprite(src: Image) -> Image:
	var out := Image.create(src.get_width()+4,src.get_height()+4,false,Image.FORMAT_RGBA8)
	for y in range(src.get_height()):
		for x in range(src.get_width()):
			var a := src.get_pixel(x,y).a
			for dy in range(-1,2):
				for dx in range(-1,2):
					var p := Vector2i(x+2+dx,y+2+dy)
					if a > out.get_pixelv(p).a:
						out.set_pixelv(p,Color(12.0/255.0,15.0/255.0,13.0/255.0,a))
	for y in range(src.get_height()):
		for x in range(src.get_width()):
			var p := Vector2i(x+2,y+2)
			out.set_pixelv(p,out.get_pixelv(p).blend(src.get_pixel(x,y)))
	return out
