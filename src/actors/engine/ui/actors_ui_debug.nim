{.used.}
import ../../actors_h
import ../../actors_plugins
import ../actors_input
import actors_ui_h

type UIDebugGame* = ref object of UI
  vsync_toggle*: bool
  framerate: int
  ups:       int
  drawcalls: int

func newUIDebug*(): UIDebugGame {.discardable.} =
  result = UIDebugGame()
  result.base = result
func newUIDebug*(uis: var seq[UI]): UIDebugGame {.discardable.} =
  result = UIDebugGame()
  result.base = result
  uis.add result
# proc add*(self: UIDebugGame) =
#   uis.add(self)
# proc remove*(self: UIDebugGame) =
#   uis.add(self)

# proc newUIDebugGame*(): UIDebugGame {.discardable.} =
#   result = UIDebugGame()
#   result.base = result
#   uis.add(result)

method draw*(self: UIDebugGame) {.locks: "unknown".}=
  #просто для теста показываем/скрываем интерфейс по кнопке space
  if input.press Key.Tilde:
    self.show = if self.show: false else: true
  # не рисуем интерфейс если не показываем
  if not self.show: return
  if app.settings.vsync == 0:
    self.vsync_toggle = false
  else: self.vsync_toggle = true
  
  igBegin("App Debug", self.show.addr, ImGuiWindowFlags.AlwaysAutoResize )
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
  igText("fps/ups = %.1f/%.1f | %.3f ms ", self.framerate, self.ups, 1000.0f / (float)self.framerate)
  igText("")
  igSameLine(130)
  igText("draw calls: %.i ", self.drawcalls)
  
  if self.vsync_toggle: discard
    #app.vsync(1)
  else: discard
    #app.vsync(0)
  igEnd()