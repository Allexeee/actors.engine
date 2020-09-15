{.used.}
{.compile: "px_math.c".}
import math
import random

export math


#-----------------------------------------------------------------------------------------------------------------------
#@misc
#-----------------------------------------------------------------------------------------------------------------------
type rad* = distinct float32

const rad_per_deg*  = PI / 180.0 
const epsilon_sqrt* = 1e-15F
const epsilon*      = 0.00001 #for floating-point inaccuracies.

proc invSqrt*(number: cfloat): cfloat {.importc.}
proc radians*(angle: float32): float32 {.inline.} = angle * rad_per_deg
proc rads*(angle: float32): rad {.inline.} = (angle * rad_per_deg).rad
proc max*(val1: float32, val2: float32): float32 =
  if val1 < val2: val2 else: val1


#-----------------------------------------------------------------------------------------------------------------------
#@vec
#-----------------------------------------------------------------------------------------------------------------------
type Vec*    = tuple[x,y,z,w: float32]
type Vec2*   = tuple[x,y: float32]
type Vec3*   = tuple[x,y,z: float32]

proc vec*(x,y,z,w: float32 = 0): Vec {.inline.} =
  (x,y,z,w)

const #identity
  vec_zero*     = vec()
  vec_right*    = vec(1,0,0,0)
  vec_left*     = vec(-1,0,0,0)
  vec_up*       = vec(0,1,0,0)
  vec_down*     = vec(0,-1,0,0)
  vec_forward*  = vec(0,0,1,0)
  vec_backward* = vec(0,0,-1,0)
  vec_one*      = vec(1,1,1,1)

proc xy*(self: var Vec): Vec2 = (self.x,self.y)
proc xyz*(self: var Vec): Vec3 = result = (self.x,self.y,self.z)
proc xy*(self: var Vec, x,y: float32) = self.x = x; self.y = y
proc vec2*(x,y: float32 = 0): Vec2 {.inline.} = (x,y)
proc vec3*(x,y,z: float32 = 0): Vec3 {.inline.} = (x,y,z)
proc col*(r,g,b,a: float32 = 1): Vec {.inline.} = (r,g,b,a)
proc rgb*(r,g,b,a: float32 = 255): Vec {.inline.} = (r/255f,g/255f,b/255f,a/255f)

proc r*(this: Vec): float32 = this.x
proc g*(this: Vec): float32 = this.y
proc b*(this: Vec): float32 = this.z
proc a*(this: Vec): float32 = this.w

proc hex*(s: string = "FFFFFFFF"): Vec {.inline.} =
  var rgba {.global.} = [255f,255f,255f,255f]
  var i = 0
  var index = 0
  rgba = [255f,255f,255f,255f]
  while i<s.len:
     if s[i] in {' ','#','_'}:
        i+=1
     var temp = 0
     case s[i]
        of '0'..'9':
           temp = (s[i].ord-'0'.ord) shl 4
           discard
        of 'a'..'f':
           temp = (s[i].ord-'a'.ord+10) shl 4
        of 'A'..'F':
           temp = (s[i].ord-'A'.ord+10) shl 4
        else: discard
     case s[i+1]:
        of '0'..'9':
           temp += (s[i+1].ord-'0'.ord)
        of 'a'..'f':
           temp += (s[i].ord-'a'.ord+10) 
        of 'A'..'F':
           temp = (s[i].ord-'A'.ord+10)
        else: discard
     rgba[index] = temp.float32
     index+=1
     i+=2 
  (rgba[0]/255.0f, rgba[1]/255.0f, rgba[2]/255.0f, rgba[3]/255.0f)

proc `==`*(a,b:var Vec):bool {.inline.} =
  a.x == b.x and
  a.y == b.y and
  a.z == b.z and
  a.w == b.w

proc `+`*(a: Vec, b: Vec): Vec {.inline.} =
  (a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w)

proc `-`*(a: Vec, b: Vec): Vec {.inline.} =
  (a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w)

proc `*`*(a: Vec, b: SomeNumber): Vec {.inline.} =
  (a.x*b.float32, a.y*b.float32, a.z*b.float32, a.w)

proc `*`*(b: SomeNumber, a: Vec): Vec {.inline.} =
  (a.x*b.float32, a.y*b.float32, a.z*b.float32, a.w)

proc `-`*(this: var Vec) {.inline.} =
  this.x = -this.x
  this.y = -this.y
  this.z = -this.z
  this.w = -this.w

proc `+=`*(this: var Vec, other: Vec) {.inline.} =
  this.x = this.x+other.x
  this.y = this.y+other.y
  this.z = this.z+other.z
  this.w = this.w+other.w

