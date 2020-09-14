## Created by Pixeye | dev@pixeye.com
## * ``types``
## * ``variables``
## * ``utils``
## * ``groups``
## * ``entities``
## * ``components``

import macros
import strutils
import strformat
import sets
import algorithm
import hashes

#----------------------------------------
#@types
#----------------------------------------
type ent* = tuple[id: int, age: int]
type eid* = distinct int
type cid* = uint16
type Ent* = ent

type CompType*  = enum
    AsComp,
    AsTag
type EntMeta*   = object
    childs*    : seq[eid]
    sig*       : seq[cid]
    sig_groups*: seq[cid]
    parent*    : eid
type EcsGroup*  = ref object
    id*        : cid
    indices*   : seq[int]
    ents*      : seq[eid]
    incl_hash* : int      # include 
    incl_sig*  : seq[cid]
    excl_hash* : int      # exclude
    excl_sig*  : seq[cid]
type IStorage*  = object
    remove* : proc (self: eid)
    cleanup*: proc ()
type CompMeta*  = ref object
    indices*: ptr seq[int]
    ents*   : ptr seq[eid]
    groups* : seq[EcsGroup]
    actions*: IStorage

#----------------------------------------
#@variables
#----------------------------------------
const ECS_ENTITY_BATCH* {.intdefine.}: int = 0
var   ECS_ENTITY_FREE* = 0
var   ECS_GROUP_SIZE*  = 0

var px_ecs_dirty     : bool
var px_ecs_meta      : seq[EntMeta]
var px_ecs_ents      : seq[ent]
var px_ecs_groups    : seq[EcsGroup]
var px_ecs_meta_comp : seq[CompMeta]

#----------------------------------------
#@utils
#----------------------------------------
template  `nil`*(T: typedesc[ent]): ent = (int.high, 0)
template  `nil`*(T: typedesc[eid]): eid = int.high.eid
template     id*(self: eid): int  = self.int
converter toEnt*(x: eid): ent = (x.int,px_ecs_ents[x.int].age)
converter toEid*(x: ent): eid = x.id.eid

proc meta*(self: ent): ptr EntMeta {.inline.} = px_ecs_meta[self.id].addr
proc meta*(self: eid): ptr EntMeta {.inline.} = px_ecs_meta[self.int].addr

proc px_ecs_genIndices(self: var seq[int]) {.used.} =
  self = newSeq[int](ECS_ENTITY_BATCH)
  for i in 0..self.high:
    self[i] = ent.nil.id

when defined(debug):
  type
    EcsError* = object of ValueError

template px_ecs_debug_remove(self: ent|eid, st_indices: ptr seq[int],st_ents: ptr seq[eid], t: typedesc): untyped {.used.}=
  when defined(debug):
    block:
      let arg1 {.inject.} = $t
      let arg2 {.inject.} = self.id
      if st_indices[][self.id] < st_ents[].len:
        raise newException(EcsError,&"\n\nYou are trying to remove a {arg1} that is not attached to entity with id {arg2}\n")
template px_ecs_debug_release(self: ent|eid): untyped {.used.} =
  when defined(debug):
    block:
      let arg1 {.inject.} = self.id
      let arg2 {.inject.} = &"\n\nYou are trying to release an empty entity with id {arg1}. Entities without any components are released automatically.\n"
      if px_ecs_meta[self.id].sig.len == 0:
        raise newException(EcsError,arg2)

proc  px_ecs_comp_format_name_alias(s: var string) {.used.}=
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
proc  px_ecs_comp_format_name(s: var string) {.used.}=
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
macro px_ecs_comp_format_alias_long(T: typedesc, mode: static CompType): untyped {.used.}=
  let tName = strVal(T)
  var proc_name = tName  
  proc_name  = toLowerAscii(proc_name[0]) & substr(proc_name, 1)
  px_ecs_comp_format_name(proc_name)
  var source = ""
  if mode == AsComp:
    source = &("""
    template `{proc_name}`*(self: ent|eid): ptr {tName} =
        px_ecs_comp_get(self,{tName})
        """)
  else:
    source = &("""
      template `{proc_name}`*(self: ent|eid): int =
          px_ecs_tag_get(self,{tName})
          """)
  result = parseStmt(source)
