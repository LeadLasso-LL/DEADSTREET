"""Premium checkpoint support; fictional 2034 prices and campaign balance."""
IDS=['roadwarden','bloodhound']
def extend(groups):
 groups['utility_vehicles'].append(('bloodhound','Bloodhound Pursuit','pursuit_suv',5,6.6,385000,680,0,5.25,2.10,1.65,'192329','Low black performance SUV with burnt-orange inlays, wide bronze wheels, a split rear spoiler and compact sensor bar.'))
 groups['heavy_transports'].append(('roadwarden','Roadwarden Lockdown','checkpoint_truck',8,4.2,940000,1700,6,6.9,2.45,2.25,'39474b','Graphite six-wheel checkpoint truck with oversized tires, an angular low cab and folded steel barricades in side racks.'))
def apply(models):
 for id in IDS:models[id].update(endgame=True,ability_status='encounter_lab',design_era='contemporary_2034',post_min_crew=2,post_setup_cost=1.)
 models['roadwarden'].update(ability_id='lockdown',ability_name='Lockdown',ability_summary='Fortify an owned light blockade and deploy two tactical cover barriers.',ability_limits='Requires a stationed, crewed truck. Automatic light-blockade breaches are stopped; normal battles still work. Leaving or losing the post removes the bonus.',axles=3,door_rows=[.22],rim_color='#859395')
 models['bloodhound'].update(ability_id='pursuit_net',ability_name='Pursuit Net',ability_summary='Intercept one hostile convoy per turn on an adjacent connected road.',ability_limits='Requires a crewed post. Pays road movement, leaves the post and triggers a normal battle. No automatic victory, capture or loot; no stacking against a pending convoy.',door_rows=[.17,-.20],rim_color='#b88c56')
