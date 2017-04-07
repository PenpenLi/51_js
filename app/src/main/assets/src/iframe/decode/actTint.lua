-- TintTo(time,R,G,B)
Decode.act.tintTo = {}
function Decode.act.tintTo.checkType(str)
	if Decode.getActType(str) == "TintTo" then
		return true;
	end
	return false;
end

function Decode.act.tintTo.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 4 then
		return cc.TintTo:create(params[1],params[2],params[3],params[4]),params[1];
	end
end

-- TintBy(time,R,G,B)
Decode.act.tintBy = {}
function Decode.act.tintBy.checkType(str)
	if Decode.getActType(str) == "TintBy" then
		return true;
	end
	return false;
end

function Decode.act.tintBy.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 4 then
		return cc.TintBy:create(params[1],params[2],params[3],params[4]),params[1];
	end
end


