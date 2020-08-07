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

import ../../actors_h
import ../../actors_tools

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

template check_error_remove_component(this: ent, t: typedesc): untyped =
  when defined(debug):
    let arg1 {.inject.} = t.name
    let arg2 {.inject.} = this.id
    if t.Id notin entities[this.id].signature:
      log_external fatal, &"You are trying to remove a {arg1} that is not attached to entity with id {arg2}"
      raise newException(EcsError,&"You are trying to remove a {arg1} that is not attached to entity with id {arg2}")

template check_error_release_empty(this: ent): untyped =
  when defined(debug):   
    let arg1 {.inject.} = this.id
    if entities[this.id].signature.card == 0:
      log_external fatal, &"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically."
      raise newException(EcsError,&"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically.")


#@extensions

proc addNew[T](this: var seq[T]): ptr T {.inline.} =
    this.add(T())
    addr this[this.high]
proc addNewRef[T](this: var seq[T]): var T {.inline.} =
    this.add(T())
    this[this.high]