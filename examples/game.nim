import actors
import macros

type CompA {.final.} = object
  arg: int

ecs.init 1_000_000

ecs.add CompA



