
# meta[1] = (a shl 16) and 0xFF
# meta[2] = (a shl 8) and 0xFF
# meta[3] = a and 0xFF

# unsigned char bytes[4];
# unsigned long n = 175;

# bytes[0] = (n >> 24) & 0xFF;
# bytes[1] = (n >> 16) & 0xFF;
# bytes[2] = (n >> 8) & 0xFF;
# bytes[3] = n & 0xFF;

# int id3 = byte0 + (byte1 << 8) + (byte2 << 16);


#import ../ecs/pixecs
#ecsInit()
import px_ecs
px_ecs_init()

type CompA* = object
  arg*: int

type TagB = distinct int



ecsAdd CompA
ecsAdd TagB, AsTag

var gr = ecsGroup CompA

var e = entGet()
var cca = e.get CompA
var ccaa = e.get CA

var ccap = e.compa
#px_ecs_comp_get
e.inc TagB, 5
echo e.tagb
echo e.ca.arg

e.del()

for ca in ecsQuery CompA:
  ca.arg = 1



# entDel(e)


# del()
# e.del()
# ecsFree();

# entFree(e)

# entFree(e)

# e.free()
# ecsFree()

# e.del()#
# e.free()
# ecsAdd CompA

# var e = entGet()
# var cca = e.get CompA
# e.compa.arg = 10



# px.tester(10)

# ecsGet CompA