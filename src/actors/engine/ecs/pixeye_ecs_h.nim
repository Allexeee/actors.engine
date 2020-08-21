import ../../actors_h

const ENTS_MAX_SIZE* = 1_000_000

type
  ent* = tuple[id: int, age: int]
  
  eid* = distinct int
  
  cid*   = uint16
 
  Ent* = ent
   
  EntityMeta* = object
    ecs*              : LayerEcs
    childs*           : seq[eid]
    signature*        : seq[cid]
    signature_groups* : seq[cid] # what groups are already used
    parent*           : eid
 
  LayerEcs* = ref object
    layer*         : LayerId
    groups*        : seq[Group]
    storages*      : seq[CompStorageBase]
  
  Group* = ref object of RootObj
    id*               : cid
    layer*            : LayerID
    ecs*              : LayerEcs
    signature_mask*        : set[cid]
    signature_excl_mask*   : set[cid]
    signature*       : seq[cid]
    signature_excl*  : seq[cid]
    indices*          : seq[int]
    entities*         : seq[eid]
 
  IStorage* = object
    remove*: proc (self: eid)
    cleanup*: proc (st: CompStorageBase)
 
  CompStorageBase* = ref object of RootObj
     compType*     : string
     groups*       : seq[Group]
     id*           : cid
     indices*      : seq[int] # sparse 
     entities*     : seq[eid] # packed
     filterid*     : int
     actions*      : IStorage
 
  CompStorage*[T] = ref object of CompStorageBase
     comps*      : seq[T]


var dirty*      = false

var metas*      = newSeq[EntityMeta](ENTS_MAX_SIZE)
var entities*   = newSeq[ent](ENTS_MAX_SIZE)
var available*  = ENTS_MAX_SIZE
var ecslayers*  = newSeqOfCap[LayerEcs](6)
#var storages*  = newSeq[ptr seq[CompStorageBase]]()
var allgroups*  = newSeq[Group]()
var  sssignature*        = newSeq[cid](24)
var slen* = 0

converter toEnt*(x: eid): ent =
  (x.int,entities[x.int].age)

converter toEid*(x: ent): eid =
  x.id.eid

template id*(self: eid): int =
  self.int

template `nil`*(T: typedesc[ent]): ent =
  (int.high,0)

template ecs*(lid: LayerId): LayerEcs =
  ecslayers[lid.int]
template ecs*(self: ent|eid): LayerEcs =
   metas[self.id].ecs

proc meta*(self: ent): ptr EntityMeta {.inline.} =
  metas[self.id].addr

proc meta*(self: eid): ptr EntityMeta {.inline.} =
  metas[self.int].addr

proc layer*(self: ent): LayerId {.inline.} =
  self.meta.ecs.layer

proc addEcs*(layerID: LayerID) =
  let ecs = LayerEcs()
  ecslayers.add(ecs)
  ecs.layer = layerID
  ecs.groups = newSeq[Group]()
  ecs.storages = newSeq[CompStorageBase]()

for i in 0..<ENTS_MAX_SIZE:
  entities[i].id = i
  entities[i].age = 1
  metas[i].ecs = nil
  metas[i].signature        = newSeqOfCap[cid](8)
  metas[i].signature_groups = newSeqOfCap[cid](4)
  

a_layer_added.add(addEcs)