proc `-=`*(this: var Vec, other: Vec) {.inline.} =
  this.x = this.x-other.x
  this.y = this.y-other.y
  this.z = this.z-other.z
  this.w = this.w-other.w

proc `*=`*(this: var Vec, other: Vec) {.inline.} =
  this.x = this.x*other.x
  this.y = this.y*other.y
  this.z = this.z*other.z
  this.w = this.w*other.w

proc `*=`*(this: var Vec, other: float32 = 1) {.inline.} =
  this.x = this.x*other
  this.y = this.y*other
  this.z = this.z*other
  this.w = this.w*other

proc `/=` *(this: var Vec, other: Vec) {.inline.} =
  this.x = this.x/other.x
  this.y = this.y/other.y
  this.z = this.z/other.z
  this.w = this.w/other.w

proc `/=` *(this: var Vec, other: float32 = 1) {.inline.} =
  this.x = this.x/other
  this.y = this.y/other
  this.z = this.z/other
  this.w = this.w/other

proc magnitudeSquare*(vec: Vec): float32 {.inline.} =
  vec.x * vec.x + vec.y * vec.y + vec.z * vec.z

proc magnitude*(vec: Vec): float32 {.inline.} =
  sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)

proc normalize*(vec: var Vec) {.inline.} =
  var arg = vec.magnitude

  if arg != 0:
     arg = 1.0/arg
  
  vec.x *= arg
  vec.y *= arg
  vec.z *= arg

proc normalize*(vec: Vec): Vec {.inline.} =
  var v = vec
  normalize(v)

proc cross*(vec1, vec2: Vec): Vec {.inline.} =
  vec(
     #x 
     vec1.y * vec2.z - vec1.z * vec2.y,
     #y 
     vec1.z * vec2.x - vec1.x * vec2.z,
     #z
     vec1.x * vec2.y - vec1.y * vec2.x,
     #w
     0)

proc dot*(vec1, vec2: Vec): float32 {.inline.} =
  vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z

proc dot4*(vec1, vec2: Vec): float32 {.inline.} =
  vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z + vec1.w * vec2.w

proc rnd*(self: var Vec, arg: float32) =
  self.x = rand(-arg..arg)
  self.y = rand(-arg..arg)
  self.z = rand(-arg..arg)

proc rnd*(self: var Vec, x: float32, y: float32) =
  self.x = rand(-x..x)
  self.y = rand(-y..y)

converter toVec*(v: Vec2): Vec {.inline.} = (v.x,v.y,0f,0f) 
converter toVec*(v: Vec3): Vec {.inline.} = (v.x,v.y,v.z,0f) 

#-----------------------------------------------------------------------------------------------------------------------
#@matrix
#-----------------------------------------------------------------------------------------------------------------------
type Matrix* = tuple[e11,e12,e13,e14,e21,e22,e23,e24,e31,e32,e33,e34,e41,e42,e43,e44: float32]

proc identity*(mx: var Matrix) {.inline.} =
    mx.e11 = 1; mx.e12 = 0; mx.e13 = 0; mx.e14 = 0;
    mx.e21 = 0; mx.e22 = 1; mx.e23 = 0; mx.e24 = 0;
    mx.e31 = 0; mx.e32 = 0; mx.e33 = 1; mx.e34 = 0;
    mx.e41 = 0; mx.e42 = 0; mx.e43 = 0; mx.e44 = 1

proc matrix*(): Matrix = result.identity()

proc normalize*(x,y,z : var float32) {.inline.} =
    let d = sqrt(x*x + y*y + z*z)
    x /= d; y /= d; z /= d

proc initTranslation*(mx: var Matrix, x,y,z : float32 = 0) {.inline.} =
    mx.e11 = 1.0; mx.e12 = 0.0; mx.e13 =  0.0; mx.e14 = 0.0;
    mx.e21 = 0.0; mx.e22 = 1.0; mx.e23 =  0.0; mx.e24 = 0.0;
    mx.e31 = 0.0; mx.e32 = 0.0; mx.e33 =  1.0; mx.e34 = 0.0;
    mx.e41 =   x; mx.e42 =   y; mx.e43 =    z; mx.e44 = 1.0

proc initScale*(mx: var Matrix, x,y,z: float32 = 0) {.inline.} = 
    mx.e11 =   x; mx.e12 = 0.0; mx.e13 =  0.0; mx.e14 = 0.0;
    mx.e21 = 0.0; mx.e22 =   y; mx.e23 =  0.0; mx.e24 = 0.0;
    mx.e31 = 0.0; mx.e32 = 0.0; mx.e33 =    z; mx.e34 = 0.0;
    mx.e41 = 0.0; mx.e42 = 0.0; mx.e43 =  0.0; mx.e44 = 1.0

