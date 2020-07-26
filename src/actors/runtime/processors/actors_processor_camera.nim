import ../../a_engine
import ../components/actors_component_camera
import ../components/actors_component_transform

type ProcessorCamera* = ref object

ecs.group cameras:
  comps: (ComponentCamera, ComponentTransform)
ecs.group transforms:
  comps: (ComponentTransform)

proc tick*(this: ProcessorCamera, dt: float) = 
  for entity in transforms:
    var ctransform = entity.ctransform
    ctransform.model.translate(ctransform.pos)

  for entity in cameras:
    var camera = entity.ccamera
    var transform = entity.ctransform
    var shader = camera.shaders[0]
    camera.view = transform.model
    #camera.projection
    
    shader.setMatrix("mx_view",camera.view)
    shader.setMatrix("mx_projection",camera.projection) 
    shader.use()
    #shaderDefault.setMatrix("mx_view", transform.model)
  #shaderDefault.setMatrix("mx_projection", mx_proj)
  #shaderDefault.use()
  #v#iew*       : Matrix
  #projection* : Matrix
  discard



#var ticks* =  newSeqOfCap[ActionT[float]](1024)



# proc tick*(dt: float) =
#   discard


#ticks.add(tick)