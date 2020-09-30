# Package

version       = "0.1.0"
author        = "Pixeye"
description   = "Game Engine"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"


# Dependencies

requires "nim >= 1.0.8"

task releasec, "Build":
   exec "nim c -d:release --passC:-flto --passL:-s --gc:refc --out: bin/game examples/test.nim"
task releasecpp, "Build":
   exec "nim cpp -d:release --passC:-flto --passL:-s --gc:refc --out: bin/game examples/test.nim"


task release, "BUILD":
   exec "nim c -d:release --gc:boehm --out: bin/game examples/basic_rendering2.nim"

task debug, "DEBUG":
   exec "nim c --d:debug  --out: bin/game examples/basic_rendering2.nim"
# task make_docs, "BUILD":
#   exec "nim doc --project --index:on src/actors.nim"
#   exec "nim buildIndex -o:docs/index.html htmldocs"
 