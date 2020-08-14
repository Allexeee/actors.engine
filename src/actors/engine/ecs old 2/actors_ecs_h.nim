import ../../actors_h

const ENTS_INIT_SIZE* = 102048

type
  ent* = tuple[id: int, age: int]
  entid* = distinct int
  cid*   = uint16
  ecsid* = distinct int

  EntityMeta* = object
    layer*            : LayerID
    childs*           : seq[ent]
    alive*            : bool
    age*              : int
    signature*        : seq[cid] 
    signature_groups* : seq[int] # what groups are already used
    dirty*            : bool

  SystemEcs* = ref object
    groups*        : seq[Group]
    operations*    : seq[Operation]
    entids*        : seq[int]
  
  Group* = ref object of RootObj
    id*               : int
    layer*            : LayerID
    signature*        : set[cid] 
    signature_excl*   : set[cid] 
    entities*         : ptr seq[ent]

  IStorage* = object
    destroy*: proc (self: ent)

  
  CompStorageBase* = ref object of RootObj
     compType*     : string
     groups*       : seq[Group]
     id*           : cid
     indices*      : seq[int] # sparse 
     entities*     : seq[ent] # packed
     filterid*     : int
     istorage*     : IStorage
     
  
  CompStorage*[T] = ref object of CompStorageBase
     comps*      : seq[T]
  
  OpKind* = enum
    Init
    
  Operation* {.packed.} = object
    kind*  : OpKind
    entity*: ent 
    arg*   : uint16

template none*(T: typedesc[ent]): ent =
  (int.high,0)

proc `$`*(self: ent): string =
    $self.id


var ents_meta*  = newSeqOfCap[EntityMeta](ENTS_INIT_SIZE)
var ents_free*  = newSeqOfCap[ent](ENTS_INIT_SIZE)
var layers*     = newSeq[SystemEcs](32)
var storages*   = newSeq[CompStorageBase]()

proc ecs*(lid: LayerId): SystemEcs {.inline.} =
  layers[lid.int]

proc addEcs*(layerID: LayerID) =
  let ecs = layers[layerID.uint].addr
  ecs[] = SystemEcs()
  ecs.groups = newSeq[Group]()
  ecs.entids = newSeq[int]()
  ecs.operations = newSeqOfCap[Operation](256)

proc len*(self:Group): int =
  if self.entities.isNil: 0
  else: self.entities[].len

a_layer_added.add(addEcs)



