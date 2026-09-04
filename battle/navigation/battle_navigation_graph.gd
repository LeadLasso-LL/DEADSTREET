class_name BattleNavigationGraph
extends RefCounted

# Static visibility topology. Query start/destination are not stored here.

var stamp: String = ""
var nodes: Array[Vector2] = []
var adjacency: Array = []
var blocking_rects: Array[Rect2] = []
var build_count: int = 0
