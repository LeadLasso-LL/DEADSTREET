"""Two premium raid vehicles; prices and movement are fictional game balance values."""
IDS=['revenant','nocturne']
def extend(groups):
 groups['two_wheelers'].append(('revenant','Revenant R2','driveby_bike',2,7.4,165000,310,0,2.32,.86,1.17,'155e65','Carbon-and-petrol-teal tandem streetbike with alloy wheels, split lighting and a raised passenger saddle.'))
 groups['passenger_cars'].append(('nocturne','Nocturne RS','driveby_sedan',4,7.1,1150000,1650,0,5.12,2.02,1.32,'492c50','Deep plum-black performance sedan with a low pillarless-style cabin, bronze wheels and sculpted carbon side skirts.'))
def apply(models):
 for id in IDS:
  models[id].update(endgame=True,ability_id='drive_by',ability_name='Drive-By',ability_summary='Destroy an undefended roadside business or building and retain remaining movement.',ability_limits='Once per vehicle per turn. Driver plus passenger required. Adds 30 heat; no free travel, capture or loot. Defended targets block the ability.',ability_status='encounter_lab',design_era='contemporary_2034',rim_color='#b89a61',drive_by_heat=30,drive_by_limit_per_turn=1,drive_by_min_crew=2)
 models['revenant'].update(doors=0,door_rows=[])
 models['nocturne'].update(doors=4,door_rows=[.20,-.22],roof_color='#20222e')
