import strformat
import strutils
import macros
import sets
import algorithm
import ../../../actors_h
import ../../../actors_tools
import ../actors_ecs_h
import ecs_entity
import ecs_utils


var storageCache = newSeq[CompStorageBase](1222)
var id_next_group = 0
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
    if gr.signature == mask_include:
      group_next = gr
      break
  if group_next.isNil:
    group_next = groups[].getref()
    group_next.id = id_next_group
    group_next.signature = mask_include
    group_next.signature_excl = mask_exclude
    group_next.entities = newSeqOfCap[ent](1000)
    group_next.layer = layer
    if not mask_include.contains(0):
      for id in mask_include:
        storages[id].groups.add(group_next)
    if not mask_exclude.contains(0):
     for id in mask_exclude:
       storages[id].groups.add(group_next)
    id_next_group += 1

  group_next

proc group*(layer: LayerID, incl: set[cid],excl: set[cid]) : Group {.inline, discardable.} =
  let ecs = layers[layer.int]
  let groups = addr ecs.groups

  var group_next : Group = nil

  for i in 0..groups[].high:
    let gr = groups[][i]
    if gr.signature == incl:
      group_next = gr
      break
  if group_next.isNil:
    group_next = groups[].getref()
    group_next.id = id_next_group
    group_next.signature = incl
    group_next.signature_excl = excl
    group_next.entities = newSeqOfCap[ent](1000)
    group_next.layer = layer
    if not incl.contains(0):
      for id in incl:
        storages[id].groups.add(group_next)
    if not excl.contains(0):
     for id in excl:
       storages[id].groups.add(group_next)
    id_next_group += 1

  group_next
  
  
  # echo incl[0]
  # echo excl[0]
# proc groupImpl(layer: LayerID, incl: set[uint16], excl: set[uint16]): Group {.inline, discardable.} =
#   let ecs = layers[layer.uint32]
#   let groups = addr ecs.groups
  
#   var group_next : Group = nil

#   for i in 0..groups[].high:
#       let gr = groups[][i]
#       if gr.signature == incl:
#           group_next = gr
#           break
  
#   if group_next.isNil:
#       group_next = groups[].add_new_ref()
#       group_next.id = id_next_group
#       group_next.signature = incl
#       group_next.signature_excl = excl
#       group_next.entities = newSeqOfCap[ent](1000)
#       #group_next.added = newSeqOfCap[ent](500)
#       #group_next.removed = newSeqOfCap[ent](500)
#       group_next.layer = layer
      # if not incl.contains(0):
      #   for id in incl:
      #     storages[id].groups.add(group_next)
      # if not excl.contains(0):
      #  for id in excl:
      #    storages[id].groups.add(group_next)
      # id_next_group += 1
  
#   group_next

# proc group*(layer: LayerID, incl: set[uint16]): Group {.inline, discardable.} =
#    group_impl(layer, incl, {0'u16})

# proc group*(layer: LayerID, incl: set[uint16], excl: set[uint16]): Group {.inline, discardable.} =
#    group_impl(layer, incl, excl)



#proc group*(layer: LayerId) = 

#dumptree:
 # let ca {.inject.} =  cast[ptr seq[CompA]](storageCache[0].compss)   

macro injectComponent*(arg: untyped, arg2: untyped, arg3: static int) =

  echo $arg
  let targ = strVal(arg)
  let targ2 = strVal(arg2)
  let targ3 = $(arg3)

  var source = &("""
    let {targ} = cast[ptr seq[{targ2}]](storageCache[0].cache)
        """)

  result = parseStmt(source)
macro injectComponent*(arg: untyped) =
  let targ = strVal(arg)
  result = parseStmt(targ)
# macro formatComponentPretty*(t: typedesc): untyped {.used.}=
#   let tName = strVal(t)
#   var proc_name = tName  
#   formatComponent(proc_name)
#   var source = ""
#   source = &("""
#     template `{proc_name}`*(self: ent): ptr {tName} =
#         impl_get(self,{tName})
#         """)

#   result = parseStmt(source)

macro makeTypeAlias(t: untyped, arg: untyped): untyped =
  var name_alias = $t
  formatComponent(name_alias) # this generate the right alias for the type
  result = nnkStmtList.newTree(
          nnkVarSection.newTree(
              nnkIdentDefs.newTree(
                nnkPragmaExpr.newTree(
                  newIdentNode(name_alias),
                  nnkPragma.newTree(ident("inject"))
                ),
                newEmptyNode(),
                newIdentNode($arg)
                )
              )
            )

