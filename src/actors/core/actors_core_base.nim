{.experimental: "codeReordering".}

type #@tactions
 Action*     = proc(){.nimcall.}
 ActionT*[T] = proc(arg: T){.nimcall.}

type #@tindexes
  IndexScene*    = distinct int
  IndexApplayer* = distinct int

type #@tobjects 
  ObjectEvents* = tuple[start: Action, tick: ActionT[float], stop: Action] 
  Object* = object
  Actor* = object
     events*: ObjectEvents
  
type #@toperations
  OpKind* = enum
    ChangeScene
  Operation* = object
    case kind*: OpKind
    of ChangeScene:
      cs_id_layer*: int
      cs_id_scene*: int

type #@tlayers
  Layer* = distinct int  
  AppLayerState* {.pure, size: int.sizeof.} = enum
    Visible, Hidden
  AppLayer* = object
    id*: int
    state*: AppLayerState
    scene*: ptr Actor

type Display* = object

proc `+` *(a, b: Layer): Layer {.borrow.}