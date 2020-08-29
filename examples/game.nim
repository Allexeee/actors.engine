import actors

logAdd stdout


proc init =
  discard
proc update =
  discard
proc draw =
  discard


app.run(init,update,draw)

# proc init*() =
#   makeUIDebug().add()
#   discard

# proc update*() =
#   if input.down Key.Esc:
#     app.quit()

# proc draw*() =
#   for ui in uis:
#     ui.draw()
#   discard

# app.run(init,update,draw)