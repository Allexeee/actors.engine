{.used.}
{.experimental: "codeReordering".}


import tables
import sets

type System* = ref object of RootObj
    layer* : Layer

type #@ecs
  ent* = tuple
    id  : uint32
    age : uint32

  SystemEcs* = ref object of System
    operations*    : seq[Operation]
    ents_alive*    : HashSet[uint32]
    groups*        : seq[Group]
  
  Entity* {.packed.} = object
    dirty*            : bool        #dirty allows to set all components for a new entity in one init command
    age*              : uint32
    layer*            : Layer
    parent*           : ent
    signature*        : set[uint16] 
    signature_groups* : set[uint16] # what groups are already used
    childs*           : seq[ent]
  
  Group* = ref object of RootObj
    id*               : uint16
    layer*            : Layer
    signature*        : set[uint16]
    signature_excl*   : set[uint16]
    entities*         : seq[ent]
    added*            : seq[ent]
    removed*          : seq[ent]
    events*           : seq[proc()]
  
  ComponentMeta {.packed.} = object
    id*        : uint16
    generation* : uint16
    bitmask*    : int
  
  StorageBase* = ref object of RootObj
    meta*      : ComponentMeta
    groups*    : seq[Group]
  
  Storage*[T] = ref object of StorageBase
    entities*  : Table[uint32, int]
    container* : seq[T]
    
  OpKind* = enum
    Init
    Add,
    Remove,
    Kill
  
  Operation* {.packed.} = object
    kind*  : OpKind
    entity*: ent 
    arg*   : uint16

type #@layer
  SystemUpdate* = ref object of System
    ticks* : seq[ITick]
  
  SystemTime* = ref object of System
    deltaCap*  : float
    scale*      : float

  Layer* = ref object of RootObj
    update* : SystemUpdate
    ecs*    : SystemEcs
    time*   : SystemTime

type #@interfaces
  ITick* = object
    tick*: proc (layer: Layer)
  IDispose* = object
    dispose*: proc()

type #@app
  AppSettings* = object
    name*      : string
    fps*       : float32
    display_size* : tuple[width: int, height: int]
    screen_size*  : tuple[width: int, height: int]
    path_shaders* : string
    path_assets*  : string

  App* = ref object
    settings*  : AppSettings
    layers*    : seq[Layer]


# type App* = ref object
#   settings*: AppSettings
#   input*   : InputIndex
#   #private
#   inputs   : seq[Input]

# let app* = App()
# app.input = addInput()

# proc getApp*(): App {.inline.} = app