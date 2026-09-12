@tool
extends EditorPlugin

const RosterExport = preload("res://addons/faction_roster_export/roster_export.gd")
var exporter: EditorExportPlugin

func _enter_tree() -> void:
	exporter = RosterExport.new()
	add_export_plugin(exporter)

func _exit_tree() -> void:
	if exporter != null:
		remove_export_plugin(exporter)
	exporter = null
