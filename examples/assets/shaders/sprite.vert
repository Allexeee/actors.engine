#version 330 core
layout (location = 0) in vec4 vertex;

out vec2 tex_coords;

uniform mat4 mx_model;
uniform mat4 mx_projection;

void main()
{
	tex_coords = vertex.zw;
	gl_Position = mx_projection * mx_model * vec4(vertex.xy,0,1.0);
	//gl_Position = mx_projection * mx_model * vec4(vertex.xy,0,1.0);
}
