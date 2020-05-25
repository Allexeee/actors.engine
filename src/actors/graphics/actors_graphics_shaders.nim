import ../actors_backend as backend
import ../actors_math
from ../actors_core import app


type
    ShaderIndex* = distinct uint32


template `$`*(this: ShaderIndex): uint32 =
    this.uint32

proc shader*(shaderName: string): ShaderIndex =
    backend.shaderNewImpl(app.settings.path_shaders & shaderName).ShaderIndex

proc use*(this: ShaderIndex) =
    backend.shaderUseImpl($this)

proc setBool*(this: ShaderIndex, name: cstring, arg: bool) {.inline.} =
    backend.shaderSetBoolImpl($this, name, arg)

proc setInt*(this: ShaderIndex, name: cstring, arg: int) {.inline.} =
    backend.shaderSetIntImpl($this, name, arg)

proc setFloat*(this: ShaderIndex, name: cstring, arg: float32) {.inline.} =
    backend.shaderSetFloatImpl($this, name, arg)

proc setColor*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
    backend.shaderSetVec4Impl($this, name, arg)

proc setMatrix*(this: ShaderIndex, name: cstring , arg: var Matrix) {.inline.} =
    backend.shader_set_matrix_impl($this, name, arg)

