# import actors

# type ComponentDraw* = proc(self: ent)

# app.add ComponentDraw, CompType.Action 


# proc drawPlayer(self: ent) =

#    echo "player ", self.id
# proc drawMonster(self: ent) = echo "monster ", self.id

# var entities = newSeq[ent]()

# entities.add(layerApp.entity())
# entities[0].get ComponentDraw, drawPlayer


# entities.add(layerApp.entity())
# entities[1].get ComponentDraw, drawMonster

# layerApp.ecs.execute()

# for e in entities:
#   e.cdraw()


