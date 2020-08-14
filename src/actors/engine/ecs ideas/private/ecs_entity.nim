import ../actors_ecs_h
import ../../../actors_h
import ../../../actors_tools

import ecs_operations

proc entity*(lid: LayerId): ent =
  let ecs = layers[lid.int]
  if ents_free.len > 0:
    result = ents_free.pop()
    let meta = addr ents_meta[result.id]
    meta.alive = true
  
  else:
    
    result.id = ents_meta.len
    result.age = 0

    let meta     = ents_meta.push_addr()
    meta.layer   = lid
    meta.age     = 0
    meta.alive   = true
    meta.childs  = newSeq[ent]()

    
  let op = ecs.operations.push_addr()
  op.entity = result
  op.kind = OpKind.Init
  ecs.entids.add(result.id)
  
  result

proc kill*(self: ent) =
  let meta = self.meta
 # echo self.id
  for e in meta.childs:
    kill(e)
  
  var age = self.age

  if age == high(int):
     age = 0
  else: age += 1



  for gid in meta.signature_groups:
    let group = allgroups[gid]
    group.remove(self)

    #ents_stash.add(op.entity)
  meta.signature_groups = {0'u16}
  meta.age = age
  #meta.parent = (0,0)
  meta.childs.setLen(0)
  meta.alive = false

  
  #ecs.ents_alive.excl(op.entity.id)
  ents_free.add((self.id,age))
  # entity.dirty = true  
  # for cid in entity.signature:
  #   let storage = storages[cid]
  #   storage.actions.destroy(self)
  # entity.signature = {}#setLen(0)
  

  
  

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

template changeEntity*(op: ptr Operation, emeta: ptr EntityMeta) =
 let cid = op.arg
 let groups = addr storages[cid].groups
 for group in groups[]:
   let masked  = checkMask(emeta, group)
   let grouped = checkGroup(emeta, group)
   if grouped and not masked:
     group.remove(op.entity, emeta)
   elif masked and not grouped:
     group.insert(op.entity, emeta)
