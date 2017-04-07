gWords={}
gMapWords={}


function gGetWords(...)
    local params = {...}
    local size   = #params
    local file=params[1]
    local key=params[2]
    if(gWords[file]==nil)then
        gWords[file]=cc.FileUtils:getInstance():getValueMapFromFile("word/"..file) 
    end 

    if size <= 2 then
        if(gWords[file][key]==nil)then
            return ""
        end
        return gWords[file][key];
    end

    local words= string.split( gWords[file][key],"@")
    local ret=words[1]
    for key, var in pairs(params) do
    	if(key>=3 and words[key-1])then
            ret= ret..var..words[key-1]
    	end
    end
    if ret == nil then
        ret = "";
    end
    return ret
end

function gGetMapWords(...)
    local params = {...}
    local size   = #params
    local file=params[1]
    local key=params[2]
    if(gMapWords[file]==nil)then
        gMapWords[file]=cc.FileUtils:getInstance():getValueMapFromFile("mapWord/"..file) 
    end 

    if size <= 2 then
        if(gMapWords[file][key]==nil)then
            return ""
        end
        return gMapWords[file][key];
    end

    local words= string.split( gMapWords[file][key],"@")
    local ret=words[1]
    for key, var in pairs(params) do
        if(key>=3 and words[key-1])then
            ret= ret..var..words[key-1]
        end
    end
    if ret == nil then
        ret = "";
    end
    return ret
end


function gGetHttpCode(type,code)
    local ret=gGetWords("noticeWords.plist",type.."_"..code)
    if(ret==nil or string.len(ret)==0)then
        return code
    end
    return ret

end

function gGetCmdCodeWord(...)
    -- local word=gGetWords("netWords.plist",cmd.."_"..code)
    -- if(word~="nil" and string.len(word)~=0)then
    --     gShowNotice(word)
    -- end

    local params = {...}
    local size   = #params
    local file="netWords.plist";
    local cmd=params[1]
    local code = params[2]

    -- print("cmd = "..cmd .. " code ="..code);
    if(gWords[file]==nil)then
        gWords[file]=cc.FileUtils:getInstance():getValueMapFromFile("word/"..file) 
    end 

    local cmd_dict = gWords[file][cmd];
    if cmd_dict == nil then
        return "nil";
    end

    local words= string.split( cmd_dict[tostring(code)],"@")

    local ret=words[1]
    for key, var in pairs(params) do
        if(key>=3 and words[key-1])then
            ret= ret..var..words[key-1]
        end
    end
    
    return ret    
end
 
function gReplaceParam(...)
    local params = {...}
    local size   = #params
    local txt=params[1] 

    local words= string.split(txt,"@")
    local ret = words[1];
    -- local index = 1;
    for key,var in pairs(words) do
        if key >= 2 and words[key] then
            -- index = key+1;
            if params[key] then
                ret = ret..params[key]..var;
            else
                ret = ret.."@"..var;
            end
            -- if key <= table.getn(params) do
            --     ret = ret..params[key]..var;
            -- else
            --     ret = ret.."@"..var;    
            -- end
        end
    end
    -- local ret=words[1]
    -- for key, var in pairs(params) do
    --     if(key>=2 and words[key])then
    --         ret= ret..var..words[key]
    --     end
    -- end

    return ret

end

function gReplaceParamOnce(content,need_replace,cur_replace)
    local words= string.split(content,need_replace)
    local ret = words[1];
    
    for key,var in pairs(words) do
        if key >= 2 then
            if key == 2 then
                ret = ret..cur_replace..var;
            else
                ret = ret..""..var;
            end
        end
    end

    return ret
end
