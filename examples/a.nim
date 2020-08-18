import actors
import macros

var dirty = false
var a = 0

proc dostuffA*() =
  a += 1
proc dostuffB*() =
  a += 1

macro testme3*(arg: untyped): untyped =
  var n = newStmtList()
  var nn = nnkIfStmt.newTree()
  var n1 = nnkElifBranch.newTree(
    ident($arg),
    nnkStmtList.newTree(
      newCall(ident("dostuffA"))
    )
  )
  var n2 = nnkElse.newTree(
    nnkStmtList.newTree(
      newCall(ident("dostuffB"))
    )
  )
  nn.insert(0,n1)
  nn.insert(1,n2)
  
  #n1.inject(0,ident(arg))
  result = nn

proc testme*() =
  dostuffA()

template testme2*() =
  if dirty:
    dostuffA()
  else: dostuffB()

dirty = true
for x in 0..<100000:
  profile.start "macro":
    testme3(dirty)
  profile.start "proc":
    testme()
  profile.start "templ":
    testme2()

dirty = false

profile.log