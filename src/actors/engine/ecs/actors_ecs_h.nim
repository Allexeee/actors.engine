import ../../actors_h

const ENTS_MAX_SIZE* = 100_000_0
#const ENTS_MAX_SIZE* = ENTS_INIT_SIZE - 1
#const GROW_SIZE* = 256

type
  ent* = tuple[id: int, age: int]
  
  eid* = distinct int
  
  Ent* = ent
 
  cid*   = uint16
   
  EntityMeta* = object
    dirty*            : bool
    layer*            : LayerID
    childs*           : seq[eid]
    signature*        : seq[cid]
    signature_groups* : seq[cid] # what groups are already used
    parent*           : eid
 
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
    entities*         : seq[eid]
 
  IStorage* = object
    destroy*: proc (self: eid)
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
    entity*: eid 
    arg*   : uint16

var metas*      = newSeq[EntityMeta](ENTS_MAX_SIZE)

var entities*   = newSeq[ent](ENTS_MAX_SIZE)
var available*  = ENTS_MAX_SIZE.high
var layers*     = newSeq[SystemEcs](12)
var storages*   = newSeq[ptr seq[CompStorageBase]]()
var allgroups*  = newSeq[Group]()

converter toEnt*(x: eid): ent =
  (x.int,entities[x.int].age)
converter toEid*(x: ent): eid =
  x.id.eid

template `nil`*(T: typedesc[ent]): ent =
  (int.high,0)
template ecs*(lid: LayerId): SystemEcs =
  layers[lid.int]

template meta*(self: ent): ptr EntityMeta =
  metas[self.id].addr

template meta*(self: eid): ptr EntityMeta =
  metas[self.int].addr
template layer*(self: ent): LayerId  =
  let meta = self.meta
  meta.layer
var eca* : SystemEcs
proc addEcs*(layerID: LayerID) =
  var ecs = layers[layerID.uint].addr
  ecs[] = SystemEcs()
  ecs.layer = layerID
  ecs.groups = newSeq[Group]()
  ecs.operations = newSeqOfCap[Operation](ENTS_MAX_SIZE)
  eca = ecs[] 


for i in 0..<ENTS_MAX_SIZE:
  entities[i].id = i
  entities[i].age = 1
  #metas[i].signature.setLen(0) 
 # metas[i].signature_groups.setLen(0)

a_layer_added.add(addEcs)