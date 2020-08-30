## Created by Pixeye | dev@pixeye.com
##
## The game engine.

{.used.}
{.experimental: "codeReordering".}

import actors/actors_plugins as plugins
import actors/actors_h       as core
import actors/actors_tools   as tools
import actors/actors_engine  as engine

export tools
export engine
export plugins
export core.LayerId

let app* = core.app


# proc layer*(self: App): LayerId {.discardable.} =
#   core.layer

# proc addLayer*(app: App): LayerId =
#   result = highest_layer_id.LayerId; highest_layer_id += 1
#   for a in a_layer_added:
#     a(result)

# proc use*(self: LayerID) =
#   layer_current = self.int
#   core.layer = self
#   for a in a_layer_changed:
#     a.Change(self)


proc run*(app: App, init: proc(), update: proc(), draw: proc()) =
  var w = engine.target.bootstrap(app)
  let context {.used.} = igCreateContext()
  assert igGlfwInitForOpenGL(w, true)
  assert igOpenGL3Init()
  igStyleColorsCherry()

  init()
  
  while not engine.target.shouldQuit():
    
    count_metrics_begin()
    engine.target.pollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()
    
    update()
    

    engine.target.render_begin()
    #plugins.render_begin()
    
    draw()
    igRender()

    #plugins.flush()
    igOpenGL3RenderDrawData(igGetDrawData())
    engine.target.render_end()

    count_metrics_end()
  
  #plugins.kill()
  engine.target.kill()
    
#plugins.imgui.kill()
#in_engine.target.kill()

#var frame* : int

# proc run*(app: App,init: proc(), update: proc(), draw: proc()) =
#   engine.target.start(app.settings.display_size, app.settings.name)
#   app.time.lag  = 0
#   app.time.last = app.time.current
#   app.vsync(app.settings.vsync)
 
#   #var ms_update = 0f
#   #var ms_render = 0f

#   init()

#   while not engine.target.shouldQuit():
#     app.time.frames += 1
#     app.time.counter.frames += 1
#     frame += 1
#     engine.target.pollEvents()
    
#     #clampUpdate():
#     #  update()
    
#     #igOpenGL3NewFrame()
#     plugins.imgui.renderer_begin()
    
#     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
#     if app.settings.vsync == 1:
#       glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
#     else:
#       glClearColor(0.2f, 0.4f, 0.3f, 1.0f)


#     draw()
    
#     plugins.imgui.flush()
#     renderer_end()
    
#     # echo "msu: ", ms_update
#     # echo "msr: ", ms_render
  
#   plugins.imgui.dispose()
#   engine.target.dispose()



# proc quit*(this: App) =
#   engine.target.release()

# proc sleep*(app: App, t: float) =
#   var time_current = app.getTime()
#   while time_current - app.time.last < t:
#     sleep(0)
#     time_current = app.getTime()

# template renderer_end(): untyped =
#   engine.target.render_end(app.settings.vsync)
#   if app.settings.vsync == 0:
#     app.sleep(1/app.settings.fps)
