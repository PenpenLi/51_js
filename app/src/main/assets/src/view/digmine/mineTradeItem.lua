local MineTradeItem=class("MineTradeItem",UILayer)

function MineTradeItem:ctor()
    self.curSelectNum=0
    self.deltaNum = 0
    -- self.addRaise=0
    self.curSelectItemid=0
    self.isPopTipReachTotalValue = false
end

function MineTradeItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_weapon_item.map")
    self:getNode("icon_reomove").__touchend=true
    self:getNode("icon_add").__touchend=true
end


function MineTradeItem:onTouchBegan(target)
    if (not gDigMine.canTradeForTarget(self.curData.itemid, gDigMine.getBlackTradeID())) or (not self:isParentTouchEnable()) then
        return
    end

    -- if Panel.getOpenPanel(PANEL_MINE_BLACK_MARKET):isReachTotoalValue() then
    --     self.isMoved = true
    --     return
    -- end

    self.isMoved=false
    self.curDt=0
    self.curAddSpeed=0.5
    self.curRemoveSpeed=0.5
    local function updateAddSelect(dt)
        self.curDt=self.curDt+dt
        if(self.curDt>self.curAddSpeed)then
            self.curDt=self.curDt-self.curAddSpeed
            self:changeSelectNum(1)
            self.curAddSpeed=self.curAddSpeed-0.09
            if(self.curAddSpeed<0.05)then
                self.curAddSpeed=0.05
            end
        end
    end
    local function updateRemoveSelect(dt)
        self.curDt=self.curDt+dt
        
        if(self.curDt>self.curRemoveSpeed)then
            self.curDt=self.curDt-self.curRemoveSpeed
            self:changeSelectNum(-1)
            self.curRemoveSpeed=self.curRemoveSpeed-0.09
            if(self.curRemoveSpeed<0.05)then
                self.curRemoveSpeed=0.05
            end
        end
    end

    

    if(target.touchName=="icon_reomove")then  
        self:scheduleUpdateWithPriorityLua(updateRemoveSelect,1)
        
    elseif(target.touchName=="icon_add")then
 
        self:scheduleUpdateWithPriorityLua(updateAddSelect,1)
    end
end

function MineTradeItem:onTouchMoved(target,touch)
    if (not gDigMine.canTradeForTarget(self.curData.itemid, gDigMine.getBlackTradeID())) or (not self:isParentTouchEnable()) then
        return
    end

    -- if Panel.getOpenPanel(PANEL_MINE_BLACK_MARKET):isReachTotoalValue() then
    --     self.isMoved = true
    --     return
    -- end

    local offsetX=touch:getDelta().x;
    local offsetY=touch:getDelta().y;
    if(math.sqrt(offsetX*offsetX+offsetY*offsetY)>5)then
        self.isMoved=true
        self.isPopTipReachTotalValue = false
    end
    if(target.touchName=="icon_reomove")then 
        if(self.isMoved)then 
            self:unscheduleUpdate()
        end
    elseif(target.touchName=="icon_add")then 
        if(self.isMoved)then 
            self:unscheduleUpdate()
        end
    end
end

function MineTradeItem:setUnSelect()
    self.deltaNum = -self.curSelectNum
    self.curSelectNum=0
    self:refreshSelect()
end

function MineTradeItem:setRemainNum(num)
    local oldSelectNum = self.curSelectNum
    self.curSelectNum=self.curData.num-num
    if(self.curSelectNum<0)then
        self.curSelectNum=0
    end
    self.deltaNum = self.curSelectNum - oldSelectNum
    self:refreshSelect()
end

function MineTradeItem:changeSelectNum(num)
    if Panel.getOpenPanel(PANEL_MINE_BLACK_MARKET):isMaxTradeTimesLimit(false) then
        if not self.isPopTipReachTotalValue then
            self.isPopTipReachTotalValue = true
            gShowCmdNotice(CMD_MINING_EVENT_9_DEAL,14)
        end
        return
    end

    if num > 0 and Panel.getOpenPanel(PANEL_MINE_BLACK_MARKET):isReachTotoalValue() then
        if not self.isPopTipReachTotalValue then
            self.isPopTipReachTotalValue = true
            gShowNotice(gGetWords("labelWords.plist","lab_mine_max_trade_value"))
        end
        return 
    end

    local oldSelectNum = self.curSelectNum
    self.curSelectNum = self.curSelectNum+num
    if(self.curSelectNum>=self.curData.num)then
         self.curSelectNum=self.curData.num
    end
    if(self.curSelectNum<0)then
        self.curSelectNum=0
    end
    self.deltaNum = self.curSelectNum - oldSelectNum
    self:refreshSelect()
    if(self.selectItemCallback)then
        self.selectItemCallback()
    end
end

function MineTradeItem:onTouchEnded(target)
    if not self:isParentTouchEnable() then
        return
    end
    if(target.touchName=="icon_reomove")then
        if(self.isMoved==false)then
            self:changeSelectNum(-1)
            self.isPopTipReachTotalValue = false
        end
    elseif(target.touchName=="icon_add")then 
        if(self.isMoved==false)then
            self:changeSelectNum(1)
            self.isPopTipReachTotalValue = false
        end
    end
    self:unscheduleUpdate()

end
function  MineTradeItem:setDataLazyCalled()
    self:setData(self.lazyData,self.lazyTagType)
    self:refreshSelect()
end

function  MineTradeItem:setLazyData(data,tagType)
    self.lazyData=data
    self.curData=data
    self.lazyTagType=tagType
    local qua=DB.getItemQuality(data.itemid) 
    local baseQua,detailQua = Icon.convertItemDetailQuality(qua+1);
    self.qua=baseQua 
    Scene.addLazyFunc(self,self.setDataLazyCalled,"equipSoul")
end

function MineTradeItem:refreshSelect()
    if(self.inited==true)then  
        self:setLabelString("txt_num",self.curSelectNum.."/"..self.curData.num)
        if(self.curSelectNum==0)then
            self:getNode("icon_reomove"):setVisible(false)
        else
            self:getNode("icon_reomove"):setVisible(true)
        end
    end
end

function   MineTradeItem:setData(data,tagType)
    self:initPanel()
    self.curData=data
    local qua=DB.getItemQuality(data.itemid) 
    local baseQua,detailQua = Icon.convertItemDetailQuality(qua+1);
    self.qua=baseQua 
    local db=data._db
    if(data.itemid==nil)then
        return
    end 
    self.addRaise=0

    if(db)then
        self.addRaise=db.equsoul
    end
    local itemid=data.itemid
    if(tagType==5)then
        itemid=itemid+ITEM_TYPE_SHARED_PRE

        if(db and db.com_num~=0)then
            self.addRaise=db.equsoul/db.com_num
        end
    end

    self.curSelectItemid=itemid
    Icon.setIcon(itemid,self:getNode("icon"),qua)
    self:refreshSelect()
end

function MineTradeItem:resetDataNum(num)
    self.curSelectNum = 0
    self.curData.num = num
end


function MineTradeItem:isParentTouchEnable()
    if self:getParent() == nil then
        return false
    end

    if (self:getParent().__touchable ~= nil) and (self:getParent().__touchable == false) then
        return false
    end

    return true
end



return MineTradeItem