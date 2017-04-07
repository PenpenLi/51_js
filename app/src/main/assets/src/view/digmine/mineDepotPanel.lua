local MineDepotPanel=class("MineDepotPanel",UILayer)

local MINE_TAG = 1
local TOOL_TAG = 2 

function MineDepotPanel:ctor(tag)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_mine_depot.map")
    self.scrollLayer = self:getNode("scroll_tool_items")
    self.tag = tag
    self:initLayer(tag)
    self.isMineTagInit = false
end

function MineDepotPanel:events()
    return {
                EVENT_ID_USER_DATA_UPDATE,
                EVENT_ID_REFRESH_DATA,
            }
end

function MineDepotPanel:dealEvent(event, param)
    if event == EVENT_ID_USER_DATA_UPDATE or event == EVENT_ID_REFRESH_DATA then
        if self.tag == TOOL_TAG then
            for i = 1, self.scrollLayer:getSize() do
                local item = self.scrollLayer:getItem(i - 1)
                if nil ~= item then
                    item:updateInfo()
                end
            end
        end
    end
end

function MineDepotPanel:onTouchBegan(target, touch, event)
    if nil == target.touchName then
        return true
    end
    local itemid = 0
    if string.find(target.touchName,"icon_pri") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("icon_pri") + 1))
        if pos ~= 6 then
            itemid = ITEM_COPPER + pos - 1
            -- Panel.popTouchTip(target,TIP_TOUCH_EQUIP_ITEM,ITEM_COPPER + pos - 1)
        else
            itemid = ITEM_STATUE
        end
    elseif string.find(target.touchName,"icon_mid") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("icon_mid") + 1))
        itemid = ITEM_DIAMOND + pos - 1
    elseif string.find(target.touchName,"icon_hig") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("icon_hig") + 1))
        itemid = ITEM_RED_CRYSTAL + pos - 1
    end

    if itemid ~= 0 then
        Panel.popTouchTip(target,TIP_TOUCH_EQUIP_ITEM,itemid)
    end

    self.beganPos = touch:getLocation()
    return true
end

function MineDepotPanel:onTouchMoved(target, touch, event)
    self.endPos = touch:getLocation()
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y)
    if dis > gMovedDis then
        Panel.clearTouchTip()
    end
end

function MineDepotPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName == "btn_mine" then
        self:chooseTag(MINE_TAG)
    elseif target.touchName == "btn_tool" then
        self:chooseTag(TOOL_TAG)
    end
    Panel.clearTouchTip()
end

function MineDepotPanel:chooseTag(tag)
    if self.tag ~= tag then
        self.tag = tag
        self:initLayer(tag)
    end
end

function MineDepotPanel:initLayer(tag)
    if tag == MINE_TAG then
        self:initMineTag()
    elseif tag == TOOL_TAG then
        self:initToolTag()
    end
end

function MineDepotPanel:resetBtnTexture()
    local btns={
        "btn_mine",
        "btn_tool",
    }

    for _, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end
end

function MineDepotPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end

function MineDepotPanel:initToolTag()
    self:selectBtn("btn_tool")
    self:getNode("panel_mine"):setVisible(false)
    self.scrollLayer:setVisible(true)
    self.scrollLayer.eachLineNum = 1
    self.scrollLayer.offsetX = 5
    self.scrollLayer.offsetY = 5
    self.scrollLayer:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    for i = 1, 6 do
        local toolItem = nil
        if i < 5 then -- 初级矿工包 ---> 高级矿石包
            toolItem = MineToolItem.new(ITEM_MINE_BAG + i - 1)
        elseif i == 5 then   -- 雷管 
            toolItem = MineToolItem.new(ITEM_DETONATOR)
        elseif i == 6 then   --- 神秘之石
            toolItem = MineToolItem.new(ITEM_MAGIC_ITEM)
        end

        if nil ~= toolItem then
            self.scrollLayer:addItem(toolItem)
        end
    end
    self.scrollLayer:layout()
end

function MineDepotPanel:initMineTag()
    self:selectBtn("btn_mine")
    self:getNode("panel_mine"):setVisible(true)
    self.scrollLayer:setVisible(false)
    self.scrollLayer:clear()
    --TODO
    if not self.isMineTagInit then
        for i = 1, 6 do
            -- Icon.setIcon(itemid,node,qua)
            if i ~= 6 then
                Icon.setIcon(ITEM_COPPER + i - 1, self:getNode("icon_pri"..i))
            else
                Icon.setIcon(ITEM_STATUE, self:getNode("icon_pri"..i)) --雕像id最大
            end
            Icon.setIcon(ITEM_DIAMOND + i - 1, self:getNode("icon_mid"..i))
            Icon.setIcon(ITEM_RED_CRYSTAL + i - 1, self:getNode("icon_hig"..i))
        end
    end
    --TODO
    for i = 1, 6 do
        if i ~= 6 then
            self:getNode("txt_pri_num"..i):setString(Data.getItemNum(ITEM_COPPER + i -1))
        else
            self:getNode("txt_pri_num"..i):setString(Data.getItemNum(ITEM_STATUE))
        end
        
        self:getNode("txt_mid_num"..i):setString(Data.getItemNum(ITEM_DIAMOND + i - 1))
        self:getNode("txt_hig_num"..i):setString(Data.getItemNum(ITEM_RED_CRYSTAL + i - 1))
    end

end

return MineDepotPanel