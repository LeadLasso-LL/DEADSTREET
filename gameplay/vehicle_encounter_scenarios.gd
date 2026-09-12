extends RefCounted
const Service=preload("res://campaign/vehicles/vehicle_encounter_service.gd")
const IDS=["wraith_zero","crownfire","eidolon","asterion","nomad","archangel","leviathan","palisade","sterling_cit","sterling_reserve","custodian"]
const BRIEFS=[
"Scout the connected road ahead. Counter-test: try to scout an unconnected location.",
"Escape one mobile interception. Movement ends this turn. Counter-test: a physical checkpoint.",
"Activate Ghost Channel and avoid a routine police stop. Counter-test: a deliberate checkpoint.",
"Reserve a legal alternate road entrance for the car's occupants. Counter-test: an occupied entrance.",
"Use a designated wilderness connection. Counter-test: bring an incompatible vehicle along.",
"Evacuate one living critical occupant from a secure zone. Counter-test: attempt to revive a dead unit.",
"Breach one light blockade per journey and gain 25 heat. Counter-test: a fortified blockade.",
"Dispatch 10 supplies, then lose the truck. Refund at the origin after two turns. Counter-test: capture the origin; refund waits until it is restored.",
"Dispatch $75,000 from the bank. Resolve to deliver; counter-test intercepts and steals it. Cash is credited exactly once.",
"Dispatch $300,000 from the bank. Resolve to deliver; counter-test intercepts and steals it. There is no bonded-cargo protection.",
"Dispatch three guards and eight prisoners. Resolve frees surviving prisoners after victory; counter-test rejects an unsuccessful raid. Allegiances stay unchanged."
]
var service=Service.new()
func reset():
 service=Service.new()
 var vehicles=[]
 for id in IDS:vehicles.append({"id":id,"model":id,"occupants":[id+"_driver"]})
 service.start_journey("lab","player",vehicles)
 service.data.accounts={"bank":500000.,"destination":0.,"interceptor":0.}
 service.data.locations={"origin":{"owner":"player","stock":{"supplies":20.}},"destination":{"owner":"player","stock":{"supplies":0.}}}
func run(index: int,counter: bool=false) -> Dictionary:
 var id=IDS[index]
 match index:
  0:return service.scout("lab",id,"a","c" if counter else "b",[{"from":"a","to":"b","kind":"road"}],{"b":{"blockade":"light","units":6,"vehicles":2}})
  1:return service.stop("lab",id,"checkpoint" if counter else "mobile_interception")
  2:
   service.set_jammer("lab",id,true)
   return service.stop("lab",id,"checkpoint" if counter else "routine_police")
  3:return service.flank("lab",id,"north",{"north":{"road_connected":true,"legal":true,"occupied":counter}})
  4:return service.cross_country("lab",[id,"eidolon"] if counter else [id],{"designated":true,"kind":"wilderness"})
  5:return service.recover("lab",id,"battle_01",{"id":id+"_driver","status":"critical","hp":0 if counter else 1},true,true)
  6:return service.stop("lab",id,"fortified_blockade" if counter else "light_blockade")
  7:
   if counter:
    var captured=service.data.locations.origin.owner=="player"
    service.data.locations.origin.owner="enemy" if captured else "player"
    return service.result(true,"Origin captured; escrow waits." if captured else "Origin restored; mature escrow pays next turn.")
   if not service.data.resources.has("bonded"):return service.dispatch_resources("bonded","lab",id,"origin",{"supplies":10.})
   return service.lose_bonded("bonded")
  8,9:
   if not service.data.cash.has(id):return service.dispatch_cash(id,id,"bank","destination",75000. if index==8 else 300000.)
   return service.settle_cash(id,"interceptor" if counter else "",counter)
  10:
   if not service.data.prisons.has("transfer"):
    var prisoners=[]
    for n in range(8):prisoners.append({"id":"prisoner_%d"%n,"allegiance":"eastex" if n<4 else "whittaker","alive":true})
    return service.dispatch_prisoners("transfer",prisoners,3)
   return service.rescue_prisoners("transfer","player",not counter)
 return service.result(false,"Unknown scenario.")
func state_text() -> String:
 var d=service.data
 var text="TURN %d    |    HEAT %d\n"%[d.turn,int(d.heat.get("player",0))]
 text+="Bank $%s   Destination $%s   Interceptor $%s\n"%[str(int(d.accounts.bank)),str(int(d.accounts.destination)),str(int(d.accounts.interceptor))]
 text+="Origin: %s · %d supplies   |   Destination: %d supplies\n"%[d.locations.origin.owner,int(d.locations.origin.stock.supplies),int(d.locations.destination.stock.supplies)]
 text+="Crownfire movement: "+("available" if service.can_move("lab","crownfire") else "ended this turn")+"\n"
 for key in d.resources:text+="Bonded cargo: "+str(d.resources[key].status)+"\n"
 for key in d.claims:text+="Escrow due turn %d · %s\n"%[d.claims[key].due,"paid" if d.claims[key].paid else "pending"]
 for key in d.cash:text+="%s: %s\n"%[key,d.cash[key].status]
 for key in d.prisons:text+="Prison transfer: %s · 3 guards / 8 prisoners\n"%d.prisons[key].status
 return text
