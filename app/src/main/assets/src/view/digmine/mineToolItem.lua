local MineToolItem=class("MineToolItem",UILayer)

function MineToolItem:ctor(itemid)
    self:init("ui/ui_mine_tool_item.map")
    self:initItem(itemid)
end

function MineToolItem:onTouchEnded(target, touch, event)
    if target.touchName == "btn_open_bag" then
        if gDigMine.canOpenToolItem(self.itemid, 1) then
            -- local num = Data.getItemNum(self.itemid)
            -- if num >= 10 then
            --     Net.sendMiningOpenBox(self.itemid, 10)
            -- else
            --     Net.sendMiningOpenBox(self.itemid, num)
            -- end
            Panel.popUp(PANEL_MULT_OPEN_BOX,self.itemid)
        end
    elseif target.touchName == "btn_buy" then
        local callback = function(num)
            Net.sendMiningBuyBox(self.itemid,num)
        end
        local vipType = Data.getToolVipType(self.itemid)
        if vipType ~= nil then
            Data.canBuyTimes(vipType,true,callback)
        end
    elseif target.touchName == "btn_use" then 
        if Data.getItemNum(ITEM_MAGIC_ITEM) < 0 then
            gShowNotice(gGetCmdCodeWord(CMD_MINING_INFO,34))
        else
            gConfirmCancel(gGetWords("labelWords.plist","lab_mine_mystical_use"), function()
                Net.sendMiningReset(1)
            end)
        end
    end
end

function MineToolItem:initItem(itemid)
    self.itemid = itemid
    local toolName = DB.getItemName(itemid)--gGetWords("mineToolsWords.plist","mine_tool_name"..itemid)
    self:getNode("txt_name"):setString(toolName)
    local num = Data.getItemNum(itemid)
    self:getNode("txt_tool_num"):setString(num)
    self:getNode("btn_buy"):setVisible(true)
    Icon.setIcon(itemid, self:getNode("icon_bg"))
    if itemid == ITEM_MINE_BAG then
        local mptNums = gDigMine.getMptFractionStr()
        self:getNode("txt_dig_tool_nums"):setString(mptNums)
        self:getNode("panel_pickax_num"):setVisible(true)
    end

    if itemid == ITEM_MAGIC_ITEM then
        self:getNode("btn_open_bag"):setVisible(false)
        self:getNode("btn_buy"):setVisible(false)
        self:getNode("btn_use"):setVisible(true)
    elseif itemid == ITEM_DETONATOR then
        self:getNode("btn_open_bag"):setVisible(false)
        self:getNode("btn_use"):setVisible(false)
    else
        self:getNode("btn_open_bag"):setVisible(true)
    end
    local introInfo = DB.getItemAttrDes(itemid)
    self:getNode("txt_tool_intro"):setString(introInfo)

    if isBanshuReview() then
        if itemid == ITEM_MINE_BAG_LEVEL1 or
            itemid == ITEM_MINE_BAG_LEVEL2 or
            itemid == ITEM_MINE_BAG_LEVEL3 then
            self:getNode("btn_buy"):setVisible(false)
        end
    end

    if isBanshuUser() then
        self:getNode("btn_buy"):setVisible(false)
    end
end

function MineToolItem:updateInfo()
    self:initItem(self.itemid)
end

return MineToolItem