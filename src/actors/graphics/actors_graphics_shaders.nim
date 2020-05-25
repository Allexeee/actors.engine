import ../actors_platform as platform
import ../actors_math
from ../actors_core import app


type
    ShaderIndex* = distinct uint32


template `$`*(this: ShaderIndex): uint32 =
    this.uint32

proc shader*(shaderName: string): ShaderIndex =
    platform.shaderNewImpl(app.settings.path_shaders & shaderName).ShaderIndex

proc use*(this: ShaderIndex) =
    platform.shaderUseImpl($this)

proc setBool*(this: ShaderIndex, name: cstring, arg: bool) {.inline.} =
    platform.shaderSetBoolImpl($this, name, arg)

proc setInt*(this: ShaderIndex, name: cstring, arg: int) {.inline.} =
    platform.shaderSetIntImpl($this, name, arg)

proc setFloat*(this: ShaderIndex, name: cstring, arg: float32) {.inline.} =
    platform.shaderSetFloatImpl($this, name, arg)

proc setColor*(this: ShaderIndex, name: cstring, arg: Vec) {.inline.} =
    platform.shaderSetVec4Impl($this, name, arg)

proc setMatrix*(this: ShaderIndex, name: cstring , arg: var Matrix) {.inline.} =
    platform.shader_set_matrix_impl($this, name, arg)

