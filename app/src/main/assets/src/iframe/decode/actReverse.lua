--Reverse(Item n)
Decode.act.reverse = {}
function Decode.act.reverse.checkType(str)
	if Decode.getActType(str) == "Reverse" then
		return true;
	end
	return false;
end

function Decode.act.reverse.create(str)
	local content = Decode.getActContent(str);
	return cc.ReverseTime:create(Decode.getActByItemName(content));
end


