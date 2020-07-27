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

var gr =  ecsMain.group(ComponentToo, ComponentFoo)
var gr2 = ecsMain.group(ComponentToo)
var gr3 = ecsMain.group(ComponentGoo, ComponentFoo)

var e1 = ecsMain.entity()
var e1cfoo = e1.get ComponentFoo
var e1ctoo = e1.get ComponentToo
e1cfoo.health = 10
ecsMain.execute
echo gr.entities.len, " ", gr2.entities.len, " ", gr3.entities.len
e1.get ComponentGoo
ecsMain.execute
echo gr.entities.len, " ", gr2.entities.len, " ", gr3.entities.len
e1.remove ComponentToo
ecsMain.execute
echo gr.entities.len, " ", gr2.entities.len, " ", gr3.entities.len