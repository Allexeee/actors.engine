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
import ../actors_utils

from actors_core_base import Layer
from actors_core_base import `+`
from sugar import `=>`

const
    public* = true
    private* = false


# type  possibly good for custom seqs
#   ArrayPart{.unchecked.} = array[0, int]
#   MySeq = object
#     len, cap: int
#     data: ArrayPart


type #@ecs
    EcsInstance = ref object
        layers* : seq[EcsLayer]
    EcsLayer = ref object
        groups      : seq[Group]
        operations* : seq[Operation] # new_seqofcap[Operation](1024)
        ents_alive* : HashSet[uint32]

type #@entities
    ent* = tuple
        id:  uint32
        age: uint32
    Entity* {.packed.} = object
        dirty*   : bool # dirty allows to set all components for a new entity in one init command
        age*    : uint32
        layer*  : int
        parent* : ent
        signature*         : set[uint16] 
        signature_temp*    : set[uint16] # double buffer, need for such methods as has/get and init operation
        signature_groups*  : set[uint16] # what groups are already used
        childs* : seq[ent]

type #@storage
    StorageBase = ref object of RootObj
        meta*: ComponentMeta
    Storage*[T] = ref object of StorageBase   
        entities* : seq[uint32]
        container*: seq[T]
    StorageCompact*[T] = ref object of StorageBase   
        entities* : Table[uint32, int]
        container*: seq[T]
    ComponentMeta {.packed.} = object
        id* : uint16
        generation: uint16
        bitmask: int
    ComponentKind* = enum
        Compact,
        Fast 

type #@groups
    Group = ref object of RootObj
        id* : uint16
        layer*: int
        signature*: set[uint16]
        entities: seq[ent]
        entities_added  : seq[ent]
        entities_removed: seq[ent]
        events: seq[proc(added: var seq[ent], removed: var seq[ent])]

type #@operations
  OpKind = enum
    Init
    Add,
    Remove,
    Kill,
    Empty,
  Operation {.packed.} = object
    kind*: OpKind
    entity*: ent 
    arg*: uint16


# confusion with {.global.} in proc, redefining
var id_next {.global.} : uint32 = 0
var lr {.global.} = 0

#@entities
proc entity*(layer: Layer = lr_ecs_main): ent {.inline.} =

    if ents_stash.len > 0:
        result = ents_stash[0]
        let e = addr entities[result.id]
        e.dirty = true
        e.layer = layer.int
        lr = e.layer
        ents_stash.del(0)
    else:
        let e = entities.add_new()
        e.dirty = true
        e.layer = layer.int
        lr = e.layer
        result.id = id_next
        result.age = 0
        id_next += 1
        
    let layer = ecs.layers[lr]
    let op = layer.operations.add_new()
    op.entity = result
    op.kind = OpKind.Init
    layer.ents_alive.incl(result.id)

proc release*(this: ent) = 
    check_error_release_empty(this)
    let entity = entities[this.id]
    let op = ecs.layers[entity.layer].operations.add_new()
    op.entity = this
    op.kind = OpKind.Kill
    entities[this.id].signature_temp = {}
    for e in entity.childs:
        release(e)

proc parent*(this: ent): ent =
    entities[this.id].parent

proc set_parent*(this: ent, par: ent) =
    let entity_this = addr entities[this.id]
    let entity_parent = addr entities[par.id]
    entity_this.parent = par
    entity_parent.childs.add(this)

proc unparent*(this: ent) =
    let entity_this = addr entities[this.id]
    let entity_parent = addr entities[entity_this.parent.id]
    
    for i in 0..entity_parent.childs.high:
        if entity_parent.childs[i].id == this.id:
            entity_parent.childs.del(i)
            break
    
    entity_this.parent = (0'u32,0'u32)

proc `$`*(this: ent): string =
    $this.id


