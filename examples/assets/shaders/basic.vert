#version 330 core
layout (location = 0) in vec2 vertex;

uniform mat4 mx_model;
uniform mat4 mx_projection;

void main()
{
 	gl_Position = mx_projection * mx_model * vec4(vertex.xy,0,1.0);
}