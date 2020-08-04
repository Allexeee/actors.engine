#version 330 core
out vec4 color;
uniform vec3 sprite_color;

in vec4 vv;

void main()
{
  color = vv;//vec4(vv, sprite_color.gb, 1.0);
}