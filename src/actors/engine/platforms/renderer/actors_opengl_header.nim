{.used.}

import ../../../actors_engine_internal
import ../../../actors_utils
import ../../../actors_vendor

import ../../actors_types
import ../../actors_math

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


const vert_default: cstring = """
    #version 330 core
    layout (location = 0) in vec3 aPos;
    void main()
    {
        gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    } """
const frag_default: cstring = """
    #version 330 core
    out vec4 FragColor;
    void main()
    {
        FragColor=vec4(1,.5f,.2f,1);
    } """


