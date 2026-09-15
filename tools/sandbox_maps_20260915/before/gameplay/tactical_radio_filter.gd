extends RefCounted
## Interior coloration for faction radios only; transport/stronghold placement stays upstream.
const VEHICLE_CUTOFF_HZ=2400.0
const BUILDING_CUTOFF_HZ=1800.0
const FOREGROUND_CUTOFF_HZ=7500.0
const EFFECT_META=&"ds_interior_filter"
const BASE_META=&"ds_interior_cutoff"
const BUS_META=&"ds_interior_bus"

static func attach(player: AudioStreamPlayer2D,building: bool)->void:
 if player.has_meta(EFFECT_META):return
 var bus_name=StringName("DeadStreetInterior_"+str(player.get_instance_id()))
 AudioServer.add_bus()
 var index=AudioServer.get_bus_count()-1
 AudioServer.set_bus_name(index,bus_name)
 AudioServer.set_bus_send(index,&"Master")
 var effect=AudioEffectLowPassFilter.new()
 effect.cutoff_hz=BUILDING_CUTOFF_HZ if building else VEHICLE_CUTOFF_HZ
 effect.db=AudioEffectFilter.FILTER_6DB
 effect.resonance=0.5
 effect.gain=1.0
 AudioServer.add_bus_effect(index,effect)
 player.bus=bus_name
 player.set_meta(EFFECT_META,effect)
 player.set_meta(BASE_META,effect.cutoff_hz)
 player.set_meta(BUS_META,bus_name)
 # Each source owns its bus, so the winner opening up never brightens the losing side.
 player.tree_exiting.connect(func():release(bus_name),CONNECT_ONE_SHOT)

static func update(player: AudioStreamPlayer2D,foreground: float)->void:
 if not player.has_meta(EFFECT_META):return
 var effect: AudioEffectLowPassFilter=player.get_meta(EFFECT_META)
 var base=float(player.get_meta(BASE_META))
 effect.cutoff_hz=exp(lerpf(log(base),log(FOREGROUND_CUTOFF_HZ),clampf(foreground,0.,1.)))

static func release(bus_name: StringName)->void:
 var index=AudioServer.get_bus_index(bus_name)
 if index>0:AudioServer.remove_bus(index)
