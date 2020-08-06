{.pragma: stbcall, cdecl.}
{.compile: "stb_image/stb_image.c".}


type STBIException* = object of ValueError

const
  # Used by req_comp
  Default* = 0          # (for stb_image)
  # Monochrome
  Grey* = 1             # (for stb_image)
  Y* = 1                # (for stb_image_write)
  # Monochrome w/ Alpha
  GreyAlpha* = 2        # (for stb_image) 
  YA* = 2               # (for stb_image_write)
  # Red, Green, Blue (and alpha)
  RGB* = 3              # (used by all)
  RGBA* = 4             # (used by all)

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