proc initRotation*(mx: var Matrix, x,y,z: float32 = 0) {.inline.} =
    let cx = cos(x)
    let sx = sin(x)
    let cy = cos(y)
    let sy = sin(y)
    let cz = cos(z)
    let sz = sin(z)
    let cxsy = cx * sy
    let sxsy = sx * sy

    mx.e11 = cy * cz
    mx.e12 = cy * sz
    mx.e13 =  -sy
    mx.e14 = 0.0

    mx.e21 = sxsy * cz - cx * sz
    mx.e22 = sxsy * sz + cx * cz
    mx.e23 = sx * cy
    mx.e24 = 0.0

    mx.e31 = cxsy * cz + sx * sz
    mx.e32 = cxsy * sz - sx * cz
    mx.e33 = cx * cy
    mx.e34 = 0.0

    mx.e41 = 0.0
    mx.e42 = 0.0 
    mx.e43 = 0.0 
    mx.e44 = 1.0

proc initRotation*(mx: var Matrix, x,y,z: float32 = 0, angle: float32) {.inline.} =
    var x = x
    var y = y
    var z = z
    normalize(x,y,z)
    var s = sin(angle)
    var c = cos(angle)
    var vs = 1 - c # versine

    mx.e11 = vs * x * x + c
    mx.e12 = vs * x * y - z * s
    mx.e13 = vs * z * x + y * s
    mx.e14 = 0

    mx.e21 = vs * x * y + z * s
    mx.e22 = vs * y * y + c
    mx.e23 = vs * y * z - x * s
    mx.e24 = 0

    mx.e31 = vs * z * x - y * s
    mx.e32 = vs * y * z + x * s
    mx.e33 = vs * z * z + c
    mx.e34 = 0
    
    mx.e41 = 0
    mx.e42 = 0
    mx.e43 = 0
    mx.e44 = 1

proc initRotationX*(mx: var Matrix, a: float32) {.inline.} =
    let cos = cos(a)
    let sin = sin(a)
    mx.e11 = 1.0; mx.e12 = 0.0; mx.e13 =  0.0; mx.e14 = 0.0;
    mx.e21 = 0.0; mx.e22 = cos; mx.e23 = -sin; mx.e24 = 0.0;
    mx.e31 = 0.0; mx.e32 = sin; mx.e33 =  cos; mx.e34 = 0.0;
    mx.e41 = 0.0; mx.e42 = 0.0; mx.e43 =  0.0; mx.e44 = 1.0

proc initRotationY*(mx: var Matrix, a: float32) {.inline.} =
    let cos = cos(a)
    let sin = sin(a)
    mx.e11 =  cos; mx.e12 = 0.0; mx.e13 = sin; mx.e14 = 0.0;
    mx.e21 =  0.0; mx.e22 = 1.0; mx.e23 = 0.0; mx.e24 = 0.0;
    mx.e31 = -sin; mx.e32 = 0.0; mx.e33 = cos; mx.e34 = 0.0;
    mx.e41 =  0.0; mx.e42 = 0.0; mx.e43 = 0.0; mx.e44 = 1.0

proc initRotationZ*(mx: var Matrix, a: float32) {.inline.} =
    let cos = cos(a)
    let sin = sin(a)
    mx.e11 = cos; mx.e12 = -sin; mx.e13 = 0.0; mx.e14 = 0.0;
    mx.e21 = sin; mx.e22 =  cos; mx.e23 = 0.0; mx.e24 = 0.0;
    mx.e31 = 0.0; mx.e32 =  0.0; mx.e33 = 1.0; mx.e34 = 0.0;
    mx.e41 = 0.0; mx.e42 =  0.0; mx.e43 = 0.0; mx.e44 = 1.0

proc matrix*(x,y,z: float32): Matrix = result.initScale(x,y,z)

proc `==`*(mx1: var Matrix, mx2: var Matrix): bool {.inline.} =
    mx1.e11 == mx2.e11 and
    mx1.e12 == mx2.e12 and
    mx1.e13 == mx2.e13 and
    mx1.e14 == mx2.e14 and
    mx1.e21 == mx2.e21 and
    mx1.e22 == mx2.e22 and
    mx1.e23 == mx2.e23 and
    mx1.e24 == mx2.e24 and
    mx1.e31 == mx2.e41 and
    mx1.e32 == mx2.e42 and
    mx1.e33 == mx2.e43 and
    mx1.e34 == mx2.e44 and
    mx1.e41 == mx2.e41 and
    mx1.e42 == mx2.e42 and
    mx1.e43 == mx2.e43 and
    mx1.e44 == mx2.e44

