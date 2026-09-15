extends RefCounted
# Conservative broad phase. Callers retain their exact hit/tie predicates.
static func build(rows: Array) -> Array:
	if rows.is_empty():
		return []
	var bounds: Rect2 = rows[0][0]
	for row in rows:
		bounds = bounds.merge(row[0])
	bounds = bounds.grow(0.0001)
	if rows.size() <= 4:
		return [bounds,rows]
	var ordered: Array = rows.duplicate()
	if bounds.size.x >= bounds.size.y:
		ordered.sort_custom(func(a,b):return a[0].get_center().x < b[0].get_center().x)
	else:
		ordered.sort_custom(func(a,b):return a[0].get_center().y < b[0].get_center().y)
	var middle: int = ordered.size()/2
	return [bounds,build(ordered.slice(0,middle)),build(ordered.slice(middle))]

static func query(tree: Array,start: Vector2,end: Vector2) -> Array[String]:
	var ids: Array[String] = []
	if not tree.is_empty():
		_collect(tree,start,end-start,ids)
	ids.sort()
	return ids

static func _collect(tree: Array,start: Vector2,displacement: Vector2,ids: Array[String]) -> void:
	if not _intersects(tree[0],start,displacement):
		return
	if tree.size() == 2:
		for row in tree[1]:
			ids.append(row[1])
		return
	_collect(tree[1],start,displacement,ids)
	_collect(tree[2],start,displacement,ids)

static func _intersects(rect: Rect2,start: Vector2,displacement: Vector2) -> bool:
	var low: float = 0.0
	var high: float = 1.0
	for axis in range(2):
		if is_zero_approx(displacement[axis]):
			if start[axis] < rect.position[axis] or start[axis] > rect.end[axis]:
				return false
			continue
		var first: float = (rect.position[axis]-start[axis])/displacement[axis]
		var last: float = (rect.end[axis]-start[axis])/displacement[axis]
		if first > last:
			var swap: float = first
			first = last
			last = swap
		low = maxf(low,first)
		high = minf(high,last)
		if low > high:
			return false
	return true
