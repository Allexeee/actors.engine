import strutils
import macros
import strformat
import ../actors_ecs_h
import ecs_groups
import ecs_utils
import ecs_ent

var query_no_match = false
var excluded_storages = newSeq[CompStorageBase]()


template partof*(self: ent, group: Group): bool =
  if group.id in self.meta.signature_groups:
    true
  else: false
template match*(self: ent, group: Group):  bool  =
   var result = true
   
   for i in group.signature2:
     let indices = storages[i.int].indices.addr
     if indices[].high<self.id or indices[][self.id] == ent.nil.id:
       result = false; break
   for i in group.signature_excl2:
     let indices = storages[i.int].indices.addr
     if indices[].high<self.id or indices[][self.id] != ent.nil.id:
       result = false; break
   result

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

template insert*(gr: Group, self: ent) = 
  var len = gr.entities.len
  var left, index = 0
  var right = len
  let meta = self.meta
  len+=1
  if self.id > gr.indices.high:
      gr.entities.add self
      gr.indices.setLen(self.id+GROW_SIZE)
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

  if self.id >= gr.indices.len:
    let size = gr.indices.len
    let sizenew = self.id + GROW_SIZE
    gr.indices.setLen(sizenew)
    for i in size..<sizenew:
      gr.indices[i] = ent.nil.id
  gr.indices[self.id] = right

template remove*(gr: Group, self: ent) =
  let meta = self.meta
  let index = binarysearch(addr gr.entities, self.id)
  gr.entities.delete(index)
  meta.signature_groups.excl(gr.id)

template remove2*(gr: Group, self: ent) =
  let meta = self.meta
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
  #echo operations[].high
  for i in 0..operations[].high:
     let op = addr operations[][i]
     let meta = op.entity.meta
     #echo meta
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

iterator query_f*(E: typedesc[ent],T: typedesc): (eid, ptr T) {.inline.} =
  var st1 = T.getStorage()
  for i in 0..st1.comps.high:
    yield (st1.entities[i].id.eid,st1.comps[i].addr)