proc `!=`*(mx1: var Matrix, mx2: var Matrix): bool {.inline.} =
    mx1.e11 != mx2.e11 or
    mx1.e12 != mx2.e12 or
    mx1.e13 != mx2.e13 or
    mx1.e14 != mx2.e14 or
    mx1.e21 != mx2.e21 or
    mx1.e22 != mx2.e22 or
    mx1.e23 != mx2.e23 or
    mx1.e24 != mx2.e24 or
    mx1.e31 != mx2.e41 or
    mx1.e32 != mx2.e42 or
    mx1.e33 != mx2.e43 or
    mx1.e34 != mx2.e44 or
    mx1.e41 != mx2.e41 or
    mx1.e42 != mx2.e42 or
    mx1.e43 != mx2.e43 or
    mx1.e44 != mx2.e44

proc equal*(mx1: var Matrix, mx2: var Matrix): bool {.inline.} = mx1 == mx2

proc `*`*(mx: var Matrix, v: float32) {.inline.} =
    mx.e11 *= v
    mx.e12 *= v
    mx.e13 *= v
    mx.e14 *= v

    mx.e21 *= v
    mx.e22 *= v
    mx.e23 *= v
    mx.e24 *= v

    mx.e31 *= v
    mx.e32 *= v
    mx.e33 *= v
    mx.e34 *= v

    mx.e41 *= v
    mx.e42 *= v
    mx.e43 *= v
    mx.e44 *= v

proc `*`*(mx: var Matrix, v: float32): Matrix {.inline.} =
    result.e11 = mx.e11 * v
    result.e12 = mx.e12 * v
    result.e13 = mx.e13 * v
    result.e14 = mx.e14 * v

    result.e21 = mx.e21 * v
    result.e22 = mx.e22 * v
    result.e23 = mx.e23 * v
    result.e24 = mx.e24 * v

    result.e31 = mx.e31 * v
    result.e32 = mx.e32 * v
    result.e33 = mx.e33 * v
    result.e34 = mx.e34 * v

    result.e41 = mx.e41 * v
    result.e42 = mx.e42 * v
    result.e43 = mx.e43 * v
    result.e44 = mx.e44 * v

proc `*`*(mx: var Matrix, v: Vec): Vec {.inline.} =
    result.x = mx.e11 * v.x + mx.e12 * v.y + mx.e13 * v.z + mx.e14 * v.w
    result.y = mx.e21 * v.x + mx.e22 * v.y + mx.e23 * v.z + mx.e24 * v.w
    result.z = mx.e31 * v.x + mx.e32 * v.y + mx.e33 * v.z + mx.e34 * v.w
    result.w = mx.e41 * v.x + mx.e42 * v.y + mx.e43 * v.z + mx.e44 * v.w

proc `*`*(mx1: var Matrix, mx2: var Matrix): Matrix {.inline.} =
    result.e11 = mx1.e11 * mx2.e11 + mx1.e12 * mx2.e21 + mx1.e13 * mx2.e31 + mx1.e14 * mx2.e41
    result.e12 = mx1.e11 * mx2.e12 + mx1.e12 * mx2.e22 + mx1.e13 * mx2.e32 + mx1.e14 * mx2.e42
    result.e13 = mx1.e11 * mx2.e13 + mx1.e12 * mx2.e23 + mx1.e13 * mx2.e33 + mx1.e14 * mx2.e43
    result.e14 = mx1.e11 * mx2.e14 + mx1.e12 * mx2.e24 + mx1.e13 * mx2.e34 + mx1.e14 * mx2.e44

    result.e21 = mx1.e21 * mx2.e11 + mx1.e22 * mx2.e21 + mx1.e23 * mx2.e31 + mx1.e24 * mx2.e41
    result.e22 = mx1.e21 * mx2.e12 + mx1.e22 * mx2.e22 + mx1.e23 * mx2.e32 + mx1.e24 * mx2.e42
    result.e23 = mx1.e21 * mx2.e13 + mx1.e22 * mx2.e23 + mx1.e23 * mx2.e33 + mx1.e24 * mx2.e43
    result.e24 = mx1.e21 * mx2.e14 + mx1.e22 * mx2.e24 + mx1.e23 * mx2.e34 + mx1.e24 * mx2.e44

    result.e31 = mx1.e31 * mx2.e11 + mx1.e32 * mx2.e21 + mx1.e33 * mx2.e31 + mx1.e34 * mx2.e41
    result.e32 = mx1.e31 * mx2.e12 + mx1.e32 * mx2.e22 + mx1.e33 * mx2.e32 + mx1.e34 * mx2.e42
    result.e33 = mx1.e31 * mx2.e13 + mx1.e32 * mx2.e23 + mx1.e33 * mx2.e33 + mx1.e34 * mx2.e43
    result.e34 = mx1.e31 * mx2.e14 + mx1.e32 * mx2.e24 + mx1.e33 * mx2.e34 + mx1.e34 * mx2.e44

    result.e41 = mx1.e41 * mx2.e11 + mx1.e42 * mx2.e21 + mx1.e43 * mx2.e31 + mx1.e44 * mx2.e41
    result.e42 = mx1.e41 * mx2.e12 + mx1.e42 * mx2.e22 + mx1.e43 * mx2.e32 + mx1.e44 * mx2.e42
    result.e43 = mx1.e41 * mx2.e13 + mx1.e42 * mx2.e23 + mx1.e43 * mx2.e33 + mx1.e44 * mx2.e43
    result.e44 = mx1.e41 * mx2.e14 + mx1.e42 * mx2.e24 + mx1.e43 * mx2.e34 + mx1.e44 * mx2.e44

