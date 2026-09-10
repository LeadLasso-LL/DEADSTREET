extends RefCounted
const Query=preload("res://gameplay/tactical_unit_hud_query.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const NAMES={"smg":"IMI UZI","rifle":"AK-47","pistol":"GLOCK 17","shotgun":"REMINGTON 870"}
static var textures={}
static func style(fill: Color,border: Color) -> StyleBoxFlat:
 var s=StyleBoxFlat.new();s.bg_color=fill;s.border_color=border;s.set_border_width_all(1);s.set_corner_radius_all(2);return s
static func label(parent: Node,at: Vector2,sz: Vector2,text: String,points: int,color: Color,font: Font) -> Label:
 var l=Label.new();parent.add_child(l);l.position=at;l.size=sz;l.text=text;l.add_theme_font_override("font",font);l.add_theme_font_size_override("font_size",points);l.add_theme_color_override("font_color",color);l.mouse_filter=Control.MOUSE_FILTER_IGNORE;return l
static func build(parent: Node,at: Vector2,font: Font) -> Dictionary:
 var card=Button.new();parent.add_child(card);card.position=at;card.size=Vector2(141,124);card.focus_mode=Control.FOCUS_NONE
 var normal=style(Color("#20282b"),Color("#475153"));var selected=style(Color("#41443b"),Color("#b9ad83"))
 card.add_theme_stylebox_override("normal",normal);card.add_theme_stylebox_override("hover",selected);card.add_theme_stylebox_override("pressed",selected)
 card.add_theme_stylebox_override("disabled",style(Color("#231e21"),Color("#5c343b")))
 var status=label(card,Vector2(8,4),Vector2(125,12),"ACTIVE",9,Color("#83b889"),font);status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var portrait=TextureRect.new();card.add_child(portrait);portrait.position=Vector2(9,19);portrait.size=Vector2(123,62)
 portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var role=label(card,Vector2(8,83),Vector2(125,15),"",12,Color("#e3e1d3"),font);role.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var gun=label(card,Vector2(5,100),Vector2(131,13),"",10,Color("#9caba9"),font);gun.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var bg=ColorRect.new();card.add_child(bg);bg.position=Vector2(9,116);bg.size=Vector2(123,4);bg.color=Color("#11181c");bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var health=ColorRect.new();card.add_child(health);health.position=Vector2(9,116);health.size=Vector2(123,4);health.mouse_filter=Control.MOUSE_FILTER_IGNORE
 return {"root":card,"status":status,"portrait":portrait,"role":role,"gun":gun,"health":health,"id":"","normal":normal,"selected":selected}
static func update(w: Dictionary,p,selected: String="",interactive=true) -> void:
 var c=Query.card_for(p,selected);w.id=c.participant_id
 var state="DEAD" if not c.is_alive else ("WOUNDED" if c.is_wounded else "ACTIVE")
 var tint=Color("#d7656a") if state=="DEAD" else (Color("#ddbd72") if state=="WOUNDED" else Color("#83b889"))
 w.status.text=state;w.status.add_theme_color_override("font_color",tint)
 w.root.disabled=not c.can_select;w.root.mouse_filter=Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
 w.root.add_theme_stylebox_override("normal",w.selected if c.is_selected else w.normal)
 w.role.text=c.weapon_type.to_upper()+" 1";w.gun.text=NAMES.get(c.weapon_type,c.weapon_type.to_upper())+"  /  T1"
 w.health.size=Vector2(123.*float(c.vitality_ratio),4);w.health.color=Color("#c6a368") if state=="WOUNDED" else Color("#7da986")
 w.portrait.modulate=Color(.72,.22,.26) if state=="DEAD" else (Color(1.,.72,.72) if state=="WOUNDED" else Color.WHITE)
 var variant=Anim.variant_for(p.identity.gang_archetype_id,p.weapon_type)
 if not textures.has(variant):
  var path="res://assets/art/units/pixel_v1/portraits/"+variant+".png";textures[variant]=load(path) if ResourceLoader.exists(path) else null
 w.portrait.texture=textures[variant]
