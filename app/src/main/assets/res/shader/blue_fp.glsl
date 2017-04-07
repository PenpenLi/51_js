#ifdef GL_ES
precision lowp float;
#endif
                                                        
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
                                                        
                                                        
void main()
{
    vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
    v_orColor *= vec4(0.8, 0.8, 1.0, 1); 
    gl_FragColor = v_orColor;
    
}