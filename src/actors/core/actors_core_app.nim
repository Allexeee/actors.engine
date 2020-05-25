{.experimental: "codeReordering".}


from   ../actors_backend import AppBase
from      actors_core_input import
  Input,
  InputIndex,
  addInput
import    actors_core_base


type #@tapp
  App* = ref object of AppBase
    layers: seq[AppLayer]
    scenes: seq[Actor]
    inputs: seq[Input]
    settings*: AppSettings
    display*: Display
    input*: InputIndex

  AppSettings* = object
    name*: string
    fps*: float32
    display_size*: tuple[width: int, height: int]
    screen_size*: tuple[width: int, height: int]
    path_shaders* : string
    path_assets* : string


let app* = App(layers: newSeq[AppLayer](0), scenes: newSeq[Actor](0))
app.input = addInput()


proc getScenes*(this: App):ptr seq[Actor] {.inline.} = addr this.scenes

proc getLayersPtr*(this: App):ptr seq[AppLayer] {.inline.} = addr this.layers 

proc getApp*(): App {.inline.} =
  app


