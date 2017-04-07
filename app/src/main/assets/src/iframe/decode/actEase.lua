-- EaseIn(Item n,rate)
Decode.act.easeIn = {}
function Decode.act.easeIn.checkType(str)
	if Decode.getActType(str) == "EaseIn" then
		return true;
	end
	return false;
end

function Decode.act.easeIn.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.EaseIn:create(act,params[2]),time;
	end
end

-- EaseOut(Item n,rate)
Decode.act.easeOut = {}
function Decode.act.easeOut.checkType(str)
	if Decode.getActType(str) == "EaseOut" then
		return true;
	end
	return false;
end

function Decode.act.easeOut.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.EaseOut:create(act,params[2]),time;
	end
end

-- EaseInOut(Item n,rate)
Decode.act.easeInOut = {}
function Decode.act.easeInOut.checkType(str)
	if Decode.getActType(str) == "EaseInOut" then
		return true;
	end
	return false;
end

function Decode.act.easeInOut.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.EaseInOut:create(act,params[2]),time;
	end
end




-- EaseExponentialIn(Item n)
Decode.act.easeExponentialIn = {}
function Decode.act.easeExponentialIn.checkType(str)
	if Decode.getActType(str) == "EaseExponentialIn" then
		return true;
	end
	return false;
end

function Decode.act.easeExponentialIn.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseExponentialIn:create(act),time;
end

-- EaseExponentialOut(Item n)
Decode.act.easeExponentialOut = {}
function Decode.act.easeExponentialOut.checkType(str)
	if Decode.getActType(str) == "EaseExponentialOut" then
		return true;
	end
	return false;
end

function Decode.act.easeExponentialOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseExponentialOut:create(act),time;
end

-- EaseExponentialInOut(Item n)
Decode.act.easeExponentialInOut = {}
function Decode.act.easeExponentialInOut.checkType(str)
	if Decode.getActType(str) == "EaseExponentialInOut" then
		return true;
	end
	return false;
end

function Decode.act.easeExponentialInOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseExponentialInOut:create(act),time;
end



-- EaseSineIn(Item n)
Decode.act.easeSineIn = {}
function Decode.act.easeSineIn.checkType(str)
	if Decode.getActType(str) == "EaseSineIn" then
		return true;
	end
	return false;
end

function Decode.act.easeSineIn.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseSineIn:create(act),time;
end

-- EaseSineOut(Item n)
Decode.act.easeSineOut = {}
function Decode.act.easeSineOut.checkType(str)
	if Decode.getActType(str) == "EaseSineOut" then
		return true;
	end
	return false;
end

function Decode.act.easeSineOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseSineOut:create(act),time;
end

-- EaseSineInOut(Item n)
Decode.act.easeSineInOut = {}
function Decode.act.easeSineInOut.checkType(str)
	if Decode.getActType(str) == "EaseSineInOut" then
		return true;
	end
	return false;
end

function Decode.act.easeSineInOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseSineInOut:create(act),time;
end




-- EaseElasticIn(Item n,period)
Decode.act.easeElasticIn = {}
function Decode.act.easeElasticIn.checkType(str)
	if Decode.getActType(str) == "EaseElasticIn" then
		return true;
	end
	return false;
end

function Decode.act.easeElasticIn.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.EaseElasticIn:create(act,params[2]),time;
	end
end

-- EaseElasticOut(Item n,period)
Decode.act.easeElasticOut = {}
function Decode.act.easeElasticOut.checkType(str)
	if Decode.getActType(str) == "EaseElasticOut" then
		return true;
	end
	return false;
end

function Decode.act.easeElasticOut.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.EaseElasticOut:create(act,params[2]),time;
	end
end

-- EaseElasticInOut(Item n,period)
Decode.act.easeElasticInOut = {}
function Decode.act.easeElasticInOut.checkType(str)
	if Decode.getActType(str) == "EaseElasticInOut" then
		return true;
	end
	return false;
end

function Decode.act.easeElasticInOut.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.EaseElasticInOut:create(act,params[2]),time;
	end
end



-- EaseBounceIn(Item n)
Decode.act.easeBounceIn = {}
function Decode.act.easeBounceIn.checkType(str)
	if Decode.getActType(str) == "EaseBounceIn" then
		return true;
	end
	return false;
end

function Decode.act.easeBounceIn.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseBounceIn:create(act),time;
end

-- EaseBounceOut(Item n)
Decode.act.easeBounceOut = {}
function Decode.act.easeBounceOut.checkType(str)
	if Decode.getActType(str) == "EaseBounceOut" then
		return true;
	end
	return false;
end

function Decode.act.easeBounceOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseBounceOut:create(act),time;
end

-- EaseBounceInOut(Item n)
Decode.act.easeBounceInOut = {}
function Decode.act.easeBounceInOut.checkType(str)
	if Decode.getActType(str) == "EaseBounceInOut" then
		return true;
	end
	return false;
end

function Decode.act.easeBounceInOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseBounceInOut:create(act),time;
end




-- EaseBackIn(Item n)
Decode.act.easeBackIn = {}
function Decode.act.easeBackIn.checkType(str)
	if Decode.getActType(str) == "EaseBackIn" then
		return true;
	end
	return false;
end

function Decode.act.easeBackIn.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseBackIn:create(act),time;
end

-- EaseBackOut(Item n)
Decode.act.easeBackOut = {}
function Decode.act.easeBackOut.checkType(str)
	if Decode.getActType(str) == "EaseBackOut" then
		return true;
	end
	return false;
end

function Decode.act.easeBackOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseBackOut:create(act),time;
end

-- EaseBackInOut(Item n)
Decode.act.easeBackInOut = {}
function Decode.act.easeBackInOut.checkType(str)
	if Decode.getActType(str) == "EaseBackInOut" then
		return true;
	end
	return false;
end

function Decode.act.easeBackInOut.create(str)
	local content = Decode.getActContent(str);
	local act,time = Decode.getActByItemName(content);
	return cc.EaseBackInOut:create(act),time;
end