#var storageIds = newSeq[cid]()



func sortStorages(x,y: CompStorageBase): int =
  let cx = x.entities
  let cy = y.entities
  if cx.len <= cy.len: -1
  else: 1
  #elif cx.len == cy.len: -1





proc view*(t,y: typedesc) =
  storageCache.setLen(0)
  storageCache.add(t.getStorageBase())
  storageCache.add(y.getStorageBase())
  storageCache.sort(sortStorages)

proc view*(t,y,u: typedesc) =
  storageCache.setLen(0)
  storageCache.add(t.getStorageBase())
  storageCache.add(y.getStorageBase())
  storageCache.add(u.getStorageBase())
  storageCache.sort(sortStorages)
import typetraits
template viewer*(t,y,u: typedesc, code: untyped): untyped =
  storageCache.setLen(0)
  storageCache.add(t.getStorageBase())
  storageCache.add(y.getStorageBase())
  storageCache.add(u.getStorageBase())
  storageCache.sort(sortStorages)

  var tname = storageCache[0].compType
  case tname:
    of t.type.name:
      t.BABA()
      # for m in boomer[y,u](t):
      #   code
    of y.type.name:
      y.BABA()
      # for m in boomer[t,u](y):
      #   code
    of u.type.name:
      u.BABA()

iterator comps2*(t,y: typedesc): (ptr t, ptr y) =
  storageCache.setLen(0)
  storageCache.add(t.getStorageBase())
  storageCache.add(y.getStorageBase())
  storageCache.sort(sortStorages)
  var tname = storageCache[0].compType
  case tname:
    of t.type.name:
      var st1 = t.getStorage()
      var st2 = y.getStorage()
      let max = st1.comps.high
      for i in 0..max:
        yield (st1.comps[i].addr,st2.comps[st2.indices[st1.entities[i].id]].addr)
    of y.type.name:
      var st1 = t.getStorage()
      var st2 = y.getStorage()
      let max = st2.comps.high
      for i in 0..max:
        yield (st1.comps[st1.indices[st2.entities[i].id]].addr,st2.comps[i].addr)

var smallest : CompStorageBase

