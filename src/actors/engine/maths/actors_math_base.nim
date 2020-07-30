{.used.}
{.compile: "actors_math_base.c".}

import math
export math


const rad_per_deg*  = PI / 180.0 
const epsilon_sqrt* = 1e-15F
const epsilon*      = 0.00001 #for floating-point inaccuracies.


type rad* = distinct float32

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


  # public static int clamp(int value, int min, int max)
  #   {
  #     if (value < min)
  #       value = min;
  #     else if (value > max)
  #       value = max;
  #     return value;
  #   }

    # public static float max(float val1, float val2)
    # {
    #   return val1 < val2 ? val2 : val1;
    # }