macro px_ecs_comp_format_alias(t: typedesc, mode: static CompType): untyped {.used.}=
  let tName = strVal(t)
  var proc_name = tName  
  px_ecs_comp_format_name(proc_name)
  var source = ""
  
  #px_ecs_tag_get
  if mode == AsComp:
    source = &("""
      template `{proc_name}`*(self: ent|eid): ptr {tName} =
          px_ecs_comp_get(self,{tName})
          """)
  else:
    source = &("""
      template `{proc_name}`*(self: ent|eid): int =
          px_ecs_tag_get(self,{tName})
          """)

  result = parseStmt(source)

proc px_ecs_init*()  =
  ECS_ENTITY_FREE      = ECS_ENTITY_BATCH
  ECS_GROUP_SIZE       = (ECS_ENTITY_BATCH/2).int
  px_ecs_groups        = newSeq[EcsGroup]()
  px_ecs_meta          = newSeq[EntMeta](ECS_ENTITY_BATCH)
  px_ecs_meta_comp     = newSeq[CompMeta](0)
  px_ecs_ents          = newSeq[ent](ECS_ENTITY_BATCH)
  for i in 0..<ECS_ENTITY_BATCH:
    px_ecs_ents[i] = (i,1)
    px_ecs_meta[i].sig        = newSeqOfCap[cid](3)
    px_ecs_meta[i].sig_groups = newSeqOfCap[cid](1)
    px_ecs_meta[i].childs = newSeqOfCap[eid](0)
    px_ecs_meta[i].parent = ent.nil

proc ecsDel*() =
  template empty(meta: ptr EntMeta, id: int)=
      px_ecs_ents[id].age = 1
      meta.sig.setLen(0)
      meta.sig_groups.setLen(0)
      meta.parent = ent.nil.eid
      meta.childs.setLen(0)
  #clean groups
  for g in px_ecs_groups:
    g.ents.setLen(0)
  #find all entities on the layer and release them
  for i in 0..px_ecs_meta.high:
    let meta = px_ecs_meta[i].addr
    empty(meta,i)
  ECS_ENTITY_FREE = ECS_ENTITY_BATCH
  #clean storages
  for st in px_ecs_meta_comp:
    st.actions.cleanup()

iterator ecsAll*: eid =
  for i in countdown(px_ecs_ents.high,0):
    yield px_ecs_ents[i].id.eid

#--------------------------------------------------------------------------------------------
#@groups
#--------------------------------------------------------------------------------------------
var incl_sig  : set[cid]
var excl_sig  : set[cid]

proc partof*(self: ent|eid, group: EcsGroup): bool =
  group.indices[self.id] < group.ents.len

proc match*(self: ent|eid, group: EcsGroup):  bool =
  for i in group.incl_sig:
    let m_st = px_ecs_meta_comp[i]
    if m_st.indices[][self.id] > m_st.ents[].high: # if has no comp
      return false
  for i in group.excl_sig:
    let m_st = px_ecs_meta_comp[i]
    if m_st.indices[][self.id] < m_st.ents[].len: # if has comp
      return false
  true

proc px_ecs_group_insert(gr: EcsGroup, self: eid) {.inline.} = 
  let len = gr.ents.len
  gr.indices[self.id] = len
  gr.ents.add(self)
  px_ecs_meta[self.int].sig_groups.add(gr.id)

proc px_ecs_group_remove(gr: EcsGroup, self: eid) {.inline.} =
  let meta = px_ecs_meta[self.int].addr
  let last = gr.indices[gr.ents[gr.ents.high].int]
  let index = gr.indices[self.id]
  gr.ents.del(index)
  swap(gr.indices[index],gr.indices[last])
  meta.sig_groups.del(meta.sig_groups.find(gr.id))

