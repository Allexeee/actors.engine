{.used.}
import os
import strformat

import ../../actors_types
import ../../../vendor/actors_gl
import ../../../actors_utils
import ../../actors_math

#from   ../../ import app

type ShaderIndex* = distinct uint32

type ShaderCompileType   = enum
  VERTEX = 0,
  FRAGMENT,
  GEOMETRY,
  PROGRAM
type ShaderLoadError*    = object of ValueError
type ShaderCompileError* = object of ValueError


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


template `$`*(this: ShaderIndex): uint32 =
  this.uint32

template checkErrorShaderCompile(obj: uint32, errType: ShaderCompileType): untyped =
    when defined(debug):
        block:
            let error {.inject.} = $errType
            var success {.inject.}: Glint
            var messageBuffer {.inject.} = newSeq[cchar](1024)
            var len {.inject.} : int32 = 0
            if errType == PROGRAM:
                glGetProgramiv(obj, GL_LINK_STATUS, success.addr)
                if success != GL_TRUE.ord:
                    glGetProgramInfoLog(obj, 1024, len.addr, messageBuffer[0].addr)
                    var message {.inject.}= ""
                    if len!=0:
                        message = toString(messageBuffer,len)
                    log fatal, &"Type: {error}", &"Message: {message}"
                    raise newException(ShaderCompileError, &"Type: {error}")
            else:
                glGetShaderiv(obj, GL_COMPILE_STATUS, success.addr);
                if success != GL_TRUE.ord:
                    glGetShaderInfoLog(obj, 1024, len.addr, messageBuffer[0].addr)
                    var message {.inject.}= ""
                    if len!=0:
                        message = toString(messageBuffer,len)
                    log fatal, &"Type: {error}", &"Message: {message}"
                    raise newException(ShaderCompileError, &"Type: {error}")

proc shader*(app: App, shader_path: string): ShaderIndex =    
    var path: string
    var vertCode = vertDefault
    var fragCode = fragDefault
    var geomCode = default(cstring)
    var id : uint32 = 0
    ##read
    ##vertex
    path = app.settings.path_shaders & shader_path & ".vert"
    if not fileExists(path):
        log warn, &"The path {path} for vertex shader doesn't exist", "Adding a default shader"
    else:
        vertCode = readFile(path)
    ##fragment
    path = app.settings.path_shaders & shader_path & ".frag"
    if not fileExists(path):
        log warn, &"The path {path} for fragment shader doesn't exist", "Adding a default shader"
    else:
        fragCode = readFile(path)
    ##geometry
    path = app.settings.path_shaders & shader_path & ".geom"
    if fileExists(path):
        geomCode = readFile(path)

    ##compile
    var vertex : Gluint = 0
    var fragment: Gluint = 0
    var geom: GLuint = 0
    ##vertex
    vertex = glCreateShader(GL_VERTEX_SHADER)
    glShaderSource(vertex,1, cast[cstringArray](vert_code.addr), nil)
    glCompileShader(vertex)
    checkErrorShaderCompile(vertex, VERTEX)
    ##fragment
    fragment = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(fragment,1'i32,cast[cstringArray](frag_code.addr), nil)
    glCompileShader(fragment)
    checkErrorShaderCompile(fragment, FRAGMENT)
    ##geom
    if geom_code!=default(cstring):
       geom = glCreateShader(GL_GEOMETRY_SHADER)
       glShaderSource(geom, 1'i32, cast[cstringArray](geom_code.addr), nil)
       glCompileShader(geom)
       checkErrorShaderCompile(geom, GEOMETRY)
    ##program
    id = glCreateProgram()
    glAttachShader(id,vertex)
    glAttachShader(id,fragment)
    if geom_code!=default(cstring):
        glAttachShader(id,geom)
    glLinkProgram(id)
    checkErrorShaderCompile(id, PROGRAM)
    glDeleteShader(vertex)
    glDeleteShader(fragment)
    result = id.ShaderIndex

proc use*(this: ShaderIndex) {.inline.} =
  glUseProgram(this.GLuint) 
#cast[ptr Glvoid](cfloat.sizeof*9)
proc setSampler*(this: ShaderIndex, name: cstring, count: GLsizei, arg: ptr uint32) {.inline.} =
   glUniform1iv(glGetUniformLocation(this.GLuint,name),count, cast[ptr Glint](arg))

proc setBool*(this: ShaderIndex, name: cstring, arg: bool) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform1i(glGetUniformLocation(this.GLuint,name),arg.Glint)

proc setInt*(this: ShaderIndex, name: cstring, arg: int) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform1i(glGetUniformLocation(this.GLuint,name),arg.Glint)

proc setFloat*(this: ShaderIndex, name: cstring, arg: float32) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform1f(glGetUniformLocation(this.GLuint,name),arg)

proc setVec*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform4f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z,arg.w)

proc setVec3*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform3f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z)

proc setColor*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
  ## dont forget to set use before changing shader
  glUniform4f(glGetUniformLocation(this.GLuint,name),arg.x,arg.y,arg.z,arg.w)

proc setMatrix*(this: ShaderIndex, name: cstring, arg: var Matrix) {.inline.} =
  ## dont forget to set use before changing shader
  glUniformMatrix4fv(glGetUniformLocation(this.GLuint,name), 1, false, arg.e11.addr)

