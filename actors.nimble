# Package

version       = "0.1.0"
author        = "Pixeye"
description   = "Game Engine"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"


# Dependencies

requires "nim >= 1.0.6"


task make_release, "BUILD":
   exec "nim cpp -d:release --passC:-flto --passL:-s --gc:refc --out: bin/game examples/game.nim"

# task make_docs, "BUILD":
#   exec "nim doc --project --index:on src/actors.nim"
#   exec "nim buildIndex -o:docs/index.html htmldocs"
 