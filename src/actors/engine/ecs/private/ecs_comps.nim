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
import ecs_debug

var id_next_component : cid = 0

template impl_storage(T: typedesc) {.used.} =
  
  var storage* =  CompStorage[T]()
  var storages_local* = newSeq[CompStorageBase](highest_layer_id)
  
  #private
  proc impl_get(self: ent, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr storage.comps[storage.indices[self.id]] 
  proc impl_get(self: eid, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr storage.comps[storage.indices[self.int]]
  proc layerChanged(_:typedesc[T], layerID: LayerID) =
    storage = cast[CompStorage[T]](storages_local[layerID.int])
  proc cleanup(_:typedesc[T], straw: CompStorageBase) =
    let st = cast[CompStorage[T]](straw)
    st.entities.setLen(0); st.comps.setLen(0)
    discard
    

  #api
  proc has*(_:typedesc[T], self: ent): bool {.inline,discardable.} =
    storage.indices[self.id] != ent.nil.id and storage.indices[self.id] < storage.entities.len
  
  proc id*(_: typedesc[T]): cid {.inline.} =
    storage.id 
  
  proc getStorage*(_: typedesc[T]): CompStorage[T] {.inline.} =
    storage
  proc get*(self: ent, _: typedesc[T]): ptr T {.inline, discardable.} = 
    if self.id >= storage.indices.len:
      let oldsize = storage.indices.len
      let newSize = self.id + GROW_SIZE
      storage.indices.setLen(newSize)
      for i in oldsize..<newsize:
        storage.indices[i] = ent.nil.id
   
    if has(_, self):
      return addr storage.comps[storage.indices[self.id]]
    

    let st = storage
    let cid = st.id
    let meta = self.meta
    
    st.indices[self.id] = st.entities.len
    st.entities.add(self)

    let comp = st.comps.push_addr()

    meta.signature.incl(cid)
    

    if not meta.dirty:
      let op = meta.layer.ecs.operations.push_addr()
      op.entity = self
      op.kind = OpKind.Add
      op.arg  = cid
    
    comp 
  
  proc remove*(self: ent, _: typedesc[T]) {.inline.} = 
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
  
  #init 
  proc init_storage(_: typedesc[T]): CompStorage[T] =
    result = CompStorage[T]()
    result.id = id_next_component
    result.compType = $T
    result.comps = newSeqOfCap[T](ENTS_INIT_SIZE)
    result.entities = newSeqOfCap[ent](ENTS_INIT_SIZE)
    genIndices(result.indices)
    result.actions = IStorage(cleanup: proc(st: CompStorageBase)=cleanup(T,st))

  storage = init_storage(T)
  storages_local[0] = storage
  
  for i in 1..storages_local.high:
    storages_local[i] = init_storage(T)
  
  #for i in 0..<highest_layer_id:
  #  layers[i].storages.add(storages_local.addr)
   # l.storages.add(storages_local.addr)

  storages.add(storages_local.addr)
  
  var l = ILayer(Change: proc (self: LayerId) = layerChanged(T,self))
  a_layer_changed.add(l)

  formatComponentPretty(T)
  formatComponentPrettyEid(T)
  formatComponentPrettyAndLong(T)
  formatComponentPrettyAndLongEid(T)

  id_next_component += 1

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


