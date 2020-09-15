{.used.}

import engine/px_ecs
import engine/actors_input
import engine/actors_math
import engine/actors_platform
import engine/actors_time
import engine/actors_ui
import engine/actors_runtime

export px_ecs
export actors_input
export actors_math
export actors_platform
export actors_time
export actors_ui
export actors_runtime

proc engineInit*() =
  actors_platform.targetInit()
  actors_platform.rendererInit()

proc release*()=
  actors_platform.targetRelease()
  actors_platform.rendererRelease()