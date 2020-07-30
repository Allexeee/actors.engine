{.used.}
{.experimental: "codeReordering".}

import a_core_types

var storage      = newSeq[Input](0) 

var pressKey* : proc(keycode: cint): bool {.inline.}
var pressMouse* : proc(keycode: cint): bool {.inline.}
var getMousePosition *: proc(): tuple[x: cfloat,y: cfloat] {.inline.}

proc addInput*(this: App): InputIndex {.discardable.} =
  var id {.global.} = 0
  let index = id.InputIndex
  storage.add(Input(id: index))
  result = index; id+=1

#@pkeyboard
proc repeat*(this: InputIndex, key: Key, delay: float = 0.15f):bool =
  let input = addr storage[this.int]
  let keycode = key.int32
  let pressed = pressKey(keycode)
  if pressed == true:
    input.keyhold_time[keycode]-=1/60f
    if input.keyhold_time[keycode] <= 0:
      input.keyhold_time[keycode] = delay
      return true
    else: return false
  else:
    input.keyhold_time[keycode] = 0.0f
    return false

proc press* (this: InputIndex, key: Key):bool =
  let input = addr storage[this.int]
  let keycode = key.int32
  let pressed = pressKey(keycode)
  if pressed and input.keycode_press[keycode] == false:
    input.keycode_press[keycode] = true
    return true
  if pressed == false and input.keycode_press[keycode]:
    input.keycode_press[keycode] = false
    return false 

proc down*  (this: InputIndex, key: Key):bool =
  let input = addr storage[this.int]
  let keycode = key.int32
  let pressed = pressKey(keycode)
  input.keycode_down[keycode] = pressed
  if pressed and input.keycode_down[keycode]==true:
    return true
  else:
    return false

proc up*    (this: InputIndex, key: Key):bool =
  let input = addr storage[this.int]
  let keycode = key.int32
  let pressed = pressKey(keycode)
  if pressed and input.keycode_up[keycode] == false:
    input.keycode_up[keycode] = true
    return false
  if pressed == false and input.keycode_up[keycode]:
    input.keycode_up[keycode] = false
    return true

#@pmouse
proc press* (this: InputIndex, key: MouseButton):bool =
  let input = addr storage[this.int]
  let keycode = key.int32
  let pressed = pressMouse(keycode)
  if pressed and input.mouse_press[keycode] == false:
    input.mouse_press[keycode] = true
    return true
  if pressed == false and input.mouse_press[keycode]:
    input.mouse_press[keycode] = false
    return false 

proc down* (this: InputIndex, key: MouseButton):bool =
  let keycode = key.int32
  return pressMouse(keycode)

proc up*    (this: InputIndex, key: MouseButton):bool =
  let input = addr storage[this.int]
  let keycode = key.int32
  let pressed = pressMouse(keycode)
  if pressed and input.mouse_up[keycode] == false:
    input.mouse_up[keycode] = true
    return false
  if pressed == false and input.mouse_up[keycode]:
    input.mouse_up[keycode] = false
    return true