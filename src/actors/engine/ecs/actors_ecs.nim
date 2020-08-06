# Implementation
include pixeye_ecs

import ../../actors_header
import ../../actors_utils

# Debug Implementation

action_check_error_remove_component = impl_ecs_check_error_remove_component
action_check_error_release_empty    = impl_ecs_check_error_release_empty

proc impl_ecs_check_error_remove_component(self: ent, t: typedesc) =
    let arg1 {.inject.} = t.name
    let arg2 {.inject.} = self.id
    if t.Id notin entities[self.id].signature:
      log_external fatal, &"You are trying to remove a {arg1} that is not attached to entity with id {arg2}"
      raise newException(EcsError,&"You are trying to remove a {arg1} that is not attached to entity with id {arg2}")
proc impl_ecs_check_error_release_empty(self: ent) =
    let arg1 {.inject.} = self.id
    if entities[self.id].signature.card == 0:
      log_external fatal, &"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically."
      raise newException(EcsError,&"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically.")


# Actors API
proc entity*(layerID: LayerID): ent {.inline, discardable.} =
  impl_entity(layerID.uint32)


template add*(self: App, component: untyped, compType: CompType = Object) =
  add(component,compType)

