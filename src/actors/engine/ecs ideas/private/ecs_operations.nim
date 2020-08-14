import strutils
import macros
import strformat
import ../actors_ecs_h
import ecs_utils

template insert*(gr: Group, self: ent) {.used.} = 
  var len = gr.entities.len
  var left, index = 0
  var right = len
  len+=1
  if self.id >= ents_meta.len:
      gr.entities.add self
      gr.indices.setLen(self.id+256)
      gr.indices[self.id] = gr.entities.high
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
          gr.indices[self.id] = index
      else:
          if right == 0 or right >= gr.entities.high:
              gr.entities.add self
          else:
              gr.entities[right] = self
          
          if self.id >= gr.indices.len:
            gr.indices.setLen(self.id+256)
          gr.indices[self.id] = right

  self.meta.signature_groups.incl(gr.id)

  # if self.id >= gr.indices.high:
  #   gr.indices.setLen(self.id+SIZE_STEP)
  # gr.indices[self.id] = gr.entities.len
  # gr.entities.add(self)
  # self.meta.signature_groups.incl(gr.id)
proc binarysearch(this: ptr seq[ent], value: int): int {.discardable, used, inline.} =
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

template remove*(gr: Group, self: ent) =
  let index = binarysearch(addr gr.entities, self.id)
  gr.entities.delete(index)
  self.meta.signature_groups.excl(gr.id)

template change*() = discard

# template insideof*(self: ent,group: Group): bool {.used.} =
#   group.indices[self.id] != ent.none.id

template insideof*(self: ent,group: Group): bool {.used.} =
  if group.id in self.meta.signature_groups:
    true
  else: false


template fits*(self: ent, group: Group): bool {.used.} =
  let meta = self.meta
  if group.signature <= meta.signature and not (group.signature_excl <= meta.signature): true
  else: false

# maybe
# template fits*(self: ent, group: Group): bool {.used.} =
#   var result = true
#   for cid in group.signature:
#     let storage = storages[cid.int]
#     if storage.indices[self.id] == int.high or storage.indices[self.id] > storage.entities.high or storage.entities[storage.indices[self.id]].id!=self.id:
#       result = false
#       break
#   if result:
#     for cid in group.signature_excl:
#       let storage = storages[cid.int]
#       if storage.indices[self.id] != int.high:
#         result = false
#         break
#   result

proc execute*(ecs: SystemEcs) {.inline.} =
  let operations = addr ecs.operations
  for i in 0..operations[].high:
     let op = addr operations[][i]
     let meta = addr ents_meta[op.entity.id]
     while true:
       case op.kind:
          of Init:
            meta.dirty = false
            for cid in meta.signature:
              let groups = addr storages[cid].groups
              for group in groups[]:
                if op.entity.fits(group) and not op.entity.insideof(group):
                 
                  group.insert(op.entity)
            break

  operations[].setLen(0)