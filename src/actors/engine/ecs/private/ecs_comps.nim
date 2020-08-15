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
import ecs_ops
import ecs_debug

var id_next_component : cid = 0

template impl_storage(T: typedesc) {.used.} =
  #INIT##
  var storage* =  CompStorage[T]()
  storage.id = id_next_component; id_next_component += 1
  storage.compType = $T

  storage.comps = newSeqOfCap[T](ENTS_INIT_SIZE)
  storage.entities = newSeqOfCap[ent](ENTS_INIT_SIZE)
  genIndices(storage.indices)

  storages.add(storage)

  #API##
  
  proc has*(_:typedesc[T], self: ent): bool {.inline,discardable.} =
    storage.indices[self.id] != ent.nil.id
  
  proc id*(_: typedesc[T]): cid =
    storage.id 
  
  proc getStorage*(_: typedesc[T]): CompStorage[T] =
    storage

  proc get*(self: ent, _: typedesc[T]): ptr T {.inline, discardable.} = 
    
    if self.id >= storage.indices.high:
      storage.indices.setLen(self.id+256)

    if has(_, self):
      return addr storage.comps[storage.indices[self.id]]

    let st = storage
    let cid = st.id
    let meta = self.meta
 
    storage.indices[self.id] = storage.entities.len
    storage.entities.add(self)

    let comp = storage.comps.push_addr()

    meta.signature.incl(cid)
    
    if not meta.dirty:
      discard
      #changeEntity
    
    comp
  
  proc remove*(self: ent, _: typedesc[T]) {.inline, discardable.} = 
    checkErrorRemoveComponent(self, T)
    var last = storage.indices[storage.entities[storage.entities.high].id]
    var index = storage.indices[self.id]

    storage.entities.del(index)
    storage.comps.del(index)
    swap(storage.indices[index],storage.indices[last])
  
    let op = self.layer.ecs.operations.addNew()
    op.entity = self
    op.arg = storage.id
    op.kind = OpKind.Remove
    self.meta.signature.excl(op.arg)
  
  proc impl_get(self: ent, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr storage.comps[storage.indices[self.id]]
  
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


