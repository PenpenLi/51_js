--Delay(0.5)
Decode.act.delay = {}
function Decode.act.delay.checkType(str)
	if Decode.getActType(str) == "Delay" then
		return true;
	end
	return false;
end

function Decode.act.delay.create(str)
	local content = Decode.getActContent(str);
	-- print("delay = "..content);
	return cc.DelayTime:create(content),content;
end


