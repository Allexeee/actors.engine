import ../../../vendor/actors_gl

type ModeFilter* = enum
  Linear = GL_LINEAR
  Nearest = GL_REPEAT

type ModeWrap* = enum
  Repeat = GL_REPEAT
  ClampToBorder = GL_CLAMP_TO_BORDER
  ClampToEdge = GL_CLAMP_TO_EDGE
  RepeatMirrored = GL_MIRRORED_REPEAT

type ModeRGB* = enum
  Rgba = GL_RGBA
  Rgb  = GL_RGB8
  
 