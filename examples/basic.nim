
# {.this: self.}

# type DB = object
#   arg *: int
#   arg2 *: int


# proc sumFields(self: ref DB): int =
#   result = arg + arg2
# proc bbb*(th: ref DB) =
#   th.arg = 1
#var dbo = db()

#{.this: self.}
# proc sumFields(self: DB) =
#   self.arg = 1
# template dd(a:untyped):typedesc[db] =
#   a: typedesc[db]

# proc getSprite(dd, arg: string) =
#   echo arg


# db.getSprite("alpaca")

# import acto rs

# var shader1 = db.getShader("basic")
# var spr     = db.getSprite("boo",shader1)
# var spr2    = db.getSprite("boo",shader1)
#app.getFullscreen
#var spr = db.getSprite("boo",shader1)

# type NameSpace1 = object
# type NameSpace2 = object

# template self*(): untyped =
#   NameSpace1

# proc testMe*(n: typedesc[NameSpace1], arg: int) = discard
# proc testMe*(n: typedesc[NameSpace2], arg: int) = discard



#testMe(self,0)

# with NameSpace1:
#   testMe(10)
#   echo ""

# block NameSpace1:
#   discard