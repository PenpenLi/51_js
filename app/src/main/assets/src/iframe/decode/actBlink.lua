--Blink(time,times)
Decode.act.blink = {}
function Decode.act.blink.checkType(str)
	if Decode.getActType(str) == "Blink" then
		return true;
	end
	return false;
end

function Decode.act.blink.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		return cc.Blink:create(params[1],params[2]),params[1];
	end
end


