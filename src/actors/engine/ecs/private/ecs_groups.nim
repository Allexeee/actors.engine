{.used.}
{.experimental: "dynamicBindSym".}

import strformat
import macros
import sets
import algorithm
import tables


import ../../../actors_h
import ../../../actors_tools
import ../actors_ecs_h
import ecs_utils
import ecs_ops

var id_next_group : cid = 0

var mask_exclude* : set[cid]
var mask_include* : set[cid]

macro gengroup*(layer: LayerId, t: varargs[untyped]) =
  var n = newNimNode(nnkStmtList)
  template genMask(arg: untyped): NimNode =
    var n = newNimNode(nnkCall)
    if arg.len > 0 and $arg[0] == "!":
      n.insert(0,newDotExpr(ident("mask_exclude"), ident("incl")))
      n.insert(1,newDotExpr(ident($arg[1]), ident("id")))
    else:
      n.insert(0,newDotExpr(ident("mask_include"), ident("incl")))
      n.insert(1,newDotExpr(ident($arg), ident("id")))
    n
  var i = 0
  for x in t.children:
    n.insert(i,genMask(x))
    i += 1
  n.insert(i,newDotExpr(ident($layer), bindSym("makeGroup",brForceOpen)))
  result = n


func sortStorages(x,y: CompStorageBase): int =
  let cx = x.entities
  let cy = y.entities
  if cx.len <= cy.len: -1
  else: 1


proc makeGroup(layer: LayerID) : Group {.inline, used, discardable.} =
  
  let ecs = layers[layer.int]
  let groups = addr ecs.groups
  var group_next : Group = nil
  for i in 0..groups[].high:
    let gr = groups[][i]
    if gr.signature_m == mask_include and
      gr.signature_m_excl == mask_exclude:
        group_next = gr; break
   
  if group_next.isNil:
    group_next = groups[].getref()
    group_next.id = id_next_group
    group_next.ecs = ecs
    for i in mask_include:
     group_next.signature.add(i) 
    for i in mask_exclude:
     group_next.signature_excl.add(i) 
    
    group_next.entities = newSeqOfCap[eid](256)
    group_next.indices.gen_indices()
    group_next.layer = layer
    
    var storages_included = newSeq[CompStorageBase]()

    for id in mask_include:
      storages[id][layer.int].groups.add(group_next)
      storages_included.add(storages[id][layer.int])
      group_next.signature_m.incl(id)
    for id in mask_exclude:
      storages[id][layer.int].groups.add(group_next)
      group_next.signature_m_excl.incl(id)
    
    storages_included.sort(sortStorages)
    tryinsert(group_next,storages_included[0].entities)


    id_next_group += 1
  
  mask_include = {}
  mask_exclude = {}
  group_next

template len*(self: Group): int =
  self.entities.len
template high*(self: Group): int =
  self.entities.high
template `[]`*(self: Group, key: int): ent =
  self.entities[key]


template group*(layer: LayerId, t: varargs[untyped]): Group =
  var group_cached {.global.} : Group
  if group_cached.isNil:
    group_cached = gengroup(layer,t)
  group_cached

