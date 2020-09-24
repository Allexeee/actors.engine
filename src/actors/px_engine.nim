{.used.}

import engine/px_ecs
import engine/px_input
import engine/px_math
import engine/px_platform
import engine/px_ui
import engine/px_runtime

export px_ecs
export px_input
export px_math
export px_platform
export px_ui
export px_runtime

proc engine_init*() =
  px_platform.target_init()
  px_platform.render_init()

proc release*()=
  px_platform.target_release()
  #px_platform.rendererRelease()