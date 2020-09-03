{.used.}

import engine/actors_ecs
import engine/actors_input
import engine/actors_math
import engine/actors_platform
import engine/actors_time
import engine/actors_ui
import engine/actors_runtime

export actors_ecs
export actors_input
export actors_math
export actors_platform
export actors_time
export actors_ui
export actors_runtime


proc release*()=
  actors_platform.target.releaseImpl()