{.used.}
{.experimental: "codeReordering".}

include actors_input_h
import ../private/actors_platform as platform

var inputs = newSeq[Input](0)

proc addInput*(self: App): InputIndex {.discardable.} =
  var id {.global.} = 0
  let index = id.InputIndex
  inputs.add(Input(id: index))
  result = index; id+=1

#@pkeyboard
proc repeat*(this: InputIndex, key: Key, delay: float = 0.15f):bool =
  let input = addr inputs[this.int]
  let keycode = key.int32
  let pressed = platform.target.pressKeyImpl(keycode)
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
  let input = addr inputs[this.int]
  let keycode = key.int32
  let pressed = platform.target.pressKeyImpl(keycode)
  if pressed and input.keycode_press[keycode] == false:
    input.keycode_press[keycode] = true
    return true
  if pressed == false and input.keycode_press[keycode]:
    input.keycode_press[keycode] = false
    return false 

proc down*  (this: InputIndex, key: Key):bool =
  let input = addr inputs[this.int]
  let keycode = key.int32
  let pressed = platform.target.pressKeyImpl(keycode)
  input.keycode_down[keycode] = pressed
  if pressed and input.keycode_down[keycode]==true:
    return true
  else:
    return false

proc up*    (this: InputIndex, key: Key):bool =
  let input = addr inputs[this.int]
  let keycode = key.int32
  let pressed = platform.target.pressKeyImpl(keycode)
  if pressed and input.keycode_up[keycode] == false:
    input.keycode_up[keycode] = true
    return false
  if pressed == false and input.keycode_up[keycode]:
    input.keycode_up[keycode] = false
    return true

#@pmouse
proc press* (this: InputIndex, key: MouseButton):bool =
  let input = addr inputs[this.int]
  let keycode = key.int32
  let pressed = platform.target.pressMouseImpl(keycode)
  if pressed and input.mouse_press[keycode] == false:
    input.mouse_press[keycode] = true
    return true
  if pressed == false and input.mouse_press[keycode]:
    input.mouse_press[keycode] = false
    return false 

proc down* (this: InputIndex, key: MouseButton):bool =
  let keycode = key.int32
  return platform.target.pressMouseImpl(keycode)

proc up*   (this: InputIndex, key: MouseButton):bool =
  let input = addr inputs[this.int]
  let keycode = key.int32
  let pressed = platform.target.pressMouseImpl(keycode)
  if pressed and input.mouse_up[keycode] == false:
    input.mouse_up[keycode] = true
    return false
  if pressed == false and input.mouse_up[keycode]:
    input.mouse_up[keycode] = false
    return true