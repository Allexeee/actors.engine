#{.push checks: off.}
import actors_ecs_h
import private/ecs_utils

include private/ecs_entity
include private/ecs_component
include private/ecs_system

export actors_ecs_h
export ecs_utils



template insert(gr: Group, self: ent, emeta: ptr EntityMeta) {.used.} = 
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

proc execute*(ecs: SystemEcs) {.inline.} =
  let operations = addr ecs.operations
  for i in 0..operations[].high:
     let op = addr operations[][i]
     let meta = addr ents_meta[op.entity.id]#entitiesMeta[op.entity.id]
     while true:
       case op.kind:
          of Init:
            meta.dirty = false
            for cid in meta.signature:
              let groups = storages[cid].groups
              for group in groups:
                let grouped = group.len > 0 and storages[cid].indices[op.entity.id]<storages[cid].entities.len #isGrouped(meta, group)
               # echo grouped
                if not grouped and isValidForGroup(op.entity.id, group):
                  
                  # var cstorages = newSeq[CompStorageBase](0)
                    
                  # for i in 0..meta.signature.high:
                    
                  #   cstorages[i] = storages[meta.signature[i].int]
                  #   cstorages.sort(sortStorages)
    
                  group.entities = storages[cid].entities.addr
            break

  operations[].setLen(0)

#{.pop.}