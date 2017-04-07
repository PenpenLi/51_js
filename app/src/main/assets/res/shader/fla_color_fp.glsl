#ifdef GL_ES
precision lowp float;
#endif
                                                        
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 v_multColor;
uniform vec4 v_baseColor;
                                                        
                                                        
void main()
{
    vec4 v_orColor =   texture2D(CC_Texture0, v_texCoord);    
    v_orColor=v_orColor*v_multColor+v_baseColor ; 
    gl_FragColor = v_orColor;
}