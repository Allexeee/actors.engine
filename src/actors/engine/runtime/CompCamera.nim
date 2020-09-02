import ../actors_ecs
import ../actors_math
import CompTransform

type Camera* = ent

type CompCamera* = object
  projection* : Matrix
  size*       : float
  main*       : bool

ecsAdd CompCamera

proc newCamera*(): Camera =
  ecsEntity:
    let ccamera = e.get CCamera
    let ctr = e.get CTransform
    ccamera.main = true
    ctr.model.identity()
    result = e


proc ortho*(self: Camera, w,h,min,max: float) =
  self.ccamera.projection.ortho(-w,w,-h,h,min,max)