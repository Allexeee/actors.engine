{.used.}
type Action*     = proc(){.nimcall.}
type ActionT*[T] = proc(arg: T){.nimcall.}

type Layer* = distinct int

proc `+` *(a, b: Layer): Layer {.borrow.}
# type IndexScene*    = distinct int
# type IndexApplayer* = distinct int

# type Layer* = distinct int


  
# type #@toperations
#   OpKind* = enum
#     ChangeScene
#   Operation* = object
#     case kind*: OpKind
#     of ChangeScene:
#       cs_id_layer*: int
#       cs_id_scene*: int

# type #@tlayers
#   Layer* = distinct int  
#   AppLayerState* {.pure, size: int.sizeof.} = enum
#     Visible, Hidden
#   AppLayer* = object
#     id*: int
#     state*: AppLayerState
#     scene*: ptr Actor

#type Display* = object

#proc `+` *(a, b: Layer): Layer {.borrow.}