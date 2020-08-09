# Package

version       = "0.1.0"
author        = "Pixeye"
description   = "Game Engine"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"


# Dependencies

requires "nim == 1.0.8"


task release, "BUILD":
   exec "nim c -d:release --passC:-flto --passL:-s --gc:refc --out: bin/game examples/test.nim"

task debug, "DEBUG":
   exec "nim c --debugger:gdb --d:debug --lineDir:on --passC:-flto --passL:-s --gc:refc --out: bin/game examples/test.nim"
# task make_docs, "BUILD":
#   exec "nim doc --project --index:on src/actors.nim"
#   exec "nim buildIndex -o:docs/index.html htmldocs"
 