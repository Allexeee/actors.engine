import strutils
import macros
import strformat
import ../actors_ecs_h
import ecs_groups
import ecs_utils
import ecs_ent

template partof*(self: ent, group: Group): bool =
  if group.id in self.meta.signature_groups:
    true
  else: false

# 10000 checks: Time elapsed for modern: 1.363000000
template match*(self: ent, group: Group):  bool  =
   var result = true
   for i in group.signature2:
     if storages[i.int].indices[self.id] == ent.nil.id:
       result = false; break
   for i in group.signature_excl2:
     if storages[i.int].indices[self.id] != ent.nil.id:
       result = false; break
   result

template insert*(gr: Group, self: ent) = 
  var len = gr.entities.len
  var left, index = 0
  var right = len
  let meta = self.meta
  len+=1
  if self.id >= metas.len:
      gr.entities.add self
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
      else:
          if right == 0 or right >= gr.entities.high:
              gr.entities.add self
          else:
              gr.entities[right] = self
  meta.signature_groups.incl(gr.id)
  gr.indices[self.id] = right

template remove*(gr: Group, self: ent) =
  let meta = self.meta
  let index = binarysearch(addr gr.entities, self.id)
  gr.entities.delete(index)
  meta.signature_groups.excl(gr.id)

template remove2*(gr: Group, self: ent) =
  let meta = self.meta
  #let index = binarysearch(addr gr.entities, self.id)
  gr.entities.delete(gr.indices[self.id])
  meta.signature_groups.excl(gr.id)
  gr.indices[self.id] = ent.nil.id

template changeEntity*(self: ent, cid: uint16) =
  let groups = storages[cid].groups
  for group in groups:
    let grouped = self.partof(group)
    let matched = self.match(group)
    if grouped and not matched:
      group.remove(self)
    elif not grouped and matched:
      group.insert(self)

template empty*(self: ent) =
  let meta = self.meta
  let ecs = meta.layer.ecs
  for gid in meta.signature_groups:
    let group = ecs.groups[gid]
    group.remove(op.entity)

  ents_free.add(op.entity)
  meta.signature_groups = {}
  meta.parent = (0,0)
  meta.childs.setLen(0)

proc execute*(ecs: SystemEcs) {.inline.} =
  let operations = addr ecs.operations
  for i in 0..operations[].high:
     let op = addr operations[][i]
     let meta = op.entity.meta
     while true:
       case op.kind:
          of Kill:
            op.entity.empty()
            break
          of Remove:
            if meta.signature == {}:
              for e in meta.childs:
                e.kill()
              op.entity.empty()
            else:
              changeEntity(op.entity,op.arg)
            break
          of Add:
            changeEntity(op.entity,op.arg)
            break

          of Init:
            meta.dirty = false
            for cid in meta.signature:
              let groups = storages[cid].groups
              for group in groups:
                if not op.entity.partof(group) and op.entity.match(group):
                  group.insert(op.entity)
            break

  operations[].setLen(0)

iterator items*(range: Group): ent =
  let ecs = layers[range.layer.uint32]
  ecs.execute()
  var i = range.entities.low
  while i <= range.entities.high:
      yield range.entities[i]
      inc i

iterator comps*(t,y,u: typedesc): (ptr t, ptr y,ptr u) {.inline.} =
  
  var st1 = t.getStorage()
  var st2 = y.getStorage()
  var st3 = u.getStorage()
  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2

  case smallest.filterid:
    of 0:
      let max = st1.comps.high
      for i in 0..max:
        yield (st1.comps[i].addr,st2.comps[st2.indices[st1.entities[i].id]].addr,st3.comps[st3.indices[st1.entities[i].id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        yield (st1.comps[st1.indices[st2.entities[i].id]].addr,st2.comps[i].addr,st3.comps[st3.indices[st2.entities[i].id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        yield (st1.comps[st1.indices[st3.entities[i].id]].addr,st2.comps[st2.indices[st3.entities[i].id]].addr,st3.comps[i].addr)
    else:
      discard

iterator comps*(t: typedesc): (ent, ptr t) {.inline.} =
  var st1 = t.getStorage()
  let max = st1.comps.high
  for i in 0..max:
    yield (st1.entities[i],st1.comps[i].addr)





# 10000 checks Time elapsed for classic: 1.907000000
# template fits*(self: ent, group: Group):  bool  =
#    let meta = self.meta
#    if group.signature <= meta.signature and card(group.signature_excl * meta.signature)==0: true
#    else: false

# template partof2*(self: ent, group: Group): bool  =
#   if group.indices[self.id] == ent.nil.id: false
#   else: true
