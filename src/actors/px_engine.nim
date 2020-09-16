{.used.}

import engine/px_ecs
import engine/px_input
import engine/px_math
import engine/actors_platform
import engine/px_ui
import engine/px_runtime

export px_ecs
export px_input
export px_math
export actors_platform
export px_ui
export px_runtime

proc engineInit*() =
  actors_platform.targetInit()
  actors_platform.rendererInit()

proc release*()=
  actors_platform.targetRelease()
  actors_platform.rendererRelease()