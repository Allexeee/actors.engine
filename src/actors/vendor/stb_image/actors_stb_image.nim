{.pragma: stbcall, cdecl.}
{.compile: "stb_image.c".}


type
  STBIException* = object of ValueError


proc stbi_load*(filename: cstring, x,y, comp: var cint, req_comp: int):
 ptr cuchar {.importc: "stbi_load".}

proc stbi_image_free*(data: ptr cchar)
    {.importc: "stbi_image_free".}

proc stbi_failure_reason*(): cstring
    {.importc: "stbi_failure_reason".}

proc stbi_set_flip_vertically_on_load*(flag_true_if_should_flip: cint)
    {.importc: "stbi_set_flip_vertically_on_load".}

proc stbi_set_flip_vertically_on_load_thread*(flag_true_if_should_flip: cint)
    {.importc: "stbi_set_flip_vertically_on_load_thread".}

proc failureReason*(): string =
  ## threadsafe function
  return $stbi_failure_reason()


