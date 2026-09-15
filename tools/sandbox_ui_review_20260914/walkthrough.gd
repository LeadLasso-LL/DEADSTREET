extends SceneTree

const Config = preload("res://gameplay/sandbox_force_config.gd")
const OUT = "C:/Users/brand/OneDrive/Documents/dead-street/tools/sandbox_ui_review_20260914/"
var scene
var panel
var pointer: Node2D
var events: Array = []
var checks: int = 0
var errors: Array = []
var frame: int = 0
var fast: bool = false
var chapter: String = "Opening the sandbox"
var focus: String = "full"

class Pointer extends Node2D:
 var pressed: bool = false
 func _draw():
  if pressed: draw_arc(Vector2.ZERO, 17, 0, TAU, 40, Color("#e1bd69"), 3, true)
  draw_colored_polygon(PackedVector2Array([Vector2(0,0),Vector2(0,23),Vector2(6,17),Vector2(11,27),Vector2(16,24),Vector2(11,15),Vector2(20,15)]), Color("#10181c"))
  draw_colored_polygon(PackedVector2Array([Vector2(2,3),Vector2(2,18),Vector2(7,13),Vector2(12,23),Vector2(13,22),Vector2(9,13),Vector2(15,13)]), Color("#fff5d7"))

func _initialize():
 for arg in OS.get_cmdline_user_args():
  if arg == "--fast": fast = true
 process_frame.connect(func():frame += 1)
 call_deferred("run")

func hold(seconds: float):
 var count = maxi(2, roundi(seconds * (3.0 if fast else 30.0)))
 for _i in range(count): await process_frame

func check(ok: bool, label: String):
 checks += 1
 if not ok:
  errors.append(label)
  printerr("UI_REVIEW_FAIL ", label)
  finish(1)

func mark(title: String, area: String = "full"):
 chapter = title
 focus = area
 events.append({"frame":frame,"seconds":float(frame)/30.0,"chapter":title,"focus":area})
 print("UI_STEP ", frame, " ", title)

func shot(name: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OUT + name + ".png")

func move_to(at: Vector2):
 var tween = create_tween()
 tween.tween_property(pointer, "position", at, 0.05 if fast else 0.22).set_trans(Tween.TRANS_SINE)
 await tween.finished
 var motion = InputEventMouseMotion.new()
 motion.position = at
 motion.global_position = at
 Input.parse_input_event(motion)
 await process_frame

func click(control: Control):
 check(is_instance_valid(control), "click target exists")
 var at: Vector2 = control.get_global_rect().get_center()
 await move_to(at)
 pointer.pressed = true
 pointer.queue_redraw()
 var down = InputEventMouseButton.new()
 down.position = at; down.global_position = at; down.button_index = MOUSE_BUTTON_LEFT; down.pressed = true
 Input.parse_input_event(down)
 await process_frame
 var up = InputEventMouseButton.new()
 up.position = at; up.global_position = at; up.button_index = MOUSE_BUTTON_LEFT; up.pressed = false
 Input.parse_input_event(up)
 await process_frame
 pointer.pressed = false
 pointer.queue_redraw()
 await hold(0.45)

func button(node: Node, text: String):
 if node is Button and node.text == text: return node
 for child in node.get_children():
  var result = button(child, text)
  if result != null: return result
 return null

func choose(option: OptionButton, index: int):
 check(index >= 0 and index < option.item_count, "valid option index")
 await click(option)
 var popup = option.get_popup()
 check(popup.visible, "dropdown opened")
 popup.set_focused_item(index)
 await hold(0.8)
 if panel != null and option == panel.map_option: await shot("map_menu")
 var key = InputEventKey.new()
 key.keycode = KEY_ENTER; key.physical_keycode = KEY_ENTER; key.pressed = true
 Input.parse_input_event(key)
 await process_frame
 key = InputEventKey.new()
 key.keycode = KEY_ENTER; key.physical_keycode = KEY_ENTER; key.pressed = false
 Input.parse_input_event(key)
 await hold(0.5)
 # Row-changing choices legitimately rebuild and free the old OptionButton.
 if is_instance_valid(option): check(option.selected == index, "dropdown applied selection")

func scroll_rows(side: String, index: int):
 var scroll: ScrollContainer = panel.lists[side].get_parent()
 var target: int = mini(index * 104, maxi(0, panel.lists[side].size.y - scroll.size.y))
 await move_to(scroll.get_global_rect().get_center())
 var tween = create_tween()
 tween.tween_property(scroll,"scroll_vertical",target,0.08 if fast else 0.55)
 await tween.finished
 await hold(0.3)

