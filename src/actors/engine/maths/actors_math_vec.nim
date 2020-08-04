import actors_math_base


type Vec* = tuple[x,y,z,w: float]
type Vec2* = tuple[x,y: float]
type Vec3* = tuple[x,y,z: float]


#@constructors
proc vec*(x,y,z,w: float = 0): Vec {.inline.} =
  (x,y,z,w)

proc col*(r,g,b,a: float = 1): Vec {.inline.} =
  (r,g,b,a)

proc rgb*(r,g,b,a: float = 255): Vec {.inline.} =
  (r/255f,g/255f,b/255f,a/255f)

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
     rgba[index] = temp.float
     index+=1
     i+=2 
  (rgba[0]/255.0, rgba[1]/255.0, rgba[2]/255.0, rgba[3]/255.0)

proc r*(this: Vec): float =
   this.x
proc g*(this: Vec): float =
   this.y
proc b*(this: Vec): float =
   this.z
proc a*(this: Vec): float =
   this.w

const #identity
  vec_zero*     = vec()
  vec_right*    = vec(1,0,0,0)
  vec_left*     = vec(-1,0,0,0)
  vec_up*       = vec(0,1,0,0)
  vec_down*     = vec(0,-1,0,0)
  vec_forward*  = vec(0,0,1,0)
  vec_backward* = vec(0,0,-1,0)
  vec_one*      = vec(1,1,1,1)


#@equility
proc `==`*(a,b:var Vec):bool {.inline.} =
  a.x == b.x and
  a.y == b.y and
  a.z == b.z and
  a.w == b.w 
#@maths
proc `+`*(a: Vec, b: Vec): Vec {.inline.} =
  (a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w)

proc `-`*(a: Vec, b: Vec): Vec {.inline.} =
  (a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w)

proc `*`*(a: Vec, b: SomeNumber): Vec {.inline.} =
  (a.x*b.float, a.y*b.float, a.z*b.float, a.w)
proc `*`*(b: SomeNumber, a: Vec): Vec {.inline.} =
  (a.x*b.float, a.y*b.float, a.z*b.float, a.w)

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

proc `*=`*(this: var Vec, other: float = 1) {.inline.} =
  this.x = this.x*other
  this.y = this.y*other
  this.z = this.z*other
  this.w = this.w*other

proc `/=` *(this: var Vec, other: Vec) {.inline.} =
  this.x = this.x/other.x
  this.y = this.y/other.y
  this.z = this.z/other.z
  this.w = this.w/other.w

proc `/=` *(this: var Vec, other: float = 1) {.inline.} =
  this.x = this.x/other
  this.y = this.y/other
  this.z = this.z/other
  this.w = this.w/other

proc magnitudeSquare*(vec: Vec): float {.inline.} =
  vec.x * vec.x + vec.y * vec.y + vec.z * vec.z

proc magnitude*(vec: Vec): float {.inline.} =
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
     0
  )

# proc cross*(vec1,vec2: var Vec): Vec {.inline.} =
#    cross(vec1,vec2)

proc dot*(vec1, vec2: Vec): float {.inline.} =
  vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z

proc dot4*(vec1, vec2: Vec): float {.inline.} =
  vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z + vec1.w * vec2.w