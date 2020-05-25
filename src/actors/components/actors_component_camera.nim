import ../actors_engine
import actors_component_transform

type ComponentCamera* = object
  view*       : Matrix
  projection* : Matrix
  fov*        : float32
  zoom*       : float32


ecs.add ComponentCamera


var lr_ecs_cameras* = ecs.addLayer()


proc newCamera*(): ent =
  result = entity()
  result.add ComponentCamera
  result.add ComponentTransform