func configure_side(side: String, weapon_indices: Array, tiers: Array, armors: Array):
 for index in range(5):
  await scroll_rows(side,index)
  mark(side.capitalize()+" / "+str(panel.config[side].units[index]["class"]).capitalize(),side)
  await choose(panel.row_widgets[side][index].weapon, weapon_indices[index])
  await choose(panel.row_widgets[side][index].tier, tiers[index])
  await choose(panel.row_widgets[side][index].armor, armors[index])
  check(panel.config[side].units[index].tier == tiers[index]+1,"per-unit tier applied")
  check(panel.config[side].units[index].armor == ("" if armors[index]==0 else Config.Armor.IDS[armors[index]-1]),"per-unit armor applied")
  await hold(0.5)
 await shot(side+"_loadouts")

func fleet_first(fleet):
 var scroll: ScrollContainer = fleet.grid.get_parent()
 scroll.scroll_vertical = 0
 await hold(0.5)
 return button(fleet.grid.get_child(0),"ADD TO CONVOY")

func run():
 DirAccess.make_dir_recursive_absolute(OUT)
 root.size = Vector2i(1152,860)
 root.content_scale_size = Vector2i(1152,860)
 root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
 root.gui_embed_subwindows = true
 DisplayServer.window_set_size(root.size)
 scene = load("res://gameplay/arsenal_review.tscn").instantiate()
 root.add_child(scene)
 var overlay = CanvasLayer.new(); overlay.layer = 200; root.add_child(overlay)
 pointer = Pointer.new(); overlay.add_child(pointer); pointer.position = Vector2(1110,845)
 await hold(1.0)
 mark("Open Battle Sandbox")
 await shot("opening")
 await hold(3.0)
 await click(button(scene.surface,"RIFLE"))
 mark("Arsenal / weapon preview")
 await click(scene.grid.get_child(2))
 await hold(2.2)
 await click(button(scene.surface,"ARMOR"))
 mark("Armor catalog / three HP tiers")
 await shot("armor_catalog")
 await hold(3.5)
 await click(button(scene.surface.get_node("ArmorCatalog"),"CLOSE"))
 await click(button(scene.surface,"CUSTOM BATTLE SETUP"))
 panel = scene.surface.get_node("ForceBuilder")
 mark("Custom Battle Setup / choose the map")
 await hold(2.0)
 await choose(panel.map_option,1)
 check(panel.config.map_id == "river_bridge","bridge selected")
 await shot("bridge_setup")
 await hold(2.0)
 mark("Choose attacking faction","attacker")
 await choose(panel.faction_options.attacker,Config.Factions.all_ids().find("mercer"))
 mark("Clear and build five attackers","attacker")
 await click(find_side_button("attacker","CLEAR"))
 check(panel.config.attacker.units.is_empty(),"clear empties attacker roster")
 check(panel.start_button.disabled,"empty roster disables Start")
 await hold(1.2)
 for i in range(5):
  await choose(panel.add_classes.attacker,i)
  await click(panel.add_buttons.attacker)
 check(panel.config.attacker.units.size()==5,"five individual attackers added")
 # Exercise the editable existing-unit class selector as well as the add-class field.
 await scroll_rows("attacker",0)
 mark("Change an existing unit class","attacker")
 await choose(panel.row_widgets.attacker[0]["class"],1)
 await choose(panel.row_widgets.attacker[0]["class"],0)
 mark("Duplicate and remove a unit","attacker")
 await click(panel.row_widgets.attacker[0]["duplicate"])
 check(panel.config.attacker.units.size()==6,"duplicate adds unit")
 await hold(0.8)
 await click(panel.row_widgets.attacker[1].remove)
 check(panel.config.attacker.units.size()==5,"remove returns to five")
 await configure_side("attacker",[2,1,3,4,2],[0,1,2,1,2],[0,1,2,3,1])
 mark("Choose defending faction","defender")
 await choose(panel.faction_options.defender,Config.Factions.all_ids().find("orlov"))
 await click(find_side_button("defender","BALANCED FIVE"))
 check(panel.config.defender.units.size()==5,"Balanced Five creates five defenders")
 await configure_side("defender",[1,3,4,2,5],[2,0,1,2,1],[3,0,1,2,3])
 mark("Attacking convoy / manual selection")
 await click(button(panel,"ATTACKING VEHICLES"))
 var fleet = panel.get_node("VehicleFleet")
 await hold(2.0)
 await click(fleet.preferred)
 await hold(1.0)
 await click(fleet.preferred)
 await click(button(fleet,"CLEAR CONVOY"))
 check(fleet.apply_button.disabled,"empty convoy rejected")
 await hold(1.2)
 await click(fleet.class_buttons.passenger_cars)
 await click(await fleet_first(fleet))
 check(fleet.apply_button.disabled,"one four-seat car cannot carry five")
 mark("Seat validation / add a second vehicle")
 await shot("insufficient_seats")
 await hold(2.0)
 await click(fleet.class_buttons.utility_vehicles)
 await click(await fleet_first(fleet))
 check(not fleet.apply_button.disabled,"mixed attacking convoy has enough seats")
 await click(fleet.class_buttons.heavy_transports)
 await hold(1.8)
 var fleet_scroll: ScrollContainer = fleet.grid.get_parent()
 await move_to(fleet_scroll.get_global_rect().get_center())
 var fleet_tween = create_tween()
 fleet_tween.tween_property(fleet_scroll,"scroll_vertical",480,0.7)
 await fleet_tween.finished
 await hold(2.0)
 await shot("fleet_scrolled")
 fleet_scroll.scroll_vertical = 0
 await click(fleet.class_buttons.two_wheelers)
 await hold(1.8)
 await shot("attacking_convoy")
 await click(fleet.apply_button)
 mark("Auto-Fit Seats / inspect automatic convoy")
 await click(button(panel,"AUTO-FIT SEATS"))
 check(panel.config.attacker.vehicles.size()==2,"auto-fit assigns two sedans for five")
 await hold(1.5)
 await click(button(panel,"ATTACKING VEHICLES"))
 fleet = panel.get_node("VehicleFleet")
 await hold(1.5)
 # Remove one automatic sedan through its visible convoy chip, then choose a utility.
 var chips: Array = []
 collect_buttons(fleet.convoy_row,chips)
 await click(chips[-1])
 check(fleet.apply_button.disabled,"removing vehicle updates seat validation")
 await click(fleet.class_buttons.utility_vehicles)
 await click(await fleet_first(fleet))
 await click(fleet.apply_button)
 mark("Defending convoy / Auto-Fit Defenders")
 await click(button(panel,"AUTO-FIT DEFENDERS"))
 await hold(1.2)
 await click(button(panel,"DEFENDING VEHICLES"))
 fleet = panel.get_node("VehicleFleet")
 await hold(1.5)
 await click(fleet.preferred)
 await hold(1.5)
 await click(fleet.preferred)
 await click(button(fleet,"CLEAR CONVOY"))
 await click(fleet.class_buttons.utility_vehicles)
 await click(await fleet_first(fleet))
 if fleet.apply_button.disabled:
  await click(fleet.class_buttons.passenger_cars)
  await click(await fleet_first(fleet))
 await shot("defending_convoy")
 await hold(2.5)
 await click(fleet.apply_button)
 mark("Final 5 vs 5 / ready to launch")
 await scroll_rows("attacker",0)
 await scroll_rows("defender",0)
 check(panel.config.attacker.units.size()==5 and panel.config.defender.units.size()==5,"final 5v5")
 check(Config.validate(panel.config).valid and not panel.start_button.disabled,"final setup valid")
 check(scene.runtime==null and scene.battle==null,"no battle launched")
 await shot("final_top")
 await hold(4.0)
 await scroll_rows("attacker",4)
 await scroll_rows("defender",4)
 await shot("final_bottom")
 await move_to(panel.start_button.get_global_rect().get_center())
 await hold(4.0)
 finish(0)

func find_side_button(side: String, text: String):
 return button(panel.counters[side].get_parent(),text)

func collect_buttons(node: Node, into: Array):
 if node is Button: into.append(node)
 for child in node.get_children():collect_buttons(child,into)

func finish(code: int):
 var report = {"checks":checks,"errors":errors,"frames":frame,"fps":30,"events":events,"no_combat":scene==null or scene.runtime==null,"config":panel.config if panel!=null else {},"fast":fast}
 FileAccess.open(OUT+("smoke.json" if fast else "record.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("UI_REVIEW_COMPLETE ",checks," checks / ",errors.size()," errors / ",frame," frames")
 quit(code)
