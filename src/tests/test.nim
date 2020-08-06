import utils/actors_profile

type LayerIndex* = distinct uint32

type l = uint32
type ll = l


var v : l = 0
var vv : ll = v

proc poo*(arg: l) = discard


vv.poo()
10.poo()


type Obj = object
  arg : int
  arg2: int

type Obj2 = object
  arg : int

type Obj3 = object
  arg : int


var arr : array[1000000,Obj]
var arr2 : array[1000000,Obj2]
var arr3 : array[1000000,Obj3]

profile.start "DIFF":
  for i in 0..999999:
    arr2[i].arg += 1
    arr3[i].arg += 1  

profile.start "ARR":
  for i in 0..999999:
    let a = arr[i].addr
    a.arg += 1
    a.arg2 += 1



log profile
#echo arr.sizeof, "_", se.sizeof()