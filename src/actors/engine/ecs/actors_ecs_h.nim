import ../../actors_h

const ENTS_INIT_SIZE* = 5000
const GROW_SIZE* = 256

type
  ent* = tuple[id: int, age: int]
  Ent* = ent
  entid* = distinct int
  cid*   = uint16

  EntityMeta* = object
    layer*            : LayerID
    childs*           : seq[ent]
    parent*           : ent
    alive*            : bool
    age*              : int
    signature*        : set[cid] 
    signature_groups* : set[cid] # what groups are already used
    dirty*            : bool

  SystemEcs* = ref object
    groups*        : seq[Group]
    operations*    : seq[Operation]
    entids*        : seq[int]
  
  Group* = ref object of RootObj
    id*               : cid
    layer*            : LayerID
    signature*        : set[cid]
    signature_excl*   : set[cid]
    signature2*        : seq[cid]
    signature_excl2*   : seq[cid]
    indices*          : seq[int]
    entities*         : seq[ent]

  IStorage* = object
    destroy*: proc (self: ent)

  
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

template `nil`*(T: typedesc[ent]): ent =
  (int.high,0)

proc `$`*(self: ent): string =
    $self.id

var e = ent.nil

var metas*   = newSeqOfCap[EntityMeta](ENTS_INIT_SIZE)
var ents_free*  = newSeqOfCap[ent](ENTS_INIT_SIZE)
var layers*     = newSeq[SystemEcs](32)
var storages*   = newSeq[CompStorageBase]()
var allgroups*  = newSeq[Group]()



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
  ecs.groups = newSeq[Group]()
  ecs.entids = newSeq[int]()
  ecs.operations = newSeqOfCap[Operation](1024)

a_layer_added.add(addEcs)