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

import ../../actors_utils
#import ../../actors_header

type #@ecs
  ent* = tuple
    id  : uint32
    age : uint32
 # System* = ref object of RootObj
 # Layer* = ref object of RootObj
  
  lid* = uint32

  SystemEcs* = ref object
    operations*    : seq[Operation]
    ents_alive*    : HashSet[uint32]
    groups*        : seq[Group]
  
  Entity* {.packed.} = object
    dirty*            : bool        #dirty allows to set all components for a new entity in one init command
    age*              : uint32
    layer*            : lid
    parent*           : ent
    signature*        : set[uint16] 
    signature_groups* : set[uint16] # what groups are already used
    childs*           : seq[ent]
  
  Group* = ref object of RootObj
    id*               : uint16
    layer*            : lid
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


