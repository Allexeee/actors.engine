import actors_types_opengl
import ../../../vendor/actors_gl
import ../../../vendor/actors_stb_image
import ../../../actors_engine


include actors_opengl_shaders

export actors_types_opengl


proc loadTexture*(path: string, mode_rgb: ModeRGB, mode_filter: ModeFilter, mode_wrap: ModeWrap): GLuint =
  var w,h,bits : cint
  var textureID : GLuint
  stbi_set_flip_vertically_on_load(true.ord)
  var data = stbi_load(path_assets & path, w, h, bits, 0)
  glCreateTextures(GL_TEXTURE_2D, 1, textureID.addr)
  glBindTexture(GL_TEXTURE_2D, textureID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mode_filter.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mode_wrap.Glint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mode_wrap.Glint)
  glTexImage2D(GL_TEXTURE_2D, 0.Glint, mode_rgb.Glint, w, h, 0.Glint, mode_rgb, GL_UNSIGNED_BYTE, data)
  stbi_image_free(data)
  textureID
