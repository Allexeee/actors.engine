#[
  Created by Mitrofanov Dmitry "Pixeye" on 20/08/2020 
  Email: dev@pixeye.com
]#

import pixeye_ecs/ecs_h
import pixeye_ecs/ecs_ent
import pixeye_ecs/ecs_comp
import pixeye_ecs/ecs_group

# Importing/Exporting is something I don't get in Nim. The routine below must be refactoredm
# but I don't know how yet. Excepting 2/3 of elements is insane. 
export
  ecs_comp,
  ecs_group
export ecs_ent except
  batched
export ecs_group except
  updateGroups,
  binarysearch,
  init_group,
  partof,
  match,
  insert,
  remove,
  `bind`
export ecs_h except
  init_indices,
  formatComponentAlias,
  formatComponent,
  formatComponentLong,
  formatComponentPrettyAndLong,
  formatComponentPretty,
  meta,
  metas,
  AMOUNT_COMPS


proc init*(ecs: var Ecs, ent_amount: int)  =
  ecs = Ecs()
  AMOUNT_ENTS   = ent_amount
  groups        = newSeq[EcsGroup]()
  metas         = newSeq[EntMeta](AMOUNT_ENTS)
  metas_storage = newSeq[CompStorageMeta](0)
  ents          = newSeq[ent](AMOUNT_ENTS)
  batched       = newSeqOfCap[eid]((AMOUNT_ENTS/2).int) 
  ents_free     = AMOUNT_ENTS
  for i in 0..<AMOUNT_ENTS:
    ents[i] = (i,1)
    metas[i].sig        = newSeqOfCap[cid](3)
    metas[i].sig_groups = newSeqOfCap[cid](1)
    metas[i].childs = newSeqOfCap[eid](0)
    metas[i].parent = ent.nil

  

