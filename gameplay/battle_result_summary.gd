extends RefCounted
# Living survivors include wounded units. Retreat requires an explicit terminal outcome.
static func for_side(b,side: String) -> Dictionary:
 var remaining=0
 for unit in b.participants.values():
  if unit.side_id==side and unit.is_alive:remaining+=1
 var result=b.tactical_result
 var retreated=result!=null and result.resolved and side!=result.winning_side_id and result.retreated_side_ids.has(side)
 var text="%d %s Remaining"%[remaining,"Unit" if remaining==1 else "Units"]
 if retreated:text+=" · Retreated from battle"
 return {"remaining":remaining,"retreated":retreated,"text":text}