iterator comps2*(t,y,u: typedesc): (ptr t, ptr y,ptr u) {.inline.} =
  var st1 = t.getStorage()
  var st2 = y.getStorage()
  var st3 = u.getStorage()
  smallest = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2

  case smallest.filterid:
    of 0:
      let max = st1.comps.high
      for i in 0..max:
        yield (st1.comps[i].addr,st2.comps[st2.indices[st1.entities[i].id]].addr,st3.comps[st3.indices[st1.entities[i].id]].addr)
    of 1:

      let max = st2.comps.high
      for i in 0..max:
        yield (st1.comps[st1.indices[st2.entities[i].id]].addr,st2.comps[i].addr,st3.comps[st3.indices[st2.entities[i].id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        yield (st1.comps[st1.indices[st3.entities[i].id]].addr,st2.comps[st2.indices[st3.entities[i].id]].addr,st3.comps[i].addr)
    else:
      discard

iterator comps2*(t: typedesc): (ent, ptr t) {.inline.} =
  var st1 = t.getStorage()
  let max = st1.comps.high
  for i in 0..max:
    yield (st1.entities[i],st1.comps[i].addr)
  
 # var st2 = y.getStorage()
  #var st3 = u.getStorage()
  #smallest = st1; smallest.filterid = 0
  #if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  #if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2

  # case smallest.filterid:
  #   of 0:
  #     let max = st1.comps.high
  #     for i in 0..max:
  #       yield (st1.comps[i].addr,st2.comps[st2.indices[st1.entities[i].id]].addr,st3.comps[st3.indices[st1.entities[i].id]].addr)
  #   of 1:

  #     let max = st2.comps.high
  #     for i in 0..max:
  #       yield (st1.comps[st1.indices[st2.entities[i].id]].addr,st2.comps[i].addr,st3.comps[st3.indices[st2.entities[i].id]].addr)
  #   of 2:
  #     let max = st3.comps.high
  #     for i in 0..max:
  #       yield (st1.comps[st1.indices[st3.entities[i].id]].addr,st2.comps[st2.indices[st3.entities[i].id]].addr,st3.comps[i].addr)
  #   else:
  #     discard

iterator comps*(t: typedesc): (ent, ptr t) = #tuple[c1: ptr t, c2: ptr y] =
  var st1 = t.getStorage()
  let max = st1.comps.high
  for i in 0..max:
    yield (st1.entities[i], st1.comps[i].addr)
iterator comps*(t,y: typedesc): (ptr t, ptr y) = #tuple[c1: ptr t, c2: ptr y] =
  var st1 = t.getStorage()
  var st2 = y.getStorage()
  let max = st1.comps.high
  for i in 0..max:
    yield (c1: st1.comps[i].addr,c2: st2.comps[i].addr)
    #yield (st1.comps[i].addr,st2.comps[st2.indices[st1.entities[i].id]].addr,st3.comps[st3.indices[st1.entities[i].id]].addr)
# iterator comps*(t,y,u: typedesc): (ptr t, ptr y, ptr u) =
#     var st1 = t.getStorage()
#     var st2 = y.getStorage()
#     var st3 = u.getStorage()
#     let max = st1.comps.high

#     for i in 0..max:
#       yield (st1.comps[i].addr,st2.comps[st2.indices[st1.entities[i].id]].addr,st3.comps[st3.indices[st1.entities[i].id]].addr)
 



     # u.compss[t,y]()
      # echo "pp"
      # for m in boomer[t,y](u):
      #   code
  # echo t.type.name
  # echo storageCache[0].type.name
  # echo storageCache[0] is t
  # echo storageCache[0] is y
  # echo storageCache[0] is u
  #code
  # var id = storageCache[0].id
  # case id:
  #   of t.id:
  #     for m in boomer[y,u](t):
  #       code
  #   of y.id:
  #     for m in boomer[t,u](y):
  #       code
  #   of u.id:
  #     for m in boomer[t,y](u):
  #       code
  
  

iterator getMe*(): ent =
  var max = storageCache[0].entities.high
  for i in 0..max:
    yield storageCache[0].entities[i]

#iterator getMe*(t)

# iterator gett*(t,y: CompStorageBase): (pointer, pointer) =
#    let max = t.entities.high
#    for i in 0..max:
#     yield (t.cache,y.cache)

# proc get*() =
#   discard

# iterator group*(t,y,: typedesc): (ptr t, ptr y) =
#   storageCache.setLen(0)
#   storageCache.add(t.getStorageBase())
#   storageCache.add(y.getStorageBase())
#   storageCache.sort(sortStorages)
#   let max = storageCache[0].entities.high
#   storageCache[0].small = true
#   storageCache[1].small = false
#  # echo storageCache[0].typedesc.equals(y)
#   for i in 0..max:
#     echo ""
  #  t.getComps()
    #var e1 = cast[ptr byte](storageCache[0].cache)
    #var e1 = cast[ptr seq[t]](storageCache[0].cache)
    #var e2 = cast[ptr seq[y]](storageCache[1].cache)
    #yield (t.compa(i),y.compa(i))

#template poopa*(n: untyped): untyped {.inject.} =
 # n = "cb"
 # parseStmt(n)

# template genComp*(n* untyped): untyped {.inject.} =
#   discard  

# template get*(t,y: typedesc, code: untyped): untyped =
#   storageCache.setLen(0)
#   storageCache.add(t.getStorageBase())
#   storageCache.add(y.getStorageBase())
#   storageCache.sort(sortStorages)
#   let max = storageCache[0].entities.high
#   #var e1 = cast[ptr byte](storageCache[0].cache)

#   for i in 0..max:
#     code
#     #var m {.inhect.} = ()
#    # var c1 {.inject.} = cast[ptr byte](storageCache[0].cache) 
#     #code
#   #for ee in gett(storageCache[0],storageCache[1]):
#     #pook(var t = 0)
#     #poopa("var a = 0")
#     #makeTypeAlias
#     #poopa(t.getCompss())
#     # t.getCompss()
#     # y.getCompss()
#     #poopa(storageCache[0].compAlias)
#    # code
#   discard




# iterator gett*(t,y: CompStorageBase): (pointer, pointer) =
#    let max = t.entities.high
#    for i in 0..max:
#     yield (t.cache,y.cache)
#iterator compBuffer*(t,y: typedesc): (ptr t, ptr y) =

#   s - storage
#   let s_t = t.getStorage()
#   let s_y = y.getStorage()
  
#   let s1 = if s_t.comps.len > s_y.comps.len: s_y else: s_t
  
  
#   for i in countdown(s.comps.high,0):
#     yield (s.comps[i].addr,s_y.comps[s_y.indices[s_y.entities[i]]].addr)


#   let comps1 = t.getComps()
#   let comps2 = y.getComps()
#   yield (comps1[0].addr,comps2[0].addr)


# template get*(t,y: typedesc, code: untyped): untyped =
#   storageCache.setLen(0)
#   storageCache.add(t.getStorageBase())
#   storageCache.add(y.getStorageBase())
#   storageCache.sort(sortStorages)
  #st
  #storageCache[0].ast
  
  #echo ast
  #injectComponent(ast)
  
 # var name = storageCache[0].compAlias
 # var ty = storageCache[0].compType
  #echo ty
 # injectComponent(storageCache[0].compAlias,ty,0)
  #injectComponent(name,ty,0)
 # name = storageCache[1].compAlias
 # ty = storageCache[1].compType
  #injectComponent(name,ty,1)
  #var comps1 = cast[ptr seq[CompB]](storageCache[0].cache)
 # var comps1 = cast[ptr seq[CompB]](t.getStorageBase().cache)
  #block:
    #for i in 0..49:
      #code
      #var cb {.inject.} = comps1[][i].addr
    #var cbb {.inject.} = cast[ptr seq[CompB]](storageCache[0].compss)
      #code
  #injectComponent(name,ty,0)
  #injectComponent(storageCache[1].compAlias,storageCache[1].compType,1)
  
  #let ca {.inject.} = members[0] # ComponentA
  #let cb {.inject.} = members[1] # ComponentB
  #var
  
  # echo storageCache[0].entities.len
  # var st = t.getStorage()
  # var sy = y.getStorage()
  # var s : pointer = st
  # s = sy
  # echo s
#  var stores = newSeq[CompStorage[typedesc]]()
  #echo storages[0].typedesc.getType
  #var s = newSeq[type]()
  #s.add(t)
  #echo sortStorages(t,y) 

  #code
#iterator compBuffer*(ptr t, ptr y): (ptr t, ptr y) =
   #yield (s.comps[i].addr,s_y.comps[s_y.indices[s_y.entities[i]]].addr) 
#iterator compBuffer*(t,y: typedesc): (ptr t, ptr y) =

  # s - storage
  # let s_t = t.getStorage()
  # let s_y = y.getStorage()
  
  # let s1 = if s_t.comps.len > s_y.comps.len: s_y else: s_t
  
  
  # for i in countdown(s.comps.high,0):
  #   yield (s.comps[i].addr,s_y.comps[s_y.indices[s_y.entities[i]]].addr)


  #let comps1 = t.getComps()
  #let comps2 = y.getComps()
  #yield (comps1[0].addr,comps2[0].addr)

# template get*(t,y: typedesc, code: untyped): untyped {.used.} =
#   storageIds.setLen(0)
#   storageIds.add(t.id)
#   storageIds.add(y.id)
#   storageIds.sort(sortStorages)
  


#   #echo storageIds
#   code
  
  
  
  # for members in compBuffer(t,y):
  #    let m1 = members[0]
  #    let m2 = members[1]

  #    makeTypeAlias(t,m1)
  #    makeTypeAlias(y,m2)

  #    code



#proc myCmp(x, y: cid): int =
  
  #if x.name < y.name: -1
 # elif x.name == y.name: 0
  #else: 1

#iterator compBuffer*(t,y: typedesc): (ptr t, ptr y) =

  # s - storage
  # let s_t = t.getStorage()
  # let s_y = y.getStorage()
  
  # let s1 = if s_t.comps.len > s_y.comps.len: s_y else: s_t
  
  
  # for i in countdown(s.comps.high,0):
  #   yield (s.comps[i].addr,s_y.comps[s_y.indices[s_y.entities[i]]].addr)


  #let comps1 = t.getComps()
  #let comps2 = y.getComps()
  #yield (comps1[0].addr,comps2[0].addr)

