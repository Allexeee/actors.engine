import ../../actors_h

const ENTS_INIT_SIZE* = 102048

type
  ent* = tuple[id: int, age: int]
  entid* = distinct int
  cid*   = uint16
  ecsid* = distinct int

  EntityMeta* = object
    layer*    : LayerID
    childs*   : seq[ent]
    alive*    : bool
    age*      : int

  SystemEcs* = object
    groups* : seq[Group]
  
  Group* = ref object of RootObj
    id*               : uint16
    layer*            : LayerID
    signature*        : set[cid]
    signature_excl*   : set[cid]
    entities*         : seq[ent]
  
  CompStorageBase* = ref object of RootObj
     compType*     : string
     groups*       : seq[Group]
     id*           : cid
     indices*      : seq[int] # sparse 
     entities*     : seq[ent] # packed
     filterid*     : int
  
  CompStorage*[T] = ref object of CompStorageBase
     comps*      : seq[T]   

template none*(T: typedesc[ent]): ent =
  (int.high,0)

proc `$`*(self: ent): string =
    $self.id


var ents_meta*  = newSeqOfCap[EntityMeta](ENTS_INIT_SIZE)
var ents_free*  = newSeqOfCap[ent](ENTS_INIT_SIZE)
var layers*     = newSeq[SystemEcs]()
var storages*   = newSeq[CompStorageBase]()
#var ecs* = 0.ecsid
#var storages* : seq[CompStorageBase]#= newSeq[CompStorageBase]()
#storages = newSeq[CompStorageBase](10)
