class_name GangArchetypeCatalog
extends RefCounted

# Presentation identity profiles for gang archetypes.
# Not a faction simulation system and not a name generator.

const ARCHETYPE_LOCAL_STREET_GANG := "local_street_gang"
const ARCHETYPE_RUSSIAN_ORGANIZED_CRIME := "russian_organized_crime"

const ARCHETYPE_ITALIAN_MOB := "italian_mob"

const CLOTHING_FAMILY_LOCAL := "neighborhood_street_criminal"
const CLOTHING_FAMILY_RUSSIAN := "organized_crime_crew"

const LOOK_01 := "look_01"
const LOOK_02 := "look_02"
const LOOK_03 := "look_03"

const LOCAL_APPEARANCE_VARIANTS: Array[String] = [LOOK_01, LOOK_02, LOOK_03]
const RUSSIAN_APPEARANCE_VARIANTS: Array[String] = [LOOK_01, LOOK_02, LOOK_03]


static func is_known(archetype_id: String) -> bool:
	return (
		archetype_id == ARCHETYPE_LOCAL_STREET_GANG
		or archetype_id == ARCHETYPE_RUSSIAN_ORGANIZED_CRIME
		or archetype_id == ARCHETYPE_ITALIAN_MOB
	)


static func profile(archetype_id: String) -> Dictionary:
	if archetype_id == ARCHETYPE_ITALIAN_MOB:
		return {"id":archetype_id,"clothing_family":"italian_suit","appearance_variants":LOCAL_APPEARANCE_VARIANTS,"unit_catalog_archetype":"unit_italian_mob"}
	if archetype_id == ARCHETYPE_LOCAL_STREET_GANG:
		return {
			"id": ARCHETYPE_LOCAL_STREET_GANG,
			"clothing_family": CLOTHING_FAMILY_LOCAL,
			"appearance_variants": LOCAL_APPEARANCE_VARIANTS,
			"unit_catalog_archetype": "unit_local_street_gang",
		}
	if archetype_id == ARCHETYPE_RUSSIAN_ORGANIZED_CRIME:
		return {
			"id": ARCHETYPE_RUSSIAN_ORGANIZED_CRIME,
			"clothing_family": CLOTHING_FAMILY_RUSSIAN,
			"appearance_variants": RUSSIAN_APPEARANCE_VARIANTS,
			"unit_catalog_archetype": "unit_russian_organized_crime",
		}
	return {}


static func appearance_variants(archetype_id: String) -> Array[String]:
	if archetype_id == ARCHETYPE_ITALIAN_MOB:
		return LOCAL_APPEARANCE_VARIANTS.duplicate()
	if archetype_id == ARCHETYPE_LOCAL_STREET_GANG:
		return LOCAL_APPEARANCE_VARIANTS.duplicate()
	if archetype_id == ARCHETYPE_RUSSIAN_ORGANIZED_CRIME:
		return RUSSIAN_APPEARANCE_VARIANTS.duplicate()
	var empty: Array[String] = []
	return empty


static func unit_catalog_archetype(archetype_id: String) -> String:
	return str(profile(archetype_id).get("unit_catalog_archetype", ""))
