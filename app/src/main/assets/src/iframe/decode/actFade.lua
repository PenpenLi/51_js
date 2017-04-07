-- FadeIn(time)
Decode.act.fadeIn = {}
function Decode.act.fadeIn.checkType(str)
	if Decode.getActType(str) == "FadeIn" then
		return true;
	end
	return false;
end

function Decode.act.fadeIn.create(str)
	local content = Decode.getActContent(str);
	return cc.FadeIn:create(content),content;
end

-- FadeOut(time)
Decode.act.fadeOut = {}
function Decode.act.fadeOut.checkType(str)
	if Decode.getActType(str) == "FadeOut" then
		return true;
	end
	return false;
end

function Decode.act.fadeOut.create(str)
	local content = Decode.getActContent(str);
	return cc.FadeOut:create(content),content;
end

-- FadeTo(time,[0,255])
Decode.act.fadeTo = {}
function Decode.act.fadeTo.checkType(str)
	if Decode.getActType(str) == "FadeTo" then
		return true;
	end
	return false;
end

function Decode.act.fadeTo.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		return cc.FadeTo:create(params[1],params[2]),params[1];
	end
end
