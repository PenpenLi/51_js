local FoodFightRecordItem=class("FoodFightRecordItem",UILayer)

function FoodFightRecordItem:ctor()
    self:init("ui/ui_duoliang_record_item.map")
end

function FoodFightRecordItem:setData(data)
    self.curData=data 

    Icon.setHeadIcon(self:getNode("icon"), (data.icon))
    self:setLabelString("txt_name",data.sname.."_"..data.uname)
    self:replaceLabelString("txt_pw",data.price)
    self:replaceLabelString("txt_food",data.food)

    if data.revenge == 1 then
        self:setLabelString("txt_fight",gGetWords("lootFoodWords.plist","txt_had_revenge"))
        self:setTouchEnableGray("btn_fight",false);
    elseif data.isUnlock == false then
        self:setTouchEnableGray("btn_fight",false);
    end
end

function FoodFightRecordItem:saveUI()
    local ret = {}
    --ret.revengenum = self.curData.revengenum
    ret.revengebuy = self.curData.revengebuy
    ret.food1 = self.curData.food1
    ret.food2 = self.curData.food2
    ret.isUnlock = self.curData.isUnlock

    Panel.pushRePopupPanel(PANEL_FOODFIGHT_MAIN)
    Panel.pushRePopupPanel(PANEL_FOODFIGHT_RECORD,ret)
end

function FoodFightRecordItem:onTouchEnded(target)
    if(target.touchName=="btn_check")then
        self:saveUI()
        Net.sendLootfoodVedio(self.curData.vid)
    elseif(target.touchName=="btn_fight")then
        --self:saveUI()
        --
        if(self.isRevengeNumEnough ~=nil and self.isRevengeNumEnough() == true)then
            local param = {}
            param.id = self.curData.id
            param.food1 = self.curData.food1
            param.food2 = self.curData.food2
            param.revengebuy = self.curData.revengebuy
            param.isUnlock = self.curData.isUnlock
            param.isNeedSend = false
            Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_LOOT_FOOD_REVENGE,param)
        end
    end
end

return FoodFightRecordItem