{.used.}
{.experimental: "dynamicBindSym".}

import macros
import sets
import algorithm

import ../../../actors_h
import ../pixeye_ecs_h
import ecs_utils
import ecs_ops

var id_next_group : cid = 0

var signature         : set[cid]
var signature_exclude : set[cid]

macro premake_group(ecs: LayerEcs, t: varargs[untyped]) =
  var n = newNimNode(nnkStmtList)
  template genMask(arg: untyped): NimNode =
    var n = newNimNode(nnkCall)
    if arg.len > 0 and $arg[0] == "!":
      n.insert(0,newDotExpr(bindSym("signature_exclude"), ident("incl")))
      n.insert(1,newDotExpr(ident($arg[1]), ident("getstorageid")))
    else:
      n.insert(0,newDotExpr(bindSym("signature") , ident("incl")))
      n.insert(1,newDotExpr(ident($arg), ident("getstorageid")))
    n
  var i = 0
  for x in t.children:
    n.insert(i,genMask(x))
    i += 1
  n.insert(i,newDotExpr(ident($ecs), bindSym("make_group",brForceOpen)))
  result = n

func sort_storages(x,y: CompStorageBase): int =
  let cx = x.entities
  let cy = y.entities
  if cx.len <= cy.len: -1
  else: 1

proc make_group(ecs: LayerEcs) : Group {.inline, used, discardable.} =
  let groups = addr ecs.groups
  var group_next : Group = nil
  for i in 0..groups[].high:
    let gr = groups[][i]
    if gr.signature_mask == signature and
      gr.signature_excl_mask == signature_exclude:
        group_next = gr; break
   
  if group_next.isNil:
    group_next = groups[].getref()
    group_next.id = id_next_group
    group_next.ecs = ecs
    
    group_next.signature_mask = signature
    group_next.signature_excl_mask = signature_exclude
    
    group_next.entities = newSeqOfCap[eid]((ENTS_MAX_SIZE/2).int)
    group_next.indices.gen_indices()
    group_next.layer = ecs.layer
    
    var storage_owner = newSeq[CompStorageBase]()

    for id in signature:
      ecs.storages[id].groups.add(group_next)
      group_next.signature.add(id)
      storage_owner.add(ecs.storages[id])
    for id in signature_exclude:
      ecs.storages[id].groups.add(group_next)
      group_next.signature_excl.add(id)

    storage_owner.sort(sortStorages)
    tryinsert(group_next,storage_owner[0].entities)

    id_next_group += 1
  
  signature = {}
  signature_exclude = {}
  group_next

template len*(self: Group): int =
  self.entities.len
template high*(self: Group): int =
  self.entities.high
template `[]`*(self: Group, key: int): ent =
  self.entities[key]

template group*(ecs: LayerEcs, t: varargs[untyped]): Group =
  var group_cached {.global.} : Group
  if group_cached.isNil:
    group_cached = premake_group(ecs,t)
  group_cached

template group*(t: varargs[untyped]): Group =
  var group_cached {.global.} : Group
  if group_cached.isNil:
    var ecs = layer_current.LayerId.ecs
    group_cached = premake_group(ecs,t)
  group_cached
