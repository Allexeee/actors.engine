{.used.}
{.experimental: "codeReordering".}
import actors

#let app* = getApp()

app.settings.fps = 60
app.settings.name = "Game"
app.settings.display_size = (1920, 1080)

 
#var lr_ecs_game = ecs.addLayer()
 
type ComponentHealth* = object
  val: int
type ComponentAI* = object
type ComponentBurning* = object
type ComponentAnimal* = object

ecs.add ComponentHealth
ecs.add ComponentAI
ecs.add ComponentBurning
ecs.add ComponentAnimal

# var e1 = ecsMain.entity()
# var foo = e1.get ComponentAI
#var too = e1.get ComponentHealth
proc newAnimal(): ent = 
  result = entity(lrMain.sysEcs)
  result.get ComponentHealth
  result.get ComponentAI
  result.get ComponentBurning
  result.get ComponentAnimal


var included = mask(ComponentHealth,ComponentAI,ComponentBurning,ComponentAnimal)
var animals  = group(lrMain.sysEcs,included)

#ecs.group burning_animals:
#  comps: (ComponentHealth,ComponentAI,ComponentBurning,ComponentAnimal)

var alpaca = newAnimal()

app.start:
   echo "blazing"

app.run:
  echo animals.entities.len
  for entity in animals:
    entity.chealth.val += 10
  if input.down escape:
    app.quit()

app.close:
  log alpaca.chealth.val
  echo "alpaca" 
