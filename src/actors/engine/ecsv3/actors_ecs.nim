#{.experimental: "codeReordering".}
{.experimental: "dynamicBindSym".}
{.used.} 

import hashes
import math
import strutils
import typetraits 
import macros
import times
import strformat
import sets

import ../../actors_h
import ../../actors_tools
import actors_ecs_h



export actors_ecs_h except
  layers,
  storages,
  makeStorage


var id_next           {.global.} : int = 0 # confusion with {.global.} in proc, redefining
var id_entity_last    {.used.}   : int = 0
var id_component_next {.used.}   : uint16 = 0 
var entitiesMeta   = newSeqOfCap[Entity](1024)
var ents_stash  = newSeqOfCap[ent](256)

include actors_ecs_formatters
include actors_ecs_debug
include actors_ecs_utils

proc entity*(layerID: LayerID): ent =
  let ecs = layers[layerID.int]
  if ents_stash.len > 0:
    result = ents_stash[0]
    let e = addr entitiesMeta[result.id]
    e.dirty = true
    e.layer = layerID
    ents_stash.del(0)
  else:
    let e = entitiesMeta.add_new()
    e.dirty = true
    e.layer = layerID
    result.id = id_next
    result.age = 0
    id_next += 1
    
    let op = ecs.operations.add_new()
    op.entity = result
    op.kind = OpKind.Init
    ecs.ents_alive.incl(result.id)
  result



template remove(gr: Group, self: ent, entityMeta: ptr Entity) =
  let index = binarysearch(addr gr.entities, self.id)
  gr.entities.delete(index)
  entityMeta.signature_groups.excl(gr.id)
  #gr.removed.add(self)