proc multiply*(mxl:  Matrix, mxr:  Matrix): Matrix {.inline.} =
    result.e11 = mxl.e11 * mxr.e11 + mxl.e12 * mxr.e21 + mxl.e13 * mxr.e31 + mxl.e14 * mxr.e41
    result.e12 = mxl.e11 * mxr.e12 + mxl.e12 * mxr.e22 + mxl.e13 * mxr.e32 + mxl.e14 * mxr.e42
    result.e13 = mxl.e11 * mxr.e13 + mxl.e12 * mxr.e23 + mxl.e13 * mxr.e33 + mxl.e14 * mxr.e43
    result.e14 = mxl.e11 * mxr.e14 + mxl.e12 * mxr.e24 + mxl.e13 * mxr.e34 + mxl.e14 * mxr.e44

    result.e21 = mxl.e21 * mxr.e11 + mxl.e22 * mxr.e21 + mxl.e23 * mxr.e31 + mxl.e24 * mxr.e41
    result.e22 = mxl.e21 * mxr.e12 + mxl.e22 * mxr.e22 + mxl.e23 * mxr.e32 + mxl.e24 * mxr.e42
    result.e23 = mxl.e21 * mxr.e13 + mxl.e22 * mxr.e23 + mxl.e23 * mxr.e33 + mxl.e24 * mxr.e43
    result.e24 = mxl.e21 * mxr.e14 + mxl.e22 * mxr.e24 + mxl.e23 * mxr.e34 + mxl.e24 * mxr.e44

    result.e31 = mxl.e31 * mxr.e11 + mxl.e32 * mxr.e21 + mxl.e33 * mxr.e31 + mxl.e34 * mxr.e41
    result.e32 = mxl.e31 * mxr.e12 + mxl.e32 * mxr.e22 + mxl.e33 * mxr.e32 + mxl.e34 * mxr.e42
    result.e33 = mxl.e31 * mxr.e13 + mxl.e32 * mxr.e23 + mxl.e33 * mxr.e33 + mxl.e34 * mxr.e43
    result.e34 = mxl.e31 * mxr.e14 + mxl.e32 * mxr.e24 + mxl.e33 * mxr.e34 + mxl.e34 * mxr.e44

    result.e41 = mxl.e41 * mxr.e11 + mxl.e42 * mxr.e21 + mxl.e43 * mxr.e31 + mxl.e44 * mxr.e41
    result.e42 = mxl.e41 * mxr.e12 + mxl.e42 * mxr.e22 + mxl.e43 * mxr.e32 + mxl.e44 * mxr.e42
    result.e43 = mxl.e41 * mxr.e13 + mxl.e42 * mxr.e23 + mxl.e43 * mxr.e33 + mxl.e44 * mxr.e43
    result.e44 = mxl.e41 * mxr.e14 + mxl.e42 * mxr.e24 + mxl.e43 * mxr.e34 + mxl.e44 * mxr.e44

