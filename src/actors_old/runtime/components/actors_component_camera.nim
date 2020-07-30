{.used.}

import ../../a_engine
import actors_component_transform

type ComponentCamera* = object
  view*       : Matrix
  projection* : Matrix
  fov*        : float32
  zoom*       : float32
  shaders*    : seq[ShaderIndex]


ecs.add ComponentCamera


var lr_ecs_cameras* = ecs.addLayer()


proc newCamera*(): ent =
  result = entity(lr_ecs_main)
  result.add ComponentCamera
  result.add ComponentTransform
