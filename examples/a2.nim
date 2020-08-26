import actors
import macros

type SegA {.final.} = object
  arg: int
type CompA {.final.} = object
  arg: int
type CompB {.final.} = object
  arg: int
type CompC {.final.} = object
  arg: int
type CompD {.final.} = object
  arg: int
type CompF {.final.} = object
  arg: int

ecs.init 1_000_000

ecs.add CompA
ecs.add CompB



