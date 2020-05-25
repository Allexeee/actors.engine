from ../actors_core import app
from ../actors_core import Display

proc getWidth*(self: var Display): int {.inline.} =
  app.settings.display_size.width

proc getHeight*(self: var Display): int {.inline.} =
  app.settings.display_size.height

proc getAspectRatio*(self: var Display): float32 {.inline.} =
  app.settings.display_size.width / app.settings.display_size.height