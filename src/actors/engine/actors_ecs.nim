{.used.}
import ../actors_h
import ecs/pixecs as actors_ecs

ecsInit()

export actors_ecs

# template add*(app: App, component: untyped, mode: static[CompType] = CompType.AsComp): untyped =
#   add(ecs,component,mode)

# template init*(app: App, ecs: Ecs, size: int) =
#   ecs.init(size)