#@storages
template internal_storagefast(t: typedesc) {.used.} =
    var storage {.used.} = Storage[t]()
    storage.container = newSeq[t]()
    storage.entities = newSeq[uint32]()
    storage.meta.id = id_component_next
    storage.meta.bitmask = 1 shl (storage.meta.id mod 32)
    storage.meta.generation = storage.meta.id div 32
    id_component_next+=1
    proc StorageSizeCalculate*(_:typedesc[t]): int {.discardable.} =
        (storage.sizeof + _.sizeof * storage.container.len + storage.entities.len * uint32.sizeof) div 1000
  
    proc StorageSize*(_:typedesc[t]) : string {.discardable.} =
        var kb {.inject.}  = formatFloat(_.StorageSizeCalculate.float32 ,format = ffDecimal,precision = 0)
        var name {.inject.} = typedesc[t].name
        var format {.inject.}  = &"Size of {name} storage: "
        format.add(kb)
        format.add(" KB")
        format
    
    proc Id*(_:typedesc[t]): uint16 {.inline, discardable.} =
        storage.meta.id
 
    proc get(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
        addr storage.container[storage.entities[self.id]]
   
    proc get(self: ptr ent, _: typedesc[t]): ptr t {.inline, discardable.} =
        addr storage.container[storage.entities[self.id]]

    proc add*(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
        check_error_has_component(self, t)
        
        let id = storage.meta.id
        let entity = addr entities[self.id]
        let comp = storage.container.add_new()

        entity.signature_temp.incl(id)
        
        if storage.entities.len<=self.id.int:
            storage.entities.setLen(self.id+1)

        storage.entities[self.id] = storage.container.high.uint32

        if not entity.dirty:
            let op = ecs.layers[entity.layer].operations.add_new()
            op.entity = self
            op.kind = OpKind.Add
            op.arg  = id

        comp
    
    proc remove*(self: ent, _: typedesc[t]) {.inline, discardable.} = 
        checkErrorRemoveComponent(self, t)
        let op = ecs.layers[entities[self.id].layer].operations.add_new()
        op.entity = self
        op.kind = OpKind.Remove
        op.arg = storage.meta.id
        entities[self.id].signature_temp.excl(op.arg)

 
    formatComponentPretty(t)


template internal_storagecompact(t: typedesc) {.used.} =
    var storage {.used.} = StorageCompact[t]()
    storage.container = newSeq[t]()
    storage.entities = Table[uint32,int]()
    storage.meta.id = id_component_next
    storage.meta.bitmask = 1 shl (storage.meta.id mod 32)
    storage.meta.generation = storage.meta.id div 32
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
    
    proc Id*(_:typedesc[t]): uint16 {.inline, discardable.} =
        storage.meta.id
    
    proc get(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
        addr storage.container[storage.entities[self.id]]
    
    proc get(self: ptr ent, _: typedesc[t]): ptr t {.inline, discardable.} =
        addr storage.container[storage.entities[self.id]]

    proc add*(self: ent, _: typedesc[t]): ptr t {.inline, discardable.} =
        check_error_has_component(self, t)
        
        let id = storage.meta.id
        let entity = addr entities[self.id]
        let comp = storage.container.add_new()

        storage.entities[self.id] = storage.container.high
        
        entity.signature_temp.incl(id)
        
        if not entity.dirty:
            let op = ecs.layers[entity.layer].operations.add_new()
            op.entity = self
            op.kind = OpKind.Add
            op.arg  = id

        comp
    
    proc remove*(self: ent, _: typedesc[t]) {.inline, discardable.} = 
        checkErrorRemoveComponent(self, t)
        let op = ecs.layers[entities[self.id].layer].operations.add_new()
        op.entity = self
        op.arg = storage.meta.id
        op.kind = OpKind.Remove
        entities[self.id].signature_temp.excl(op.arg)


    formatComponentPretty(t)


macro add*(this: EcsInstance, component: untyped, component_kind: static[ComponentKind] = ComponentKind.Fast): untyped =
    if component_kind == Fast:
        result = nnkStmtList.newTree(
             nnkCommand.newTree(
                bindSym("internal_storagefast", brForceOpen),
                newIdentNode($component)
               )
            )
    elif component_kind == Compact:
         result = nnkStmtList.newTree(
             nnkCommand.newTree(
                bindSym("internal_storagecompact", brForceOpen),
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


#@groups
macro group*(this: EcsInstance, name : untyped, code : untyped): untyped =
    let tree_components = findChild(code, it.kind == nnkCall and it[0].strVal == "comps")

    when defined(debug):
        assert tree_components.isNil == false, "add some components"

    let tree_scope = findChild(code, it.kind == nnkCall and it[0].strVal == "scope")
    let tree_layer = findChild(code, it.kind == nnkCall and it[0].strVal == "layer")

    var layer : NimNode = nil

    if not tree_layer.isNil:
        layer = tree_layer[1][0]
    else: layer = newIdentNode("lr_ecs_main")
    
    var components = newNimNode(nnkCurly)
    if tree_components[1].kind == nnkStmtList:
        for f in tree_components[1]:
            var node = nnkDotExpr.newTree(
                newIdentNode($f),
                newIdentNode("Id"))
            components.add(node)
    else:       
        for f in tree_components[1][0]:
            var node = nnkDotExpr.newTree(
                newIdentNode($f),
                newIdentNode("Id"))
            components.add(node)

    var inject_group = nnkIdentDefs.newTree()
    
    
    var is_private = true
    if not tree_scope.isNil:
        let scope_type = $tree_scope[1][0]
        when defined(debug):
            assert scope_type == "public", "did you mean public ?"
        is_private = false
    
    if is_private:
        inject_group.add(newIdentNode($name))
    else:
        inject_group.add(nnkPostfix.newTree(
            newIdentNode("*"),
            newIdentNode($name)
        ))

    inject_group.add(newEmptyNode())
    inject_group.add(nnkCall.newTree(
                    bindSym("add_group", brForceOpen),
                        components,
                        layer
                    ))
    
    let nGroup = nnkStmtList.newTree(
        nnkVarSection.newTree(inject_group)
        )

    result = nGroup

var id_next_group {.global.} : uint16 = 0
proc add_group(components: set[uint16], layer : Layer) : Group {.inline, used.} =
    var signature = components
    var group_next : Group = nil
    let groups = addr ecs.layers[layer.int].groups
    
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
        group_next.layer = layer.int
        id_next_group += 1

    group_next

## вместо entity_data передавай layer и сигнатуру
template group_insert(self: ent, entity_data: ptr Entity) = 
    let groups = addr ecs.layers[entity_data.layer].groups
    for i in 0..groups[].high:
        let gr = groups[][i]
        if gr.id notin entity_data.signature_groups:
            if gr.signature <= entity_data.signature:
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
                entity_data.signature_groups.incl(gr.id)
                gr.entities_added.add(self)

template group_remove(self: ent, entity_data: ptr Entity) =
    for gr in ecs.layers[entity_data.layer].groups:
        if gr.signature <= entity_data.signature:
            let id = binarysearch(addr gr.entities, op.entity.id)
            gr.entities.delete(id)
            entity_data.signature_groups.excl(gr.id)
            gr.entities_removed.add(self)

template handle*(self: Group, code: untyped): untyped =
    self.events.add((added: var seq[ent], removed : var seq[ent]) => code )



#@checkers
template active_impl(this, entity: untyped): untyped =
    entity.age == this.age and entity.signature_temp.card>0

proc is_active*(this: ent): bool {.inline, discardable.} =
    let entity = addr entities[this.id]
    active_impl(this,entity)

proc has*(this: ent, t: typedesc): bool {.inline.} =
    let entity = entities[this.id]
    active_impl(this,entity) and entity.signature_temp.contains(t.Id)

proc has*(this: ent, t,y: typedesc): bool {.inline.} =
    let entity = addr entities[this.id]
    active_impl(this,entity)              and
    entity.signature_temp.contains(t.Id) and
    entity.signature_temp.contains(y.Id)

proc has*(this: ent, t,y,u: typedesc): bool {.inline.} =
    let entity = addr entities[this.id]
    active_impl(this,entity)              and
    entity.signature_temp.contains(t.Id) and
    entity.signature_temp.contains(y.Id) and
    entity.signature_temp.contains(u.Id)

proc has*(this: ent, t,y,u,i: typedesc): bool {.inline.} =
    let entity = addr entities[this.id]
    active_impl(this,entity)              and
    entity.signature_temp.contains(t.Id) and
    entity.signature_temp.contains(y.Id) and
    entity.signature_temp.contains(u.Id) and
    entity.signature_temp.contains(i.Id)

proc has*(this: ent, t,y,u,i,o: typedesc): bool {.inline.} =
    let entity = addr entities[this.id]
    active_impl(this,entity)              and
    entity.signature_temp.contains(t.Id) and
    entity.signature_temp.contains(y.Id) and
    entity.signature_temp.contains(u.Id) and
    entity.signature_temp.contains(i.Id) and
    entity.signature_temp.contains(o.Id)

proc has*(this: ent, t,y,u,i,o,p: typedesc): bool {.inline.} =
    let entity = addr entities[this.id]
    active_impl(this,entity)              and
    entity.signature_temp.contains(t.Id) and
    entity.signature_temp.contains(y.Id) and
    entity.signature_temp.contains(u.Id) and
    entity.signature_temp.contains(i.Id) and
    entity.signature_temp.contains(o.Id) and
    entity.signature_temp.contains(p.Id)

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



#@iterators
iterator items*(range: Group): ent =
    var i = range.entities.low
    while i <= range.entities.high:
        yield range.entities[i]
        inc i
    ecs.process_operations(range.layer)



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
        get(self,{tName})""")
    var source2 = &("""
    template `{proc_name}`*(self: ptr ent): ptr {tName} =
        get(self,{tName})""")
    result = parseStmt(source)
    result.add(parseStmt(source2))



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

var layer_next {.global.} : Layer = 0.Layer
proc addLayer*(this: EcsInstance): Layer =
    result = layer_next; layer_next = layer_next + 1.Layer
    let ecs_layer = add_new(this[].layers)
    ecs_layer.groups = new_seqofcap[Group](16)
    ecs_layer.operations = new_seqofcap[Operation](256)
    ecs_layer.ents_alive = initHashSet[uint32]()

proc release*(this: EcsInstance, layers: varargs[Layer]) =
    for l in layers:
        let ecs_layer = this.layers[l.int]
        ecs_layer.operations.setLen(0)
        for index in ecs_layer.ents_alive:
            let entity_data = addr entities[index]
            entity_data.age = 0
            entity_data.signature = {}
            entity_data.signature_temp = {}
            entity_data.signature_groups = {}
            entity_data.parent = (0'u32,0'u32)
            entity_data.childs.setLen(0)
            ents_stash.add((index,0'u32))
        ecs_layer.ents_alive.clear()
        for gr in ecs_layer.groups:
            gr.entities.setLen(0)
            gr.entities_added.setLen(0)
            gr.entities_removed.setLen(0)
            gr.events.setLen(0)


#@processing
proc process_operations*(this: EcsInstance, lr_index: int = lr_ecs_main.int) {.inline.} = 
    let layer = addr this.layers[lr_index]
    let operations = addr layer.operations
    let size = operations[].len
    for i in 0..operations[].high:
        let op = addr operations[][i]
        let entity_data = addr entities[op.entity.id]
        let arg = op.arg
        
        while true:
            case op.kind:
                of Kill:
                    group_remove(op.entity, entity_data)
                    # we dont clean signatures as the entity will be killed anyway
                    op.kind = Empty

                of Remove:
                    group_remove(op.entity, entity_data)
                    entity_data.signature.excl(op.arg)
                    if entity_data.signature == {}:
                        for e in entity_data.childs:
                            e.release()
                        op.kind = Empty
                    else:
                        break

                of Empty:
                    if op.entity.age == high(uint32):
                        op.entity.age = 0
                    else:
                        op.entity.age += 1
                    entity_data.age = op.entity.age
                    ents_stash.add(op.entity)
                    entity_data.signature = {}
                    entity_data.signature_temp = {}
                    entity_data.signature_groups = {}
                    entity_data.parent = (0'u32,0'u32)
                    entity_data.childs.setLen(0)
                    layer.ents_alive.excl(op.entity.id)
                    break

                of Add: 
                    entity_data.signature.incl(arg)
                    group_insert(op.entity, entity_data)
                    break
                
                of Init:
                    entity_data.dirty = false
                    entity_data.signature = entity_data.signature_temp
                    group_insert(op.entity, entity_data)
                    break
    
    operations[].setLen(0)
    
    if size>0:
        for gr in layer.groups:
            for ev in gr.events:
                ev(gr.entities_added,gr.entities_removed)
            gr.entities_added.setLen(0)
            gr.entities_removed.setLen(0)



#@errors
when defined(debug):
    type
        EcsError* = object of ValueError

template check_error_remove_component(this: ent, t: typedesc): untyped =
    when defined(debug):
        let arg1 {.inject.} = t.name
        let arg2 {.inject.} = this.id
        if t.Id notin entities[this.id].signature_temp:
            log_external fatal, &"You are trying to remove a {arg1} that is not attached to entity with id {arg2}"
            raise newException(EcsError,&"You are trying to remove a {arg1} that is not attached to entity with id {arg2}")

template check_error_release_empty(this: ent): untyped =
    when defined(debug):   
        let arg1 {.inject.} = this.id
        if entities[this.id].signature_temp.card == 0:
            log_external fatal, &"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically."
            raise newException(EcsError,&"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically.")

template check_error_has_component(this: ent, t: typedesc): untyped =
    when defined(debug):
        let arg1 {.inject.} = t.name
        let arg2 {.inject.} = this.id
        if t.Id in entities[this.id].signature_temp:
            log_external fatal, &"You are trying to add a {arg1} that is already attached to entity with id {arg2}"
            raise newException(EcsError,&"You are trying to add a {arg1} that is already attached to entity with id {arg2}")



#@setup
var 
    ecs* = EcsInstance(layers: newSeq[EcsLayer]())
var
    id_component_next {.used.} : uint16 = 0 
    id_entity_last {.used.} : uint32 = 0
    entities = new_seqofcap[Entity](1024)
    ents_stash = new_seqofcap[ent](256)
var
    lr_ecs_core* = ecs.addLayer()
    lr_ecs_main* = ecs.addLayer()
