import ../../actors_h

const ENTS_INIT_SIZE* = 100_000_0
const GROW_SIZE* = 256

type
  ent* = tuple[id: int, age: int]
  
  eid* = distinct int
  
  Ent* = ent
 
  cid*   = uint16
   
  EntityMeta* = object
    layer*            : LayerID
    childs*           : seq[ent]
    parent*           : ent
    age*              : int
    signature*        : seq[cid]
    signature_groups* : seq[cid] # what groups are already used
    dirty*            : bool
    alive*            : bool
 
  SystemEcs* = ref object
    groups*        : seq[Group]
    operations*    : seq[Operation]
    layer*         : LayerId
  
  Group* = ref object of RootObj
    id*               : cid
    layer*            : LayerID
    ecs*              : SystemEcs
    signature*        : seq[cid]
    signature_excl*   : seq[cid]
    indices*          : seq[int]
    entities*         : seq[ent]
 
  IStorage* = object
    destroy*: proc (self: ent)
    cleanup*: proc (st: CompStorageBase)
 
  CompStorageBase* = ref object of RootObj
     compType*     : string
     groups*       : seq[Group]
     id*           : cid
     indices*      : seq[int] # sparse 
     entities*     : seq[ent] # packed
     filterid*     : int
     actions*      : IStorage
 
  CompStorage*[T] = ref object of CompStorageBase
     comps*      : seq[T]
 
  OpKind* = enum
    Init,
    Add,
    Remove,
    Kill
  
  Operation* {.packed.} = object
    kind*  : OpKind
    entity*: ent 
    arg*   : uint16


var metas*      = newSeq[EntityMeta](ENTS_INIT_SIZE)

var ents_free*  = newSeqOfCap[ent](256)
var layers*     = newSeq[SystemEcs](12)
var storages*   = newSeq[ptr seq[CompStorageBase]]()
var allgroups*  = newSeq[Group]()
converter toEnt*(x: eid): ent =
  (x.int,metas[x.int].age)

template `nil`*(T: typedesc[ent]): ent =
  (int.high,0)
template ecs*(lid: LayerId): SystemEcs =
  layers[lid.int]
template meta*(self: ent): ptr EntityMeta =
  metas[self.id].addr
template layer*(self: ent): LayerId  =
  let meta = self.meta
  meta.layer
  
proc addEcs*(layerID: LayerID) =
  let ecs = layers[layerID.uint].addr
  ecs[] = SystemEcs()
  ecs.layer = layerID
  ecs.groups = newSeq[Group]()
  #ecs.entids = newSeq[int](ENTS_INIT_SIZE)
  ecs.operations = newSeqOfCap[Operation](ENTS_INIT_SIZE)


a_layer_added.add(addEcs)