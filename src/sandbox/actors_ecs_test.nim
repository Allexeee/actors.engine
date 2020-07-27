import actors_ecs
import macros
import strformat
import strutils
import times
import tables
import sets
import typetraits 
import ../actors/actors_utils
#from actors_ecs import addNew

type ComponentFoo* = object
  health*: int
type ComponentToo* = object
  health*: int
type ComponentGoo* = object
  health*: int

ecs.add ComponentFoo
ecs.add ComponentToo
ecs.add ComponentGoo

#var incl = mask(CToo, CGoo)
#var excl = mask(CToo, CGoo)
# #mask(ComponentToo,ComponentToo)
# #var included = mask[ComponentToo, ComponentGoo]
# #var excluded = mask[ComponentGoo]
#echo incl[ComponentToo]
#var ggg = ecsMain.group(!(CToo), !(CToo))
#var ggg = ecsMain.group(+(CToo),-(CToo))


var gr  =  ecsMain.group(incl(CToo,CFoo))
var gr2 =  ecsMain.group(incl(CToo))
var gr3 =  ecsMain.group(incl(CGoo,CFoo), excl(ComponentToo))
# var gr =  ecsMain.group(ComponentToo, ComponentFoo)
# var gr2 = ecsMain.group(ComponentToo)
# var gr3 = ecsMain.group(ComponentGoo, ComponentFoo)

var s1 = {0,1,2}
var s2 = {3}

var s3 = {0,1,2,3}

if s1 <= s3 and not (s2 <= s3):
  echo "Pook"

var e1 = ecsMain.entity()
var e1cfoo = e1.get ComponentFoo
var e1ctoo = e1.get ComponentToo
e1cfoo.health = 10
ecsMain.execute
echo gr.entities.len, " ", gr2.entities.len, " ", gr3.entities.len
e1.get ComponentGoo
ecsMain.execute
echo gr.entities.len, " ", gr2.entities.len, " ", gr3.entities.len
#echo e1.exist
#e1.release
#ecsMain.execute
#echo e1.exist
echo gr.entities.len, " ", gr2.entities.len, " ", gr3.entities.len