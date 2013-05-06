#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_fragmentMaskColor;
uniform sampler2D u_texture;


void main()
{
    vec4 clr = texture2D(u_texture, v_texCoord); 
    //clr.r = clr.a*u_mask_color.r*u_color_mask + clr.r*(1.0-u_color_mask);
    //clr.g = clr.a*u_mask_color.g*u_color_mask + clr.g*(1.0-u_color_mask);
    //clr.b = clr.a*u_mask_color.b*u_color_mask + clr.b*(1.0-u_color_mask);
	//clr = clr.a * u_color_mask * u_color_mask *clr;

    gl_FragColor = v_fragmentColor * clr * v_fragmentMaskColor;
}