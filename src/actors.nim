## closure ienumerators
{.used.}
{.experimental: "codeReordering".}
import actors/actors_h       as header
import actors/actors_tools   as tools
import actors/actors_plugins as plugins
import actors/actors_engine  as engine
import actors/private/actors_engine as in_engine

export tools
export engine

let app* = header.app
let input* = app.addInput()


proc addLayer*(): LayerId =
  discard

proc run*(app: App, init: proc(), update: proc(), draw: proc()) =
  in_engine.target.bootstrap(app)
  init()
  while not in_engine.target.shouldQuit():
    discard
  
  plugins.imgui.kill()
  in_engine.target.kill()

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
