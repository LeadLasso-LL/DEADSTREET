extends RefCounted
const Weapons = preload("res://battle/combat/battle_weapon_catalog.gd")
const Vehicles = preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const VEHICLE_SPECS = [
	["Price", "price", 0, "money", -1, "Purchase price per vehicle."],
	["Seats, incl. driver", "unit_capacity", 0, "", 1, "Total unit seats, including the driver."],
	["Road movement", "movement_per_turn", 1, "/turn", 1, "Road movement per turn. A convoy travels at its slowest vehicle's pace."],
	["Upkeep", "upkeep_per_turn", 0, "money", -1, "Operating cost per turn. Lower is cheaper."],
	["Resource capacity", "resource_capacity", 0, "", 1, "Resource carrying capacity."],
	["Protective cover", "cover", 0, "bool", 1, "Whether the vehicle provides protective cover."],
	["Doors", "doors", 0, "", 0, "Door count; a design difference, not an automatic improvement."],
	["Length", "length", 1, "m", 0, "Physical length. A larger footprint is a tradeoff."],
	["Width", "width", 1, "m", 0, "Physical width. A larger footprint is a tradeoff."],
	["Height", "height", 1, "m", 0, "Physical height. A larger footprint is a tradeoff."]
]
# Same catalogue values feed the normal details and the comparison. Direction is
# +1 when more is beneficial, -1 when less is beneficial, 0 for a neutral tradeoff.
const SPECS = [
	["Price", "price", 0, "money", -1, "Purchase price per firearm; recruitment and training are separate."],
	["Range", "max_range", 1, "", 1, "Maximum firing distance in battlefield units."],
	["Fire rate", "shots_per_second", 2, "/s", 1, "Shots per second while firing; aiming, movement and reloads can slow this."],
	["Movement", "movement_multiplier", 0, "%", 1, "Change to normal movement speed. Differences are percentage points (pp)."],
	["Standard hit damage", "solid_trauma", 2, "", 1, "Health damage from a solid hit."],
	["Critical hit damage", "critical_trauma", 2, "", 1, "Health damage from a critical hit."],
	["Graze damage", "graze_trauma", 2, "", 1, "Health damage from a grazing hit."],
	["Initial aim", "acquire_seconds", 2, "s", -1, "Time to acquire an initial shot. Shorter is faster."],
	["Aim recovery", "reacquire_seconds", 2, "s", -1, "Time to reacquire a shot after losing settled aim. Shorter is faster."],
	["Shots before reload", "magazine_capacity", 0, "", 1, "Shots per magazine before the next reload."],
	["Reload cycle", "reload_seconds", 1, "s", -1, "Reload duration. Shorter is faster."],
	["Recoil per shot", "recoil_per_shot", 3, "", -1, "How much each shot unsettles aim. Lower is steadier."],
	["Recoil recovery", "recoil_recovery", 3, "", 1, "How quickly accumulated recoil settles. Higher is faster."],
	["Base solid hit chance", "solid_probability", 0, "%", 1, "Chance before conditions and unit bonuses. Difference is in percentage points."],
	["Base critical hit chance", "critical_probability", 0, "%", 1, "Chance before conditions and unit bonuses. Difference is in percentage points."],
	["Base graze chance", "graze_probability", 0, "%", 0, "A tradeoff: grazes can replace misses or stronger hits. No automatic better/worse rating."],
	["Base miss chance", "miss_probability", 0, "%", -1, "Chance before conditions and unit bonuses. Lower means fewer misses."]
]

static func money(value: float) -> String:
	var digits = str(int(abs(value)))
	var result = ""
	for i in range(digits.length()):
		if i > 0 and (digits.length()-i)%3 == 0: result += ","
		result += digits[i]
	return result

static func rows(id: String, vehicles: bool = false) -> Array:
	var model = Vehicles.model(id) if vehicles else Weapons.get_model(id)
	var result = []
	for spec in (VEHICLE_SPECS if vehicles else SPECS):
		var value = float(Weapons.purchase_price(id)) if spec[1] == "price" and not vehicles else float(model.get(spec[1]))
		if spec[1] == "movement_multiplier": value = (value-1.0)*100.0
		elif spec[3] == "%": value *= 100.0
		var row = {"label":spec[0], "key":spec[1], "value":value, "precision":spec[2], "unit":spec[3], "direction":spec[4], "hint":spec[5]}
		row.text = format_value(row, value)
		result.append(row)
	return result

static func format_value(row: Dictionary, value: float, delta: bool = false) -> String:
	# Round at the displayed precision before detecting zero, avoiding +/-0.
	var scale = pow(10.0, row.precision)
	value = round(value*scale)/scale
	if delta and is_zero_approx(value): return "—"
	if row.unit == "bool":
		if delta: return "Added" if value > 0 else "Lost"
		return "Yes" if value > 0 else "No"
	var sign_text = ("+" if value > 0 else "−") if delta else ""
	if row.unit == "money": return sign_text+"$"+money(value)
	var number = ("%."+str(row.precision)+"f") % abs(value) if delta else ("%."+str(row.precision)+"f") % value
	if not delta and row.key == "movement_multiplier" and value > 0: number = "+"+number
	return sign_text+number+(" pp" if delta and row.unit == "%" else str(row.unit))

static func compare(selected: String, hovered: String, vehicles: bool = false) -> Array:
	var base = rows(selected, vehicles)
	var other = rows(hovered, vehicles)
	var result = []
	for i in range(base.size()):
		var row = other[i].duplicate()
		row.base_text = base[i].text
		row.base_value = base[i].value
		row.delta = row.value-row.base_value
		row.delta_text = format_value(row, row.delta, true)
		row.benefit = 0 if row.delta_text == "—" else sign(row.delta)*row.direction
		result.append(row)
	return result
