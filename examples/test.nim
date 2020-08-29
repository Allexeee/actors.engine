import macros
import strformat, strutils
#import tester
# dumpTree:
#   from tester import testA


macro load*(modulesSeq: varargs[untyped]): untyped =
  result = newStmtList()
  for m in modulesSeq:
    echo m
    #result.add(nnkFromStmt.newTree(ident(&"{m}"), ident("testA")))

load tester

#testA()

# macro load*(modulesSeq: varargs[untyped]): untyped =
#   result = newStmtList()
#   for module in modulesSeq:
    #result.add parseStmt("from " & $module & " import testA")


#load(tester)
# load tester


# macro echoName(x: untyped): untyped =
#   let name = $name(x)
#   let node = nnkCommand.newTree(newIdentNode(!"echo"), newLit(name))
#   insert(body(x), 0, node)
#   # echo "treeRepr = ", treeRepr(x)
#   result = x

# proc add*(p: int): int {.echoName.} =
#   result = p + 1

# proc process*(p: int) {.echoName.} =
#   echo "ans for ", p, " is ", add(p)

# process(5)
# process(8)