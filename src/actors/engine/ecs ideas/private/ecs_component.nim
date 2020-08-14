{.experimental: "dynamicBindSym".}
{.used.} 

import algorithm
import strformat
import strutils
import macros
import sets

import ../../../actors_tools
import ../../../actors_h
import ../actors_ecs_h
import ecs_utils
import ecs_operations

var id_next_component : cid = 0





template impl_storage(T: typedesc) {.used.} =
  var storage* =  CompStorage[T]() #init_storage[T]()
  storage.comps = newSeq[T]()
  storage.indices = newSeq[int](ENTS_INIT_SIZE)
  storage.entities = newSeq[ent]()
  for i in 0..storage.indices.high:
    storage.indices[i] = int.high
  storage.id = id_next_component; id_next_component += 1
  storages.add(storage)
  storage.compType = $T
  
  proc remove(t: typedesc[T], self: ent) {.inline, discardable.} =
    
    var lastindex = storage.entities.high
    #echo storage.indices[self.id]
    storage.entities.delete(storage.indices[self.id])
    storage.comps.delete(storage.indices[self.id])
    storage.indices[self.id] = ent.none.id
    #swap(storage.indices[lastindex], storage.indices[self.id])
    
    let groups = addr storage.groups
    for group in groups[]:
      let fits = self.fits(group)
      let grouped = self.insideof(group)
      #echo fits, " and ", grouped, " ", self.id
      if grouped and not fits:
        let index = group.indices[self.id]#binarysearch(addr gr.entities, self.id)
        #echo index, "to delete"
        group.entities.delete(index)
        for i in index..group.entities.high:
          group.indices[group.entities[i].id] -= 1
        self.meta.signature_groups.excl(group.id)
        group.indices[self.id] = ent.none.id
      elif not grouped and fits:
        group.insert(self)
          #entityMeta.signature_groups.excl(gr.id)
        #i#f op.entity.fits(group) and not op.entity.insideof(group):
         #   group.insert(op.entity)

  #   for group in groups:
  #     let in_group = self.is_inside(group)
  #     let fits = self.fits(group)
  #    # let len = storage.entities.high
  #     if in_group and not fits:
  #      # let last = storage.entities[len]
  #       let eid = group.indices[self.id]
  #       #echo eid,"  ",group.entities.len," ",self.id
  #       group.entities.delete(eid)
  #       group.indices[self.id] = ent.none.id
  #      # swap(group.indices[last.id], group.indices[self.id])
  #       self.meta.signature_groups.excl(group.id)
  #     elif not in_group and fits:
  #       group.insert(self)
  #       #group.indices[self.id] = ent.none.id
  #   let len = storage.entities.high
  #   let last = storage.entities[len]
    
  #   echo self.id, " puk ", storage.indices[self.id], " ", storage.entities.len, " ", storage.compType
    
  #   storage.entities.delete(storage.indices[self.id])
  #   storage.comps.delete(storage.indices[self.id])
  #   #storage.entities.setLen(len)
  #   #storage.comps.setLen(len)
  #   storage.indices[self.id] = ent.none.id
  #   #swap(storage.indices[last.id], storage.indices[self.id])
    
  #   let groups = storage.groups
  #   for group in groups:
  #     let in_group = self.is_inside(group)
  #     let fits = self.fits(group)
  #    # let len = storage.entities.high
  #     if in_group and not fits:
  #      # let last = storage.entities[len]
  #       let eid = group.indices[self.id]
  #       #echo eid,"  ",group.entities.len," ",self.id
  #       group.entities.delete(eid)
  #       group.indices[self.id] = ent.none.id
  #      # swap(group.indices[last.id], group.indices[self.id])
  #       self.meta.signature_groups.excl(group.id)
  #     elif not in_group and fits:
  #       group.insert(self)
  #       #group.indices[self.id] = ent.none.id

    
    
  #  # echo indices[last.id]
  #  # echo storage.indices[last.id]
       
  storage.actions = IStorage(destroy: proc(self: ent) = T.remove(self))

  proc has*(_:typedesc[T], self: ent): bool {.inline,discardable.} =
    storage.indices[self.id] != ent.none.id
  

  proc id*(_: typedesc[T]): cid =
    storage.id 
  
  proc getStorageBase*(_: typedesc[T]): CompStorageBase =
    storage

  proc getStorage*(_: typedesc[T]): CompStorage[T] =
    storage

  proc getComps*(_: typedesc[T]): ptr seq[T] =
    storage.comps.addr
 
  proc get*(self: ent, _: typedesc[T]): ptr T {.inline, discardable.} = 
    if self.id >= storage.indices.high:
      storage.indices.setLen(self.id+256)

    if has(_, self):
      return addr storage.comps[storage.indices[self.id]]

    let st = storage
    let cid = st.id
    let meta = addr ents_meta[self.id]
 

     
    storage.indices[self.id] = storage.entities.len
    storage.entities.add(self)

    let comp = storage.comps.push_addr()

    meta.signature.incl(cid)
    
    if not meta.dirty:
      discard
      #changeEntity
    
    comp
  
  proc remove*(self: ent, _: typedesc[T]) {.inline, discardable.} = 
    #checkErrorRemoveComponent(self, t)
   # let entity = addr ents_meta[self.id]
    var index = storage.indices[self.id]
    storage.indices[self.id] = int.high
    storage.entities.delete(index)
    storage.comps.delete(index)
    #storage.comps.del(id)
    #storage.entities.del(id)
   # let op = entity.layer.ecs.operations.addNew()
    #op.entity = self
    #op.arg = storage.meta.id
   # op.kind = OpKind.Remove
    #entity.signature.excl(op.arg)
  
  proc impl_get(self: ent, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr storage.comps[storage.indices[self.id]]
  
  proc theget*(self: int, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr storage.comps[storage.indices[storage.entities[self].id]]
  
  
  formatComponentPretty(T)
  formatComponentPrettyAndLong(T)

macro add*(self: App, component: untyped): untyped =

  result = nnkStmtList.newTree(
          nnkCommand.newTree(
              bindSym("impl_storage", brForceOpen),
              newIdentNode($component)
            )
          )
  

  var name_alias = $component
  if (name_alias.contains("Component") or name_alias.contains("Comp")):
      formatComponentAlias(name_alias)
      
      let node = nnkTypeSection.newTree(
      nnkTypeDef.newTree(
          nnkPostfix.newTree(
              newIdentNode("*"),
              newIdentNode(name_alias)),
              newEmptyNode(),
      newIdentNode($component)
      ))
      result.add(node)




# template makeMask*(t,y: typedesc) {.used.} =
#   type mask = tuple[formatComponentName(t):ptr t, formatComponentName(y): ptr y]
  
  #type mask1 = tuple[ca: CA, cb: CB]
  
# dumptree:
#   type mask = tuple[ca: ptr CompA, cb: ptr CompB]

# macro genMask*(): untyped =

#   result = nnkStmtList.newTree(
#             nnkTypeSection.newTree(
#               nnkTypeDef.newTree(
#                 nnkPostfix.newTree(
#                   newIdentNode("*"),
#                   newIdentNode("mask")
#                   ),
#                   newEmptyNode(),
#                   newIdentNode("int")
#                 )
#           )
#           )
          
  # var params = nnkStmtList.newTree(
  #         nnkCommand.newTree(
  #             bindSym("make_storage", brForceOpen),
  #             newIdentNode($component)
  #           )
  #         )
  # result = nnkTypeSection.newTree(
  #     nnkTypeDef.newTree(
  #         nnkPostfix.newTree(
  #             nnkPostfix.newTree(
  #             newIdentNode("*"),
  #             newIdentNode("mask")),
  #             newEmptyNode(),
  #     newIdentNode("int")
  #     )))
      
  #result.add(node)
  # result = nnkTypeSection.newTree(
  #   nnkTypeDef.newTree(
  #     newIdentNode("mask")),
  #   nnkTupleTy.newTree(
  #     nnkIdentDefs.newTree(
  #       newIdentNode("ca"),
  #       nnkPtrTy.newTree(
  #         newIdentNode("CompA")
  #       )
  #     ),
  #     nnkIdentDefs.newTree(
  #       newIdentNode("cb"),
  #       nnkPtrTy.newTree(
  #         newIdentNode("CompB")
  #       )
  #     )
  #   )
  # )


type poo = object
type foo = object

macro fff*(t,y: typedesc) =
  
  #var tName = strVal(t)
  var n1 = strVal(t)
  formatComponent(n1)
  var n2 = strVal(y)  
  formatComponent(n1)
  
  var source = ""

  source = &("""tuple[{n1}: ptr {t},{n2}: ptr {y}""")
  result = parseStmt(source)


type tester*[t,y] = fff(t,y)

proc pooper*[t,y](): tester =
  echo result
#var ttt : tuple[arg: fff, arg2: fff]

#tuple[a: ptr t, b: ptr y, c: ptr u]
# iterator comps*(t,y: typedesc): tuple[formatComponentName(t), formatComponentName(y)] =
#   let st1 = t.getStorage()
#   let st2 = y.getStorage()
#   var i = 0
#   let max = st1.comps.len
#   while i < max:
#     yield (st1.comps[i].addr,st2.comps[i].addr)
#     inc i

# iterator comps*(t: typedesc, y: typedesc, u: typedesc): tuple[a: ptr t, b: ptr y, c: ptr u] =
#   let comps1 = t.GetComps()
#   let comps2 = y.GetComps()
#   let comps3 = u.GetComps()

#   let st1 = t.GetStorage()
#   let len1 = comps1[].len
#   let len2 = comps2[].len
#   let len3 = comps3[].len
#   let max = if len1 > len2: len2 else: len1
#   var i = 0
#   while i < max:
#     let e = st1.indices[i]
#     yield (comps1[][i].addr,comps2[][e].addr, comps3[][e].addr)
#     inc i