proc px_ecs_group_init() : EcsGroup {.inline, used, discardable.} =
  var id_next_group {.global.} : cid = 0
  var group_next : EcsGroup = nil
  
  let incl_hash = incl_sig.hash
  let excl_hash = excl_sig.hash
  
  func sort_storages(x,y: CompMeta): int =
    let cx = x.ents
    let cy = y.ents
    if cx[].len <= cy[].len: -1
    else: 1

  proc addGroup(): var EcsGroup =
    px_ecs_groups.add(EcsGroup())
    px_ecs_groups[px_ecs_groups.high]
  
  for i in 0..px_ecs_groups.high:
    let gr = px_ecs_groups[i]
    if gr.incl_hash == incl_hash and
      gr.excl_hash == excl_hash:
         group_next = gr; break

  if group_next.isNil:
    group_next = addGroup()
    group_next.id = id_next_group
    group_next.ents = newSeqOfCap[eid](ECS_GROUP_SIZE)
    group_next.incl_hash = incl_hash
    group_next.excl_hash = excl_hash
    px_ecs_genindices(group_next.indices)
    var storage_owner = newSeq[CompMeta]()
    
    for id in incl_sig:
      group_next.incl_sig.add(id)
      px_ecs_meta_comp[id].groups.add(group_next)
      storage_owner.add(px_ecs_meta_comp[id])
    for id in excl_sig:
      group_next.excl_sig.add(id)
      px_ecs_meta_comp[id].groups.add(group_next)
   
    storage_owner.sort(sortStorages)

    for i in storage_owner[0][].ents[]:
      if match(i,group_next):
        px_ecs_group_insert(group_next,i)

    id_next_group += 1
  
  incl_sig = {}
  excl_sig = {}
  group_next

proc px_ecs_groups_update(self: eid, cid: uint16) {.inline.} =
  let groups = px_ecs_meta_comp[cid].groups
  for group in groups:
    let grouped = self.partof(group)
    let matched = self.match(group)
    if grouped and not matched:
      px_ecs_group_remove(group,self)
    elif not grouped and matched:
      px_ecs_group_insert(group,self)

template ecsGroup*(t: varargs[untyped]): EcsGroup =
  var group_cached {.global.} : EcsGroup
  if group_cached.isNil:
    group_cached = px_ecs_group_gen(t)
  group_cached

iterator items*(range: EcsGroup): eid =
  for i in countdown(range.ents.high,0):
    yield range.ents[i]

template len*(self: EcsGroup): int =
  self.ents.len

template high*(self: EcsGroup): int =
  self.ents.high

template `[]`*(self: EcsGroup, key: int): ent =
  self.ents[key]

proc `bind`*(self: ent|eid) {.inline.} =
  px_ecs_dirty = false
  let meta = px_ecs_meta[self.id]
  for cid in meta.sig:
    let groups = px_ecs_meta_comp[cid].groups
    for group in groups:
      if not self.partof(group) and self.match(group):
        px_ecs_group_insert(group,self)

macro px_ecs_group_gen*(t: varargs[untyped]) =
  var n = newNimNode(nnkStmtList)
  template genMask(arg: untyped): NimNode =
    var n = newNimNode(nnkCall)
    if arg.len > 0 and $arg[0] == "!":
      n.insert(0,newDotExpr(bindSym("excl_sig"), ident("incl")))
      n.insert(1,newDotExpr(ident($arg[1]), ident("px_ecs_comp_id")))
    else:
      n.insert(0,newDotExpr(bindSym("incl_sig") , ident("incl")))
      n.insert(1,newDotExpr(ident($arg), ident("px_ecs_comp_id")))
    n
  var i = 0
  for x in t.children:
    n.insert(i,genMask(x))
    i += 1
  n.insert(i,newCall(bindSym("px_ecs_group_init",brForceOpen)))
  result = n

#--------------------------------------------------------------------------------------------
#@entities
#--------------------------------------------------------------------------------------------
template px_ecs_ent_get(): untyped =
  var e1 {.inject.} = px_ecs_ents[ECS_ENTITY_BATCH-ECS_ENTITY_FREE].addr
  var e2 {.inject.} = px_ecs_ents[e1.id].addr 
  ECS_ENTITY_FREE -= 1
  swap(e1,e2)
  px_ecs_dirty = true

proc px_ecs_ent_clear(meta: ptr EntMeta, self: eid) {.inline,used.} =
  for i in countdown(meta.sig_groups.high,0):
    px_ecs_group_remove(px_ecs_groups[meta.sig_groups[i]],self)
    
  for i in countdown(meta.sig.high,0):
    px_ecs_meta_comp[meta.sig[i].int].actions.remove(self)

  ECS_ENTITY_FREE += 1

  px_ecs_ents[self.int].age += 1
  if px_ecs_ents[self.int].age == 0x7FFFFFFF:
    px_ecs_ents[self.int].age = 0

  system.swap(px_ecs_ents[self.int],px_ecs_ents[ECS_ENTITY_BATCH-ECS_ENTITY_FREE])
  meta.sig.setLen(0) 
  meta.sig_groups.setLen(0)
  meta.parent = ent.nil.id.eid
  meta.childs.setLen(0)

