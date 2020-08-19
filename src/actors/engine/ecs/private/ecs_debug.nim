import ../actors_ecs_h

when defined(debug):
  type
    EcsError* = object of ValueError

template check_error_remove_component*(this: ent, t: typedesc): untyped {.used.}=
  when defined(debug):
    let arg1 {.inject.} = $t
    let arg2 {.inject.} = this.id
    let id = t.id.int
    var valid {.inject.} = false
    for i in 0..metas[this.id].signature.high:
      if id == i:
        valid = true; break;

    if not valid:
      echo "Fsfdsfdsfsd"
      log_external fatal, &"You are trying to remove a {arg1} that is not attached to entity with id {arg2}"
      raise newException(EcsError,&"You are trying to remove a {arg1} that is not attached to entity with id {arg2}")

template check_error_release_empty*(this: ent): untyped {.used.}=
  when defined(debug):   
    let arg1 {.inject.} = this.id
    if metas[this.id].signature.len == 0:
      log_external fatal, &"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically."
      raise newException(EcsError,&"You are trying to release an empty entity with id {arg1}. Entities without any components are released automatically.")
