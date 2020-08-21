{.experimental: "dynamicBindSym".}
{.used.} 

import strformat
import strutils
import macros
import sets

import ../../../actors_h
import ../pixeye_ecs_h
import ecs_utils


var id_next_component : cid = 0

template impl_storage(T: typedesc) {.used.} =
  
  var storage* =  CompStorage[T]()
  var storageid* : cid
  var storages_local_t* = newSeq[CompStorage[T]](highest_layer_id)
  #private
  proc impl_get(self: ent, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr storage.comps[storage.indices[self.id]] 
  
  proc impl_get(self: eid, _: typedesc[T]): ptr T {.inline, discardable, used.} =
    addr storage.comps[storage.indices[self.int]]
  
  proc layerChanged(_:typedesc[T], layerID: LayerID) =
    storage = storages_local_t[layerID.int] #cast[CompStorage[T]](storages_local[layerID.int])
  
  proc cleanup(_:typedesc[T], straw: CompStorageBase) =
    let st = cast[CompStorage[T]](straw)
    st.entities.setLen(0); st.comps.setLen(0)
  
  proc removeById(_: typedesc[T], self: eid) {.inline.} = 
    var last = storage.indices[storage.entities[storage.entities.high].int]
    var index = storage.indices[self.int]
    storage.entities.del(index)
    storage.comps.del(index)
    swap(storage.indices[index],storage.indices[last])
    

  #api
  proc has*(_:typedesc[T], self: eid): bool {.inline,discardable.} =
    storage.indices[self.int] != ent.nil.id and storage.indices[self.int] < storage.entities.len
  
  proc has*(_:typedesc[T], self: ent): bool {.inline,discardable.} =
    storage.indices[self.id] != ent.nil.id and storage.indices[self.id] < storage.entities.len
  
  proc getstorageid*(_: typedesc[T]): cid {.inline.} =
    storage.id 
  proc getStorage*(_: typedesc[T]): CompStorage[T] {.inline.} =
    storage
   
  # proc getStorage*(_: typedesc[T], layer: LayerId): CompStorage[T] {.inline.} =
  #   storages_local_t[ecs.int]
 
  proc get*(self: ent|eid, _: typedesc[T]): ptr T {.inline,discardable.} = 
  
    if has(_, self):
      return addr storage.comps[storage.indices[self.id]]
    
    let cid = storageid
    let st = cast[CompStorage[T]](self.ecs.storages[storageid])

    st.indices[self.id] = st.entities.len 
    st.entities.add(self)


    self.meta.signature.add(cid)
    
    if not dirty:
      changeEntity(self,cid)
    
    st.comps.add(T())
    st.comps[st.comps.high].addr
    
  
  proc remove*(self: ent|eid, _: typedesc[T]) {.inline.} = 
 
    var last = storage.indices[storage.entities[storage.entities.high].int]
    var index = storage.indices[self.id]

    storage.entities.del(index)
    storage.comps.del(index)
    swap(storage.indices[index],storage.indices[last])
  
    let meta = self.meta
    meta.signature.del(meta.signature.find(storage.id))
    if meta.signature.len == 0:
      for e in meta.childs:
        e.kill()
      empty(meta,meta.layer.ecs,self)
    else:
      changeEntity(self,storage.id)

  proc init_storage(_: typedesc[T]): CompStorage[T] =
    result = CompStorage[T]()
    result.id = id_next_component
    result.compType = $T
    result.comps = newSeqOfCap[T](ENTS_MAX_SIZE)
    result.entities = newSeqOfCap[eid](ENTS_MAX_SIZE)
    genIndices(result.indices)
    result.actions = IStorage(cleanup: proc(st: CompStorageBase)=cleanup(T,st), remove: proc(self: eid)=removeById(T, self))
    storageid = result.id
  #init

  storage = init_storage(T)
  storages_local_t[0] = storage
  for i in 1..storages_local_t.high:
    let st = init_storage(T)
    storages_local_t[i] = st
  
  for ecs in ecslayers:
    ecs.storages.add(storage)
  
  a_layer_changed.add(ILayer(Change: proc (self: LayerId) = layerChanged(T,self)))

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


