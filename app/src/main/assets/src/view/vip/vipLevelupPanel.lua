local VipLevelupPanel=class("VipLevelupPanel",UILayer)

function VipLevelupPanel:ctor(type)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_vip_levelup.map")
    
    local newVip = gUserInfo.vip;
    self.curData = DB.getVip(newVip);
    local data = self.curData;
    local shows=string.split(data.show,";")
    if data.vip > 0 then
        table.insert(shows,100);
    end

    local curShows = {};
    for key, show in pairs(shows) do
        local ret = {};
        ret.type = show;
        ret.sortid = toint(key);
        if(self:isHightLight(show))then
            ret.sortid = 0;
        end
        table.insert(curShows,ret);
    end
    -- print_lua_table(shows);

    local sortFun = function(a1,a2)
        return a1.sortid < a2.sortid;
    end
    table.sort(curShows,sortFun);

    for key, show in pairs(curShows) do
        local item=VipItemDetail.new(self)
        item:setData(show.type,data,self:isHightLight(show.type))
        self:getNode("scroll"):addItem(item);
    end

    self:getNode("scroll"):layout()

    self:setLabelAtlas("txt_vip",newVip);
    self:replaceLabelString("txt_tip",newVip);

    self:getNode("scroll").breakTouch = true;
    self:addFullScreenTouchToClose();

    local callback = function ()
        gCreateTouchScreenTip(self,cc.c3b(255,255,255));
    end
    self.initTime = socket.gettime();
    self.touchCd = 1.0;
    gCallFuncDelay(self.touchCd,self,callback);

    local flaEnd = gCreateFla("ui_vip_huode",0);
    gAddChildInCenterPos(self:getNode("icon_vip"),flaEnd)

    flaEnd = gCreateFla("ui_vip_zi",-1);
    gAddChildInCenterPos(self:getNode("icon_vip"),flaEnd)
end

function VipLevelupPanel:closeAllItemExtend()
    local items = self:getNode("scroll"):getAllItem();
    for key,item in pairs(items) do
        if(item)then
            item:setExtend(false);
        end
    end
end

function VipLevelupPanel:resetContainerSize()
    self:getNode("scroll"):layout(false);
    -- self:resetLayOut();
    -- self.totalHeight = self:getNode("container"):getContentSize().height;
    -- self:resetContainerPos();
end

function VipLevelupPanel:isHightLight( show )
    -- body
    local hightlight = string.split(self.curData.highlight,";");
    if hightlight ~= nil then
        for key,var in pairs(hightlight) do
            if var == show then
                return true;
            end
        end
    end
    return false;
end

function VipLevelupPanel:onTouchEnded(target)

    if socket.gettime() - self.initTime < self.touchCd then
        return;
    end

    if  target.touchName=="full_close"then
        Panel.popBack(self:getTag())
    end
end

return VipLevelupPanel