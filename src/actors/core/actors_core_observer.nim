from sugar import `=>`, `->`
export `->`, `=>`

type
  Wrapper[TSource, TProp] =  ref object
    source: TSource
    val: TProp
    prop: proc(arg: TSource): TProp
    callback: proc(arg: TSource)
  
var storage = newSeq[proc()](0)

proc onChange*[TSource, TProp](source: TSource, prop:TSource -> TProp, callback: proc(src: TSource)): int {.discardable.} =
  
  let wrapper = new(Wrapper[TSource,TProp])
  wrapper.source = source
  wrapper.prop = prop
  wrapper.callback = callback

  storage.add(()=>(
    let next = wrapper.prop(source); 
    if wrapper.val!=next:
      wrapper.val = next
      wrapper.callback(source))
  )  
 
  return storage.len-1

template handleObserver*(): untyped =
  for action_id in 0..<storage.len:
    storage[action_id]()
  discard

template dispose*(arg: int): untyped =
  storage.delete(arg)