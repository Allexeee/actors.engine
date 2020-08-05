#version 450 core
layout (location = 0) in vec3  a_position;
layout (location = 1) in vec4  a_color;
layout (location = 2) in vec2  a_texcoord;
layout (location = 3) in float a_texindex;

//layout (location = 1) in vec4 v;
uniform mat4 mx_model;
uniform mat4 mx_projection;

out vec4  v_color;
out vec2  v_texcoord;
out float v_texindex;

void main()
{
	v_color = a_color;
 	v_texcoord = a_texcoord;
	v_texindex = a_texindex;
	gl_Position = mx_projection * vec4(a_position,1.0);
}