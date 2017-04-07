--Show()
Decode.act.show = {}
function Decode.act.show.checkType(str)
	if Decode.getActType(str) == "Show" then
		return true;
	end
	return false;
end

function Decode.act.show.create(str)
	return cc.Show:create(),0;
end

