import strformat
import strutils
import macros
import sets
import algorithm
import ../../../actors_h
import ../../../actors_tools
import ../actors_ecs_h
import ecs_utils


var storageCache = newSeq[CompStorageBase](1222)
var id_next_group : cid = 0
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

  n.insert(i,newDotExpr(ident($layer), ident("makeGroup")))
  result = n
proc makeGroup*(layer: LayerID) : Group {.inline, discardable.} =
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