proc `*`*(mx1: Matrix, mx2: Matrix): Matrix {.inline.} =
    result.e11 = mx1.e11 * mx2.e11 + mx1.e12 * mx2.e21 + mx1.e13 * mx2.e31 + mx1.e14 * mx2.e41
    result.e12 = mx1.e11 * mx2.e12 + mx1.e12 * mx2.e22 + mx1.e13 * mx2.e32 + mx1.e14 * mx2.e42
    result.e13 = mx1.e11 * mx2.e13 + mx1.e12 * mx2.e23 + mx1.e13 * mx2.e33 + mx1.e14 * mx2.e43
    result.e14 = mx1.e11 * mx2.e14 + mx1.e12 * mx2.e24 + mx1.e13 * mx2.e34 + mx1.e14 * mx2.e44

    result.e21 = mx1.e21 * mx2.e11 + mx1.e22 * mx2.e21 + mx1.e23 * mx2.e31 + mx1.e24 * mx2.e41
    result.e22 = mx1.e21 * mx2.e12 + mx1.e22 * mx2.e22 + mx1.e23 * mx2.e32 + mx1.e24 * mx2.e42
    result.e23 = mx1.e21 * mx2.e13 + mx1.e22 * mx2.e23 + mx1.e23 * mx2.e33 + mx1.e24 * mx2.e43
    result.e24 = mx1.e21 * mx2.e14 + mx1.e22 * mx2.e24 + mx1.e23 * mx2.e34 + mx1.e24 * mx2.e44

    result.e31 = mx1.e31 * mx2.e11 + mx1.e32 * mx2.e21 + mx1.e33 * mx2.e31 + mx1.e34 * mx2.e41
    result.e32 = mx1.e31 * mx2.e12 + mx1.e32 * mx2.e22 + mx1.e33 * mx2.e32 + mx1.e34 * mx2.e42
    result.e33 = mx1.e31 * mx2.e13 + mx1.e32 * mx2.e23 + mx1.e33 * mx2.e33 + mx1.e34 * mx2.e43
    result.e34 = mx1.e31 * mx2.e14 + mx1.e32 * mx2.e24 + mx1.e33 * mx2.e34 + mx1.e34 * mx2.e44

    result.e41 = mx1.e41 * mx2.e11 + mx1.e42 * mx2.e21 + mx1.e43 * mx2.e31 + mx1.e44 * mx2.e41
    result.e42 = mx1.e41 * mx2.e12 + mx1.e42 * mx2.e22 + mx1.e43 * mx2.e32 + mx1.e44 * mx2.e42
    result.e43 = mx1.e41 * mx2.e13 + mx1.e42 * mx2.e23 + mx1.e43 * mx2.e33 + mx1.e44 * mx2.e43
    result.e44 = mx1.e41 * mx2.e14 + mx1.e42 * mx2.e24 + mx1.e43 * mx2.e34 + mx1.e44 * mx2.e44

proc setPosition*(mx: var Matrix, x,y,z: float32 = 0) {.inline.} =
    mx.e41 = x
    mx.e42 = y
    mx.e43 = z
    mx.e44 = 1

proc setPosition*(mx: var Matrix, vec: Vec) {.inline.} =
    mx.e41 = vec.x
    mx.e42 = vec.y
    mx.e43 = vec.z
    mx.e44 = 1

proc translate*(mx: var Matrix, x,y,z : float32 = 0) {.inline.} =
    mx.e11 += x * mx.e14
    mx.e12 += y * mx.e14
    mx.e13 += z * mx.e14
    mx.e21 += x * mx.e24
    mx.e22 += y * mx.e24
    mx.e23 += z * mx.e24
    mx.e31 += x * mx.e34
    mx.e32 += y * mx.e34
    mx.e33 += z * mx.e34
    mx.e41 += x * mx.e44
    mx.e42 += y * mx.e44
    mx.e43 += z * mx.e44

proc translate*(mx: var Matrix, vec: Vec) {.inline.} =
    mx.e11 += vec.x * mx.e14
    mx.e12 += vec.y * mx.e14
    mx.e13 += vec.z * mx.e14
    mx.e21 += vec.x * mx.e24
    mx.e22 += vec.y * mx.e24
    mx.e23 += vec.z * mx.e24
    mx.e31 += vec.x * mx.e34
    mx.e32 += vec.y * mx.e34
    mx.e33 += vec.z * mx.e34
    mx.e41 += vec.x * mx.e44
    mx.e42 += vec.y * mx.e44
    mx.e43 += vec.z * mx.e44

proc scale*(mx: var Matrix, x,y,z: float32 = 1) {.inline.} =
    mx.e11 *= x
    mx.e21 *= x
    mx.e31 *= x
    mx.e41 *= x

    mx.e12 *= y
    mx.e22 *= y
    mx.e32 *= y
    mx.e42 *= y

    mx.e13 *= z
    mx.e23 *= z
    mx.e33 *= z
    mx.e44 *= z

