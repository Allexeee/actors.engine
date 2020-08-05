{.used.}

import ../../../vendor/actors_gl

type ARenum* = GLenum

const
  MODE_LINEAR*          : ARenum = GL_LINEAR
  MODE_NEAREST*         : ARenum = GL_NEAREST
  MODE_REPEAT*          : ARenum = GL_REPEAT
  MODE_CLAMP_TO_BORDER* : ARenum = GL_CLAMP_TO_BORDER
  MODE_CLAMP_TO_EDGE*   : ARenum = GL_CLAMP_TO_EDGE
  MODE_REPEAT_MIRRORED* : ARenum = GL_MIRRORED_REPEAT
  MODE_RGB*             : ARenum = GL_RGB8
  MODE_RGBA*            : ARenum = GL_RGBA
