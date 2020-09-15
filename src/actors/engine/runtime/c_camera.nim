import ../px_ecs
import ../actors_math
import c_transform

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