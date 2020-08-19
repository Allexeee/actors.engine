import strutils
import macros
import strformat
import sets
import tables

import ../../../actors_h
import ../actors_ecs_h
import ecs_groups
import ecs_utils
import ecs_debug

template partof*(self: ent, group: Group): bool =
  if group.id in self.meta.signature_groups:
    true
  else: false
template match*(self: ent, group: Group):  bool  =
   var result = true
   for i in group.signature:
     let indices = storages[i.int][self.meta.layer.int].indices.addr
     if indices[].high<self.id or indices[][self.id] == ent.nil.id:
       result = false; break
   for i in group.signature_excl:
     let indices = storages[i.int][self.meta.layer.int].indices.addr
     if indices[].high<self.id or indices[][self.id] != ent.nil.id:
       result = false; break
   result

template insert*(gr: Group, self: eid) = 
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

template remove*(gr: Group, self: eid) =
  let meta = self.meta
  let index = binarysearch(addr gr.entities, self.int)
  gr.entities.delete(index)
  gr.indices[self.int] = ent.nil.id
  meta.signature_groups.delete(meta.signature_groups.find(gr.id))

template changeEntity*(self: eid, cid: uint16) =
  let groups = storages[cid][self.meta.layer.int].groups   
  for group in groups:
    let grouped = self.partof(group)
    let matched = self.match(group)
    if grouped and not matched:
      group.remove(self)
    elif not grouped and matched:
      group.insert(self)

template empty*(meta: ptr EntityMeta, ecs: SystemEcs, self: eid) {.used.} =
  available += 1

  for gid in meta.signature_groups:
    ecs.groups[gid].remove(self)
  
  for cid in meta.signature:
    storages[cid.int][ecs.layer.int].actions.remove(self)

  entities[self.int].age.incAge()
  system.swap(entities[self.int],entities[ENTS_MAX_SIZE-available])
  meta.signature.setLen(0) 
  meta.signature_groups.setLen(0)
  meta.parent = ent.nil.id.eid
  meta.childs.setLen(0)
  meta.dirty = true

proc kill*(self: ent|eid) {.inline.} =
  check_error_release_empty(self)
  let meta = self.meta
  let ecs = self.layer.ecs
  for e in meta.childs:
    kill(e)
  empty(meta,ecs,self)

proc kill*(ecs: SystemEcs) {.inline.} =
    proc emptyOnLayerKill(id: int) {.used.} =
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
      if m.layer.int == ecs.layer.int:
        emptyOnLayerKill(i)
  #clean storages
    for st in storages:
      let lst = st[ecs.layer.int]
      lst.actions.cleanup(lst)

iterator items*(range: Group): eid =
  for i in countdown(range.entities.high,0):
    yield range.entities[i]

iterator query*(E: typedesc[ent],T: typedesc): (eid, ptr T) {.inline.} =
  var st1 = T.getStorage()
  for i in countdown(st1.comps.high,0):
     yield (st1.entities[i].id.eid,st1.comps[i].addr)

iterator query*(T: typedesc): ptr T {.inline.} =
  let st1 = T.getStorage()
  for i in countdown(st1.comps.high,0):
     yield st1.comps[i].addr

var e1 {.global.} : ptr ent
var e2 {.global.} : ptr ent

template entity*(lid: LayerId, code: untyped): ent  =
  e1 = entities[ENTS_MAX_SIZE-available].addr
  e2 = entities[e1.id].addr
  available -= 1
  swap(e1.age,e2.age)
  let e {.inject.}= entities[e2.id]
  swap(e1.id,e2.id)
  metas[e.id].layer = lid
  block:
    code
    e.bind()
  e

template bind_impl(self: ent) =
  let meta = self.meta
  meta.dirty = false
  for cid in meta.signature:
     let groups = storages[cid][meta.layer.int].groups
     for group in groups:
       if not self.partof(group) and self.match(group):
         group.insert(self.id.eid)

proc `bind`*(self: ent) {.inline,discardable.} =
  bind_impl(self)

proc exist*(self:ent): bool =
  let cached = entities[self.id].addr
  echo self.id, "_", cached.id
  echo self.age, "_", cached.age
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

macro get*(this: ent, args: varargs[untyped]): untyped =
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
