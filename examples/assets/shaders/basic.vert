#version 330 core
layout (location = 0) in vec2 vertex;
layout (location = 1) in vec4 v;
uniform mat4 mx_model;
uniform mat4 mx_projection;

out vec4 vv;

void main()
{
	vv = v;
 	gl_Position = mx_projection * mx_model * vec4(vertex.xy,0,1.0);
}