iterator query_f*(E: typedesc[ent],T,Y: typedesc):  (ent, ptr T, ptr Y) {.inline.} = 
  let st1 = T.getStorage()
  let st2 = Y.getStorage()

  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1

  case smallest.filterid:
    of 0:
      let max = st1.comps.high
      for i in 0..max:
        let e = st1.entities[i]
        let id = e.id
        yield (e,st1.comps[i].addr,st2.comps[st2.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let e = st2.entities[i]
        let id = e.id
        yield (e,st1.comps[st1.indices[id]].addr,st2.comps[i].addr)
    else:
        discard

iterator query_f*(E: typedesc[ent],T,Y,U: typedesc):  (ent, ptr T, ptr Y, ptr U) {.inline.} = 
  let st1 = T.getStorage()
  let st2 = Y.getStorage()
  let st3 = U.getStorage()
  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2

  case smallest.filterid:
    of 0:
      let max = st1.comps.high
      for i in 0..max:
        let e = st1.entities[i]
        let id = e.id
        yield (e,st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let e = st2.entities[i]
        let id = e.id
        yield (e,st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        let e = st3.entities[i]
        let id = e.id
        yield (e,st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr)
    else:
        discard

iterator query_f*(E: typedesc[ent],T,Y,U,I: typedesc):  (ent, ptr T, ptr Y, ptr U, ptr I) {.inline.} = 
  let st1 = T.getStorage()
  let st2 = Y.getStorage()
  let st3 = U.getStorage()
  let st4 = I.getStorage()
  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
  if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3

  case smallest.filterid:
    of 0:
      let max = st1.comps.high
      for i in 0..max:
        let e = st1.entities[i]
        let id = e.id
        yield (e,st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let e = st2.entities[i]
        let id = e.id
        yield (e,st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        let e = st3.entities[i]
        let id = e.id
        yield (e,st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr)
    of 3:
      let max = st4.comps.high
      for i in 0..max:
        let e = st4.entities[i]
        let id = e.id
        yield (e, st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[i].addr)
    else:
        discard

iterator query_f*(E: typedesc[ent],T,Y,U,I,O: typedesc):  (ent, ptr T, ptr Y, ptr U, ptr I, ptr O) {.inline.} =
  let st1 = T.getStorage()
  let st2 = Y.getStorage()
  let st3 = U.getStorage()
  let st4 = I.getStorage()
  let st5 = O.getStorage()
  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
  if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3
  if st5.entities.len < smallest.entities.len: smallest = st5; smallest.filterid = 4

  case smallest.filterid:
    of 0:
      let max = st1.comps.high
      for i in 0..max:
        let e = st1.entities[i]
        let id = e.id
        yield (e, st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let e = st2.entities[i]
        let id = e.id
        yield (e, st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        let e = st3.entities[i]
        let id = e.id
        yield (e,st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
    of 3:
      let max = st4.comps.high
      for i in 0..max:
        let e = st4.entities[i]
        let id = e.id
        yield (e, st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[i].addr,st5.comps[st5.indices[id]].addr)
    of 4:
      let max = st5.comps.high
      for i in 0..max:
        let e = st5.entities[i]
        let id = e.id
        yield (e, st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[st4.indices[id]].addr,st5.comps[i].addr)
    else:
        discard

iterator query_f*(T: typedesc): ptr T {.inline.} =
  let st1 = T.getStorage()
  let max = st1.comps.high
  for i in 0..max:
    yield st1.comps[i].addr

iterator query_f*(T,Y: typedesc): (ptr T, ptr Y) {.inline.} =
  let st1 = T.getStorage()
  let st2 = Y.getStorage()

  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  case smallest.filterid:
    of 0:
      let max = st1.comps.high  
      for i in 0..max:
        let id = st1.entities[i].id
        yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let id = st2.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr)
    else:
      discard

iterator query_f*(T,Y,U: typedesc):  (ptr T, ptr Y, ptr U) {.inline.} =
  let st1 = T.getStorage()
  let st2 = Y.getStorage()
  let st3 = U.getStorage()
  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
 
  case smallest.filterid:
    of 0:
      let max = st1.comps.high  
      for i in 0..max:
        let id = st1.entities[i].id
        yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let id = st2.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        let id = st3.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr)
    else:
        discard

iterator query_f*(T,Y,U,I: typedesc):  (ptr T, ptr Y, ptr U, ptr I) {.inline.} =
  let st1 = T.getStorage()
  let st2 = Y.getStorage()
  let st3 = U.getStorage()
  let st4 = I.getStorage()
  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
  if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3

  case smallest.filterid:
    of 0:
      let max = st1.comps.high  
      for i in 0..max:
        let id = st1.entities[i].id
        yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let id = st2.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        let id = st3.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr)
    of 3:
      let max = st4.comps.high
      for i in 0..max:
        let id = st4.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[i].addr)
    else:
        discard

iterator query_f*(T,Y,U,I,O: typedesc):  (ptr T, ptr Y, ptr U, ptr I, ptr O) {.inline.} =
  let st1 = T.getStorage()
  let st2 = Y.getStorage()
  let st3 = U.getStorage()
  let st4 = I.getStorage()
  let st5 = O.getStorage()
  var smallest : CompStorageBase = st1; smallest.filterid = 0
  if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
  if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3
  if st5.entities.len < smallest.entities.len: smallest = st5; smallest.filterid = 4

  case smallest.filterid:
    of 0:
      let max = st1.comps.high
      for i in 0..max:
        let id = st1.entities[i].id
        yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
    of 1:
      let max = st2.comps.high
      for i in 0..max:
        let id = st2.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
    of 2:
      let max = st3.comps.high
      for i in 0..max:
        let id = st3.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
    of 3:
      let max = st4.comps.high
      for i in 0..max:
        let id = st4.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[i].addr,st5.comps[st5.indices[id]].addr)
    of 4:
      let max = st5.comps.high
      for i in 0..max:
        let id = st5.entities[i].id
        yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[st4.indices[id]].addr,st5.comps[i].addr)
    else:
        discard

iterator query*(T: typedesc): ptr T {.inline.} =

  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration

    let st1 = T.getStorage()
    let max = st1.comps.high

    for i in 0..max:
      yield st1.comps[i].addr

  excluded_storages.setLen(0)

iterator query*(T,Y: typedesc): (ptr T, ptr Y) {.inline.} =
  
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    
    let st1 = T.getStorage()
    let st2 = Y.getStorage()
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
   
    case smallest.filterid:
      of 0:
        let max = st1.comps.high
        for i in 0..max: 
          let id = st1.entities[i].id
          yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let id = st2.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr)
      else:
        discard

  excluded_storages.setLen(0)

iterator query*(T,Y,U: typedesc):  (ptr T, ptr Y, ptr U) {.inline.} =

  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
   
    let st1 = T.getStorage()
    let st2 = Y.getStorage()
    let st3 = U.getStorage()
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
    if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
  
    case smallest.filterid:
      of 0:
        let max = st1.comps.high  
        for i in 0..max:
          let id = st1.entities[i].id
          yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let id = st2.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr)
      of 2:
        let max = st3.comps.high
        for i in 0..max:
          let id = st3.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr)
      else:
          discard
  excluded_storages.setLen(0)

