# Created by Pixeye | dev@pixeye.com

import px_ecs

type CompObject = object
  arg: int

#bind ecs, CompObject

ecs_get CompObject

#bind(ecs,CompObject)
#ecs_set CompObject

#var i = 1
proc get_alpaca*(): ent = get_ent():
  let cobject = e.get CompObject
  echo cobject.arg, "ba"
  echo e.id
  e.cobject.arg = 1
  
  cobject.arg = 20
proc get_mob*(): ent = get_ent():
  let cobject = e.get CObject
  echo cobject.arg, "ba"
  echo e.id
  cobject.arg = 20
proc mob_get*(): ent = get_ent():
  let cobject = e.get CObject
  echo cobject.arg, "ba"
  echo e.id
  cobject.arg = 20


#proc alpaca_get_health*() = discard
#proc mob_get_heath*() = discard
#proc get_alpaca_health*() = discard
proc get_mob_health*() = discard
proc set_mob_health*() = discard
proc mob_get_health*() = discard
proc mob_set_health*() = discard
#proc mob_get_health*() = discard
#proc test_mob_health*() = discard


#proc 

#var mob = get_mob()
#mob.cobject.arg = 1


#mob.cobject.arg

#getmob
#mob

# # mob_get
# mob_get_heath
# mob_get
# mob_get_heath


# get
# reg_get_ent
# reg.get_ent
# ent_get
