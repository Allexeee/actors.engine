#version 450 core
layout (location = 0) out vec4 color;

in vec4  v_color;
in vec2  v_texcoord;
in float v_texindex;

uniform sampler2D u_textures[2];

void main()
{
  int index = int(v_texindex);
  color = texture(u_textures[index],v_texcoord);
}