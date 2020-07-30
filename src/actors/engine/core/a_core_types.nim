{.used.}
{.experimental: "codeReordering".}


import tables
import sets

type System* = ref object of RootObj
    layer* : Layer

type #@ecs
  ent* = tuple
    id  : uint32
    age : uint32

  SystemEcs* = ref object of System
    operations*    : seq[Operation]
    ents_alive*    : HashSet[uint32]
    groups*        : seq[Group]
  
  Entity* {.packed.} = object
    dirty*            : bool        #dirty allows to set all components for a new entity in one init command
    age*              : uint32
    layer*            : Layer
    parent*           : ent
    signature*        : set[uint16] 
    signature_groups* : set[uint16] # what groups are already used
    childs*           : seq[ent]
  
  Group* = ref object of RootObj
    id*               : uint16
    layer*            : Layer
    signature*        : set[uint16]
    signature_excl*   : set[uint16]
    entities*         : seq[ent]
    added*            : seq[ent]
    removed*          : seq[ent]
    events*           : seq[proc()]
  
  ComponentMeta {.packed.} = object
    id*        : uint16
    generation* : uint16
    bitmask*    : int
  
  StorageBase* = ref object of RootObj
    meta*      : ComponentMeta
    groups*    : seq[Group]
  
  Storage*[T] = ref object of StorageBase
    entities*  : Table[uint32, int]
    container* : seq[T]
    
  OpKind* = enum
    Init
    Add,
    Remove,
    Kill
  
  Operation* {.packed.} = object
    kind*  : OpKind
    entity*: ent 
    arg*   : uint16

type #@layer
  SystemUpdate* = ref object of System
    ticks* : seq[ITick]
  
  SystemTime* = ref object of System
    deltaCap*  : float
    scale*      : float

  Layer* = ref object of RootObj
    update* : SystemUpdate
    ecs*    : SystemEcs
    time*   : SystemTime

type #@interfaces
  ITick* = object
    tick*: proc (layer: Layer)
  IDispose* = object
    dispose*: proc()

type #@app
  AppSettings* = object
    name*      : string
    fps*       : float32
    display_size* : tuple[width: int, height: int]
    screen_size*  : tuple[width: int, height: int]
    path_shaders* : string
    path_assets*  : string

  App* = ref object
    settings*  : AppSettings
    layers*    : seq[Layer]

type #@input
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

  InputIndex* = distinct int
  
  SystemInput = object
    mouse_press: array[MouseButton.high.int32,bool]
    mouse_up: array[MouseButton.high.int32,bool]  
  
  Input* = object
    id: InputIndex
    keycode_press: array[Key.high.int32,bool]
    keycode_up:    array[Key.high.int32,bool] 
    keycode_down:  array[Key.high.int32,bool] 
    keycode_hold:  array[Key.high.int32,bool] 
    keyhold_time:  array[Key.high.int32,float]




# type App* = ref object
#   settings*: AppSettings
#   input*   : InputIndex
#   #private
#   inputs   : seq[Input]

# let app* = App()
# app.input = addInput()

# proc getApp*(): App {.inline.} = app