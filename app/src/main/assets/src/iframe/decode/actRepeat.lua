-- Repeat(Item n,times)
Decode.act.repeatAct = {}
function Decode.act.repeatAct.checkType(str)
	if Decode.getActType(str) == "Repeat" then
		return true;
	end
	return false;
end

function Decode.act.repeatAct.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.Repeat:create(act,params[2]),time*params[2];
	end
end


-- RepeatForever(Item n)
Decode.act.repeatForever = {}
function Decode.act.repeatForever.checkType(str)
	if Decode.getActType(str) == "RepeatForever" then
		return true;
	end
	return false;
end

function Decode.act.repeatForever.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.RepeatForever:create(act),time;
end


