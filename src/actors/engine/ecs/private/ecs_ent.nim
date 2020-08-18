import ../actors_ecs_h
import ../../../actors_h
import ../../../actors_tools
import ecs_debug
import ecs_utils


template makeEntity*(lid: LayerId, code: untyped): untyped =
  let r = lid.entity()
  block:
    let e {.inject.} = r
    code
  r

proc entity*(lid: LayerId): ent {. discardable, inline.} =
  var e1 {.global.} : ptr ent
  var e2 {.global.} : ptr ent
  let next = ENTS_MAX_SIZE.high-available
  e1 = entities[next].addr
  e2 = entities[e1.id].addr
  swap(e1.age,e2.age)
  result = entities[e2.id]
  swap(e1.id,e2.id)
  
  let metas = metas[result.id].addr
  metas.layer   = lid
  metas.dirty   = true
  available -= 1
  
  # let ops = layers[lid.int].operations.addr
  # ops[].setLen(ops[].len+1) 
  # let op = ops[ops[].high].addr
  # op.entity = result.id.eid
  # op.kind = OpKind.Init 

# int available = 0

# 0  1    2  3  4  5  6    (0)
# 0  x    2  3  4  5  6    (0)
# 0  6|1  2  3  4  5  1|0  (1)

#age = 0
# size - available
    #1|0

proc kill*(self: ent) {.inline.} =
  check_error_release_empty(self)
  available += 1
  system.swap(entities[self.id],entities[entities.len-available])
  entities[self.id].age.incAge()
  let meta = self.meta
  let ecs = self.layer.ecs
  for e in meta.childs:
    kill(e)
  let op = ecs.operations.inc()
  op.entity = self.id.eid
  op.kind = OpKind.Kill

proc exist*(self:ent): bool =
  let cached = entities[self.id].addr
  cached.id == self.id and cached.age == self.age

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
