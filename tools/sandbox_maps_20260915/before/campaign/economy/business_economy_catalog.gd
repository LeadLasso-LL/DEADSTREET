class_name BusinessEconomyCatalog
extends RefCounted

const BusinessEconomyDefinition := preload("res://campaign/economy/business_economy_definition.gd")

var _definitions: Dictionary[String, BusinessEconomyDefinition] = {}


func add_definition(definition: BusinessEconomyDefinition) -> bool:
	if definition == null:
		push_error("BusinessEconomyCatalog.add_definition: definition is null.")
		return false
	if definition.business_type_id.is_empty():
		push_error("BusinessEconomyCatalog.add_definition: business_type_id is empty.")
		return false
	if _definitions.has(definition.business_type_id):
		push_error(
			"BusinessEconomyCatalog.add_definition: duplicate business_type_id '%s'."
			% definition.business_type_id
		)
		return false
	_definitions[definition.business_type_id] = definition
	return true


func get_definition(business_type_id: String) -> BusinessEconomyDefinition:
	if business_type_id.is_empty() or not _definitions.has(business_type_id):
		return null
	return _definitions[business_type_id]


func has_definition(business_type_id: String) -> bool:
	if business_type_id.is_empty():
		return false
	return _definitions.has(business_type_id)
