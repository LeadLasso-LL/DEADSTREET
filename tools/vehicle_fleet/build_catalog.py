"""Dead Street's fictional vehicle models. Prices/speeds are game balance values."""
from pathlib import Path
import json,sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from endgame_catalog import extend, apply
from driveby_catalog import extend as extend_driveby, apply as apply_driveby
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
GROUPS['two_wheelers'] += [
 ('pulse','Pulse EX','electric_trail',1,6.1,8800,9,0,2.12,.82,1.22,'66a593','Mint-and-graphite electric trail bike: compact battery spine, exposed tires and a solo saddle.'),
 ('cinder','Cinder 900','cafe',2,5.6,12500,24,0,2.30,.85,1.13,'343e42','Graphite cafe roadster with a copper tank, brown saddle and compact rear cowl.')]
GROUPS['passenger_cars'] += [
 ('aurelia','Aurelia E4','ev_fastback',4,6.6,61000,58,0,4.95,1.98,1.39,'70b3bb','Ice-teal electric fastback with a black glass roof, swept cabin and continuous light signatures.'),
 ('solstice','Solstice Spider','roadster',2,7.0,82000,110,0,4.42,1.94,1.16,'da773b','Copper-orange open-top roadster with two tan seats, twin roll hoops and a low windscreen.'),
 ('mistral','Mistral Estate','shooting_brake',4,6.2,58000,76,0,4.98,1.96,1.43,'285c4e','Racing-green shooting brake: long sculpted hood, low wagon roof and bronze wheels.'),
 ('kestrel','Kestrel RX','rally_hatch',4,6.0,18500,44,0,4.03,1.86,1.42,'7652a3','Violet rally hatch with white door flashes, wide arches and a short roof spoiler.'),
 ('halcyon','Halcyon H1','hypercar',2,7.4,148000,168,0,4.72,2.04,1.19,'67b3cb','Glacier-blue hypercar with a black canopy, gold lower trim and a broad rear aero blade.')]
GROUPS['utility_vehicles'] += [
 ('torque','Torque EV5','ev_pickup',5,5.4,68000,67,0,5.54,2.08,1.82,'456e78','Steel-teal electric crew pickup with a horizontal light bar and a recessed practical bed.'),
 ('dunecat','Dunecat R','prerunner',4,5.1,36500,83,0,5.62,2.15,1.95,'b28550','Sand-orange desert pickup with broad arches, a braced rear bed and four enclosed seats.'),
 ('obsidian','Obsidian X','coupe_suv',5,5.9,92000,121,0,5.05,2.08,1.73,'514568','Amethyst performance SUV with a falling roofline, broad stance and dark panoramic roof.')]
GROUPS['heavy_transports'] += [
 ('lastlight','Lastlight Prison Bus','raider_bus',12,2.3,13600,122,12,8.20,2.43,3.02,'807b59','Raiders of the Sand prison bus: barred windows, patched panels, roof luggage and rear supply space.'),
 ('dustchapel','Dustchapel RV','raider_rv',8,2.9,18800,128,8,7.60,2.42,3.00,'a38c67','Raiders expedition motorhome with repaired siding, reclaimed solar panel, canvas rolls and a rear spare.'),
 ('relay','Relay TRC','command_van',6,4.6,118000,145,4,6.25,2.12,2.57,'243733','Black-green TRC communications van with six seats, roof sensor equipment and a compact cargo bay.'),
 ('concierge','Concierge Lounge','luxury_shuttle',6,4.9,108000,136,4,5.92,2.08,2.17,'d0c7b5','Champagne luxury shuttle with dark rear glazing, six travel seats and restrained gold trim.')]

