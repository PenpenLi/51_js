local ActivityVipPanel=class("ActivityVipPanel",UILayer)

function ActivityVipPanel:ctor(data)
    self:init("ui/ui_hd_tongyong1.map")

    self.curData=data
    
    self:getNode("vip_layer"):setVisible(true)
    self:getNode("txt_info"):setVisible(false)

    self.bolOver = false;

    self.txt_vip1 = self:getNode("txt_vip1");self.txt_vip1:setVisible(true)
	self.txt_vip2 = self:getNode("txt_vip2");self.txt_vip1:setVisible(true)
	self.txt_vip3 = self:getNode("txt_vip3");self.txt_vip1:setVisible(true)
    
    self:getNode("btn_lab"):setString(gGetWords("btnWords.plist","btn_get_reward")) 
    
    self:refreshTxt();
end

function ActivityVipPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_VIP)then
        self:refreshTxt()
    end
end

function ActivityVipPanel:getVipLevelIndex(vip)
	local mixVip = toint(Data.activity.vip_get[1]);
	if (vip<mixVip) then
		return 1;
	end
	local maxLen = table.getn(Data.activity.vip_get);
	local maxVip = toint(Data.activity.vip_get[maxLen]);
	if (vip>=maxVip) then
		return maxLen;
	end
	local index = 1;
	for k,v in pairs(Data.activity.vip_get) do
		if (vip >= toint(v)) then
			-- print("vip="..vip..",v="..toint(v));
			index = k + 1;
		end
	end
	-- print("index = "..index)
	return index;
end

function ActivityVipPanel:getVip()
	self.index = self:getVipLevelIndex(Data.getCurVip())
	return Data.activity.vip_get[self.index];
end

function ActivityVipPanel:getVipLevel(index)
	local maxLen = table.getn(Data.activity.vip_get_level)
	local newIndex = math.min(index,maxLen);
	local level = toint(Data.activity.vip_get_level[newIndex]);
	return level;
end

function ActivityVipPanel:refreshTxt()
    self.index = self:getVipLevelIndex(Data.getCurVip())
    local level = self:getVipLevel(self.index);
	self:replaceRtfString("txt_vip3",level,self:getVip());
	self:replaceRtfString("txt_vip2",Data.getCurVip());

    local mixVip = toint(Data.activity.vip_get[1]);
	if (Data.getCurVip()<mixVip) then--第一次
		self.txt_vip1:setVisible(true)
		self.txt_vip2:setVisible(false)
	else
		self.txt_vip1:setVisible(false)
		self.txt_vip2:setVisible(true)
	end

    self.bolOver = false;
	local maxLen = table.getn(Data.activity.vip_get);
    local maxGetVip = toint(Data.activity.vip_get[maxLen]);
    -- print("maxGetVip="..maxGetVip)
    if (Data.getCurVip()>=maxGetVip) then
        self.bolOver = true;
        self:setTouchEnableGray("btn_go",false);
        self.txt_vip3:setVisible(false)
    end
end

function ActivityVipPanel:dealGet()
	local level = self:getVipLevel(self.index);
	if (Data.getCurLevel()<level) then--等级不足
		local sWord = gGetWords("activityNameWords.plist","vip_level");
        gShowNotice(sWord)
		return;
	end
	if (self.bolOver==false) then
		-- print("self.index="..self.index)
		Net.sendGetVip(self.index-1)
	end
end

function ActivityVipPanel:onTouchEnded(target)
    if  target.touchName=="btn_go"then
        -- Panel.popUp(PANEL_ATLAS)
        self:dealGet();
    end
end

return ActivityVipPanel