import ../actors_ecs_h
import ../../../actors_h
import ../../../actors_tools
import ecs_debug
#import ecs_operations

proc entity*(lid: LayerId): ent =
  let ecs = layers[lid.int]
  if ents_free.len > 0:
    result = ents_free.pop()
    let meta = result.meta
    meta.alive = true
  
  else:
    
    result.id = metas.len
    result.age = 0

    let meta     = metas.push_addr()
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
    check_error_release_empty(self)
    var meta = self.meta
    let ecs = self.layer.ecs
    let op = ecs.operations.addNew()
    op.entity = self
    op.kind = OpKind.Kill
   
    for e in meta.childs:
        kill(e)
    
    meta.signature = {}
    
    if meta.age == high(int):
      meta.age = 0
    else: meta.age += 1
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