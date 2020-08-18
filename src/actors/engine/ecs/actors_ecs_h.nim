import tables
import ../../actors_h



const ENTS_MAX_SIZE* = 1_000_000
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
     entities*     : seq[eid] # packed
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
var available*  = ENTS_MAX_SIZE
var layers*     = newSeq[SystemEcs](12)
var storages*   = newSeq[ptr seq[CompStorageBase]]()
var allgroups*  = newSeq[Group]()

var groups_table* = newTable[int,Group]()
var groups_table_exclude* = newTable[int,Group]()
var groups_table_with_exclude* = newTable[int,TableRef[int,Group]]()

converter toEnt*(x: eid): ent =
  (x.int,entities[x.int].age)
converter toEid*(x: ent): eid =
  x.id.eid

template id*(self: eid): int =
  self.int

template `nil`*(T: typedesc[ent]): ent =
  (int.high,0)

template ecs*(lid: LayerId): SystemEcs =
  layers[lid.int]

proc meta*(self: ent): ptr EntityMeta {.inline.} =
  metas[self.id].addr
proc meta*(self: eid): ptr EntityMeta {.inline.} =
  metas[self.int].addr
proc layer*(self: ent): LayerId {.inline.} =
  self.meta.layer

proc addEcs*(layerID: LayerID) =
  var ecs = layers[layerID.uint].addr
  ecs[] = SystemEcs()
  ecs.layer = layerID
  ecs.groups = newSeq[Group]()
  ecs.operations = newSeqOfCap[Operation](ENTS_MAX_SIZE)


for i in 0..<ENTS_MAX_SIZE:
  entities[i].id = i
  entities[i].age = 1
  metas[i].signature        = newSeqOfCap[cid](8)
  metas[i].signature_groups = newSeqOfCap[cid](4)
  metas[i].dirty = true
  


a_layer_added.add(addEcs)