extends SceneTree
const Armor=preload("res://campaign/equipment/armor_catalog.gd")
const Service=preload("res://campaign/equipment/armor_service.gd")
const Starter=preload("res://gameplay/starter_world_service.gd")
const Participant=preload("res://battle/core/battle_participant.gd")
const Consequence=preload("res://battle/combat/battle_combat_consequence_service.gd")
const Query=preload("res://gameplay/tactical_unit_hud_query.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Tiers=preload("res://battle/combat/battle_unit_tier_catalog.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
var errors: Array=[]
var cases:=0
func check(ok: bool,message: String):
 if not ok:errors.append(message)
func _initialize():call_deferred("run")
func run():
 var state=Starter.create();var owner: String=Starter.PLAYER_FACTION_ID
 var gang=state.get_faction(owner);gang.money=5000
 var soldier=state.get_soldier(Starter.SOLDIER_ID)
 check(soldier.armor_id=="","default unequipped")
 check(not Service.equip(state,owner,soldier.id,"field_carrier").success,"no free campaign equipment")
 check(Service.purchase(state,owner,"patrol_vest").success,"purchase")
 check(gang.money==4700 and gang.armor_inventory.patrol_vest==1,"purchase stock and funds")
 check(Service.equip(state,owner,soldier.id,"patrol_vest").success,"equip")
 check(gang.armor_inventory.patrol_vest==0,"equipped removed from stock")
 Service.purchase(state,owner,"field_carrier")
 check(Service.equip(state,owner,soldier.id,"field_carrier").success,"swap")
 check(gang.armor_inventory.patrol_vest==1 and gang.armor_inventory.field_carrier==0,"swap returns old vest")
 var stock=gang.armor_inventory.duplicate();var money: float=gang.money
 check(not Service.purchase(state,owner,"invented").success,"invalid purchase rejected")
 check(not Service.equip(state,"rival_gang",soldier.id,"patrol_vest").success,"foreign ownership rejected")
 check(gang.money==money and gang.armor_inventory==stock,"failed actions are atomic")
 var save=state.to_dict();var restored=GameState.new();restored.from_dict(save)
 check(restored.get_soldier(soldier.id).armor_id=="field_carrier","save restores armor")
 check(restored.get_faction(owner).armor_inventory==stock,"save restores inventory")
 save.soldiers[soldier.id].erase("armor_id");save.factions[owner].erase("armor_inventory")
 restored.from_dict(save)
 check(restored.get_soldier(soldier.id).armor_id=="" and restored.get_faction(owner).armor_inventory.is_empty(),"old saves")
 check(Service.equip(state,owner,soldier.id,"").success and gang.armor_inventory.field_carrier==1,"unequip")
 gang.money=0;stock=gang.armor_inventory.duplicate()
 check(not Service.purchase(state,owner,"reinforced_carrier").success and gang.armor_inventory==stock,"insufficient funds atomic")
 for faction: String in Factions.all_ids():
  for role: String in Factions.CLASSES:
   for model: String in Weapons.models_for_class(role):
    for training in range(1,4):
     for id: String in [""]+Armor.IDS:
      var p=Participant.new("test","test",faction,"attacker",role)
      p.identity=Identity.make("test",faction,role);p.weapon_model_id=model;p.unit_tier=training;p.armor_id=id;p.vitality=p.max_vitality
      var expected: float=1.5*(1.+Armor.bonus(id))
      check(is_equal_approx(p.max_vitality,expected),"capacity")
      var card=Query.card_for(p, "")
      check(card.armor_tier==Armor.tier(id) and card.unit_tier==training and is_equal_approx(card.vitality_ratio,1.),"HUD full capacity")
      Consequence.apply_trauma(null,p,.2)
      check(is_equal_approx(p.vitality,expected-.2),"damage must not clamp away armor")
      Consequence.apply_trauma(null,p,100.)
      check(not p.is_alive and p.vitality==0.,"armored units still die")
      cases+=1
 for id: String in Armor.IDS:
  check(Armor.texture(id)!=null,"standalone artwork "+id)
 print("ARMOR_RULES cases=",cases," errors=",errors)
 quit(0 if errors.is_empty() else 1)
