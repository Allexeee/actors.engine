## Created by Pixeye | dev@pixeye.com
## 
## ❒ This module contains user interface types and API

{.used.}

import ../px_h
import ../px_plugins
import px_input
import px_platform


type UiWindow* = ref object of RootObj
  show* : bool
  base* : UiWindow

method draw*(self: UiWindow) {.base,  locks: "unknown".} = 
  discard


#-----------------------------------------------------------------------------------------------------------------------
#@window debug
#-----------------------------------------------------------------------------------------------------------------------
type UiDebugGame* = ref object of UiWindow
  vsync_toggle*: bool
  framerate: int
  ups:       int


func getWindowDebug*(): UiDebugGame {.discardable.} =
  result = UiDebugGame()
  result.base = result
func getWindowDebug*(uiStorage: var seq[UiWindow]): UiDebugGame {.discardable.} =
  result = UiDebugGame()
  result.base = result
  uiStorage.add result

method draw*(self: UiDebugGame) {.locks: "unknown".}=
  
  if input.press Key.Tilde:
    self.show = not self.show
  if not self.show:
    return

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
  igText("draw calls: %.i", stats.drawcalls_prev)
  igText("")
  igSameLine(130)
  igText("   sprites: %.i", stats.sprites_prev)
  
  if self.vsync_toggle: 
    app.vsync(1)
  else:
    app.vsync(0)
  if self.show == false:
    tildaPressed = false
  igEnd()