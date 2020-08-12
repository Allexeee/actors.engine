{.experimental: "dynamicBindSym".}
{.used.} 

import strformat
import strutils
import macros
import sets

import ../../../actors_tools
import ../../../actors_h
import ../actors_ecs_h
import ecs_utils

var id_next_component : cid = 0


template init_storage[T](): CompStorage[T] =
  let storage*  = CompStorage[T]()
  storage.comps = newSeq[T]()
  storage.indices = newSeq[int](ENTS_INIT_SIZE)
  storage.entities = newSeq[int]()
  for i in 0..storage.indices.high:
    storage.indices[i] = int.high
  storage.id = id_next_component; id_next_component += 1
  storages.add(storage)
  storage



template impl_storage(T: typedesc) {.used.} =
  
  var storage* =  CompStorage[T]() #init_storage[T]()
  storage.comps = newSeq[T]()
  storage.indices = newSeq[int](ENTS_INIT_SIZE)
  storage.entities = newSeq[ent]()
  for i in 0..storage.indices.high:
    storage.indices[i] = int.high
  storage.id = id_next_component; id_next_component += 1
  #storage.compType = $T
 # storage.compAlias = storage.compType
  #formatComponent(storage.compAlias)
 # storage.cache = storage.comps.addr
  # block:
  #   let a {.inject.} = storage.compAlias 
  #   let b {.inject.} = storage.compType 
  #   let c {.inject.} = storage.id 
  #   storage.ast = &("""let {a} = cast[ptr seq[{b}]](storages[{c}].cache)""")

  proc has*(_:typedesc[T], self: ent): bool {.inline,discardable.} =
    #echo storage.indices[self.id]
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
      
    if has(_, self):
      return addr storage.comps[storage.indices[self.id]]
 
    if self.id >= storage.indices.high:
      storage.indices.setLen(self.id+1)
     
    storage.indices[self.id] = storage.entities.len
    storage.entities.add(self)
    
    let comp = storage.comps.push_addr()
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