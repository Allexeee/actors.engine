import ../actors_ecs_h
import ../../../actors_tools

# var ents_max = 5000
# var comps = 120
# var groups = 100
# var avg_compsize = 185
# var avg_comps_e = 1792
# var meta = EntityMeta.sizeof
# echo meta
# var m2 = comps+groups

# var m1 = meta * ents_max
# var m3 = m2*ents_max*4
# var m4 = groups*avg_comps_e*8
# var m5 = comps*avg_comps_e*12
# var m6 = comps*avg_comps_e*avg_compsize
# var m7 = comps*ents_max*avg_compsize

# proc mb*(self: int): float =
#   self/1000/1000
# echo (m1+m3+m4+m5).mb
# echo (m6).mb
# echo (m1+m3+m4+m5+m6).mb
# echo (m1+m3+m4+m5+m7).mb

# proc binarysearch(this: ptr seq[ent], value: int): int {.discardable, used, inline.} =
#   var m : int = -1
#   var left = 0
#   var right = this[].high
#   while left <= right:
#       m = (left+right) div 2
#       if this[][m].id == value: 
#           discard
#       if this[][m].id < value:
#           left = m + 1
#       else:
#           right = m - 1
#   return m

var steps = 60*3600
var size = 40000
var size_r = (size / 4).int
var s = newSeq[ent](size)
var r = newSeq[int](size_r)

var comps = {0,1,5,12}
var comps_s = @[0,1,5,12]
var ran = @[0,1,5,12,8,9,100,110,40]
import random
randomize(getTime().toSeconds.toBiggestInt)
var b = false

for i in 0..<steps:
  var r = ran.sample()
  profile.start "set":
    b = comps.contains(r)
  profile.start "linear":
    for x in comps_s:
      if x == r: b = true; break

profile.log


# for i in 0..<steps:
#   var r = ran.sample()
#   profile.start "del":
#     b = comps.contains(r)

    #a.del(0)

# a = newSeq[int](10000)

# profile.start "delete":
#   for i in 0..<steps:
#     a.delete(0)

# profile.log





