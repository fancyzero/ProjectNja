
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
attribute vec4 a_mask_color;

uniform		mat4 u_MVPMatrix;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying lowp vec4 v_fragmentMaskColor;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_fragmentMaskColor;
#endif
void main()
{
    gl_Position = u_MVPMatrix * a_position;
	v_fragmentColor = a_color;
	v_texCoord = a_texCoord;
	v_fragmentMaskColor = a_mask_color;
}
