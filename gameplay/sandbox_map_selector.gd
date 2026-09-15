extends Panel
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
signal map_selected(id: String)
var selected="harold"
var option: OptionButton
var hero: TextureRect
var heading: Label
var summary: Label
var place: Label
var choices={}
var font: SystemFont
func _ready():
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 add_theme_stylebox_override("panel",Card.style(Color("#182329"),Color("#6d7565")))
 Card.label(self,Vector2(16,13),Vector2(300,25),"BATTLEFIELD",17,Color("#d2bf8d"),font)
 option=OptionButton.new();option.name="MapDropdown";add_child(option)
 option.fit_to_longest_item=false;option.clip_text=true;option.add_theme_font_size_override("font_size",14)
 for id in Maps.IDS:option.add_item(Maps.info(id).name);option.set_item_metadata(option.item_count-1,id)
 option.item_selected.connect(func(i):map_selected.emit(Maps.IDS[i]))
 hero=picture(self);hero.name="SelectedMapImage"
 heading=Card.label(self,Vector2.ZERO,Vector2.ZERO,"",21,Color("#ece9db"),font);heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 place=Card.label(self,Vector2.ZERO,Vector2.ZERO,"",12,Color("#d2bf8d"),font)
 summary=Card.label(self,Vector2.ZERO,Vector2.ZERO,"",12,Color("#adbcb8"),font);summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 for id in Maps.IDS:
  var b=Button.new();b.name="Map_"+id;add_child(b);b.toggle_mode=true;b.tooltip_text=Maps.info(id).name+" / "+Maps.info(id).hint;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
  b.pressed.connect(func():map_selected.emit(id))
  var p=picture(b);p.texture=Maps.texture(id)
  var label=Card.label(b,Vector2.ZERO,Vector2.ZERO,Maps.info(id).name,11,Color("#e5e6d9"),font);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.mouse_filter=Control.MOUSE_FILTER_IGNORE
  choices[id]={"button":b,"image":p,"label":label}
 select_map(selected);resized.connect(arrange);arrange()
func picture(parent: Node) -> TextureRect:
 var p=TextureRect.new();parent.add_child(p);p.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;p.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;p.clip_contents=true;p.mouse_filter=Control.MOUSE_FILTER_IGNORE;p.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;return p
func arrange():
 if hero==null:return
 var w=size.x-32.
 option.position=Vector2(16,47);option.size=Vector2(w,38)
 var hero_h=clampf(size.y-382.,140.,204.)
 hero.position=Vector2(16,86);hero.size=Vector2(w,hero_h)
 var title_y=98.+hero_h
 heading.position=Vector2(16,title_y);heading.size=Vector2(w,54)
 place.position=Vector2(16,title_y+50);place.size=Vector2(w,22)
 summary.position=Vector2(16,title_y+72);summary.size=Vector2(w,37)
 var columns=3 if Maps.IDS.size()>4 else 2
 var rows=ceili(float(Maps.IDS.size())/columns)
 var tile_w=(w-(columns-1)*10.)/columns
 var tile_h=78.
 for i in range(Maps.IDS.size()):
  var c=choices[Maps.IDS[i]]
  c.button.position=Vector2(16+(i%columns)*(tile_w+10),size.y-rows*(tile_h+8)-2.+floori(float(i)/columns)*(tile_h+8));c.button.size=Vector2(tile_w,tile_h)
  c.image.position=Vector2(3,3);c.image.size=Vector2(tile_w-6,tile_h-32)
  c.label.position=Vector2(3,tile_h-29);c.label.size=Vector2(tile_w-6,27)
func select_map(id: String):
 selected=id
 if hero==null:return
 option.select(Maps.IDS.find(id));hero.texture=Maps.texture(id);heading.text=Maps.info(id).name;place.text=Maps.info(id).place.to_upper();summary.text=Maps.info(id).hint
 for key in choices:
  var b=choices[key].button;b.set_pressed_no_signal(key==id)
  var border=Color("#d2bf8d") if key==id else Color("#425554")
  b.add_theme_stylebox_override("normal",Card.style(Color("#263831") if key==id else Color("#111c21"),border))
  b.add_theme_stylebox_override("pressed",Card.style(Color("#34473b"),Color("#d2bf8d")))
  b.add_theme_stylebox_override("hover",Card.style(Color("#34433e"),Color("#ddd1ae")))
