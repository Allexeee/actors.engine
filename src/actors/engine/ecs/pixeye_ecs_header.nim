{.experimental: "codeReordering".}
{.experimental: "dynamicBindSym".}
{.used.} 

import sets
import macros
import strformat
import strutils
import times
import tables
import sets
import hashes
import typetraits 
import math


type
  ent* = tuple
    id  : uint32
    age : uint32
  
  SystemEcs* = ref object
    operations*    : seq[Operation]
    ents_alive*    : HashSet[uint32]
    groups*        : seq[Group]
  
  Entity* {.packed.} = object
    dirty*            : bool        #dirty allows to set all components for a new entity in one init command
    age*              : uint32
    layer*            : uint32
    parent*           : ent
    signature*        : set[uint16] 
    signature_groups* : set[uint16] # what groups are already used
    childs*           : seq[ent]
  
  Group* = ref object of RootObj
    id*               : uint16
    layer*            : uint32
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

when defined(debug):
  type
    EcsError* = object of ValueError
    EcsErrorTypedAction* = proc(self: ent, t: typedesc)
    EcsErrorAction* = proc(self: ent)


#@extensions

proc addNew [T](this: var seq[T]): ptr T {.inline.} =
    this.add(T())
    addr this[this.high]
proc addNewRef [T](this: var seq[T]): var T {.inline.} =
    this.add(T())
    this[this.high]