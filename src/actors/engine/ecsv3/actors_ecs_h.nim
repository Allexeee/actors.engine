#{.experimental: "codeReordering".}
{.experimental: "dynamicBindSym".}
{.used.} 

import sets
import ../../actors_h

type
  ent* = tuple
    id  : int
    age : int
  entid* = int

  ents* {.acyclic.} = seq[ent]

  SystemEcs* = ref object
    operations*    : seq[Operation]
    ents_alive*    : HashSet[int]
    groups*        : seq[Group]
  
  Entity* {.packed.} = object
    dirty*            : bool        #dirty allows to set all components for a new entity in one init command
    age*              : int
    layer*            : LayerID
    parent*           : ent
    signature*        : set[uint16] 
    signature_groups* : set[uint16] # what groups are already used
    childs*           : seq[ent]
  
  Group* {.acyclic.} = ref object of RootObj
    id*               : uint16
    layer*            : LayerID
    signature*        : set[uint16]
    signature_excl*   : set[uint16]
    entities*         : seq[ent]


  ComponentMeta* {.packed.} = object
    id*         : uint16
    generation* : uint16
    bitmask*    : int
  
  StorageBase* {.acyclic.} = ref object of RootObj
    meta*      : ComponentMeta
    groups*    : seq[Group]
  
  Storage*[T] {.acyclic.} = ref object of StorageBase
    indices*    : seq[int] # sparse
    entities*   : seq[entid] # packed
    components* : seq[T]


# EntityIndices
# A sparse array
# Contains integers which are the indices in EntityList.
# The index (not the value) of this sparse array is itself the entity id.
# EntityList
# A packed array
# Contains integers - which are the entity ids themselves
# The index doesn't have inherent meaning, other than it must be correct from EntityIndices
# ComponentList
# A packed array
# Contains component data (of this pool type)
# It is aligned with EntityList such that the element at EntityList[N] has component data of ComponentList[N]

  CompType* = enum
    Object,
    Action
    
  OpKind* = enum
    Init
    Add,
    Remove,
    Kill
  
  Operation* {.packed.} = object
    kind*  : OpKind
    entity*: ent 
    arg*   : uint16


 #proc `[]`*[I: Ordinal;T](a: T; i: I): T {.
#@extensions
proc `[]`*[I: Ordinal;T: Group](self: T; i: I): ent =
  self.entities[i]

template none*(T: typedesc[ent]): ent =
  (0,0)

var storages* = newSeq[StorageBase]()
var layers* : array[16,SystemEcs]

proc ecs*(layerID: LayerID): var SystemEcs {.inline, used.} =
  layers[layerID.uint]



proc makeStorage*[t](): Storage[t] =
  result = Storage[t]()
  result.components = newSeq[t]()
  result.indices  = newSeq[int](4096)
  result.entities = newSeq[entid]()
  result.groups = newSeqOfCap[Group](32)

# proc ecs*(lid: LayerId): SystemEcs {.inline.} =
#   layers[lid.int]

template meta*(self: ent): ptr Entity =
  ents_meta[self.id].addr

proc addEcs*(layerID: LayerID) =
  #layers[layerID.uint] = SystemEcs()
  let ecs = layers[layerID.uint].addr
  ecs[] = SystemEcs()
  ecs.operations = newSeq[Operation]()
  ecs.groups = newSeq[Group]()

# proc len*(self:Group): int =
#   if self.entities.isNil: 0
#   else: self.entities[].len

a_layer_added.add(addEcs)
#   EntityIndices
# A sparse array
# Contains integers which are the indices in EntityList.
# The index (not the value) of this sparse array is itself the entity id.
# EntityList
# A packed array
# Contains integers - which are the entity ids themselves
# The index doesn't have inherent meaning, other than it must be correct from EntityIndices
# ComponentList
# A packed array
# Contains component data (of this pool type)
# It is aligned with EntityList such that the element at EntityList[N] has component data of ComponentList[N]