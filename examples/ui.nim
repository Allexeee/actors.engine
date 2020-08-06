{.used.}
{.experimental: "codeReordering".}

import actors
import actors/vendor/actors_imgui

var uis* = newSeq[UI]()

proc newUIDebugGame*(): UIDebugGame {.discardable.} =
  result = UIDebugGame()
  result.base = result
  uis.add(result)



type Actor* = ref object of RootObj
  entity* : ent

type ActorPlayer* = ref object of Actor


var actorss* = newSeq[Actor]()


# proc dra*()
# metho
#method draw*(self: ActorPlayer) 


type UI* = ref object of RootObj
  show* : bool
  base* : UI
 
type UIDebugGame* = ref object of UI
  vsync_toggle*: bool


method draw*(self: UI) {.base,  locks: "unknown".} = 
  discard

method draw*(self: UIDebugGame) =
  # просто для теста показываем/скрываем интерфейс по кнопке space
  if input.press Key.Tilde:
    self.show = if self.show: false else: true
  
  # не рисуем интерфейс если не показываем
  if not self.show: return
  if app.settings.vsync == 0:
    self.vsync_toggle = false
  else: self.vsync_toggle = true
  # igBegin начинает отрисовку интерфейса, передаем self.show чтобы если что скрыть интерфейс нажав
  # на крестик в углу интерфейса
  igBegin("App Debug", self.show.addr, ImGuiWindowFlags.AlwaysAutoResize )
  # делаем размера окна 320 пикселей
  igPushItemWidth(320)
  igSliderFloat(" Fps", app.settings.fps.addr, 5f, 1000f, "%.0f")
  igSliderFloat(" Ups", app.settings.ups.addr, 20f, 120f, "%.0f")
  igCheckbox(" Vsync", self.vsync_toggle.addr)
  igSameLine()
  if self.vsync_toggle:
    igText("on")
  else: 
    igText("off")
  igSameLine(130)
  igText("fps/ups = %.1f/%.1f | %.3f ms ", app.framerate_last, app.ups_last, 1000.0f / app.framerate_last)
  igText("")
  igSameLine(130)
  igText("draw calls: %.i ", drawcallsLast)
  
  if self.vsync_toggle:
    app.vsync(1)
  else:
    app.vsync(0)
  igEnd()
