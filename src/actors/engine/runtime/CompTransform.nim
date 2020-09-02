import ../actors_ecs
import ../actors_math

type CompTransform* = object
  pos*   : Vec
  model* : Matrix

ecsAdd CompTransform
template `x`*(self:ent): var float32 =
  self.ctransform.pos.x
template `x=`*(self:ent, arg: float): untyped =
  self.ctransform.pos.x = arg
template `x+=`*(self:ent, arg: float): untyped =
  self.ctransform.pos.x = arg
template `x-=`*(self:ent, arg: float): untyped =
  self.ctransform.pos.x = arg

template `y`*(self:ent): var float32 =
  self.ctransform.pos.y
template `y=`*(self:ent, arg: float): untyped =
  self.ctransform.pos.y = arg
template `y+=`*(self:ent, arg: float): untyped =
  self.ctransform.pos.y = arg
template `y-=`*(self:ent, arg: float): untyped =
  self.ctransform.pos.y = arg
# template `x+=`*(self:ent, arg: float): untyped =
#   self.ctransform.pos.x = arg
  # var v = self.ctransform.pos
  # v.x = arg.float32
  # self.ctransform.pos = v
  #self.ctransform.pos.x = a.float32
