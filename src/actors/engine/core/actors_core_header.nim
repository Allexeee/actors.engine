# type System* = ref object of RootObj
#     layer* : Layer

# type 
#   SystemUpdate* = ref object of System
#    ticks* : seq[ITick]
#   SystemTime* = ref object of System
#     scale*      : float32
#   Layer* = ref object of RootObj
#     update* : SystemUpdate
#     ecs*    : SystemEcs
#     time*   : SystemTime