proc scale*(mx: var Matrix, vec: Vec) {.inline.} =
    mx.e11 *= vec.x
    mx.e21 *= vec.x
    mx.e31 *= vec.x
    mx.e41 *= vec.x

    mx.e12 *= vec.y
    mx.e22 *= vec.y
    mx.e32 *= vec.y
    mx.e42 *= vec.y

    mx.e13 *= vec.z
    mx.e23 *= vec.z
    mx.e33 *= vec.z
    mx.e44 *= vec.z

proc rotate*(mx: var Matrix, angle: rad, x: float32 = 1, y,z: float32 = 0) {.inline.} =
    var tmp = matrix()
    var x = x; var y = y; var z = z
    var len = sqrt(x*x+y*y+z*z)
    if len != 1.0 and len != 0.0:
        len = 1.0 / len
        x *= len
        y *= len
        z *= len
    
    var s = sin(-angle.float32)
    var c = cos(-angle.float32)
    var t = 1.0 - c

    tmp.e11 = x*x*t + c
    tmp.e12 = y*x*t + z*s
    tmp.e13 = z*x*t - y*s
    tmp.e14 = 0

    tmp.e21 = x*y*t - z*s
    tmp.e22 = y*y*t + c
    tmp.e23 = z*y*t + x*s
    tmp.e24 = 0

    tmp.e31 = x*z*t + y*s
    tmp.e32 = y*z*t - x*s
    tmp.e33 = z*z*t + c
    tmp.e34 = 0

    tmp.e41 = 0
    tmp.e42 = 0
    tmp.e43 = 0
    tmp.e44 = 1
    
    mx = mx * tmp

proc rotate*(mx: var Matrix, angle: float, axis: Vec) {.inline.} =
    var tmp = matrix()
    var x = axis.x; var y = axis.y; var z = axis.z
    var len = sqrt(x*x+y*y+z*z)
    if len != 1.0 and len != 0.0:
        len = 1.0 / len
        x *= len
        y *= len
        z *= len
    
    var s = sin(-angle)
    var c = cos(-angle)
    var t = 1.0 - c

    tmp.e11 = x*x*t + c
    tmp.e12 = y*x*t + z*s
    tmp.e13 = z*x*t - y*s
    tmp.e14 = 0

    tmp.e21 = x*y*t - z*s
    tmp.e22 = y*y*t + c
    tmp.e23 = z*y*t + x*s
    tmp.e24 = 0

    tmp.e31 = x*z*t + y*s
    tmp.e32 = y*z*t - x*s
    tmp.e33 = z*z*t + c
    tmp.e34 = 0

    tmp.e41 = 0
    tmp.e42 = 0
    tmp.e43 = 0
    tmp.e44 = 1
    
    mx = mx * tmp

proc transpose*(mx: var Matrix) {.inline.} =
    var tmp: float32
    tmp = mx.e12; mx.e12 = mx.e21; mx.e21 = tmp;
    tmp = mx.e13; mx.e13 = mx.e31; mx.e31 = tmp;
    tmp = mx.e14; mx.e14 = mx.e41; mx.e41 = tmp;
    tmp = mx.e23; mx.e23 = mx.e32; mx.e32 = tmp;
    tmp = mx.e24; mx.e24 = mx.e42; mx.e42 = tmp;
    tmp = mx.e34; mx.e34 = mx.e43; mx.e43 = tmp;