# 2034 stance pass. Original economy/capacities stay intact; only the body heights
# and presentation descriptors change. Older models remain intentional used stock.
HEIGHTS={'interceptor':1.40,'vigil':1.39,'civicline':1.40,'blackwater':1.41,'monarch':1.47,'regent':1.45,'kensei':1.34,'bayou':1.44,'rattleback':1.45,'sentinel':1.86,'warden':1.77,'watchdog':1.88,'rancher':1.84,'crossway':1.61,'mesa':1.82,'backcountry':1.99,'aegis':2.46,'bulwark':2.42,'bastion':2.92,'courier':2.20,'shuttle':2.28,'meridian':2.60}
ROOFS={'cabrillo':'#c5bda5','monarch':'#c9c5b7','regent':'#55353c','sentinel':'#26343b','aurelia':'#24363c','mistral':'#243a36','obsidian':'#273139','concierge':'#283a40'}
DESCRIPTIONS={
 'interceptor':'2034 NBPD pursuit sedan: low roof, long hood, sculpted shoulders and a slim emergency lightbar.',
 'vigil':'2034 TRC response sedan: low swept cabin, long hood, black paint and green/gold markings.',
 'warden':'Modern NBPD patrol SUV with a low glass line, broad hood, exposed wheels and green/white livery.',
 'watchdog':'Black TRC armored utility truck with balanced hood/cabin height, broad wheels and gold markings.',
 'monarch':'Plum-and-ivory luxury flagship with a lower crowned roof, long hood and formal modern grille.',
 'regent':'Champagne chauffeur saloon with a burgundy roof, raked pillars and generous hood and trunk.',
 'sentinel':'Pearl-white luxury SUV with a lower black roof, sculpted body and bronze wheels.',
 'aegis':'Modern black TRC armored transport with a substantial hood, protected windows, ten seats and eight cargo slots.',
 'bulwark':'Modern NBPD SWAT transport with a broad hood, low protected glazing, eight seats and six cargo slots.',
 'bastion':'TRC modern cab troop truck with covered benches and a separate supply section.',
 'kensei':'Modern blue performance coupe with a low greenhouse, wide wheel arches and a compact rear wing.'}
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
PREFERENCES.update({
 'eastex':['yardbird','rattleback','switchblade','kestrel','mesa','courier'],
 'ventresca':['regent','blackwater','mistral','sentinel','concierge','harbor'],
 'ravicci':['monarch','veloce','halcyon','solstice','obsidian','concierge'],
 'zangyaku':['nightjar','pulse','kensei','specter','aurelia','meridian'],
 'bitian':['vesper','civicline','aurelia','crossway','courier','harbor'],
 'stateline':['ironhorse','longhaul','cinder','workhorse','mesa','shuttle'],
 'sierra_roja':['nightjar','specter','obsidian','dunecat','sentinel','meridian'],
 'whittaker':['badlands','workhorse','mesa','dunecat','outlander','shortbox'],
 'mcallister':['monarch','aurelia','volta','mistral','sentinel','concierge'],
 'trc':['outrider','vigil','watchdog','aegis','bastion','relay'],
 'mercer44':['yardbird','switchblade','cabrillo','kestrel','rancher','courier'],
 'wm_corp':['monarch','aurelia','torque','backcountry','sentinel','shortbox'],
 'lombardia':['monarch','regent','mistral','sentinel','concierge','harbor'],
 'sand_raiders':['yardbird','badlands','workhorse','pilgrim','lastlight','dustchapel'],
 'blacktop':['ironhorse','longhaul','cinder','workhorse','dunecat','wayfarer']})
extend(GROUPS)
extend_driveby(GROUPS)

def build():
 models={}
 for group,rows in GROUPS.items():
  for row in rows:
   id,name,body,seats,speed,price,upkeep,cargo,length,width,height,paint,desc=row
   models[id]=dict(id=id,name=name,vehicle_class=group,body=body,unit_capacity=seats,movement_per_turn=speed,price=price,upkeep_per_turn=upkeep,resource_capacity=cargo,length=length,width=width,height=HEIGHTS.get(id,height),paint='#'+paint,description=DESCRIPTIONS.get(id,desc),cover=group!='two_wheelers',doors=0 if group=='two_wheelers' else (2 if group=='heavy_transports' or body in ['sportcoupe','grandtourer','exotic_curved','hypercar','roadster','pickup'] else 4))
   if id in ROOFS:models[id]['roof_color']=ROOFS[id]
   if id in ['mistral','sentinel','halcyon']:models[id]['rim_color']='#af9563'
   if id=='kestrel':models[id]['rim_color']='#c7c5b8'
   models[id]['design_era']='heritage' if id in ['cabrillo','belvedere','workhorse','uralek','taiga'] else ('scavenged' if id in ['lastlight','dustchapel','pilgrim','wayfarer','rattleback','bayou','yardbird'] else 'contemporary_2034')
 for m in models.values():
  m['brand']='trc' if m['id'] in ['outrider','vigil','watchdog','bastion','aegis','relay'] else ('nbpd' if m['id'] in ['marshal','interceptor','warden','bulwark'] else '')
  m['door_rows']=[] if m['doors']==0 else ([.20] if m['body']=='armored_transport' else ([.34] if m['vehicle_class']=='heavy_transports' else ([.23] if m['body']=='pickup' else ([.12,-.075] if m['doors']==4 else [.12]))))
 apply(models)
 apply_driveby(models)
 data=dict(version=5,setting_year=2034,classes=CLASSES,models=models,faction_preferences=PREFERENCES,notes={'capacity':'Includes the driver; all occupants are units. Empty vehicles may exist in inventory.','movement':'Road distance units per campaign turn; convoys use the slowest vehicle. Not road top speed.','resources':'Only Heavy Transports carry campaign resources. One abstract resource unit occupies one cargo slot; personal equipment is not freight.','balance':'Prices, upkeep, and movement are initial game-balance values. Models and manufacturers are fictional.','preferences':'Suggestions only; the sandbox unlocks every model for every faction.','era':'2034 contemporary fleet with deliberate heritage and scavenged exceptions. Electric powertrains currently affect listed upkeep only; charging and fuel systems are not implemented.'})
 (ROOT/'assets/data/vehicle_models.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('FLEET_CATALOG',len(models),'models',len(PREFERENCES),'factions')
if __name__=='__main__':build()
