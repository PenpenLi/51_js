local FoodFightRecordPanel=class("FoodFightRecordPanel",UILayer)

function FoodFightRecordPanel:ctor(data)
    self:init("ui/ui_duoliang_record_di.map")

    self:getNode("scrol").breakTouch = true
    self:getNode("scrol").eachLineNum=1 
    self:getNode("scrol"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scrol").scrollBottomCallBack = function()
        self:onMoveDown();
    end
    
    self.iShowIndex = 0;
    self.iShowMax = 100;
    self.iShowSize = 10;

    self.revengenum = Net.lootfoodinfo.revengenum
    self.revengebuy = data.revengebuy
    self.food1 = data.food1
    self.food2 = data.food2
    self.isUnlock = data.isUnlock
    self.isNeedSend = data.isNeedSend

    self:setLabelString("txt_food1",self.food1)
    self:setLabelString("txt_food2",self.food2)
    self:refreshBuyNum()

    -- 活动结束，无法购买复仇次数
    if self.isUnlock == false then
        self:getNode("left_num"):getParent():setVisible(false)
        self:getNode("btn_buy"):getParent():setVisible(false)
    end

    self.list = {}

    if not self.isNeedSend then
        self:refreshScrol(Net.lootfoodrecord)
    end
end

function FoodFightRecordPanel:onPopup()
    Data.redpos.lootfoodrecord = false
    if self.isNeedSend then
        Net.send_lootfood_record()
    end
    
end

function FoodFightRecordPanel:refreshBuyNum() 
    local leftnum = self.revengebuy + gLootfoodRevengeNum - self.revengenum
    if leftnum < 0 then
        leftnum = 0
    end
    
    self:setLabelString("left_num",leftnum)
    self:getNode("left_num"):getParent():layout()
end

function FoodFightRecordPanel:onMoveDown()
    if (self.iShowIndex>=self.iShowMax) then
        return;
    end

    local scrol = self:getNode("scrol")
    for i=1+self.iShowIndex,self.iShowSize+self.iShowIndex do
        local key = i
        if (key<=table.getn(self.list)) then
            local var = self.list[key]
            local item = FoodFightRecordItem.new()
            var.revengenum = self.revengenum
            var.revengebuy = self.revengebuy
            var.food1 = self.food1
            var.food2 = self.food2
            var.isUnlock = self.isUnlock
            item:setData(var)
            scrol:addItem(item)

            local callback = function()
                local leftnum = self.revengebuy + gLootfoodRevengeNum - self.revengenum
                if leftnum > 0 then
                    return true
                end

                self:onBuyNum()
                return false
            end

            item.isRevengeNumEnough = callback
        end
    end
    scrol:layout(self.iShowIndex==0)
    self.iShowIndex = self.iShowIndex + self.iShowSize;
    self.iShowIndex = math.min(self.iShowIndex,self.iShowMax)
end

function  FoodFightRecordPanel:events()
    return {EVENT_ID_LOOTFOOD_RECORD,EVENT_ID_LOOTFOOD_REVENGE_BUY}
end

function FoodFightRecordPanel:refreshScrol(param)
    self.list = param
    self.iShowMax = table.getn(self.list)

    if self.iShowMax > 0 then
        self:getNode("space_layer"):setVisible(false)
    else
        self:getNode("space_layer"):setVisible(true)
    end

    self:onMoveDown();
end

function FoodFightRecordPanel:dealEvent(event,param)
    if(event==EVENT_ID_LOOTFOOD_RECORD)then
        self:refreshScrol(param)
    elseif(event==EVENT_ID_LOOTFOOD_REVENGE_BUY)then
        self.revengebuy = self.revengebuy+param
        self:refreshBuyNum()
    end
end

function FoodFightRecordPanel:onBuyNum()
    Data.vip.lootfoodreveng.setUsedTimes(self.revengebuy);
    local callback = function(num)
        Net.sendLootfoodBuyrevenge(num)
    end
    Data.canBuyTimes(VIP_LOOT_FOOD_REVENG,true,callback);
end

function FoodFightRecordPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_buy" then
        self:onBuyNum()
    end
end

return FoodFightRecordPanel