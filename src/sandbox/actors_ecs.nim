## Распредели группы в хранилища
##
##
##
##
##
##
##
##
##

{.experimental: "codeReordering".}
{.experimental: "dynamicBindSym".}
{.used.} 

import macros
import strformat
import strutils
import times
import tables
import sets
import hashes
import typetraits 
import math

import ../actors/actors_utils

type ent* = tuple
  id  : uint32
  age : uint32

type EcsInstance = ref object

type SystemEcs* = ref object
  operations*   : seq[Operation]
  ents_alive*   : HashSet[uint32]
  groups        : seq[Group]
  #groupsTable   : Table[uint16,seq[Group]]

type Entity* {.packed.} = object
  dirty*            : bool        #dirty allows to set all components for a new entity in one init command
  age*              : uint32
  layer*            : int
  system*           : SystemEcs
  parent*           : ent
  isAlive           : bool
  signature*        : set[uint16] 
  #signature_comps*  : set[uint16] # double buffer, need for such methods as has/get and init operation
  signature_groups* : set[uint16] # what groups are already used
  childs*           : seq[ent]
  #groups*           : seq[Group]

type Group* = ref object of RootObj
  id*               : uint16
  system*           : SystemEcs
  layer*            : int
  signature*        : set[uint16]
  entities*         : seq[ent]
  entities_added*   : seq[ent]
  entities_removed* : seq[ent]
  events*           : seq[proc(added: var seq[ent], removed: var seq[ent])]

type ComponentMeta {.packed.} = object
  id*        : uint16
  generation : uint16
  bitmask    : int

type StorageBase = ref object of RootObj
  meta*      : ComponentMeta
  groups*    : seq[Group]

type Storage*[T] = ref object of StorageBase
  entities*  : Table[uint32, int]
  container* : seq[T]
  
type OpKind = enum
  Init
  Add,
  Remove,
  Kill,
  Empty
type Operation {.packed.} = object
  kind*  : OpKind
  entity*: ent 
  arg*   : uint16


var ecs* = EcsInstance()

var id_next {.global.}         : uint32 = 0 # confusion with {.global.} in proc, redefining
var id_component_next {.used.} : uint16 = 0 
var id_entity_last {.used.}    : uint32 = 0
var entities   = new_seqofcap[Entity](1024)
var ents_stash = newSeqOfCap[ent](256)

var ecsMain* = SystemEcs()


#@entities
proc entity*(this: SystemEcs): ent {.inline.} =

    if ents_stash.len > 0:
        result = ents_stash[0]
        let e = addr entities[result.id]
        e.dirty = true
        e.system = this
        #e.layer = layer.int
        #lr = e.layer
        ents_stash.del(0)
    else:
        let e = entities.addNew()
        e.dirty = true
        e.system = this
        #e.layer = layer.int
        #lr = e.layer
        result.id = id_next
        result.age = 0
        id_next += 1
    

    #let layer = ecs.layers[lr]
    let op = this.operations.addNew()
    op.entity = result
    op.kind = OpKind.Init
    this.ents_alive.incl(result.id)
    #op.entity = result
    #op.kind = OpKind.Init
    #layer.ents_alive.incl(result.id)

proc release*(this: ent) = 
    #check_error_release_empty(this)
    let entity = entities[this.id]
    let op = entity.system.operations.addNew()
    op.entity = this
    op.kind = OpKind.Kill
    entities[this.id].isAlive = false
    for e in entity.childs:
        release(e)

#@groups
proc group*(this: SystemEcs, Comp1: typedesc): Group =
  result = group_impl(this, {Comp1.ID})
proc group*(this: SystemEcs, Comp1, Comp2: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3, Comp4: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID, Comp4.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3, Comp4, Comp5: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID, Comp4.ID, Comp5.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3, Comp4, Comp5, Comp6: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID, Comp4.ID, Comp5.ID, Comp6.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3, Comp4, Comp5, Comp6, Comp7: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID, Comp4.ID, Comp5.ID, Comp6.ID, Comp7.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3, Comp4, Comp5, Comp6, Comp7, Comp8: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID, Comp4.ID, Comp5.ID, Comp6.ID, Comp7.ID, Comp8.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3, Comp4, Comp5, Comp6, Comp7, Comp8, Comp9: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID, Comp4.ID, Comp5.ID, Comp6.ID, Comp7.ID, Comp8.ID, Comp9.ID})
proc group*(this: SystemEcs, Comp1, Comp2, Comp3, Comp4, Comp5, Comp6, Comp7, Comp8, Comp9, Comp10: typedesc): Group =
  result = group_impl(this, {Comp1.ID, Comp2.ID, Comp3.ID, Comp4.ID, Comp5.ID, Comp6.ID, Comp7.ID, Comp8.ID, Comp9.ID, Comp10.ID})


