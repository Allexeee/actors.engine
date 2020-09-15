{.used.}

import engine/px_ecs
import engine/actors_input
import engine/px_math
import engine/actors_platform
import engine/actors_time
import engine/actors_ui
import engine/px_runtime

export px_ecs
export actors_input
export px_math
export actors_platform
export actors_time
export actors_ui
export px_runtime

proc engineInit*() =
  actors_platform.targetInit()
  actors_platform.rendererInit()

proc release*()=
  actors_platform.targetRelease()
  actors_platform.rendererRelease()