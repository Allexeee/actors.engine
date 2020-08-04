import types/actors_types_public
import types/actors_types_private

var app* : App

var origins* = @[
  (-0.5f,-0.5f), # center
  (0f,0f),       # bottom-left
  (1f,1f),
  # (0.5f,-0f),       # bottom-right
  # (0f,-0.5f),
  # (0.5f,-0.5f)
]

export actors_types_public
export actors_types_private