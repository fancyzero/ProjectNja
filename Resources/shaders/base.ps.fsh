#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_fragmentMaskColor;
uniform sampler2D u_texture;


void main()
{
	//gl_FragColor = v_fragmentMaskColor;
	
    vec4 clr = texture2D(u_texture, v_texCoord); 
    //clr.r = clr.a*v_fragmentMaskColor.r*u_color_mask + clr.r*(1.0-u_color_mask);
    //clr.g = clr.a*v_fragmentMaskColor.g*u_color_mask + clr.g*(1.0-u_color_mask);
    //clr.b = clr.a*v_fragmentMaskColor.b*u_color_mask + clr.b*(1.0-u_color_mask);
	clr.r = clr.a*v_fragmentMaskColor.r*v_fragmentMaskColor.a + clr.r*(1.0-v_fragmentMaskColor.a);
	clr.g = clr.a*v_fragmentMaskColor.g*v_fragmentMaskColor.a + clr.g*(1.0-v_fragmentMaskColor.a);
	clr.b = clr.a*v_fragmentMaskColor.b*v_fragmentMaskColor.a + clr.b*(1.0-v_fragmentMaskColor.a);
    gl_FragColor = v_fragmentColor * clr;
	
}