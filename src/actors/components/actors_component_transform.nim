import ../actors_engine

type ComponentTransform* = object
  model* : Matrix
  pos*   : Vec
  scale* : Vec


ecs.add ComponentTransform


proc pos*(e: ent): ptr Vec =
  addr e.ctransform.pos

proc scale*(e: ent): ptr Vec =
  addr e.ctransform.scale