{.used.}
{.compile: "actors_math.c".}

import math
export math

type rad* = distinct float32

type Vec*    = tuple[x,y,z,w: float32]
type Vec2*   = tuple[x,y: float32]
type Vec3*   = tuple[x,y,z: float32]
type Matrix* = tuple[e11,e12,e13,e14,e21,e22,e23,e24,e31,e32,e33,e34,e41,e42,e43,e44: float32]

const rad_per_deg*  = PI / 180.0 
const epsilon_sqrt* = 1e-15F
const epsilon*      = 0.00001 #for floating-point inaccuracies.

proc invSqrt*(number: cfloat): cfloat {.importc.}

proc radians*(angle: float32): float32 {.inline.} =
  angle * rad_per_deg

proc rads*(angle: float32): rad {.inline.} =
  (angle * rad_per_deg).rad

proc max*(val1: float32, val2: float32): float32 =
  if val1 < val2:
    val2
  else:
    val1