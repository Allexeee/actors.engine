{.used.}
{.experimental: "dynamicBindSym".}
#import algorithm
#import strutils
import strformat
import macros
import sets
import ../../../actors_h
import ../../../actors_tools
import ../actors_ecs_h
import ecs_utils


var id_next_group : cid = 0
var storageCache {.used.} = newSeq[CompStorageBase](256)

var mask_exclude* : set[cid]
var mask_include* : set[cid]

macro group*(layer: LayerId, t: varargs[untyped]) =
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
  #bindSym("impl_storage_compact", brForceOpen) 
  n.insert(i,newDotExpr(ident($layer), bindSym("makeGroup",brForceOpen)))
  result = n

proc makeGroup(layer: LayerID) : Group {.inline, used, discardable.} =
  let ecs = layers[layer.int]
  let groups = addr ecs.groups
  var group_next : Group = nil
  for i in 0..groups[].high:
    let gr = groups[][i]
    if mask_include == gr.signature:
      group_next = gr
      break
  if group_next.isNil:
    group_next = groups[].getref()
    group_next.id = id_next_group
    group_next.signature = mask_include
    group_next.signature_excl = mask_exclude
    for i in mask_include:
     group_next.signature2.add(i) 
    for i in mask_exclude:
     group_next.signature_excl2.add(i) 
    
    group_next.entities = newSeqOfCap[ent](256)
    group_next.indices.gen_indices()
    group_next.layer = layer
    for id in mask_include:
      storages[id].groups.add(group_next)
    for id in mask_exclude:
      storages[id].groups.add(group_next)
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