iterator query*(T,Y,U,I: typedesc):  (ptr T, ptr Y, ptr U, ptr I) {.inline.} =
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    let st1 = T.getStorage()
    let st2 = Y.getStorage()
    let st3 = U.getStorage()
    let st4 = I.getStorage()
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
    if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
    if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3

    case smallest.filterid:
      of 0:
        let max = st1.comps.high  
        for i in 0..max:
          let id = st1.entities[i].id
          yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let id = st2.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
      of 2:
        let max = st3.comps.high
        for i in 0..max:
          let id = st3.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr)
      of 3:
        let max = st4.comps.high
        for i in 0..max:
          let id = st4.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[i].addr)
      else:
          discard
  excluded_storages.setLen(0)

iterator query*(T,Y,U,I,O: typedesc):  (ptr T, ptr Y, ptr U, ptr I, ptr O) {.inline.} =
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    var st1 = T.getStorage()
    var st2 = Y.getStorage()
    var st3 = U.getStorage()
    var st4 = I.getStorage()
    var st5 = O.getStorage()
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
    if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
    if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3
    if st5.entities.len < smallest.entities.len: smallest = st5; smallest.filterid = 4

    case smallest.filterid:
      of 0:
        let max = st1.comps.high
        for i in 0..max:
          let id = st1.entities[i].id
          yield (st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let id = st2.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
      of 2:
        let max = st3.comps.high
        for i in 0..max:
          let id = st3.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
      of 3:
        let max = st4.comps.high
        for i in 0..max:
          let id = st4.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[i].addr,st5.comps[st5.indices[id]].addr)
      of 4:
        let max = st5.comps.high
        for i in 0..max:
          let id = st5.entities[i].id
          yield (st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[st4.indices[id]].addr,st5.comps[i].addr)
      else:
          discard
  excluded_storages.setLen(0)

iterator query*(E: typedesc[ent],T: typedesc): (eid, ptr T) {.inline.} =
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    let st1 = T.getStorage()
    let max = st1.comps.high
    for i in 0..max:
      yield (st1.entities[i].id.eid,st1.comps[i].addr)
  excluded_storages.setLen(0)

