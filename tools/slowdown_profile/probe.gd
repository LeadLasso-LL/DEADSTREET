extends RefCounted
static var stats: Dictionary = {}
static func record(key: String, usec: int) -> void:
	var item: Dictionary = stats.get(key, {"calls":0,"total_us":0,"max_us":0})
	item.calls += 1
	item.total_us += usec
	item.max_us = maxi(item.max_us, usec)
	stats[key] = item
