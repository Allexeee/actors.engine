import actors
import macros
import strformat
import math
import times
import sets
import strutils
import macros
import strformat
import times
import strformat
import tables
import strutils

type CompA = object
  arg: int
type CompB = object
  arg: int
type CompC = object
  arg: int

app.add CompA
app.add CompB
app.add CompC


var lgame = addLayer()

# var none = ent.none
# echo none

let size = 10
let half = (size.float * 0.5f).int
let quat = (size.float * 0.75f).int
#echo quat
var all = newSeq[ent]()
var ents = newSeq[ent]()
for i in 0..size:
  var e = lgame.entity()
  e.get CompA
  #if i>half:
  e.get CompB
  #if i>quat:
  e.get CompC
  #if i > half:
   
  #if i > quat:
    #echo i
  #  e.get CompC
    #ents.add(e)
  all.add(e)
 
for e in all:
  #echo e
  if e.has(CompA,CompB,CompC):
    ents.add(e)
# for i in 0..size:

#  if e.has(CompA,CompB,CompC):
#     echo "g"
#     ents.add(e)

#echo ents.len
#echo st1.entities.len  
#var s = newSeq[]
# template pook*(a: untyped): untyped {.dirty.} =
#   var ab {.inject.} = a

# for ca, cb in group(CompA,CompB):
#   ca.arg += 1


  #m[][0].arg += 1

#view(CompA,CompB,CompC)
var steps = 60*600
# profile.start "dynamic1":
#   for i in 0..steps:
#     for e, ca in comps(CompA):
#       ca.arg += 1
#       #e.cb.arg += 1
#       if e.has CompB:
#         e.cb.arg += 1
# profile.start "dynamic2":
#   for i in 0..steps:
#     for ca, cb, cc in comps2(CompA, CompB, CompC):
#       ca.arg += 1
#        cb.arg += 1
#       cc.arg += 1
profile.start "dynamic2":
  for i in 0..steps:
    for cb, ca in comps2(CompB,CompA):
      ca.arg += 1
      cb.arg += 1
profile.start "dynamic3":
  for i in 0..steps:
    for e, ca in comps2(CompA):
      ca.arg += 1
      e.cb.arg+=1
#Profile TEST UNITY took 4.835365100 seconds to complete over 1 iteration, averaging 4.835365100 seconds per call
profile.start "group":
   for i in 0..steps:
     for e in ents:
       #echo e.id
       
       e.ca.arg += 1
       e.cb.arg += 1

       
  

#ents
echo ents.len
profile.log
#var temp = (25,0)
#echo temp.ca.arg
# echo temp.cb.arg
# echo temp.ca.arg
# echo temp.ca.arg
# echo temp.cb.arg
# get(CompB,CompA):
#   echo ""
  # pook(CompB.getComps())
  # echo ab[][0]
  #echo e[][0].addr
  #echo cb[][0]
  #cb.arg+=1
  #cb.arg+=1
  #echo cb.arg 
  #cbb.arg += 1

#var temp = (61,0)
#echo temp.cb.arg

# let cc = cast[ptr seq[CompA]](st1.compss)
# for i in 0..cc[].high:
#   echo cc[][i]

#var arg = cast[ptr seq[CompA]](st1.compss)
#echo cast[ptr seq[CompA]](st1.compss)[].len
# type BOOO* = object
#   a : pointer
#   b : pointer

# type Elem1 = object
#   arg : int
# type Elem2 = object
#   arg : int
#   args : seq[Elem1]
#   str  : string


# var eee = Elem2()
# eee.str = "POOOOOOOKER"

# echo Elem2.sizeOf
# echo eee.sizeOf

# var b : BOOO
# var ee : Elem1
# var eee = newSeq[Elem1](10)
# eee[5].arg = 10000
# ee.arg = 1000
# b.a = eee.addr

# echo b.sizeof
# var arg = cast[ptr seq[Elem1]](b.a)
# echo arg[]

# proc test(self: BOOO) =
#   var arg = cast[ptr seq[Elem1]](self.a) 
#   echo arg[]
#   arg[][5].arg = 5000

# test(b)
# echo arg[]
# echo Elem2.sizeof
#get(CompB,CompA):
#  echo "po"
#   ca.arg += 1
  #cb.arg += 1


# var e = lgame.entity()
# e.get CompA
# e.get CompB


# iterator compa*(t,y: typedesc): (ptr t,ptr y) =
#   let comps1 = t.getComps()
#   let comps2 = y.getComps()
#   yield (comps1[0].addr,comps2[0].addr)


# get(CompA,CompB):
#   ca.arg += 1
  #cb.arg += 1

#echo e.ca.arg

#var m : mask = 0
#var str : CompStorage[CompA]

#initStorage[CompStorage[CompA]]()



#echo pooper()

# for i in 0..size:
#   var e = lgame.entity()
#   e.get CompA
#   e.get CompB

# for ca in comps(CompA):
#   ca.arg += 2

# for ca in comps(CompA, CompB):
#   ca.arg += 2

# var e = (0,0)
# echo e.ca.arg