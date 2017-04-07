#ifdef GL_ES
precision lowp float;
#endif
                                                        
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
                                                        
                                                        
void main()
{
    vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
    vec3 gray = vec3(0.58,0.239,0.204)*v_orColor.a;
    gl_FragColor = vec4(gray.r,gray.g,gray.b, v_orColor.a);
    
}