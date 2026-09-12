"""Approved endgame abilities and independent campaign service vehicles."""
ROWS = {
 'two_wheelers':[
  ('wraith_zero','Wraith Zero','flagship_bike',1,7.2,88000,145,0,2.25,.82,1.14,'262435','Obsidian electric superbike with violet accents, exposed wheels and a compact scout sensor.'),
  ('crownfire','Crownfire V-Twin','flagship_cruiser',2,7.0,125000,225,0,2.80,1.02,1.16,'812c3a','Deep crimson custom cruiser with black chrome, a broad rear tire and swept teardrop tank.')],
 'passenger_cars':[
  ('eidolon','Eidolon GT','stealth_gt',4,6.9,640000,950,0,5.20,2.04,1.34,'23364d','Midnight-blue four-seat grand tourer with silver blades, a low glass roof and concealed electronics.'),
  ('asterion','Asterion One','flagship_hypercar',2,7.8,980000,1400,0,4.88,2.12,1.14,'e6ad72','Pearl-orange hypercar with a black canopy, sculpted side tunnels and a dramatic split rear wing.')],
 'utility_vehicles':[
  ('nomad','Nomad Sovereign 6x6','flagship_6x6',6,5.3,445000,775,0,6.30,2.30,2.08,'235647','Satin emerald six-wheel expedition truck with bronze wheels, an enclosed cabin and low roof equipment.'),
  ('archangel','Archangel Recovery','rescue_suv',5,5.6,520000,925,0,5.70,2.18,1.92,'e0dacf','Pearl-white armored rescue SUV with burgundy medical detailing and a protected recovery compartment.')],
 'heavy_transports':[
  ('leviathan','Leviathan Breacher','breacher',12,3.6,1350000,2300,8,7.30,2.48,2.72,'20282d','Black six-wheel armored transporter with a reinforced wedge bumper and recessed protected lamps.'),
  ('palisade','Palisade Escrow','vault_truck',6,3.8,1800000,3100,14,7.15,2.46,2.80,'46515c','Graphite-and-platinum vault transport with a sealed cargo capsule, heavy rear locks and discreet gold trim.'),
  ('sterling_cit','Sterling CIT-4','cash_truck',3,4.5,86000,120,0,5.50,2.20,2.36,'c8c8ac','Independent green-and-ivory armored bank truck with a sealed cash compartment and three crew seats.'),
  ('sterling_reserve','Sterling Bastion Reserve','reserve_truck',4,3.6,165000,230,0,6.55,2.38,2.61,'39454b','Independent charcoal-and-silver armored reserve truck with protected glazing and a larger secure cash bay.'),
  ('custodian','Custodian P8','prison_transport',3,3.8,68000,140,0,6.50,2.26,2.60,'466477','Slate-blue prison transport with barred rear glazing, segregated compartments and eight prisoner places.')]
}
ABILITIES = {
 'wraith_zero':('forward_eye','Forward Eye','Scout the next connected road location before entering.','Reveals the blockade and convoy strength at one adjacent road node; it does not reveal the entire map.'),
 'crownfire':('breakaway','Breakaway','Escape one mobile interception per journey.','Ends this vehicle\'s movement for the turn. Roadblocks still stop it; other convoy vehicles are not protected.'),
 'eidolon':('ghost_channel','Ghost Channel','An active jammer blocks routine police pullover events.','Wanted checkpoints and deliberate interceptions still work. Only this car receives the protection.'),
 'asterion':('flanking_arrival','Flanking Arrival','Choose an alternate connected road entrance for its occupants.','The entrance must be legal, connected and available. It does not relocate the rest of the convoy.'),
 'nomad':('cross_country','Cross-Country','Take designated dirt and wilderness connections.','The vehicle must split from companions that cannot use the route. No water, walls or unmarked shortcuts.'),
 'archangel':('life_support','Life Support','Recover one critically wounded occupant per battle.','Requires reaching a secure extraction zone alive. The survivor remains wounded and unavailable until recovery.'),
 'leviathan':('breach_charge','Breach Charge','Force through one light blockade per journey.','Fortified checkpoints still require combat. A breach adds 25 heat and protects only its own occupants.'),
 'palisade':('bonded_cargo','Bonded Cargo','Lost cargo is replaced at its departure location after two turns.','Captured cargo never becomes enemy loot. Claims wait in escrow if the origin is lost. Truck and crew remain at risk.')
}

def extend(groups):
 for key,rows in ROWS.items():groups[key]+=rows

def apply(models):
 for key,info in ABILITIES.items():
  models[key].update(endgame=True,ability_id=info[0],ability_name=info[1],ability_summary=info[2],ability_limits=info[3],ability_status='encounter_lab',design_era='contemporary_2034')
 for key in ['sterling_cit','sterling_reserve','custodian']:
  models[key].update(service_only=True,operator='independent',ability_status='encounter_lab',design_era='contemporary_2034')
 models['sterling_cit'].update(cash_capacity=75000,service_role='bank_cash',rim_color='#bbc1b6')
 models['sterling_reserve'].update(cash_capacity=300000,service_role='bank_cash',rim_color='#9caab3')
 models['custodian'].update(prisoner_capacity=8,total_occupant_capacity=11,service_role='prisoner_transfer')
 for key in ['nomad','leviathan']:models[key]['axles']=3
 for key in ['asterion','eidolon']:models[key]['doors']=2 if key=='asterion' else 4
 models['asterion']['door_rows']=[.12]
 for key in ['leviathan','palisade','sterling_cit','sterling_reserve','custodian']:models[key]['door_rows']=[.25]
 models['nomad']['rim_color']='#b69562'
 models['crownfire']['rim_color']='#52565d'

IDS=[r[0] for rows in ROWS.values() for r in rows]
