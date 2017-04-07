Decode={}
Decode.act = {}
Decode.actions = {};

function Decode.decodeAction(data)
    
    -- print_lua_table(data);
    local act = nil;
	Decode.actions = {};
    --actions
    for key,var in pairs(data.actions) do
    	table.insert(Decode.actions,{itemName = "Item "..(key-1),itemContent = var});
    end

    -- print_lua_table(Decode.actions);

    --runAction
    act,time = Decode.getActByItemName(data.runAction);

    return act,time;
end

function Decode.getActByItemName(itemName)
    for key,var in pairs(Decode.actions) do
    	if var.itemName == itemName then
    		return Decode.decodeOneActionString(var.itemContent);
    	end
    end
    return nil;
end

function Decode.decodeOneActionString(str)
	for key,var in pairs(Decode.act) do
		if var.checkType(str) then
			return var.create(str);
		end
	end
end

-- str = "Hide()"
function Decode.getActType(str)
	-- print("Decode.getActType = "..str);
	local index = string.find(str,"%(");
	if index ~= nil then
		local actType = string.sub(str,1,index-1);
		-- print("actType = "..actType);
		return actType;
	end
	return "";
end
function Decode.getActContent(str)
	local startIndex = string.find(str,"%(");
	local endIndex = string.find(str,"%)",-1);
	if startIndex ~= nil and endIndex ~= nil then
		local actContent = string.sub(str,startIndex+1,endIndex-1);
		-- print("actContent" .. actContent);
		return actContent;
	end
	return "";
end

