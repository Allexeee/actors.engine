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

proc healthEvents()

var included = mask(CToo,CFoo)
var excluded = mask(CGoo)
var healths  = group(ecsMain,included)
healths.events.add(healthEvents)

var e1 = ecsMain.entity()
var foo = e1.get ComponentFoo
ecsMain.execute
echo healths.entities.len
var too = e1.get ComponentToo
ecsMain.execute
echo healths.entities.len
echo e1.exist
e1.release

echo e1.exist
ecsMain.execute
echo e1.exist
echo healths.entities.len

proc healthEvents() =
  for e in healths.entities_added:
    echo e.id, "___BA"
  discard


