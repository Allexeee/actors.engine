import actors_ecs_h

when defined(debug):
  type
    EcsError* = object of ValueError

template check_error_remove_component(this: ent, t: typedesc): untyped {.used.}=
  when defined(debug):
    let arg1 {.inject.} = t.name
    let arg2 {.inject.} = this.id
    if t.Id notin entities[this.id].signature:
      log_external fatal, &"You are trying to remove a {arg1} that is not attached to entity with id {arg2}"
      raise newException(EcsError,&"You are trying to remove a {arg1} that is not attached to entity with id {arg2}")

template check_error_release_empty(this: ent): untyped {.used.}=
  when defined(debug):   
    let arg1 {.inject.} = this.id
    if entities[this.id].signature.card == 0:
      log_external fatal, &"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically."
      raise newException(EcsError,&"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically.")
