{.experimental: "codeReordering".}

#@header
import ../actors_backend


type #@tkeys
  Key* {.pure, size: int32.sizeof.} = enum
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
    a = 65
    b = 66
    c = 67
    d = 68
    e = 69
    f = 70
    g = 71
    h = 72
    i = 73
    j = 74
    k = 75
    l = 76
    m = 77
    n = 78
    o = 79
    p = 80
    q = 81
    r = 82
    s = 83
    t = 84
    u = 85
    v = 86
    w = 87
    x = 88
    y = 89
    z = 90
    LeftBracket = 91
    Backslash = 92
    RightBracket = 93
    GraveAccent = 96
    World1 = 161
    World2 = 162
    escape = 256
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
  MouseButton* {.pure, size: int32.sizeof.} = enum
    mb_left = 0
    mb_right = 1
    mb_middle = 2
    mb_any = 3
    Mb5 = 4
    Mb6 = 5
    Mb7 = 6
    Mb8 = 7

type #@tinputs
  Input* = object
    id: InputIndex
    keycode_press: array[Key.high.toint32,bool]
    keycode_up:    array[Key.high.toint32,bool] 
    keycode_down:  array[Key.high.toint32,bool] 
    keycode_hold:  array[Key.high.toint32,bool] 
    keyhold_time:  array[Key.high.toint32,float]
  InputSystem = object
    mouse_press: array[MouseButton.high.toint32,bool]
    mouse_up: array[MouseButton.high.toint32,bool]  
  InputIndex* = distinct int


converter toint32*(x: Key): int32 = x.int32
converter toint32*(x: MouseButton): int32 = x.int32

#@v
var storage =newSeq[Input](0) 
var input_system = InputSystem()


proc addInput*(): InputIndex =
  var id {.global.} = 0
  let index = id.InputIndex
  storage.add(Input(id:index))
  result = index; id+=1

#@pkeyboard
proc repeat*(this: InputIndex, key: Key, delay: float = 0.15f):bool =
  let input = addr storage[this.int]
  let keycode = key.toint32
  let pressed = pressKeyImpl(keycode)
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
  let keycode = key.toint32
  let pressed = pressKeyImpl(keycode)
  if pressed and input.keycode_press[keycode] == false:
    input.keycode_press[keycode] = true
    return true
  if pressed == false and input.keycode_press[keycode]:
    input.keycode_press[keycode] = false
    return false 

proc down*  (this: InputIndex, key: Key):bool =
  let input = addr storage[this.int]
  let keycode = key.toint32
  let pressed = pressKeyImpl(keycode)
  input.keycode_down[keycode] = pressed
  if pressed and input.keycode_down[keycode]==true:
    return true
  else:
    return false

proc up*    (this: InputIndex, key: Key):bool =
  let input = addr storage[this.int]
  let keycode = key.toint32
  let pressed = pressKeyImpl(keycode)
  if pressed and input.keycode_up[keycode] == false:
    input.keycode_up[keycode] = true
    return false
  if pressed == false and input.keycode_up[keycode]:
    input.keycode_up[keycode] = false
    return true

#@pmouse
proc press* (this: InputIndex, key: MouseButton):bool =
  let keycode = key.toint32
  let pressed = pressMouseImpl(keycode)
  if pressed and input_system.mouse_press[keycode] == false:
    input_system.mouse_press[keycode] = true
    return true
  if pressed == false and input_system.mouse_press[keycode]:
    input_system.mouse_press[keycode] = false
    return false 

proc down* (this: InputIndex, key: MouseButton):bool =
  let keycode = key.toint32
  return pressMouseImpl(keycode)

proc up*    (this: InputIndex, key: MouseButton):bool =
  let keycode = key.toint32
  let pressed = pressMouseImpl(keycode)
  if pressed and input_system.mouse_up[keycode] == false:
    input_system.mouse_up[keycode] = true
    return false
  if pressed == false and input_system.mouse_up[keycode]:
    input_system.mouse_up[keycode] = false
    return true


# #@docs
# #@docs keyboard
# proc press* (this: IndexInput, key: Key):bool
#   ##Returns true during the frame the user starts pressing down the key identified by the key enum parameter.
# #@docs mouse
# proc press* (this: IndexInput, key: MouseButton):bool
  ##Returns true during the frame the user pressed the given mouse button