proc px_ecs_ent_del(self: ent|eid) {.inline.} =
  # Release is called via release, don't use this
  let meta = px_ecs_meta[self.id].addr
  for i in countdown(meta.childs.high,0):
    px_ecs_ent_del(meta.childs[i])
  px_ecs_ent_clear(meta,self)

proc del*(self: ent|eid) {.inline.} =
  px_ecs_debug_release(self)
  px_ecs_ent_del(self)

template entGet*(code: untyped): ent =
  var result : ent
  block:
    px_ecs_ent_get()
    let e {.inject,used.} : ent = (e1.id,e2.age)
    result = e
    code
    ecs_group.bind(e.id.eid)
  result

proc     entGet*(): ent =
  px_ecs_ent_get()
  result.id  = e1.id
  result.age = e2.age

proc exist*(self:ent): bool =
  let cached = px_ecs_ents[self.id].addr
  cached.id == self.id and cached.age == self.age

proc  parent*(self: ent): ent =
  self.meta.parent
proc `parent=`*(self: ent ,other: ent) =
  let meta = self.meta
  if other == ent.nil or meta.parent.int != eid.nil.int:
    var parent_meta = meta.parent.meta
    let index = parent_meta.childs.find(self)
    parent_meta.childs.del(index)
  
  meta.parent = other
 
  if meta.parent.int != eid.nil.int:
    var parent_meta = other.meta
    parent_meta.childs.add(self)

template has*(self:ent|eid, T: typedesc): bool =
  T.has(self)
template has*(self:ent|eid, T: typedesc): bool =
  T.has(self)
template has*(self:ent|eid, T,Y: typedesc): bool =
  T.has(self) and 
  Y.has(self)
template has*(self:ent|eid, T,Y,U: typedesc): bool =
  T.has(self) and
  Y.has(self) and
  U.has(self)
template has*(self:ent|eid, T,Y,U,I: typedesc): bool =
  T.has(self) and
  Y.has(self) and
  U.has(self) and
  I.has(self)
template has*(self:ent|eid, T,Y,U,I,O: typedesc): bool =
  T.has(self) and
  Y.has(self) and
  U.has(self) and
  I.has(self) and
  O.has(self)
template has*(self:ent|eid, T,Y,U,I,O,P: typedesc): bool =
  T.has(self) and
  Y.has(self) and
  U.has(self) and
  I.has(self) and
  O.has(self) and
  P.has(self)

macro tryGet*(this: ent, args: varargs[untyped]): untyped =
  var command = nnkCommand.newTree(
                  nnkDotExpr.newTree(
                      ident($this),
                      ident("has")))
  var code = args[args.len-1]
  for i in 0..args.len-2:
    var elem = args[i]
    command.add(ident($elem))
    var elem_name = $elem
    px_ecs_comp_format_name_alias(elem_name) 
    var elem_var = toLowerAscii(elem_name[0]) & substr(elem_name, 1)
    px_ecs_comp_format_name(elem_var)
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

#--------------------------------------------------------------------------------------------
#@components
#--------------------------------------------------------------------------------------------
var next_storage_id = 0