var id_next_group {.global.} : uint16 = 0
proc group_impl(this: SystemEcs, components: set[uint16]): Group = 
  var signature = components
  var group_next : Group = nil
  let groups = addr this.groups
  
  for i in 0..groups[].high:
      let gr = groups[][i]
      if gr.signature == signature:
          group_next = gr
          break
  
  if group_next.isNil:
      group_next = groups[].add_new_ref()
      group_next.id = id_next_group
      group_next.signature = signature
      group_next.entities = newSeqOfCap[ent](1000)
      group_next.entities_added = newSeqOfCap[ent](500)
      group_next.entities_removed = newSeqOfCap[ent](500)
      group_next.system = this
      for id in signature:
        storages[id].groups.add(group_next)
      id_next_group += 1
  
  group_next
    

template insert(gr: Group, self: ent, entityMeta: ptr Entity) = 
  var len = gr.entities.len
  var left, index = 0
  var right = len
  len+=1
  if self.id >= entities.len.uint32:
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
  gr.entities_added.add(self)
 
template remove(gr: Group, self: ent, entityMeta: ptr Entity) =
  let index = binarysearch(addr gr.entities, self.id)
  gr.entities.delete(index)
  #entityMeta.signature_groups.excl(gr.id)
  gr.entities_removed.add(self)

# template group_add(self: ptr Operation, entityMeta: ptr Entity) =
#   let groups = addr storages[self.arg].groups
#   for i in 0..groups[].high:
#     let gr = groups[][i]
#     if gr.id notin entityMeta.signature_groups:
#       if gr.signature <= entityMeta.signature:
# template group_check(self: ptr Operation, entityMeta: ptr Entity) =
#   let groups = addr storages[self.arg].groups
#   for i in 0..groups[].high:
#       let gr = groups[][i]
#       if gr.id notin entityMeta.signature_groups:
#           if gr.signature <= entityMeta.signature:
#   # for gr in storages[self.arg].groups:
#   #   if gr.signature <= entityMeta.signature:
       
#   #      #let id = binarysearch(addr gr.entities, op.entity.id)
#    # discard
#   discard

# template group_remove(self: ent, entityMeta: ptr Entity,cid: int) =
#   # for gid in entityMeta.signature_groups:
#   #   discard

#   #var i = 0
#   for gr in storages[cid].groups:
#     if gr.signature <= entityMeta.signature:
#         let id = binarysearch(addr gr.entities, op.entity.id)
#         gr.entities.delete(id)
#         entityMeta.signature_groups.excl(gr.id)
#         #groupsToRemove.add(i)
#         gr.entities_removed.add(self)
#    # i+=1
#   #for index in groupsToRemove:
#   #  entityMeta.groups.delete(index)
#  # groupsToRemove.setLen(0)

#@processing
proc execute*(ecs: SystemEcs) {.inline.} =
  let operations = addr ecs.operations
  let size = operations[].len
  for i in 0..operations[].high:
     let op = addr operations[][i]
     let entityMeta = addr entities[op.entity.id]
     #let arg = op.arg
     while true:
       case op.kind:
          of Kill:
            op.kind = Empty
          of Remove:
            let cid = op.arg
            let groups = addr storages[cid].groups
            for group in groups[]:
              if group.id in entityMeta.signature_groups:
                #if cid notin entityMeta.signature:
                  group.remove(op.entity,entityMeta)
              #else:
              
              #   if group.signature <= entityMeta.signature:
              #     group.insert(op.entity, entityMeta)
#entityMeta.signature_groups.excl(gr.id)
          
            if entityMeta.signature == {}:
                op.kind = Empty
                for e in entityMeta.childs:
                    e.release()

            break
          of Empty:
            if op.entity.age == high(uint32):
              op.entity.age = 0
            else:
              op.entity.age += 1
              entityMeta.age = op.entity.age
              ents_stash.add(op.entity)
              entityMeta.signature = {}
              entityMeta.signature_groups = {}
              entityMeta.parent = (0'u32,0'u32)
              entityMeta.childs.setLen(0)
              ecs.ents_alive.excl(op.entity.id)
            break
          of Add:
            let cid = op.arg
            let groups = addr storages[cid].groups
            for group in groups[]:
              if group.signature <= entityMeta.signature:
                group.insert(op.entity, entityMeta)
              else:
                if group.id in entityMeta.signature_groups:
                  group.remove(op.entity, entityMeta)
            break
              
          of Init:
            entityMeta.dirty = false
            for cid in entityMeta.signature:
              let groups = addr storages[cid].groups
              for group in groups[]:
                if group.id notin entityMeta.signature_groups:
                  if group.signature <= entityMeta.signature:
                    group.insert(op.entity, entityMeta)
            break
          

  operations[].setLen(0)
  if size>0:
     for gr in ecs.groups:
         for ev in gr.events:
             ev(gr.entities_added,gr.entities_removed)
         gr.entities_added.setLen(0)
         gr.entities_removed.setLen(0)

#@formatters
proc formatComponent(s: var string) =
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toLowerAscii(s[0]) & substr(s, 1)

