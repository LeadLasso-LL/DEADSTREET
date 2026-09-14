extends SceneTree
const OUT = "C:/Users/brand/OneDrive/Documents/dead-street/tools/sandbox_tutorial_20260914/"
const Config = preload("res://gameplay/sandbox_force_config.gd")
var regions: Array = []
func _initialize(): call_deferred("run")
func add_region(id: String, rect: Rect2, title: String, help: String, priority: int = 10):
	var clipped = rect.intersection(Rect2(0,0,1440,1000))
	if clipped.size.x < 2 or clipped.size.y < 2: return
	regions.append({"id":id,"rect":[clipped.position.x,clipped.position.y,clipped.size.x,clipped.size.y],"title":title,"text":help,"priority":priority})
func control(id: String, node: Control, title: String, help: String, priority: int = 40):
	if node.is_visible_in_tree(): add_region(id,node.get_global_rect(),title,help,priority)
func run():
	root.size = Vector2i(1440,1000)
	DisplayServer.window_set_size(root.size)
	var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var config = Config.from_legacy({"attacker":{"faction":"mercer"},"defender":{"faction":"orlov"}})
	for side in ["attacker","defender"]:
		for i in range(5):
			config[side].units[i].tier = 2
			config[side].units[i].armor = "field_carrier"
	await scene.start_battle(false,config)
	scene.set_process(false)
	var b = scene.battle
	if b == null: printerr("TUTORIAL_FAIL battle"); quit(1); return
	var view = scene.runtime.get_node("TacticalBattleView")
	view.battle_presentation.skip_to_ready()
	await create_timer(.15).timeout
	var started = load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
	if started == null or not started.success: printerr("TUTORIAL_FAIL start"); quit(1); return
	scene.ready_started = true
	scene.set_process(true)
	view._dusk_zoom = 1.0
	view._dusk_pan = Vector2.ZERO
	view._frame_camera()
	await create_timer(12.0).timeout
	var hud = view.get_node("CommandHudLayer").get_child(0)
	var orders = view.orders_controller
	orders.select_class()
	orders.command_selected("hold")
	await create_timer(.8).timeout
	b.tactical_paused = true
	await create_timer(.15).timeout
	var groups = "Use these buttons to select all of your units for direct commands, or select units by weapon class. Hold Shift when choosing a weapon class to add it to your selection."
	for id in hud.class_buttons: control("group_"+id,hud.class_buttons[id],"SELECT YOUR UNITS",groups)
	var commands = {
		"hold":["HOLD","Select units, then click Hold. They move to nearby protective cover and stay there. They aim and fire automatically."],
		"push":["PUSH","Select units, then click Push. Move the pointer left or right to place an advance line on the map, then left-click to confirm. Units advance using cover and resume fighting on their own when they reach their positions. Right-click or press Esc to cancel the line."],
		"fall_back":["FALL BACK","Select units, then click Fall Back. Move the pointer left or right to place a retreat line, then left-click to confirm. Units seek cover on your side of the line and hold there. Right-click or press Esc to cancel the line."],
		"clear":["CLEAR ORDERS","Select units, then click Clear Orders to remove their movement, cover and target orders. They return to fighting on their own."]}
	for id in hud.buttons: control(id,hud.buttons[id],commands[id][0],commands[id][1])
	var playback = [["PAUSE","Pause the fight to inspect units and give orders. Press Space to pause or resume; choose a speed button to resume at that speed."],["SLOW MOTION","Run the fight at half speed. You can still select units and give orders."],["NORMAL SPEED","Resume the fight at normal speed."],["FAST FORWARD","Run the fight at one and a half times normal speed."]]
	for i in range(4): control("playback_%d"%i,hud.playback_buttons[i],playback[i][0],playback[i][1])
	for node in hud.playback.get_children():
		if node is CheckButton:
			control(node.text.to_lower(),node,node.text,"Show or hide faction emblems above units. The highlighted emblem marks a selected unit." if node.text=="EMBLEMS" else "Turn battle audio on or off.")
	control("count",hud.count_label,"YOUR ROSTER","Active counts your living units, including wounded units. Eliminated counts units you have lost. Their cards remain in the roster.")
	control("faction",hud.faction_label,"YOUR FACTION","This is the faction you command. The unit cards below belong to your side.")
	control("faction_emblem",hud.faction_emblem,"YOUR EMBLEM","Look for this emblem above units to recognize your side.")
	control("strength",hud.strength_label,"RELATIVE STRENGTH","Compare the two forces here. Advantage, Even or Disadvantage gives a quick strength comparison; it does not guarantee the outcome.")
	control("strength_bar",hud.strength_fill.get_parent(),"STRENGTH BAR","Green is your side's share of the strength comparison; red is the enemy's share. More green means a stronger position.")
	control("feedback",hud.feedback_label,"ORDER FEEDBACK","Check this message when an order cannot be carried out. A unit may be wounded, a cover position may be occupied, or no suitable route or protective position may be available.")
	for id in hud.cards:
		var card = hud.cards[id]
		control("card_"+id,card,"UNIT CARD","Click a card to select that unit. Shift-click to add or remove it from your selection. Highlighted cards are selected. Eliminated units cannot receive orders.",30)
		control("portrait_"+id,card.portrait,"UNIT PORTRAIT","This picture identifies the unit. Click its card to select it; Shift-click to change a group selection.")
		control("weapon_icon_"+id,card.weapon_symbol,"WEAPON CLASS","This symbol identifies the unit's weapon class. Use the matching class button above to select units with that class.")
		control("role_"+id,card.role,"WEAPON CLASS","The unit's weapon class. Units aim, fire and reload automatically while following your orders.")
		control("weapon_"+id,card.weapon_model,"EQUIPPED WEAPON","The weapon this unit is carrying. Its weapon affects how it fights, including range and rate of fire.")
		control("tier_"+id,card.number,"TIER AND UNIT NUMBER","T is the unit's tier. The number after it identifies this unit in your roster. Unit tier and weapon tier are separate.")
		control("health_"+id,card.status,"HEALTH AND STATUS","The percentage shows remaining health. Wounded units prioritize survival and cannot follow new combat orders. Eliminated units are out of the fight.")
		add_region("health_bar_"+id,Rect2(card.health.get_global_rect().position,Vector2(card.get_global_rect().size.x-15,7)),"HEALTH BAR","The bar shrinks as this unit loses health. Yellow indicates a wounded unit; an empty bar means the unit is eliminated.",45)
		if not card.command_status.text.is_empty(): control("order_"+id,card.command_status,"CURRENT ORDER","Holding, Pushing or Falling Back shows this unit's current group order. Choose another order to replace it, or use Clear Orders.")
	var transform = view.get_global_transform_with_canvas()
	var geometry = b.battlefield_geometry
	var cover_help = "Select your units, then left-click this cover object to send them to available protective positions around it. Units need a reachable, unoccupied position. Cover protects from some directions, so watch for enemies moving around it."
	for prop in preload("res://battle/geometry/harold_street_catalog.gd").props():
		if prop[2] == "building":
			var area: Rect2 = transform * view._rect_to_view(prop[1])
			# The visible facade rises above its ground footprint.
			area.position.y -= 130 * view._camera.zoom.y
			area.size.y += 130 * view._camera.zoom.y
			add_region("building_"+prop[0],area,"BUILDING", "Buildings block movement and shots. Move around them to reach the other side. Use nearby cover objects for protective positions.",5)
	for id in geometry.cover_objects:
		var area: Rect2 = transform * view._cover_object_hit_rect(b,id)
		var object = geometry.get_cover_object(id)
		var obstacle = geometry.get_obstacle(object.associated_obstacle_id) if not object.associated_obstacle_id.is_empty() else null
		if obstacle != null and obstacle.presentation_kind not in ["trash_can","trash_can_fallen"]:
			area.position.y -= 7 * view._camera.zoom.y
			area.size.y += 7 * view._camera.zoom.y
		add_region("cover_"+id,area,"TAKE COVER",cover_help,20)
	for id in b.participants:
		var p = b.get_participant(id)
		if not view.actor_presenter._unit_nodes.has(id): continue
		var node = view.actor_presenter._unit_nodes[id]
		var point: Vector2 = node.get_global_transform_with_canvas()*Vector2.ZERO
		var friendly: bool = p.side_id==b.attacker_side_id
		var title = "YOUR UNIT" if friendly else "ENEMY UNIT"
		var help = "Left-click a unit to select it. Shift-click to add or remove it from a group. Drag a box around friendly units to select several. Then click the map or use an order button." if friendly else "With your units selected, left-click an enemy to make it their priority target. Your units fire when they have range and a clear shot; this order does not make them chase."
		if not p.is_alive: title="ELIMINATED UNIT";help="This unit is out of the fight and can no longer move or attack."
		elif p.is_wounded: title="WOUNDED UNIT";help="This unit prioritizes survival and cannot follow new combat orders. Its card remains available for inspection."
		var scale_factor: float = view._camera.zoom.x
		add_region("unit_"+id,Rect2(point-Vector2(12,30)*scale_factor,Vector2(24,34)*scale_factor),title,help,25)
		if view.battle_presentation.markers.has(id): control("marker_"+id,view.battle_presentation.markers[id],"FACTION EMBLEM","The emblem identifies this unit's faction. A highlighted emblem shows a selected unit. Use the Emblems switch to hide or show these markers.",28)
	control("battle_context",view.battle_presentation.context,"BATTLE LOCATION AND SIDES","This panel names the battlefield and shows which faction is attacking and which is defending.",50)
	add_region("map",Rect2(0,0,1440,hud.surface.position.y),"MOVE AND LOOK AROUND","With units selected, left-click open ground to move them there. Drag a box to select friendly units. Scroll to zoom, hold the middle mouse button and drag to pan, or press Home to fit the map. Right-click or press Esc to clear your selection.",0)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"harold.png")
	var data = {"schema_version":1,"size":[1440,1000],"map":"harold","attacker":"mercer","defender":"orlov","battle_seconds":scene.battle_clock,"phase":b.battle_phase,"regions":regions}
	var f=FileAccess.open(OUT+"harold.json",FileAccess.WRITE); f.store_string(JSON.stringify(data,"\t")); f.close()
	print("TUTORIAL_CAPTURE_OK ",regions.size()," regions at ",scene.battle_clock," seconds")
	quit()
