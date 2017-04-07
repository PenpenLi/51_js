Shader={}

Shader.GRAY_SHADER="luaShaderGray"
Shader.BLUE_SHADER="luaShaderBlue"
Shader.FLA_COLOR_SHADER="luaShaderFlaColor"
Shader.FLA_SHADOW_SHADER="luaShadowFlaColor"
Shader.FLA_SHADOW_BLACK_SHADER="luaShadowBlackFlaColor"
Shader.UV_ANI_SHADER="luaShaderUVAni"

function Shader.getShader(name)
    local ret=  cc.GLProgramCache:getInstance():getGLProgram(name)
    if(ret~=nil)then
        return ret
    end

    print("create shader "..name)
    local shader =nil
    if(name==Shader.GRAY_SHADER)then
        shader = cc.GLProgram:createWithFilenames("shader/gray_vp.glsl","shader/gray_fp.glsl")
     
    elseif(name==Shader.FLA_SHADOW_SHADER)then
        shader = cc.GLProgram:createWithFilenames("shader/shadow_vp.glsl","shader/shadow_fp.glsl") 
    elseif(name==Shader.FLA_SHADOW_BLACK_SHADER)then
        shader = cc.GLProgram:createWithFilenames("shader/shadow_vp_black.glsl","shader/shadow_fp_black.glsl")  
    elseif(name==Shader.FLA_COLOR_SHADER)then
        shader = cc.GLProgram:createWithFilenames("shader/fla_color_vp.glsl","shader/fla_color_fp.glsl")
        
    elseif(name==Shader.UV_ANI_SHADER)then
        shader = cc.GLProgram:createWithFilenames("shader/uv_ani_vp.glsl","shader/uv_ani_fp.glsl")

    elseif(name==Shader.BLUE_SHADER)then
        shader = cc.GLProgram:createWithFilenames("shader/blue_vp.glsl","shader/blue_fp.glsl")

    end

    if(shader)then
        Shader.addShader(name ,shader)
        
    end
    return shader

end

function Shader.addShader(name ,shader)
    cc.GLProgramCache:getInstance():addGLProgram(shader,name)
end

Shader.getShader(Shader.FLA_COLOR_SHADER)
Shader.getShader(Shader.FLA_SHADOW_SHADER)
Shader.getShader(Shader.FLA_SHADOW_BLACK_SHADER)
Shader.getShader(Shader.GRAY_SHADER)
Shader.getShader(Shader.BLUE_SHADER)