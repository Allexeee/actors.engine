import ../actors_ecs_h
import ../../../actors_h
import ../../../actors_tools
import ecs_debug
import ecs_utils


var next_id = 0

proc entity*(lid: LayerId): ent =
  let ecs = layers[lid.int]
  if ents_free.len > 0:
    result = ents_free.pop()
    let meta = result.meta
    meta.alive = true
  
  else:
    
    result.id = next_id; next_id.inc
    result.age = 0
    
    if result.id > metas.high:
      metas.setLen(result.id+GROW_SIZE)
    
    let meta     = metas[result.id].addr
    meta.layer   = lid
    meta.age     = 0
    meta.alive   = true
    meta.childs  = newSeq[ent]()
    meta.signature_groups = {}

    
  let op = ecs.operations.inc
  op.entity = result
  op.kind = OpKind.Init
  ecs.entids.add(result.id)
  
  result

proc kill*(self: ent) = 
  check_error_release_empty(self)
  let meta = self.meta
  let ecs = self.layer.ecs
 
  for e in meta.childs:
      kill(e)

  meta.signature = {}  
  meta.age.incAge()
  
  let op = ecs.operations.addNew()
  op.entity = self
  op.kind = OpKind.Kill


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


