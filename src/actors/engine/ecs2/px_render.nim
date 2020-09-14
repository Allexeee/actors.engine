import px_ecs
import test



for ca in ecsQuery CompA:
  ca.arg = 1


var e = entGet()
var ca = e.get CompA
