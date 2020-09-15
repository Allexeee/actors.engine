import px_ecs
import px_math

#-----------------------------------------------------------------------------------------------------------------------
#@ctransform
#-----------------------------------------------------------------------------------------------------------------------
type CompTransform* = object
  pos*   : Vec
  model* : Matrix

ecsAdd CompTransform

template `x` *(self:ent): var float32         = self.ctransform.pos.x
template `x=`*(self:ent, arg: float): untyped = self.ctransform.pos.x = arg
template `y` *(self:ent): var float32         = self.ctransform.pos.y


#-----------------------------------------------------------------------------------------------------------------------
#@ccamera
#-----------------------------------------------------------------------------------------------------------------------
type Camera* = ent
type CompCamera* = object
  projection* : Matrix
  size*       : float
  main*       : bool

ecsAdd CompCamera

proc getCamera*(): Camera =
  result = entGet():
    let ccamera = e.get CompCamera
    let ctr     = e.get CompTransform
    ccamera.main = true
    ctr.model.identity()
proc ortho*(self: Camera, w,h,min,max: float) =
  self.ccamera.projection.ortho(-w,w,-h,h,min,max)
