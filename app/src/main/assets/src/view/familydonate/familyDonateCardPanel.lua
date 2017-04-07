local FamilyDonateCardPanel=class("FamilyDonateCardPanel",UILayer)


function FamilyDonateCardPanel:ctor()

	self.isWindow = true
    self:init("ui/ui_family_juanzeng_wujiang.map")

    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll").eachLineNum=3
    self:getNode("scroll").offsetX=2
    self:getNode("scroll").offsetY=3
    self:getNode("scroll").paddingX = 8
    self:getNode("scroll").paddingY = 6

    self.selectBtnName = nil
    self:onTouchEnded({touchName="btn_card"})
end



function FamilyDonateCardPanel:onTouchEnded(target)

    if self.selectBtnName == target.touchName then
        return
    end
    self.selectBtnName = target.touchName
    if  target.touchName=="btn_magic" then
    	self:selectBtn("btn_magic")
    	self:setSelectColor(0)
    elseif target.touchName== "btn_card" then
    	self:selectBtn("btn_card")
    	self:setSelectCoutry(0)
	elseif string.find(target.touchName,"btn_color") ~= nil then
    	local index = toint(string.sub(target.touchName,string.len(target.touchName)))
    	self:setSelectColor(index)
    elseif string.find(target.touchName,"btn_coutry") ~= nil then
    	local index = toint(string.sub(target.touchName,string.len(target.touchName)))
    	self:setSelectCoutry(index)

    elseif target.touchName=="btn_close" then
    	self:onClose()
    end

end

function FamilyDonateCardPanel:resetBtnTexture()
    local btns={
        "btn_magic",
        "btn_card",
    }
    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function FamilyDonateCardPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
    if  name=="btn_magic" then
    	self:getNode("layer_colorsel"):setVisible(true)
		self:getNode("layer_countrysel"):setVisible(false)
    elseif name== "btn_card" then
    	self:getNode("layer_colorsel"):setVisible(false)
		self:getNode("layer_countrysel"):setVisible(true)
    end
end

function FamilyDonateCardPanel:setSelectCoutry(index)
	for i=0,4 do
		if index==i then
			self:changeTexture("btn_coutry"..i,"images/ui_public1/n-di-gou2.png")
		else
			self:changeTexture("btn_coutry"..i,"images/ui_public1/n-di-gou1.png")
		end
    end
    self:getNode("scroll"):clear()
    for key, var in pairs(gUserCards) do
        local cardDb=DB.getCardById(var.cardid);
        local dbDonateItem  = DB.getFamilyDonateItem(var.cardid+ITEM_TYPE_SHARED_PRE)
        if(toint(cardDb.country) == (index+1) and dbDonateItem ~= nil )then
            local item = FamilyDonateCardItem.new(self)
            item:setData(var,1)
            item.sort = CardPro.countPower(var)
            self:getNode("scroll"):addItem(item)
        end
    end
    local sortfunc = function(item1,item2)
        return item1.sort > item2.sort
    end

    self:getNode("scroll"):sortItems(sortfunc);
    if(self:getNode("scroll"):getSize()>0) then
        self:getNode("bg_kong"):setVisible(false)
    end
    self:getNode("scroll"):layout()
end

function FamilyDonateCardPanel:setSelectColor(index)

	for i=0,1 do
		if index==i then
			self:changeTexture("btn_color"..i,"images/ui_public1/n-di-gou2.png")
		else
			self:changeTexture("btn_color"..i,"images/ui_public1/n-di-gou1.png")
		end
    end
    local quality = QUALITY5  --紫色
    if index == 1 then
        quality = QUALITY8  --橙色
    end
    self:getNode("scroll"):clear()

    local  curShowItems = {}
    for key, var in pairs(gUserTreasureShared) do
         curShowItems[var.itemid]=var
    end

    for key, var in pairs(gUserTreasure) do
        if curShowItems[var.itemid]==nil then
            curShowItems[var.itemid]=var
        end
    end

    for key, var in pairs(curShowItems) do
        local treasure=DB.getTreasureById(var.itemid)
        local dbDonateItem  = DB.getFamilyDonateItem(var.itemid+ITEM_TYPE_SHARED_PRE)
        if(toint(treasure.quality) == quality and dbDonateItem~= nil)then
            local item = FamilyDonateCardItem.new(self)
            item:setData(var,2)
            item.sort = var.itemid
            self:getNode("scroll"):addItem(item)
        end
    end
    local sortfunc = function(item1,item2)
        return item1.sort > item2.sort
    end
    self:getNode("scroll"):sortItems(sortfunc);
    if(self:getNode("scroll"):getSize()>0) then
        self:getNode("bg_kong"):setVisible(false)
    end
    self:getNode("scroll"):layout()
end


function FamilyDonateCardPanel:setData(data)
    
end

return FamilyDonateCardPanel