template empty(ecs: SystemEcs, op: ptr Operation, entityMeta: ptr Entity) =
    for gid in entityMeta.signature_groups:
      let group = ecs.groups[gid]
      group.remove(op.entity,entityMeta)

    ents_stash.add(op.entity)
    entityMeta.signature_groups = {0'u16}
    entityMeta.parent = (0,0)
    entityMeta.childs.setLen(0)
    ecs.ents_alive.excl(op.entity.id)

proc empty2*(ecs: SystemEcs, sss: ent, entity: ptr Entity) =
    for gid in entity.signature_groups:
      let group = ecs.groups[gid]
      group.remove(sss,entity)

    ents_stash.add(sss)
    entity.signature_groups = {0'u16}
    entity.parent = (0,0)
    entity.childs.setLen(0)
    ecs.ents_alive.excl(sss.id)

proc kill1*(self: ent) = 
    check_error_release_empty(self)
    var entity = addr entitiesMeta[self.id]
    #let op = layer.operations.addNew()
    #op.entity = self
   # op.kind = OpKind.Kill
   
    for e in entity.childs:
        kill1(e)
    
    entity.signature = {}
    
    if entity.age == high(int):
      entity.age = 0
    else: entity.age += 1
    
    layers[entity.layer.int].empty2(self,entity)



proc kill*(self: ent) = 
    check_error_release_empty(self)
    var entity = addr entitiesMeta[self.id]
    let layer = layers[entity.layer.int]
    let op = layer.operations.addNew()
    op.entity = self
    op.kind = OpKind.Kill
   
    for e in entity.childs:
        kill(e)
    
    entity.signature = {0'u16}
    
    if entity.age == high(int):
      entity.age = 0
    else: entity.age += 1

    
  #   op.entity.age == high(uint32):
  #   op.entity.age = 0
  # else:
  #   op.entity.age += 1
  #   entityMeta.age = op.entity.age
  #   ents_stash.add(op.entity)
  #   entityMeta.signature_groups = {0'u16}
  #   entityMeta.parent = (0'u32,0'u32)
  #   entityMeta.childs.setLen(0)
  #   ecs.ents_alive.excl(op.entity.id)


proc unparent(self: ent) =
    let entity_self = addr entitiesMeta[self.id]
    let entity_parent = addr entitiesMeta[entity_self.parent.id]
    
    for i in 0..entity_parent.childs.high:
        if entity_parent.childs[i].id == self.id:
            entity_parent.childs.del(i)
            break
    
    entity_self.parent = ent.none


proc `parent=`*(self: ent,parent: ent) {.inline.} =
  if parent == ent.none:
    unparent(self)
  else:
    let entity_this = addr entitiesMeta[self.id]
    let entity_parent = addr entitiesMeta[parent.id]
    entity_this.parent = parent
    entity_parent.childs.add(self)

proc parent*(self: ent): ent {.inline.} =
    entitiesMeta[self.id].parent


proc `$`*(this: ent): string =
    $this.id

#@checkers
template exist_impl(this, entity: untyped): untyped =
  entity.age == this.age and entity.signature.card>0

proc exist*(this: ent): bool =
  exist_impl(this,addr entitiesMeta[this.id])

template has*(self:ent, t: typedesc): bool =
  t.has(self)
template has*(self:ent, t,y: typedesc): bool =
  t.has(self) and 
  y.has(self)
template has*(self:ent, t,y,u: typedesc): bool =
  t.has(self) and
  y.has(self) and
  u.has(self)
template has*(self:ent, t,y,u,i: typedesc): bool =
  t.has(self) and
  y.has(self) and
  u.has(self) and
  i.has(self)
template has*(self:ent, t,y,u,i,o: typedesc): bool =
 t.has(self) and
 y.has(self) and
 u.has(self) and
 i.has(self) and
 o.has(self)
template has*(self:ent, t,y,u,i,o,p: typedesc): bool =
 t.has(self) and
 y.has(self) and
 u.has(self) and
 i.has(self) and
 o.has(self) and
 p.has(self)


macro get*(this: ent, args: untyped, code: untyped): untyped =
  var command = nnkCommand.newTree(
                  nnkDotExpr.newTree(
                      ident($this),
                      ident("has")))
  if args.len > 1:
      for elem in args:
          command.add(ident($elem))
          var elem_name = $elem
          formatComponentAlias(elem_name) 
          var elem_var = toLowerAscii(elem_name[0]) & substr(elem_name, 1)
          formatComponent(elem_var)
          var n = nnkLetSection.newTree(
              nnkIdentDefs.newTree(
                  newIdentNode(elem_var),
                  newEmptyNode(),
                  nnkDotExpr.newTree(
                      newIdentNode($this),
                      newIdentNode(elem_var)
                  ),
              )
          )
          code.insert(0,n)
  else:
      command.add(ident($args))
      var elem_name = $args
      formatComponentAlias(elem_name) 
      var elem_var = toLowerAscii(elem_name[0]) & substr(elem_name, 1)
      formatComponent(elem_var)
      var n = nnkLetSection.newTree(
          nnkIdentDefs.newTree(
              newIdentNode(elem_var),
              newEmptyNode(),
              nnkDotExpr.newTree(
                  newIdentNode($this),
                  newIdentNode(elem_var)
              ),
          )
      )
      code.insert(0,n)

  var node_head = nnkStmtList.newTree(
      nnkIfStmt.newTree(
          nnkElifBranch.newTree(
              command,
               nnkStmtList.newTree(
                   code
               )
          )
      )
  )
  result = node_head

template mask*(T: typedesc): set[uint16] =
  {T.ID}
template mask*(T,Y: typedesc): set[uint16] =
  {T.ID,Y.ID}
template mask*(T,Y,U: typedesc): set[uint16] =
  {T.ID,Y.ID, U.ID}
template mask*(T,Y,U,I: typedesc): set[uint16] =
  {T.ID,Y.ID, U.ID, I.ID}
template mask*(T,Y,U,I,O: typedesc): set[uint16] =
  {T.ID,Y.ID, U.ID, I.ID,O.ID}
template mask*(T,Y,U,I,O,P: typedesc): set[uint16] =
  {T.ID,Y.ID, U.ID, I.ID,O.ID,P.ID}
template mask*(T,Y,U,I,O,P,S: typedesc): set[uint16] =
  {T.ID,Y.ID, U.ID, I.ID,O.ID,P.ID,S.ID}
template mask*(T,Y,U,I,O,P,S,D: typedesc): set[uint16] =
  {T.ID,Y.ID, U.ID, I.ID,O.ID,P.ID,S.ID,D.ID}

#@groups
var id_next_group {.global.} : uint16 = 0
var mask_exclude* : set[uint16]
var mask_include* : set[uint16]

template gen_indices*(self: var seq[int]) {.used.} =
  self = newSeq[int](ENTS_INIT_SIZE)
  for i in 0..self.high:
    self[i] = ent.none.id


macro group*(layer: LayerId, t: varargs[untyped]) =
  var n = newNimNode(nnkStmtList)
  template genMask(arg: untyped): NimNode =
    var n = newNimNode(nnkCall)
    if arg.len > 0 and $arg[0] == "!":
      n.insert(0,newDotExpr(ident("mask_exclude"), ident("incl")))
      n.insert(1,newDotExpr(ident($arg[1]), ident("ID")))
    else:
      n.insert(0,newDotExpr(ident("mask_include"), ident("incl")))
      n.insert(1,newDotExpr(ident($arg), ident("ID")))
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
    #group_next.indices.gen_indices()
    group_next.layer = layer
    for id in mask_include:

      storages[id].groups.add(group_next)
    for id in mask_exclude:
      storages[id].groups.add(group_next)
    id_next_group += 1
  
  mask_include = {}
  mask_exclude = {}
  group_next


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
#       if not incl.contains(0):
#         for id in incl:
#           storages[id].groups.add(group_next)
#       if not excl.contains(0):
#        for id in excl:
#          storages[id].groups.add(group_next)
#       id_next_group += 1
  
#   group_next

# proc group*(layer: LayerID, incl: set[uint16]): Group {.inline, discardable.} =
#    group_impl(layer, incl, {0'u16})

# proc group*(layer: LayerID, incl: set[uint16], excl: set[uint16]): Group {.inline, discardable.} =
#    group_impl(layer, incl, excl)


template insert(gr: Group, self: ent, entityMeta: ptr Entity) = 
  var len = gr.entities.len
  var left, index = 0
  var right = len
  len+=1
  if self.id >= entitiesMeta.len:
      gr.entities.add self
  else:
      var conditionSort = right - 1
      if conditionSort > -1 and self.id < gr.entities[conditionSort].id:
          while right > left:
              var midIndex = (right+left) div 2
              if gr.entities[midIndex].id == self.id:
                  index = midIndex
                  break
              if gr.entities[midIndex].id < self.id:
                  left = midIndex+1
              else:
                  right = midIndex
              index = left
          gr.entities.insert(self, index)
      else:
          if right == 0 or right >= gr.entities.high:
              gr.entities.add self
          else:
              gr.entities[right] = self
  entityMeta.signature_groups.incl(gr.id)
  # gr.added.add(self)



template checkMask(entity: ptr Entity, group: Group): bool =
  #echo card(group.signature * entityMeta.signature)
  if group.signature <= entityMeta.signature and 
    card(group.signature_excl * entityMeta.signature) == 0:
      true
  else: false

template checkGroup(entity: ptr Entity, group: Group): bool =
  if group.id in entity.signature_groups:
    true
  else: false

template changeEntity(op: ptr Operation, entityMeta: ptr Entity) =
  let cid = op.arg
  let groups = addr storages[cid].groups
  for group in groups[]:
    let masked  = checkMask(entityMeta, group)
    let grouped = checkGroup(entityMeta, group)
    if grouped and not masked:
      group.remove(op.entity, entityMeta)
    elif masked and not grouped:
      group.insert(op.entity, entityMeta)
  discard



#@processing
proc execute*(ecs: SystemEcs) {.inline.} =
  let operations = addr ecs.operations
  #let size = operations[].len
  for i in 0..operations[].high:
     let op = addr operations[][i]
     let entityMeta = addr entitiesMeta[op.entity.id]
     while true:
       case op.kind:
          of Kill:
            ecs.empty(op,entityMeta)
            break
          of Remove:
            if entityMeta.signature == {}:
              for e in entityMeta.childs:
                  e.kill()
              ecs.empty(op,entityMeta)
            else:
              changeEntity(op, entityMeta);
            break
          of Add:
            changeEntity(op, entityMeta);  
            break
              
          of Init:
            entityMeta.dirty = false
            for cid in entityMeta.signature:
              let groups = addr storages[cid].groups
             
              for group in groups[]:
                let grouped = checkGroup(entityMeta, group)
                if not grouped:
       
                  if checkMask(entityMeta, group):
                  
                    group.insert(op.entity, entityMeta)
            break
          

  operations[].setLen(0)
  # if size>0:
  #    for gr in ecs.groups:
  #        for ev in gr.events:
  #            ev()
  #        gr.added.setLen(0)
  #        gr.removed.setLen(0)

iterator items*(range: Group): ent =
  let ecs = layers[range.layer.uint32]
  ecs.execute()
  var i = range.entities.low
  while i <= range.entities.high:
      yield range.entities[i]
      inc i



iterator compss*[t,y](): tuple[a: ptr t, b: ptr y] =
  let comps1 = t.GetComps()
  let comps2 = y.GetComps()
  let st1 = t.GetStorage()
  let len1 = comps1[].len
  let len2 = comps2[].len
  let max = if len1 > len2: len2 else: len1
  var i = 0
  while i < max:
    yield (comps1[][i].addr,comps2[][st1.indices[i]].addr)
    inc i

iterator group*(t: typedesc, y: typedesc, u: typedesc): tuple[e: ent, a: ptr t, b: ptr y, c: ptr u] =
  let comps1 = t.GetComps()
  let comps2 = y.GetComps()
  let comps3 = u.GetComps()

  let st1 = t.GetStorage()
  let len1 = comps1[].len
  let len2 = comps2[].len
  let len3 = comps3[].len
  let max = if len1 > len2: len2 else: len1
  var i = 0
  while i < max:
    let e = st1.indices[i]
    yield ((e,entitiesMeta[e].age), comps1[][i].addr,comps2[][e].addr, comps3[][e].addr)
    inc i

iterator comps*(t: typedesc, y: typedesc, u: typedesc): tuple[a: ptr t, b: ptr y, c: ptr u] =
  let comps1 = t.GetComps()
  let comps2 = y.GetComps()
  let comps3 = u.GetComps()

  let st1 = t.GetStorage()
  let len1 = comps1[].len
  let len2 = comps2[].len
  let len3 = comps3[].len
  let max = if len1 > len2: len2 else: len1
  var i = 0
  while i < max:
    let e = st1.indices[i]
    yield (comps1[][i].addr,comps2[][e].addr, comps3[][e].addr)
    inc i
  

#@storage
template impl_storage_compact(t: typedesc, compType: CompType) {.used.} =
  let storage* {.used.} = makeStorage[t]()

  storage.meta.id  = id_component_next
  id_component_next+=1

  storage.meta.bitmask = 1 shl (storage.meta.id mod 32)
  storage.meta.generation = storage.meta.id div 32
  
  storages.add(storage)
  proc GetStorage*(_:typedesc[t]): Storage[t] =
    storage
  proc GetComps*(_:typedesc[t]): ptr seq[t] =
    addr storage.components

  proc StorageSizeCalculate*(_:typedesc[t]): int {.discardable.} =
    (storage.sizeof + _.sizeof * storage.container.len + storage.entities.len * uint32.sizeof+storage.entities.len * int.sizeof) div 1000
  
  proc StorageSize*(_:typedesc[t]) : string {.discardable.} =
      var kb {.inject.}  = formatFloat(_.StorageSizeCalculate.float32 ,format = ffDecimal,precision = 0)
      var name {.inject.} = typedesc[t].name
      var format {.inject.}  = &"Size of {name} storage: "
      format.add(kb)
      format.add(" KB")
      format
  
  proc has*(_:typedesc[t], self: ent): bool {.inline,discardable.} =
    storage.indices[self.id] != ent.none.id

  proc ID*(_:typedesc[t]): uint16 {.inline, discardable.} =
      storage.meta.id
  
  template impl_get_action(self: ent, _: typedesc[t]) {.used.} =
      storage.components[storage.indices[self.id]](self)
  proc impl_get(self: ent, _: typedesc[t]): ptr t {.inline, discardable, used.} =
      addr storage.components[storage.indices[self.id]]
  proc impl_get(self: ptr ent, _: typedesc[t]): ptr t {.inline, discardable, used.} =
      addr storage.components[storage.indices[self.id]]

  proc get*(self: ent, _: typedesc[t], arg: t) =
      let id = storage.meta.id
      let entity = addr entitiesMeta[self.id]
      if t.ID in entitiesMeta[self.id].signature:
        storage.container[storage.entities[self.id]] = arg
      else:
        storage.container.add(arg)
      
      if self.id >= (uint32)storage.entities.high:
        storage.entities.setLen(self.id+1)

      storage.entities[self.id] = (uint32)storage.container.high
      entity.signature.incl(id)
    
      if not entity.dirty:
          let op = entity.layer.ecs.operations.addNew()
          op.entity = self
          op.kind = OpKind.Add
          op.arg  = id

  proc get*(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
      
      #const st = storage
      let st = storage
      let cid = st.meta.id
      let entity = addr entitiesMeta[self.id]
        
      if self.id >= (entid)st.indices.high:
        st.indices.setLen(self.id+1)

      st.indices[self.id] = st.entities.len
      st.entities.add(self.id)
      
      let comp = st.components.addNew()
      
      entity.signature.incl(cid)
      
      if not entity.dirty:
        let op = entity.layer.ecs.operations.addNew()
        op.entity = self
        op.kind = OpKind.Add
        op.arg  = cid
      
      comp
      # if t.Id in entitiesMeta[self.id].signature:
      #   return addr storage.components[storage.entities[self.id]]

      # let id = storage.meta.id
      # let entity = addr entitiesMeta[self.id]
      # let comp = storage.components.addNew()
            
      # if self.id >= (uint32)storage.entities.high:
      #   storage.entities.setLen(self.id+1)
      
      # storage.entities[self.id] = (uint32)storage.components.high
      # entity.signature.incl(id)
    
      # if not entity.dirty:
      #     let op = entity.layer.ecs.operations.addNew()
      #     op.entity = self
      #     op.kind = OpKind.Add
      #     op.arg  = id

      # comp
  
 

  proc remove*(self: ent, _: typedesc[t]) {.inline, discardable.} = 
      checkErrorRemoveComponent(self, t)
      let entity = addr entitiesMeta[self.id]
      let op = entity.layer.ecs.operations.addNew()
      op.entity = self
      op.arg = storage.meta.id
      op.kind = OpKind.Remove
      entity.signature.excl(op.arg)


  formatComponentPretty(t, compType)
  formatComponentPrettyAndLong(t, compType)

macro add*(self: App, component: untyped, compType: static CompType = Object): untyped =

  result = nnkStmtList.newTree(
          nnkCommand.newTree(
              bindSym("impl_storage_compact", brForceOpen),
              newIdentNode($component),
              newIdentNode($compType)
            )
          )
  

  var name_alias = $component
  if (name_alias.contains("Component") or name_alias.contains("Comp")):
      formatComponentAlias(name_alias)
      
      let node = nnkTypeSection.newTree(
      nnkTypeDef.newTree(
          nnkPostfix.newTree(
              newIdentNode("*"),
              newIdentNode(name_alias)),
              newEmptyNode(),
      newIdentNode($component)
      ))
      result.add(node)