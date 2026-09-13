extends RefCounted
static var enabled: bool = false
static var stack: Array = []
static var totals: Dictionary = {}
static var frame: Dictionary = {}
static func enter(key: String) -> void:
	if enabled: stack.append([key, Time.get_ticks_usec(), 0])
static func leave() -> void:
	if not enabled: return
	var item: Array = stack.pop_back()
	var elapsed: int = Time.get_ticks_usec()-int(item[1])
	var key: String = item[0]
	var row: Array = totals.get(key, [0,0,0,0])
	row[0]+=1;row[1]+=elapsed;row[2]+=elapsed-int(item[2]);row[3]=maxi(row[3],elapsed)
	totals[key]=row
	frame[key]=frame.get(key,0)+elapsed
	if not stack.is_empty():stack.back()[2]+=elapsed
