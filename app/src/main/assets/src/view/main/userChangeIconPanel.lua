local UserChangeIconPanel=class("UserChangeIconPanel",UILayer)

UserChangeIconPanel.data = {};
UserChangeIconPanel.data.icons = {};
UserChangeIconPanel.data.frames = {};

-- function UserChangeIconPanel.initData()
--     -- body
--     UserChangeIconPanel.data.icons = {};
--     for key,var in pairs(icon_db) do
--         if var.unlocktype == 1 then
--             table.insert(UserChangeIconPanel.data.icons,{icon=var.iconid,unlocktype=var.unlocktype});
--         end
--     end
-- end

function UserChangeIconPanel:getIconData()
    UserChangeIconPanel.data.icons = {};
    -- UserChangeIconPanel.initData();
    for key,var in pairs(gUserCards) do
        -- if var.quality >= 3 then
            local data = DB.getIconData(var.cardid);
            if data then
                local icon_data = {};
                icon_data.icon = data.iconid;
                icon_data.quality = var.quality;
                if data.unlocktype == 1 then
                    icon_data.unlocktype = 1;
                elseif data.unlocktype == 2 then
                    if var.quality >= 3 then
                        icon_data.unlocktype = 1;
                    else
                        icon_data.unlocktype = 2;
                    end
                end
                table.insert(UserChangeIconPanel.data.icons,icon_data);
            end
        -- end
    end
    -- print_lua_table(UserChangeIconPanel.data.icons);

    local function sort(v1,v2)
        if v1.unlocktype < v2.unlocktype then
            return true;
        elseif v1.unlocktype == v2.unlocktype then
            if v1.quality > v2.quality then
                return true;
            end    
        end
        return false;
    end
    table.sort(UserChangeIconPanel.data.icons,sort);
end

function UserChangeIconPanel:ctor(type)
    self:getIconData();
    self:init("ui/ui_user_head.map")
    -- self.isBlackBgVisible=false  
    self._panelTop=true
    self.listType = 0;
    self.choosed_icon = Data.getCurIcon();
    self.choosed_frame = Data.getCurFrame();
    self:refreshIcon();
    self:createIconList();
    self:createFrameList();
    self:selectBtn("btn_icon");
end

function UserChangeIconPanel:refreshIcon()

    local userCard = Data.getUserCardById(self.choosed_icon);
    local awakeLv = 0;
    if(userCard)then
        awakeLv = userCard.awakeLv;
    end

    Icon.setHeadIcon(self:getNode("bg_icon"),awakeLv*10000000+self.choosed_frame*100000+self.choosed_icon);
    -- Icon.setIcon(self.choosed_icon,self:getNode("bg_icon"));
    -- self:changeTexture("bg_icon","images/icon/head/frame"..self.choosed_frame..".png");
end

function UserChangeIconPanel:resetBtnTexture()
    local btns={
        "btn_icon",
        "btn_frame"
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end
end
function UserChangeIconPanel:showLayer(name)
    local layers={
        {"btn_icon","layer_icon"},
        {"btn_frame","layer_frame"}
    }

    for key, layer in pairs(layers) do
        self:getNode(layer[2]):setVisible(layer[1] == name);
    end
end
function UserChangeIconPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/button_s2-1.png")
    self:getNode("flag_arrow"):setPositionY(self:getNode(name):getPositionY());

    self:showLayer(name);
    -- if name=="btn_icon"then
    --   self:refreshList(1);
    -- elseif  name=="btn_frame"then
    --   self:refreshList(2);
    -- end
    
end

function UserChangeIconPanel:createIconList()
    -- body
    self:getNode("scroll_icon"):clear();

    -- for i=1,3 do
    --     table.insert(UserChangeIconPanel.data.icons,10000+i);
    -- end

    self:getNode("scroll_icon").eachLineNum = 4;
    for key,var in pairs(UserChangeIconPanel.data.icons) do
        local item = UserIconItem.new();
        item:setData(var);
        item:setChoosed(self.choosed_icon);
        item.onChoosed = function (icon)
            self:onChooseIcon(icon);
        end
        self:getNode("scroll_icon"):addItem(item);
    end
    self:getNode("scroll_icon"):layout();
end

function UserChangeIconPanel:onChooseIcon(icon)
    self.choosed_icon = icon;
    self:refreshIcon();
    local items = self:getNode("scroll_icon"):getAllItem();
    for key,var in pairs(items) do
        var:setChoosed(self.choosed_icon);
    end
end

function UserChangeIconPanel:createFrameList()
    -- body
    self:getNode("scroll_frame"):clear();

    for i=0,2 do
        table.insert(UserChangeIconPanel.data.frames,i);
    end

    self:getNode("scroll_frame").eachLineNum = 3;
    for key,var in pairs(UserChangeIconPanel.data.frames) do
        local item = UserIconFrameItem.new();
        item:setData(var);
        item:setChoosed(self.choosed_frame);
        item.onChoosed = function (frame)
            self:onChooseFrame(frame);
        end
        self:getNode("scroll_frame"):addItem(item);
    end
    self:getNode("scroll_frame"):layout();
    
end

function UserChangeIconPanel:onChooseFrame(frame)
    self.choosed_frame = frame;
    self:refreshIcon();
    local items = self:getNode("scroll_frame"):getAllItem();
    for key,var in pairs(items) do
        var:setChoosed(self.choosed_frame);
    end
end

function UserChangeIconPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        -- TODU: 交互
        local newIcon = nil;
        if self.choosed_icon ~= Data.getCurIcon() then
            newIcon = self.choosed_icon;
        end
        local newFrame = nil;
        if self.choosed_frame ~= Data.getCurFrame() then
            newFrame = self.choosed_frame;
        end
        if newIcon or newFrame then
            Net.sendSysChangeIcon(self.choosed_icon,self.choosed_frame);
        end
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_icon" or target.touchName=="btn_frame" then
        self:selectBtn(target.touchName);
    end
end

-- function UserChangeIconPanel:events()
--     return {EVENT_ID_ICON_CHANGE}
-- end

-- function UserChangeIconPanel:dealEvent(event,param)
--     if event == EVENT_ID_ICON_CHANGE then
--         self:refreshIcon();
--     end
-- end



return UserChangeIconPanel