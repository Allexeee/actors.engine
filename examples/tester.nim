import actors

proc init*() =
  makeUIDebug().add()
  discard

proc update*() =
  if input.down Key.Esc:
    app.quit()

proc draw*() =
  for ui in uis:
    ui.draw()
  discard
echo sizeof(int)
app.run(init,update,draw)