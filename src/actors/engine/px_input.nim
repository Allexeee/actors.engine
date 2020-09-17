## Created by Pixeye | dev@pixeye.com
## Input types and API
{.used.}

import ../px_h
import px_platform as platform

type Key* {.pure, size: int32.sizeof.} = enum
  Space = 32
  Apostrophe = 39
  Comma = 44
  Minus = 45
  Period = 46
  Slash = 47
  K0 = 48
  K1 = 49
  K2 = 50
  K3 = 51
  K4 = 52
  K5 = 53
  K6 = 54
  K7 = 55
  K8 = 56
  K9 = 57
  Semicolon = 59
  Equal = 61
  A = 65
  B = 66
  C = 67
  D = 68
  E = 69
  F = 70
  G = 71
  H = 72
  I = 73
  J = 74
  K = 75
  L = 76
  M = 77
  N = 78
  O = 79
  P = 80
  Q = 81
  R = 82
  S = 83
  T = 84
  U = 85
  V = 86
  W = 87
  X = 88
  Y = 89
  Z = 90
  LeftBracket = 91
  Backslash = 92
  RightBracket = 93
  Tilde = 96
  World1 = 161
  World2 = 162
  Esc = 256
  Enter = 257
  Tab = 258
  Backspace = 259
  Insert = 260
  Delete = 261
  Right = 262
  Left = 263
  Down = 264
  Up = 265
  PageUp = 266
  PageDown = 267
  Home = 268
  End = 269
  CapsLock = 280
  ScrollLock = 281
  NumLock = 282
  PrintScreen = 283
  Pause = 284
  F1 = 290
  F2 = 291
  F3 = 292
  F4 = 293
  F5 = 294
  F6 = 295
  F7 = 296
  F8 = 297
  F9 = 298
  F10 = 299
  F11 = 300
  F12 = 301
  F13 = 302
  F14 = 303
  F15 = 304
  F16 = 305
  F17 = 306
  F18 = 307
  F19 = 308
  F20 = 309
  F21 = 310
  F22 = 311
  F23 = 312
  F24 = 313
  F25 = 314
  Kp0 = 320
  Kp1 = 321
  Kp2 = 322
  Kp3 = 323
  Kp4 = 324
  Kp5 = 325
  Kp6 = 326
  Kp7 = 327
  Kp8 = 328
  Kp9 = 329
  KpDecimal = 330
  KpDivide = 331
  KpMultiply = 332
  KpSubtract = 333
  KpAdd = 334
  KpEnter = 335
  KpEqual = 336
  LeftShift = 340
  LeftControl = 341
  LeftAlt = 342
  LeftSuper = 343
  RightShift = 344
  RightControl = 345
  RightAlt = 346
  RightSuper = 347
  Menu = 348 
type MouseButton* {.pure, size: int32.sizeof.} = enum
  mb_left = 0
  mb_right = 1
  mb_middle = 2
  mb_any = 3
  Mb5 = 4
  Mb6 = 5
  Mb7 = 6
  Mb8 = 7
type InputIndex* = distinct int
type Input* = object
  id*           :  InputIndex
  mouse_press*  :  array[MouseButton.high.int32,bool]
  mouse_up*     :  array[MouseButton.high.int32,bool]
  keycode_press*:  array[Key.high.int32,bool]
  keycode_up*   :  array[Key.high.int32,bool] 
  keycode_down* :  array[Key.high.int32,bool] 
  keycode_hold* :  array[Key.high.int32,bool] 
  keyhold_time* :  array[Key.high.int32,float]

var inputs = newSeq[Input](0)

proc addInput*(self: App): InputIndex {.discardable.} =
  var id {.global.} = 0
  let index = id.InputIndex
  inputs.add(Input(id: index))
  result = index; id+=1


#-----------------------------------------------------------------------------------------------------------------------
#@keyboard
#-----------------------------------------------------------------------------------------------------------------------
proc repeat*(self: InputIndex, key: Key, delay: float = 0.15f):bool =
  let input = addr inputs[self.int]
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

proc press* (self: InputIndex, key: Key):bool =
  let input = addr inputs[self.int]
  let keycode = key.int32
  let pressed = platform.target.pressKeyImpl(keycode)
  if pressed and input.keycode_press[keycode] == false:
    input.keycode_press[keycode] = true
    return true
  if pressed == false and input.keycode_press[keycode]:
    input.keycode_press[keycode] = false
    return false 

proc down*  (self: InputIndex, key: Key):bool =
  let input = addr inputs[self.int]
  let keycode = key.int32
  let pressed = platform.target.pressKeyImpl(keycode)
  input.keycode_down[keycode] = pressed
  if pressed and input.keycode_down[keycode]==true:
    return true
  else:
    return false

proc up*    (self: InputIndex, key: Key):bool =
  let input = addr inputs[self.int]
  let keycode = key.int32
  let pressed = platform.target.pressKeyImpl(keycode)
  if pressed and input.keycode_up[keycode] == false:
    input.keycode_up[keycode] = true
    return false
  if pressed == false and input.keycode_up[keycode]:
    input.keycode_up[keycode] = false
    return true


#-----------------------------------------------------------------------------------------------------------------------
#@mouse
#-----------------------------------------------------------------------------------------------------------------------
proc press* (self: InputIndex, key: MouseButton):bool =
  let input = addr inputs[self.int]
  let keycode = key.int32
  let pressed = platform.target.pressMouseImpl(keycode)
  if pressed and input.mouse_press[keycode] == false:
    input.mouse_press[keycode] = true
    return true
  if pressed == false and input.mouse_press[keycode]:
    input.mouse_press[keycode] = false
    return false 

proc down* (self: InputIndex, key: MouseButton):bool =
  let keycode = key.int32
  return platform.target.pressMouseImpl(keycode)

proc up*   (self: InputIndex, key: MouseButton):bool =
  let input = addr inputs[self.int]
  let keycode = key.int32
  let pressed = platform.target.pressMouseImpl(keycode)
  if pressed and input.mouse_up[keycode] == false:
    input.mouse_up[keycode] = true
    return false
  if pressed == false and input.mouse_up[keycode]:
    input.mouse_up[keycode] = false
    return true


#-----------------------------------------------------------------------------------------------------------------------
#@code
#-----------------------------------------------------------------------------------------------------------------------
let input* = app.addInput()
