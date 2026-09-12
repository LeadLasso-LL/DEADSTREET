extends SceneTree
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Tiers=preload("res://battle/combat/battle_unit_tier_catalog.gd")
const Participant=preload("res://battle/core/battle_participant.gd")
const State=preload("res://battle/core/battle_state.gd")
const SoldierData=preload("res://campaign/units/soldier.gd")
const Query=preload("res://gameplay/tactical_unit_hud_query.gd")
var failures: Array[String]=[]
func check(ok: bool,message: String) -> void:
	if not ok: failures.append(message)
func _initialize() -> void:
	var b=State.new("tier_test","test","","","attacker","defender","deployment")
	var combinations: int=0
	check(Factions.all_ids().size()==23,"23 factions")
	check(Anim.manifest().clips.size()==17,"17 regular animation states")
	for faction: String in Factions.all_ids():
		for role: String in Factions.CLASSES:
			var p=Participant.new(faction+role,"","player_gang","attacker",role)
			b.participants[p.participant_id]=p
			p.identity=Identity.make(p.participant_id,faction,role)
			check(p.has_identity(),"identity "+faction+role)
			for model: String in Weapons.models_for_class(role):
				check(Weapons.equip_for_setup(b,p,model),"class assignment "+faction+model)
				var variant=Anim.variant_for(faction,role,model)
				check(not variant.is_empty(),"binding "+faction+model)
				var baseline=Weapons.get_model(model)
				var miss: float=baseline.miss_probability
				for tier in range(1,4):
					check(Tiers.set_for_setup(b,p,tier),"tier set")
					var trained=Weapons.for_participant(p)
					check(trained!=null and trained.has_valid_combat_profile(),"valid profile")
					check(p.weapon_model_id==model,"tier keeps weapon")
					check(Query.card_for(p,"").unit_tier==tier,"HUD stars")
					check(is_equal_approx(p.vitality,1.5),"tier keeps health")
					for field: String in ["max_range","movement_multiplier","magazine_capacity","shots_per_second","graze_trauma","solid_trauma","critical_trauma","tier"]:
						check(trained.get(field)==baseline.get(field),"preserved "+field)
					if tier==1:check(trained==baseline,"tier one exact baseline")
					else:
						check(trained.miss_probability<baseline.miss_probability,"accuracy benefit")
						check(trained.reload_seconds<baseline.reload_seconds,"reload benefit")
					check(baseline.miss_probability==miss,"shared model immutable")
					combinations+=1
			var other: String="ak47" if role!="rifle" else "glock_17"
			var prior: String=p.weapon_model_id
			check(not Weapons.equip_for_setup(b,p,other),"reject class mismatch")
			check(p.weapon_model_id==prior,"failed assignment keeps weapon")
			check(not Tiers.set_for_setup(b,p,4),"reject invalid tier")
			b.battle_phase="active"
			check(not Tiers.set_for_setup(b,p,1),"no mid-battle tier mutation")
			check(not Weapons.equip_for_setup(b,p,prior),"no mid-battle free reload")
			b.battle_phase="deployment"
	var legacy_participant=Participant.new("legacy","","player_gang","attacker","rifle")
	legacy_participant.unit_tier=3
	var before_profiles=Tiers._profiles.size()
	var legacy_profile=Weapons.for_participant(legacy_participant)
	for tick in range(200):
		check(Weapons.for_participant(legacy_participant)==legacy_profile,"legacy tier profile retained")
	check(Tiers._profiles.size()<=before_profiles+1,"legacy tier cache stays bounded")
	check(legacy_profile.solid_trauma==Weapons.get_definition("rifle").solid_trauma,"legacy tier preserves damage")
	var soldier=SoldierData.new("test","player","","pistol")
	soldier.unit_tier=3
	var restored=SoldierData.new();restored.from_dict(soldier.to_dict())
	check(restored.unit_tier==3,"save tier round trip")
	var legacy=soldier.to_dict();legacy.erase("unit_tier");restored.from_dict(legacy)
	check(restored.unit_tier==1,"old saves default tier one")
	restored.unit_tier=99;check(restored.unit_tier==3,"tier clamps high")
	restored.unit_tier=-1;check(restored.unit_tier==1,"tier clamps low")
	print("ROSTER_RULES combinations=",combinations," failures=",failures)
	quit(0 if failures.is_empty() else 1)