proc invert*(mx: var Matrix) {.inline.} =

    let e11 = mx.e11
    let e12 = mx.e12
    let e13 = mx.e13
    let e14 = mx.e14
    let e21 = mx.e21
    let e22 = mx.e22
    let e23 = mx.e23
    let e24 = mx.e24 
    let e31 = mx.e31
    let e32 = mx.e32
    let e33 = mx.e33
    let e34 = mx.e34
    let e41 = mx.e41
    let e42 = mx.e42
    let e43 = mx.e43
    let e44 = mx.e44

    let b01 = e11*e22 - e12*e21
    let b02 = e11*e23 - e13*e21
    let b03 = e11*e24 - e14*e21
    let b04 = e12*e23 - e13*e22
    let b05 = e12*e24 - e14*e22
    let b06 = e13*e24 - e14*e23
    let b07 = e31*e42 - e32*e41
    let b08 = e31*e43 - e33*e41
    let b09 = e31*e44 - e34*e41
    let b10 = e32*e43 - e33*e42
    let b11 = e32*e44 - e34*e42
    let b12 = e33*e44 - e34*e43

    let det_inv = 1.0f/(b01*b12 - b02*b11 + b03*b10 + b04*b09 - b05*b08 + b06*b07)

    mx.e11 = ( e22*b12 - e23*b11 + e24*b10)*det_inv
    mx.e12 = (-e12*b12 + e13*b11 - e14*b10)*det_inv
    mx.e13 = ( e42*b06 - e43*b05 + e44*b04)*det_inv
    mx.e14 = (-e32*b06 + e33*b05 - e34*b04)*det_inv
    mx.e21 = (-e21*b12 + e23*b09 - e24*b08)*det_inv
    mx.e22 = ( e11*b12 - e13*b09 + e14*b08)*det_inv
    mx.e23 = (-e41*b06 + e43*b03 - e44*b02)*det_inv
    mx.e24 = ( e31*b06 - e33*b03 + e34*b02)*det_inv
    mx.e31 = ( e21*b11 - e22*b09 + e24*b07)*det_inv
    mx.e32 = (-e11*b11 + e12*b09 - e14*b07)*det_inv
    mx.e33 = ( e41*b05 - e42*b03 + e44*b01)*det_inv
    mx.e34 = (-e31*b05 + e32*b03 - e34*b01)*det_inv
    mx.e41 = (-e21*b10 + e22*b08 - e23*b07)*det_inv
    mx.e42 = ( e11*b10 - e12*b08 + e13*b07)*det_inv
    mx.e43 = (-e41*b04 + e42*b02 - e43*b01)*det_inv
    mx.e44 = ( e31*b04 - e32*b02 + e33*b01)*det_inv

when defined(renderer_opengl):
  proc ortho*(mx: var Matrix, left, right, bottom, top, near, far : float) {.inline.} =
    let rl = right - left
    let tb = top - bottom
    let fn = far - near

    mx.e11 = 2.0/rl
    mx.e12 = 0
    mx.e13 = 0
    mx.e14 = -(right + left) / rl

    mx.e21 = 0
    mx.e22 = 2.0/tb
    mx.e23 = 0
    mx.e24 = -(top + bottom) / tb

    mx.e31 = 0
    mx.e32 = 0
    mx.e33 = -2.0/fn
    mx.e34 = -(far + near) / fn

    mx.e41 = 0
    mx.e42 = 0
    mx.e43 = 0
    mx.e44 = 1
else:
  proc ortho*(mx: var Matrix, left, right, bottom, top, near, far : float) {.inline.} =
    let rl = right - left
    let tb = top - bottom
    let fn = far - near

    mx.e11 = 2.0/rl
    mx.e12 = 0
    mx.e13 = 0
    mx.e14 = 0

    mx.e21 = 0
    mx.e22 = 2.0/tb
    mx.e23 = 0
    mx.e24 = 0

    mx.e31 = 0
    mx.e32 = 0
    mx.e33 = -2.0/fn
    mx.e34 = 0

    mx.e41 = -(right + left) / rl
    mx.e42 = -(top + bottom) / tb
    mx.e43 = -(far + near) / fn
    mx.e44 = 1

proc frustrum(mx: var Matrix, left, right, bottom, top, near, far: float) {.inline.} =
    let n2 = near * 2
    let rl = right - left
    let tb = top - bottom
    let fn = far - near

    mx.e11 = n2 / rl
    mx.e12 = 0
    mx.e13 = 0
    mx.e14 = 0

    mx.e21 = 0
    mx.e22 = n2 / tb
    mx.e23 = 0
    mx.e24 = 0

    mx.e31 =  (right + left) / rl
    mx.e32 =  (top + bottom) / tb
    mx.e33 = -(far + near) / fn
    mx.e34 = -1

    mx.e41 = 0
    mx.e42 = 0
    mx.e43 = -(far * n2) / fn
    mx.e44 = 0

proc setPerspective*(mx: var Matrix, fov, aspect, near, far: float) {.inline.} =
    var top = near * tan(fov * 0.5)
    var right = top * aspect
    mx.frustrum(-right,right,-top,top,near,far)

proc lookAt*(eye: Vec, target: Vec, up: Vec): Matrix {.inline.} =
   var z = eye-target
   normalize(z)
   var x = cross(up, z)
   normalize(x)
   var y = cross(z,x)
   normalize(y)
 
   #echo z.x
   result.e11 = x.x
   result.e12 = x.y
   result.e13 = x.z
   result.e14 = 0

   result.e21 = y.x
   result.e22 = y.y
   result.e23 = y.z
   result.e24 = 0

   result.e31 = z.x
   result.e32 = z.y
   result.e33 = z.z
   result.e34 = 0

   result.e41 = eye.x
   result.e42 = eye.y
   result.e43 = eye.z
   result.e44 = 1

   result.invert()
