{.used.}

import ../../actors_h
import ../../actors_plugins
import ../actors_input
import ../actors_platform
import actors_ui_h


type UiDebugGame* = ref object of UiWindow
  vsync_toggle*: bool
  framerate: int
  ups:       int
  drawcalls: int

func getDebugWindow*(): UiDebugGame {.discardable.} =
  result = UiDebugGame()
  result.base = result
func getDebugWindow*(uiStorage: var seq[UiWindow]): UiDebugGame {.discardable.} =
  result = UiDebugGame()
  result.base = result
  uiStorage.add result

method draw*(self: UiDebugGame) {.locks: "unknown".}=
  #просто для теста показываем/скрываем интерфейс по кнопке space
  if input.press Key.Tilde:
    self.show = if self.show: false else: true
  # не рисуем интерфейс если не показываем
  if not self.show: return
  if app.meta.vsync == 0:
    self.vsync_toggle = false
  else: self.vsync_toggle = true
  
  igBegin("App Debug", self.show.addr, ImGuiWindowFlags.AlwaysAutoResize )
  igPushItemWidth(320)
  igSliderFloat(" Fps", app.meta.fps.addr, 5f, 1000f, "%.0f")
  igSliderFloat(" Ups", app.meta.ups.addr, 20f, 120f, "%.0f")
  igCheckbox(" Vsync", self.vsync_toggle.addr)

  igSameLine()
  if self.vsync_toggle:
      igText("on")
  else: 
      igText("off")

  igSameLine(130)
  igText("fps/ups = %.1f/%.1f | %.3f ms ", app.time.counter.frames_last, app.time.counter.updates_last, 1000.0f / (float)app.time.counter.frames_last)
  igText("")
  igSameLine(130)
  igText("draw calls: %.i ", self.drawcalls)
  
  if self.vsync_toggle: 
    app.vsync(1)
  else:
    app.vsync(0)
  igEnd()