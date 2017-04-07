local ShopNoticePanel=class("ShopNoticePanel",UILayer)

function ShopNoticePanel:ctor(data)
    self.appearType = 1;
    self:init("ui/ui_shop_notice.map")
    self._panelTop = true;
    Data.limit_open = false
    self.type = SHOP_TYPE_1
    if (data.type) then
        self.type = data.type
    end
    -- self.type = 3
    for i=2,3 do
        self:getNode("sign_"..i):setVisible(false)
        self:getNode("lab_type"..i):setVisible(false)
    end
    if (self.type==SHOP_TYPE_2) then
        self:getNode("sign_2"):setVisible(true)
        self:getNode("lab_type2"):setVisible(true)
    elseif (self.type==SHOP_TYPE_3) then
        self:getNode("sign_3"):setVisible(true)
        self:getNode("lab_type3"):setVisible(true)
    end
    self:initNpc(self.type)
    self:addFullScreenTouchToClose();
end

function ShopNoticePanel:initNpc(type)
    loadFlaXml("ui_shop")
    local npcIcon = gCreateFla("ui_shopnpc"..type, 1)
    self:getNode("role_bg"):removeAllChildren();
    gAddChildInCenterPos(self:getNode("role_bg"),npcIcon)
end

function ShopNoticePanel:onTouchEnded(target)
    if  target.touchName=="full_close" or target.touchName == "btn_close" then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_confirm" then
        Panel.popBack(self:getTag());
        Panel.popUp(PANEL_SHOP,self.type)
    end
end


return ShopNoticePanel