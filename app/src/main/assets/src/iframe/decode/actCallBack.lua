-- PlayFlash(name,loop,endDel)
Decode.act.playflash = {}
function Decode.act.playflash.checkType(str)
	if Decode.getActType(str) == "PlayFlash" then
		return true;
	end
	return false;
end

function Decode.act.playflash.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 3 then
		-- print_lua_table(cc);
		-- local callback = function()
		-- 	print("xxxx");
		-- 	local ani = FlashAni.new();
		-- 	ani:playAct(params[1],toint(params[3]),params[2]);
		-- 	node:addChild(ani);
		-- end
		-- return cc.CallFunc:create(callback);
		local act = cc.CallFunc:create(playflash,{name=params[1],loop=params[2],endDel=toint(params[3])});
		return act,0;
		-- return cc.CallFunC:create(remove);
	end
end

function playflash(node,data)
	local ani = FlashAni.new();
	ani:playAct(data.name,data.endDel,data.loop);
	gAddChildByAnchorPos(node,ani,node:getAnchorPoint());
	-- node:addChild(ani);
end