template px_ecs_storage(T: typedesc, mode: CompType) {.used.} =
  var st_id      : int
  var st_indices : seq[int]
  var st_ents    : seq[eid]
  var st_comps   : seq[T]

  proc px_ecs_comps(_:typedesc[T]): ptr seq[T] {.inline,used.} =
    st_comps.addr
  
  proc px_ecs_comp_id(_:typedesc[T]): cid {.used.} = st_id.cid

  proc px_ecs_comp_clear(_:typedesc[T]) = 
    st_ents.setLen(0); st_comps.setLen(0)
  
  proc px_ecs_comp_del(_:typedesc[T],self: eid) =
    let last = st_indices[st_ents[st_ents.high].int]
    let index = st_indices[self.int]
    st_ents.del(index)
    st_comps.del(index)
    swap(st_indices[index],st_indices[last])
    st_indices[index] = int.high

  proc px_ecs_comp_init(_:typedesc[T]) =
    st_id = next_storage_id;next_storage_id+=1
    st_ents    =  newSeqOfCap[eid](ECS_GROUP_SIZE)
    st_comps   =  newSeqOfCap[T](ECS_GROUP_SIZE)
    px_ecs_genindices(st_indices)
    px_ecs_meta_comp.add(CompMeta())
   
    var m_st = px_ecs_meta_comp[px_ecs_meta_comp.high].addr
    m_st[].ents    = st_ents.addr
    m_st[].indices = st_indices.addr
    m_st[].groups  = newSeq[EcsGroup]()
    m_st[].actions = IStorage(cleanup: proc()=px_ecs_comp_clear(T),remove: proc(self:eid)=px_ecs_comp_del(T, self))
  
  proc px_ecs_comp_get(self: ent|eid, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr st_comps[st_indices[self.id]] 
  
  proc px_ecs_tag_get(self: ent|eid, _: typedesc[T]): int {.inline, discardable, used.} =
    st_comps[st_indices[self.id]].int

  proc px_ecs_comp_get_storage(_:typedesc[T]): ptr seq[T] {.inline, used.} =
    st_comps.addr

  proc has*(_:typedesc[T], self: eid): bool {.inline,discardable.} =
    st_indices[self.int] < st_ents.len
  
  proc get*(self: ent|eid, _:typedesc[T]): ptr T =
    if has(_,self):
      return st_comps[st_indices[self.id]].addr

    let len = st_ents.len
    st_indices[self.id] = len
    st_ents.add(self)
    
    px_ecs_meta[self.id].sig.add(st_id.cid)
    
    if not px_ecs_dirty:
      px_ecs_groups_update(self.id.eid,st_id.cid)

    st_comps.add(T())
    st_comps[len].addr
  
  proc remove*(self: ent|eid, _: typedesc[T]) =
    px_ecs_debug_remove(self, st_indices.addr, st_ents.addr,_)
    let last = st_indices[st_ents[st_ents.high].int]
    let index = st_indices[self.id]

    st_ents.del(index)
    st_comps.del(index)
    swap(st_indices[index],st_indices[last])
    
    let meta = self.meta
    meta.sig.del(meta.sig.find(st_id.cid))
    if meta.sig.len == 0:
      self.release()
    else:
      px_ecs_groups_update(self.id.eid,st_id.cid)

  proc inc*(self: ent|eid, _:typedesc[T], arg: int = 1) =
    if has(_,self):
      let temp =  st_comps[st_indices[self.id]].int + arg
      st_comps[st_indices[self.id]] = temp.T
    
    let len = st_ents.len
    st_indices[self.id] = len
    st_ents.add(self)
    
    px_ecs_meta[self.id].sig.add(st_id.cid)
 
    if not px_ecs_dirty:
      px_ecs_groups_update(self.id.eid,st_id.cid)
 
    st_comps.add(arg.T)
  
  proc dec*(self: ent|eid, _:typedesc[T], arg: int = 1) =
    if not has(_,self): return

    let temp =  st_comps[st_indices[self.id]].int - arg
    
    if temp <= 0:
      remove(self, T)
    else:
      st_comps[st_indices[self.id]] = temp.T
  
  px_ecs_comp_init(T)

  px_ecs_comp_format_alias(T, mode)
  px_ecs_comp_format_alias_long(T, mode)

iterator ecsQuery*(E: typedesc[Ent], T: typedesc): (eid, ptr T) =
  let st_comps = T.px_ecs_comp_get_storage
  let st_ents =  T.px_ecs_ents
  for i in countdown(st_comps[].high,0):
    yield (st_ents[][i], st_comps[][i].addr)

iterator ecsQuery*(T: typedesc): ptr T=
  let st_comps = T.px_ecs_comp_get_storage
  for i in countdown(st_comps[].high,0):
    yield st_comps[][i].addr

iterator ecsQuerye*(T: typedesc): eid =
  let st_ents =  T.px_ecs_comp_get_storage
  for i in countdown(st_ents[].high,0):
    yield st_ents[i]

macro ecsAdd*(component: untyped, mode: static[CompType] = CompType.AsComp): untyped =
  let node_storage = nnkCommand.newTree()

  node_storage.insert(0,bindSym("px_ecs_storage", brForceOpen))
  node_storage.insert(1,newIdentNode($component))
  node_storage.insert(2,newIdentNode($mode))

  result = nnkStmtList.newTree(
          node_storage
          )
  var name_alias = $component
  if (name_alias.contains("Component") or name_alias.contains("Comp")):
      px_ecs_comp_format_name_alias(name_alias)
      
      let node = nnkTypeSection.newTree(
      nnkTypeDef.newTree(
          nnkPostfix.newTree(
              newIdentNode("*"),
              newIdentNode(name_alias)),
              newEmptyNode(),
      newIdentNode($component)
      ))
      result.add(node)

