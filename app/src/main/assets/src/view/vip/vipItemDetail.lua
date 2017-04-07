local VipItemDetail=class("VipItemDetail",UILayer)

function VipItemDetail:ctor(vipItem)
    self:init("ui/ui_vip_item_detail.map")
    self.vipItem = vipItem
    self.isExtend = false;
end

function VipItemDetail:setExtend(isExtend)
	if(self.isExtend == isExtend)then
		return;
	end
	self.isExtend = isExtend;
	self:getNode("bg_content"):setVisible(self.isExtend);
	local size = self:getContentSize();
	if(self.isExtend)then
		size.height = size.height + self:getNode("bg_content"):getContentSize().height;
	else
		size.height = size.height - self:getNode("bg_content"):getContentSize().height;
	end
	self:setContentSize(size);
	self:resetLayOut();
	self.vipItem:resetContainerSize();
end

function VipItemDetail:onTouchEnded(target)
	if(target.touchName == "btn")then
		local isExtend = self.isExtend;
		self.vipItem:closeAllItemExtend();
		self:setExtend(not isExtend);
		-- self.isExtend = not self.isExtend;
		-- self:getNode("bg_content"):setVisible(self.isExtend);
		-- local size = self:getContentSize();
		-- if(self.isExtend)then
		-- 	size.height = size.height + self:getNode("bg_content"):getContentSize().height;
		-- else
		-- 	size.height = size.height - self:getNode("bg_content"):getContentSize().height;
		-- end
		-- self:setContentSize(size);
		-- self.vipItem:resetContainerSize();
	end
end


function VipItemDetail:setData(type,vip,heightlight)
	local value = DB.getVipValue(vip,type);
	if type == 100 then
		value = vip.vip - 1;
	end

	self:getNode("btn"):setVisible(false);
	self:getNode("bg_content"):setVisible(false);
    if heightlight then
    	self:getNode("txt_info").defaultColor = cc.c3b(169,249,51);
    	-- self:getNode("txt_info"):setDefaultConfig(cc.c3b(169,249,51));
		self:getNode("btn"):setVisible(true);
		-- self:getNode("bg_content"):setVisible(true);
		self:setLabelString("txt_content",gGetWords("vipWords.plist","content"..type));
		-- local size = self:getNode("txt_content"):getContentSize();
		-- if(size.height<20)then
			-- size.height = 20;
		-- end
		-- size.width = self:getNode("bg_content"):getContentSize().width;
		-- size.height = size.height + 8*2;
		-- self:getNode("bg_content"):setContentSize(size);
		-- self:getNode("txt_content"):setPositionY(size.height - 8);
		self:adaptNode(self:getNode("bg_content"));
    end

    self:setRTFString("txt_info",gGetWords("vipWords.plist","word"..type,"\\w{c=ffffff}"..value.."\\"))
    -- local width = self:getNode("btn"):getContentSize().width*self:getNode("btn"):getScale();
    -- self:getNode("btn"):setPositionX(self:getNode("txt_info"):getContentSize().width+width+20);
    self:resetLayOut();
    local height = self:getNode("layout"):getContentSize().height+5;
    -- print("layout height = "..self:getNode("layout"):getContentSize().height);
    -- print("bg_content = "..self:getNode("bg_content"):getContentSize().height);
    -- print("height = "..height);
    self:setContentSize(cc.size(self:getContentSize().width,height));
end



return VipItemDetail