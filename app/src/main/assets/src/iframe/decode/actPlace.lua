--Place({100,0})
Decode.act.place = {}
function Decode.act.place.checkType(str)
	if Decode.getActType(str) == "Place" then
		return true;
	end
	return false;
end

function Decode.act.place.create(str)
	local content = Decode.getActContent(str);
	local posStr = string.sub(content,2,-2);
	local pos = string.split(posStr,",");
	return cc.Place:create(cc.p(pos[1],pos[2])),0;
end