proc formatComponentAlias(s: var string) =
  var indexes : array[8,int]
  var i = 0
  var index = 0
  while i<s.len:
     if s[i] in 'A'..'Z': 
       indexes[index] = i
       index += 1
       assert index < 7, "too long name"

     i+=1
  if index>=2:
    delete(s,1,indexes[1]-1)
  s = toUpperAscii(s[0]) & substr(s, 1)

macro formatComponentPretty(t: typedesc): untyped =
  let tName = strVal(t)
  var proc_name = tName  
  formatComponent(proc_name)
  var source = &("""
  template `{proc_name}`*(self: ent): ptr {tName} =
      impl_get(self,{tName})""")
  # var source2 = &("""
  # template `{proc_name}`*(self: ptr ent): ptr {tName} =
  #     impl_get(self,{tName})""")
  result = parseStmt(source)
  #result.add(parseStmt(source2))

var storages* = newSeq[StorageBase]()

#@storage
template impl_storage(t: typedesc) {.used.} =
  var storage {.used.} = Storage[t]()
  storage.container = newSeq[t]()
  storage.entities  = Table[uint32,int]()
  storage.meta.id = id_component_next
  storage.meta.bitmask = 1 shl (storage.meta.id mod 32)
  storage.meta.generation = storage.meta.id div 32
  storage.groups = newSeqOfCap[Group](32)
  storages.add(storage)
  id_component_next+=1


  proc StorageSizeCalculate*(_:typedesc[t]): int {.discardable.} =
    (storage.sizeof + _.sizeof * storage.container.len + storage.entities.len * uint32.sizeof+storage.entities.len * int.sizeof) div 1000
  
  proc StorageSize*(_:typedesc[t]) : string {.discardable.} =
      var kb {.inject.}  = formatFloat(_.StorageSizeCalculate.float32 ,format = ffDecimal,precision = 0)
      var name {.inject.} = typedesc[t].name
      var format {.inject.}  = &"Size of {name} storage: "
      format.add(kb)
      format.add(" KB")
      format
  
  proc ID*(_:typedesc[t]): uint16 {.inline, discardable.} =
      storage.meta.id
  
  proc impl_get(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
      addr storage.container[storage.entities[self.id]]
  
  proc impl_get(self: ptr ent, _: typedesc[t]): ptr t {.inline, discardable.} =
      addr storage.container[storage.entities[self.id]]

  proc get*(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
      #check_error_has_component(self, t)
      if t.Id in entities[self.id].signature:
        return impl_get(self,_)

      let id = storage.meta.id
      let entity = addr entities[self.id]
      let comp = storage.container.addNew()

      storage.entities[self.id] = storage.container.high
      entity.signature.incl(id)
    
      if not entity.dirty:
          let op = entity.system.operations.addNew()
          op.entity = self
          op.kind = OpKind.Add
          op.arg  = id

      comp
  
  proc remove*(self: ent, _: typedesc[t]) {.inline, discardable.} = 
      checkErrorRemoveComponent(self, t)
      let entity = addr entities[self.id]
      let op = entity.system.operations.addNew()
      op.entity = self
      op.arg = storage.meta.id
      op.kind = OpKind.Remove
      entity.signature.excl(op.arg)


  formatComponentPretty(t)

macro add*(this: EcsInstance, component: untyped): untyped =
  result = nnkStmtList.newTree(
           nnkCommand.newTree(
              bindSym("impl_storage", brForceOpen),
              newIdentNode($component)
             )
          )

  var name_alias = $component
  if (name_alias.contains("Component")):
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

#@utils
proc binarysearch(this: ptr seq[ent], value: uint32): int {.discardable, inline.} =
  var m : int = -1
  var left = 0
  var right = this[].high
  while left <= right:
      m = (left+right) div 2
      if this[][m].id == value: 
          discard
      if this[][m].id < value:
          left = m + 1
      else:
          right = m - 1
  return m

proc hash*(x: set[uint16]): Hash =
  result = x.hash
  result = !$result

#@errors
when defined(debug):
  type
    EcsError* = object of ValueError

template check_error_remove_component(this: ent, t: typedesc): untyped =
  when defined(debug):
    let arg1 {.inject.} = t.name
    let arg2 {.inject.} = this.id
    if t.Id notin entities[this.id].signature:
      log_external fatal, &"You are trying to remove a {arg1} that is not attached to entity with id {arg2}"
      raise newException(EcsError,&"You are trying to remove a {arg1} that is not attached to entity with id {arg2}")

template check_error_release_empty(this: ent): untyped =
  when defined(debug):   
    let arg1 {.inject.} = this.id
    if entities[this.id].signature.card == 0:
      log_external fatal, &"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically."
      raise newException(EcsError,&"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically.")

template check_error_has_component(this: ent, t: typedesc): untyped =
  when defined(debug):
    let arg1 {.inject.} = t.name
    let arg2 {.inject.} = this.id
    if t.Id in entities[this.id].signature:
      log_external fatal, &"You are trying to add a {arg1} that is already attached to entity with id {arg2}"
      raise newException(EcsError,&"You are trying to add a {arg1} that is already attached to entity with id {arg2}")



