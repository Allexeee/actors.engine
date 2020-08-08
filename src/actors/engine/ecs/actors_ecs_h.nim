#{.experimental: "codeReordering".}
{.experimental: "dynamicBindSym".}
{.used.} 

import sets
import ../../actors_h

type
  ent* = tuple
    id  : uint32
    age : uint32

  ents* = seq[ent]

  SystemEcs* = ref object
    operations*    : seq[Operation]
    ents_alive*    : HashSet[uint32]
    groups*        : seq[Group]
  
  Entity* {.packed.} = object
    dirty*            : bool        #dirty allows to set all components for a new entity in one init command
    age*              : uint32
    layer*            : LayerID
    parent*           : ent
    signature*        : set[uint16] 
    signature_groups* : set[uint16] # what groups are already used
    childs*           : seq[ent]
  
  Group* = ref object of RootObj
    id*               : uint16
    layer*            : LayerID
    signature*        : set[uint16]
    signature_excl*   : set[uint16]
    entities*         : seq[ent]
    added*            : seq[ent]
    removed*          : seq[ent]
    events*           : seq[proc()]
  
  ComponentMeta* {.packed.} = object
    id*        : uint16
    generation* : uint16
    bitmask*    : int
  
  StorageBase* = ref object of RootObj
    meta*      : ComponentMeta
    groups*    : seq[Group]
  
  Storage*[T] = ref object of StorageBase
    entities*  : seq[int]
    container* : seq[T]
  
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


#@extensions
template none*(T: typedesc[ent]): untyped =
  (0'u32,0'u32)

var storages* = newSeq[StorageBase](1)
var layers* : array[16,SystemEcs]

proc ecs*(layerID: LayerID): var SystemEcs {.inline, used.} =
  layers[layerID.uint]