iterator query*(E: typedesc[ent],T,Y: typedesc):  (ent, ptr T, ptr Y) {.inline.} = 
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    let st1 = T.getStorage()
    let st2 = Y.getStorage()
  
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
  
    case smallest.filterid:
      of 0:
        let max = st1.comps.high
        for i in 0..max:
          let e = st1.entities[i]
          let id = e.id
          yield (e,st1.comps[i].addr,st2.comps[st2.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let e = st2.entities[i]
          let id = e.id
          yield (e,st1.comps[st1.indices[id]].addr,st2.comps[i].addr)
      else:
          discard
  excluded_storages.setLen(0)

iterator query*(E: typedesc[ent],T,Y,U: typedesc):  (ent, ptr T, ptr Y, ptr U) {.inline.} = 
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    let st1 = T.getStorage()
    let st2 = Y.getStorage()
    let st3 = U.getStorage()
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
    if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
  
    case smallest.filterid:
      of 0:
        let max = st1.comps.high
        for i in 0..max:
          let e = st1.entities[i]
          let id = e.id
          yield (e,st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let e = st2.entities[i]
          let id = e.id
          yield (e,st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr)
      of 2:
        let max = st3.comps.high
        for i in 0..max:
          let e = st3.entities[i]
          let id = e.id
          yield (e,st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr)
      else:
          discard
  excluded_storages.setLen(0)

iterator query*(E: typedesc[ent],T,Y,U,I: typedesc):  (ent, ptr T, ptr Y, ptr U, ptr I) {.inline.} = 
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    let st1 = T.getStorage()
    let st2 = Y.getStorage()
    let st3 = U.getStorage()
    let st4 = I.getStorage()
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
    if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
    if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3
  
    case smallest.filterid:
      of 0:
        let max = st1.comps.high
        for i in 0..max:
          let e = st1.entities[i]
          let id = e.id
          yield (e,st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let e = st2.entities[i]
          let id = e.id
          yield (e,st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr)
      of 2:
        let max = st3.comps.high
        for i in 0..max:
          let e = st3.entities[i]
          let id = e.id
          yield (e,st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr)
      of 3:
        let max = st4.comps.high
        for i in 0..max:
          let e = st4.entities[i]
          let id = e.id
          yield (e, st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[i].addr)
      else:
          discard
  excluded_storages.setLen(0)

iterator query*(E: typedesc[ent],T,Y,U,I,O: typedesc):  (ent, ptr T, ptr Y, ptr U, ptr I, ptr O) {.inline.} =
  block iteration:
    for ii in excluded_storages:
      if ii.entities.len > 0: break iteration
    let st1 = T.getStorage()
    let st2 = Y.getStorage()
    let st3 = U.getStorage()
    let st4 = I.getStorage()
    let st5 = O.getStorage()
    var smallest : CompStorageBase = st1; smallest.filterid = 0
    if st2.entities.len < smallest.entities.len: smallest = st2; smallest.filterid = 1
    if st3.entities.len < smallest.entities.len: smallest = st3; smallest.filterid = 2
    if st4.entities.len < smallest.entities.len: smallest = st4; smallest.filterid = 3
    if st5.entities.len < smallest.entities.len: smallest = st5; smallest.filterid = 4
  
    case smallest.filterid:
      of 0:
        let max = st1.comps.high
        for i in 0..max:
          let e = st1.entities[i]
          let id = e.id
          yield (e, st1.comps[i].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
      of 1:
        let max = st2.comps.high
        for i in 0..max:
          let e = st2.entities[i]
          let id = e.id
          yield (e, st1.comps[st1.indices[id]].addr,st2.comps[i].addr,st3.comps[st3.indices[id]].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
      of 2:
        let max = st3.comps.high
        for i in 0..max:
          let e = st3.entities[i]
          let id = e.id
          yield (e,st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[i].addr,st4.comps[st4.indices[id]].addr,st5.comps[st5.indices[id]].addr)
      of 3:
        let max = st4.comps.high
        for i in 0..max:
          let e = st4.entities[i]
          let id = e.id
          yield (e, st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr,st4.comps[i].addr,st5.comps[st5.indices[id]].addr)
      of 4:
        let max = st5.comps.high
        for i in 0..max:
          let e = st5.entities[i]
          let id = e.id
          yield (e, st1.comps[st1.indices[id]].addr,st2.comps[st2.indices[id]].addr,st3.comps[st3.indices[id]].addr, st4.comps[st4.indices[id]].addr,st5.comps[i].addr)
      else:
          discard
  excluded_storages.setLen(0)


proc exclude*(T: typedesc) =
  excluded_storages.add(T.getStorage())
proc exclude*(T,Y: typedesc) =
  excluded_storages.add(T.getStorage())
  excluded_storages.add(Y.getStorage())
proc exclude*(T,Y,U: typedesc) =
  excluded_storages.add(T.getStorage())
  excluded_storages.add(Y.getStorage())
  excluded_storages.add(U.getStorage())
proc exclude*(T,Y,U,I: typedesc) =
  excluded_storages.add(T.getStorage())
  excluded_storages.add(Y.getStorage())
  excluded_storages.add(U.getStorage())
  excluded_storages.add(I.getStorage())
proc exclude*(T,Y,U,I,O: typedesc) =
  excluded_storages.add(T.getStorage())
  excluded_storages.add(Y.getStorage())
  excluded_storages.add(U.getStorage())
  excluded_storages.add(I.getStorage())
  excluded_storages.add(O.getStorage())