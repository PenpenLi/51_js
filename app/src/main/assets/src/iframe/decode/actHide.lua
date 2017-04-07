--Hide()
Decode.act.hide = {}
function Decode.act.hide.checkType(str)
	if Decode.getActType(str) == "Hide" then
		return true;
	end
	return false;
end

function Decode.act.hide.create(str)
	return cc.Hide:create(),0;
end

