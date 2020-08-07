import ../actors/engine/actors_ecs
import utils/actors_profile


type id* = distinct uint32
type idd* = uint32

export test
  except idd

var arr = newSeq[int](10000)

# for i in 0..arr.len.high:
#   arr[i] = i


var pidd : idd = 344
var pid  : id = id(344)

profile.start "dist":
  for i in 0..1000000:
    arr[pid.int] += 1

profile.start "norm":
  for i in 0..1000000:
    arr[pidd] += 1


log profile

#type ComponentPoo = object

#var layer : LayerID = 0'u32

#var aa = App
#app.Add ComponentPoo