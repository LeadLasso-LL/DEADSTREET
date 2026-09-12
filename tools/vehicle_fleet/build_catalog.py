"""Dead Street's fictional vehicle models. Prices/speeds are game balance values."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[2]
CLASSES={
 'two_wheelers':{'name':'Two-Wheelers','max_units':2,'resources':False},
 'passenger_cars':{'name':'Passenger Cars','max_units':4,'resources':False},
 'utility_vehicles':{'name':'Utility Vehicles','max_units':7,'resources':False},
 'heavy_transports':{'name':'Heavy Transports','max_units':12,'resources':True}}
# id, name, body, seats incl. driver, road movement/turn, dollars, upkeep/turn,
# resource slots, length/width/height (world units), paint, description
GROUPS={
'two_wheelers':[
 ('yardbird','Yardbird Bicycle','bicycle',1,1.,90,0,0,1.8,.62,1.1,'827657','Used steel-frame bicycle; almost free to run, painfully slow on long routes.'),
 ('putter','Putter 50','moped',1,2.6,650,2,0,1.8,.7,1.1,'a08b63','Small step-through moped with a single saddle and front basket.'),
 ('vesper','Vesper 150','scooter',2,3.5,1900,5,0,1.95,.78,1.2,'91a099','Retro city scooter with a proper pillion seat and leg shield.'),
 ('switchblade','Switchblade 600','sportbike',1,6.8,5700,14,0,2.05,.76,1.15,'246cc1','Cobalt supersport with low clip-on bars, a solo tail, and clearly exposed wheels.'),
 ('nightjar','Nightjar RR','sportbike',2,7.5,13500,28,0,2.1,.76,1.12,'d83b30','Scarlet-and-white superbike with a raked nose, low bars and a raised pillion pad.'),
 ('badlands','Badlands 400','dualsport',1,5.8,4200,12,0,2.16,.82,1.28,'a59668','Tall single-seat trail motorcycle with high mudguards.'),
 ('ironhorse','Ironhorse V-Twin','cruiser',2,5.5,9800,23,0,2.5,.94,1.12,'272a2b','Long, low cruiser with chrome pipes, wide bars, and a passenger pad.'),
 ('longhaul','Longhaul Tourer','tourer',2,5.2,17800,32,0,2.65,1.05,1.35,'71382d','Burgundy V-twin bagger with a swept tank, windshield and compact saddlebags.')],
'passenger_cars':[
 ('rattleback','Rattleback Hatch','hatch',4,3.8,1400,16,0,3.85,1.75,1.48,'8e9584','Faded compact hatchback; inexpensive four-seat transport.'),
 ('bayou','Bayou Sedan','sedan',4,5.,3800,26,0,5.15,2.1,1.46,'68766c','Worn full-size sedan with a broad trunk and dependable road pace.'),
 ('civicline','Civicline DX','compact',4,5.4,7400,27,0,4.35,1.8,1.43,'bbb7a5','Clean, practical compact sedan; economical everyday transport.'),
 ('interceptor','Interceptor P4','police_sedan',4,5.9,28000,55,0,5.05,1.98,1.52,'e1dfcd','NBPD pursuit sedan: green/white paint, push bar, and roof lightbar.'),
 ('cabrillo','Cabrillo Lowline','lowrider',4,4.7,14500,38,0,5.3,2.02,1.35,'976644','Long vintage lowrider with chrome trim and cream roof.'),
 ('blackwater','Blackwater Executive','executive',4,5.8,32000,58,0,5.02,1.9,1.46,'303a43','Understated dark executive sedan with a long hood.'),
 ('monarch','Monarch V12','luxury',4,6.,78000,115,0,5.5,2.02,1.57,'44314e','Deep-plum and ivory luxury saloon with a formal chrome grille and sculpted shoulders.'),
 ('regent','Regent Town Car','towncar',4,5.2,46000,78,0,5.55,2.02,1.53,'b6a47c','Champagne chauffeur sedan with a burgundy roof, restrained chrome and long rear doors.'),
 ('volta','Volta GT','grandtourer',2,6.9,68000,98,0,4.65,1.94,1.28,'187db0','Azure-blue grand tourer with a long sculpted hood, swept headlights and a black roof.'),
 ('specter','Specter S','sportcoupe',2,7.2,95000,125,0,4.48,1.96,1.2,'a6cb26','Acid-lime mid-engine wedge with wide rear haunches, side intakes and a black canopy.'),
 ('kensei','Kensei Turbo','tuner',4,6.4,24000,52,0,4.4,1.86,1.36,'465a73','Compact performance coupe with four seats and a modest rear wing.'),
 ('belvedere','Belvedere Eight','vintage',4,4.6,21000,65,0,5.18,1.95,1.5,'653b38','Restored old sedan with rounded fenders and bright chrome bumpers.')],
'utility_vehicles':[
 ('workhorse','Workhorse C10','pickup',3,4.5,4200,35,0,5.05,1.95,1.72,'a99677','Single-cab pickup with a three-place bench; bed is not troop seating.'),
 ('mesa','Mesa Crew','crew_pickup',5,4.9,16500,52,0,5.75,2.04,1.85,'813f35','Four-door crew-cab pickup with five enclosed seats.'),
 ('backcountry','Backcountry XL','lifted_pickup',5,4.4,25000,68,0,5.85,2.12,2.06,'696e51','Lifted crew-cab pickup, large tires and a short practical bed.'),
 ('rancher','Rancher Seven','suv',7,4.7,22500,61,0,5.35,2.04,1.91,'b8ad8b','Full-size three-row SUV; useful seven-person transport.'),
 ('sentinel','Sentinel Luxe','luxury_suv',7,5.1,86000,125,0,5.5,2.13,1.98,'ded9c9','Pearl-white luxury SUV with a black roof, bronze wheels and polished trim.'),
 ('crossway','Crossway AWD','crossover',5,5.2,17500,43,0,4.68,1.86,1.66,'7b8990','Everyday five-seat crossover with a compact footprint.'),
 ('warden','Warden Patrol','police_suv',5,5.3,43000,79,0,5.08,2.02,1.86,'dedccd','NBPD patrol SUV with green/white livery and lightbar.'),
 ('watchdog','Watchdog Tactical','tactical_utility',5,4.5,92000,150,0,5.05,2.14,1.98,'20282b','Black TRC armored utility truck with sloped panels, protected glass and muted-gold markings.'),
 ('taiga','Taiga 4x4','surplus_utility',4,4.1,11500,52,0,4.22,1.9,1.96,'697151','Aged Kurgan-style utility 4x4 with a spare tire and canvas rear roof.'),
 ('outlander','Outlander Wagon','offroad',5,4.6,14000,48,0,4.55,1.88,1.82,'a69370','Boxy off-road wagon with roof rack and utilitarian steel wheels.')],
'heavy_transports':[
 ('courier','Courier Panel Van','panelvan',2,4.2,10500,58,10,5.35,2.02,2.28,'bbb6a5','Two cab seats and an enclosed cargo compartment; freight-focused.'),
 ('shuttle','Shuttle Twelve','passengervan',12,3.9,24500,76,2,5.92,2.1,2.38,'acb4b1','Twelve proper seats; only a small luggage/resource compartment remains.'),
 ('meridian','Meridian Highroof','highroof',8,4.4,47000,92,6,6.2,2.1,2.68,'505d66','High-roof crew van with eight seats and a separated rear cargo bay.'),
 ('shortbox','Shortbox 11','boxtruck',2,3.2,16500,92,24,6.2,2.38,3.12,'d4c8a8','Approximately eleven-foot enclosed box behind a two-seat cab; no passengers in the box.'),
 ('stepmaster','Stepmaster Delivery','stepvan',2,3.4,19500,90,18,6.0,2.25,2.95,'9a9d86','Walk-in delivery van with a tall square body and broad cargo doors.'),
 ('wayfarer','Wayfarer RV','rv',6,2.8,9000,100,6,7.2,2.42,3.1,'b9a68a','Worn motorhome with six belted travel seats and limited storage; Sand Raider favorite.'),
 ('pilgrim','Pilgrim Bus','bus',12,2.6,7800,105,8,8.1,2.43,3.15,'b08b44','Retired short bus: twelve retained seats, rear rows removed for supplies.'),
 ('bastion','Bastion Personnel','military_truck',12,3.5,135000,185,12,7.4,2.45,2.98,'506346','TRC troop transporter with rear benches, covered load bed, and protected cab.'),
 ('uralek','Uralek 6x6','surplus_truck',12,3.1,42000,155,16,7.55,2.46,3.0,'717052','Kurgan surplus six-wheel transporter; bench seats and a designated cargo section.'),
 ('harbor','Harbor Cargo','cabover',3,3.6,31000,105,20,6.75,2.3,3.05,'657f83','Three-seat cab-over delivery truck with a large enclosed freight body.')]
}
GROUPS['two_wheelers'] += [
 ('outrider','Outrider TRC','dualsport',1,6.2,14500,26,0,2.22,.88,1.30,'202a27','Black TRC reconnaissance motorcycle; green fairing, gold markings and exposed trail tires.'),
 ('marshal','Marshal Police','tourer',1,5.7,22500,38,0,2.60,1.02,1.40,'e4e0d0','NBPD motor-patrol bike with green/white fairing, POLICE cases, screen and emergency lights.')]
GROUPS['passenger_cars'] += [
 ('veloce','Veloce Rosso','exotic_curved',2,7.1,89000,118,0,4.55,1.98,1.23,'d93026','Scarlet mid-engine exotic with rounded fenders, a teardrop canopy and deep side scoops.'),
 ('vigil','Vigil TRC','executive',4,5.8,52000,88,0,5.02,1.94,1.48,'212a2b','Branded black TRC response sedan with a green side stripe and gold star-and-eye markings.')]
GROUPS['heavy_transports'] += [
 ('aegis','Aegis Armored TRC','armored_transport',10,3.8,168000,210,8,6.15,2.40,2.65,'1e2529','Black TRC armored truck: protected cabin, sloped armor, ten seats and a separate supply compartment.'),
 ('bulwark','Bulwark SWAT','armored_transport',8,3.9,118000,175,6,6.0,2.38,2.60,'293e38','NBPD SWAT rescue truck with protected windows, POLICE/SWAT branding and a compact freight bay.')]
PREFERENCES={
 'mercer':['yardbird','putter','bayou','cabrillo','rancher','courier'],
 'eastex':['yardbird','rattleback','switchblade','civicline','mesa','courier'],
 'calle_ocho':['vesper','cabrillo','belvedere','mesa','outlander','courier'],
 'ventresca':['regent','blackwater','belvedere','sentinel','meridian','harbor'],
 'ravicci':['monarch','veloce','specter','sentinel','meridian','harbor'],
 'orlov':['blackwater','bayou','taiga','outlander','courier','uralek'],
 'zangyaku':['nightjar','switchblade','kensei','specter','blackwater','meridian'],
 'bitian':['vesper','civicline','blackwater','crossway','courier','harbor'],
 'stateline':['ironhorse','longhaul','badlands','workhorse','mesa','shuttle'],
 'sierra_roja':['nightjar','specter','sentinel','backcountry','mesa','meridian'],
 'whittaker':['badlands','workhorse','mesa','backcountry','outlander','shortbox'],
 'mcallister':['regent','monarch','volta','sentinel','rancher','meridian'],
 'trc':['outrider','vigil','watchdog','aegis','bastion','meridian'],
 'nbpd':['marshal','interceptor','warden','bulwark','shuttle','meridian'],
 'mercer44':['yardbird','switchblade','cabrillo','kensei','rancher','courier'],
 'wm_corp':['regent','monarch','mesa','backcountry','sentinel','shortbox'],
 'union_sur':['cabrillo','switchblade','mesa','backcountry','meridian','harbor'],
 'lombardia':['monarch','regent','blackwater','sentinel','meridian','harbor'],
 'sand_raiders':['yardbird','badlands','rattleback','workhorse','wayfarer','pilgrim'],
 'saffar':['monarch','blackwater','outlander','rancher','meridian','harbor'],
 'kurgan':['badlands','taiga','outlander','workhorse','uralek','courier'],
 'ashford_crane':['vesper','rattleback','bayou','regent','courier','stepmaster'],
 'blacktop':['ironhorse','longhaul','switchblade','workhorse','mesa','wayfarer']}
def build():
 models={}
 for group,rows in GROUPS.items():
  for row in rows:
   id,name,body,seats,speed,price,upkeep,cargo,length,width,height,paint,desc=row
   models[id]=dict(id=id,name=name,vehicle_class=group,body=body,unit_capacity=seats,movement_per_turn=speed,price=price,upkeep_per_turn=upkeep,resource_capacity=cargo,length=length,width=width,height=height,paint='#'+paint,description=desc,cover=group!='two_wheelers',doors=0 if group=='two_wheelers' else (2 if body in ['sportcoupe','grandtourer','exotic_curved','pickup','panelvan','passengervan','highroof','bus','rv','boxtruck','stepvan','cabover','military_truck','surplus_truck','armored_transport'] else 4))
 for m in models.values():
  m['brand']='trc' if m['id'] in ['outrider','vigil','watchdog','bastion','aegis'] else ('nbpd' if m['id'] in ['marshal','interceptor','warden','bulwark'] else '')
  m['door_rows']=[] if m['doors']==0 else ([.20] if m['body']=='armored_transport' else ([.34] if m['vehicle_class']=='heavy_transports' else ([.23] if m['body']=='pickup' else ([.12,-.075] if m['doors']==4 else [.12]))))
 data=dict(version=2,classes=CLASSES,models=models,faction_preferences=PREFERENCES,notes={'capacity':'Includes the driver; all occupants are units. Empty vehicles may exist in inventory.','movement':'Road distance units per campaign turn; convoys use the slowest vehicle. Not road top speed.','resources':'Only Heavy Transports carry campaign resources. One abstract resource unit occupies one cargo slot; personal equipment is not freight.','balance':'Prices, upkeep, and movement are initial game-balance values. Models and manufacturers are fictional.','preferences':'Suggestions only; the sandbox unlocks every model for every faction.'})
 (ROOT/'assets/data/vehicle_models.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('FLEET_CATALOG',len(models),'models',len(PREFERENCES),'factions')
if __name__=='__main__':build()
