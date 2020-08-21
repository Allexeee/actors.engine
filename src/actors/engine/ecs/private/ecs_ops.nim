import strutils
import macros
import sets
import tables

import ../../../actors_h
import ../pixeye_ecs_h
import ecs_utils
import ecs_debug

template partof*(self: ent|eid, group: Group): bool =
  if group.id in self.meta.signature_groups:
    true
  else: false

template match*(self: ent|eid, group: Group):  bool =
  var result = true
  for i in group.signature:
    let indices = group.ecs.storages[i.int].indices
    if indices.high<self.id or indices[self.id] == ent.nil.id:
      result = false;break
  for i in group.signature_excl:
    let indices = group.ecs.storages[i.int].indices
    if indices.high<self.id or indices[self.id] != ent.nil.id:
      result = false;break
  result

proc insert*(gr: Group, self: eid) {.inline.} = 
  var len = gr.entities.len
  var left, index = 0
  var right = len
  let meta = self.meta
  len+=1
  var conditionSort = right - 1
  if conditionSort > -1 and self.int < gr.entities[conditionSort].int:
      while right > left:
          var midIndex = (right+left) div 2
          if gr.entities[midIndex].int == self.int:
              index = midIndex
              break
          if gr.entities[midIndex].int < self.int:
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

  meta.signature_groups.add(gr.id)

  gr.indices[self.int] = right

proc tryinsert*(gr: Group, eids: var seq[eid]) {.inline.} =
  for i in eids:
    let matched = ecs_ops.match(i,gr)
    if matched:
      gr.insert(i)

proc remove*(gr: Group, self: eid) {.inline.} =
  let meta = self.meta
  let index = binarysearch(addr gr.entities, self.int)
  gr.entities.delete(index)
  gr.indices[self.int] = ent.nil.id
  meta.signature_groups.delete(meta.signature_groups.find(gr.id))

proc changeEntity*(self: eid, cid: uint16) {.inline.} =
  let groups = self.ecs.storages[cid].groups   #storages[cid][self.meta.layer.int].groups   
  for group in groups:
    let grouped = self.partof(group)
    let matched = self.match(group)
    if grouped and not matched:
      group.remove(self)
    elif not grouped and matched:
      group.insert(self)

proc empty*(meta: ptr EntityMeta, ecs: LayerEcs, self: eid) {.inline,used.} =
  available += 1
  
  for i in countdown(meta.signature_groups.high,0):
    ecs.groups[meta.signature_groups[i]].remove(self)

  for i in countdown(meta.signature.high,0):
    ecs.storages[meta.signature[i].int].actions.remove(self)


  entities[self.int].age.incAge()
  system.swap(entities[self.int],entities[ENTS_MAX_SIZE-available])
  meta.signature.setLen(0) 
  meta.signature_groups.setLen(0)
  meta.parent = ent.nil.id.eid
  meta.childs.setLen(0)

proc kill*(self: ent|eid) {.inline.} =
  check_error_release_empty(self)
  let meta = self.meta
  let ecs = self.layer.ecs
  for i in countdown(meta.childs.high,0):
    kill(meta.childs[i])
  empty(meta,ecs,self)

proc kill*(ecs: LayerEcs) {.inline.} =
    proc emptyOnLayerKill(id: int) {.inline,used.} =
      let meta = metas[id].addr
      available += 1
      entities[id].age.incAge()
      system.swap(entities[id],entities[ENTS_MAX_SIZE-available])
      meta.signature.setLen(0) 
      meta.signature_groups.setLen(0)
      meta.parent = ent.nil.id.eid
      meta.childs.setLen(0)
  #clean groups
    let groups = ecs.groups
    for g in groups:
      g.entities.setLen(0)
      for i in 0..g.indices.high:
        g.indices[i] = ent.nil.id
  #find all entities on the layer and release them
    for i in 0..metas.high:
      let m = metas[i].addr
      if m.ecs == ecs:
        emptyOnLayerKill(i)
  #clean storages
    for st in ecs.storages:
      #let lst = st[ecs.layer.int]
      st.actions.cleanup(st)

iterator items*(range: Group): eid =
  for i in countdown(range.entities.high,0):
    yield range.entities[i]

iterator query*(ecs: LayerEcs, E: typedesc[ent],T: typedesc): (eid, ptr T) {.inline.} =
  var st1 = cast[CompStorage[T]](ecs.storages[T.getstorageid])
  for i in countdown(st1.comps.high,0):
     yield (st1.entities[i].id.eid,st1.comps[i].addr)

iterator query*(ecs: LayerEcs, T: typedesc): ptr T {.inline.} =
  let st1 = cast[CompStorage[T]](ecs.storages[T.getstorageid])
  for i in countdown(st1.comps.high,0):
     yield st1.comps[i].addr

iterator query*(T: typedesc): ptr T {.inline.} =
  let st1 = T.getStorage()
  for i in countdown(st1.comps.high,0):
     yield st1.comps[i].addr

var e1 {.global.} : ptr ent
var e2 {.global.} : ptr ent


proc bind_impl(self: eid) {.inline.} =
  let meta = self.meta
  for cid in meta.signature:
     let groups = meta.ecs.storages[cid].groups
     for group in groups:
       if not self.partof(group) and self.match(group):
         group.insert(self)

template entity*(ecs: LayerEcs, code: untyped) =
  proc `bind`(self: eid) {.inline,discardable.} =
    bind_impl(self)

  e1 = entities[ENTS_MAX_SIZE-available].addr
  e2 = entities[e1.id].addr
  available -= 1
  swap(e1.age,e2.age)
 
  block:
    dirty = true
    let e {.inject.} = entities[e2.id]
    swap(e1.id,e2.id)
    metas[e.id].ecs = ecs
    code
    e.bind()
    dirty = false

template entity*(ecs: LayerEcs, name: untyped, code: untyped): untyped =
  
  proc `bind`(self: eid) {.inline,discardable.} =
    bind_impl(self)

  e1 = entities[ENTS_MAX_SIZE-available].addr
  e2 = entities[e1.id].addr
  available -= 1
  swap(e1.age,e2.age)
  let name {.inject.} = entities[e2.id]
  swap(e1.id,e2.id)
  metas[name.id].ecs = ecs
  block:
    dirty = true
    code
    name.bind()
    dirty = false

proc exist*(self:ent): bool =
  let cached = entities[self.id].addr
  cached.id == self.id and cached.age == self.age

template has*(self:eid, t: typedesc): bool =
  t.has(self)
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

macro tryget*(this: ent, args: varargs[untyped]): untyped =
  var command = nnkCommand.newTree(
                  nnkDotExpr.newTree(
                      ident($this),
                      ident("has")))
  var code = args[args.len-1]
  for i in 0..args.len-2:
    var elem = args[i]
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
