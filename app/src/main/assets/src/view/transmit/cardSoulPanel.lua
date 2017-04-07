local CardSoulPanel=class("CardSoulPanel",UILayer)

local NumsConf={0,5,10}

function CardSoulPanel:ctor(type,data)

    self:init("ui/ui_card_soul_get.map")
    self:getNode("scroll").eachLineNum=5
    self.isMainLayerMenuShow = false;
    self:getNode("scroll").offsetX=3
    self:getNode("scroll").offsetY=0
    self:getNode("scroll").padding=5
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    for key, var in pairs(NumsConf) do
        self:replaceRtfString("txt_remain_num"..key,var)
    end

    local addNum=DB.getClientParamToTable("CARD_SOUL_MELT_NUM")
    local addDia=DB.getClientParam("CARD_SOUL_MELT_PRICE")
    self.totalDia = 0;
    local function updateNum()
        if(self.isDirty==false)then
            return
        end
        self.isDirty=false
        
        local totalDia=0
        local totalNum=0
        for key, item in pairs(self:getNode("scroll").items) do
            if(item.curSelectNum)then
                totalNum=totalNum+addNum[item.curData._db.evolve]*item.curSelectNum
                totalDia=totalDia+item.curSelectNum*addDia
            end
        end
        self:setLabelString("txt_dia",totalDia)
        self:setLabelString("txt_num",math.floor(totalNum))
        if(totalNum==0)then
            self:setTouchEnable("btn_merge",false,true)
        else
            self:setTouchEnable("btn_merge",true,false)
        end
        if(self.totalDia ~= totalDia)then
            self.totalDia = totalDia;
            self:resetAdaptNode();
        end
    end
    self:scheduleUpdateWithPriorityLua(updateNum,1)
    self:selectNum(1)
    self:selectBtn("btn_soul")
    self:initSoulPanel()
end


function  CardSoulPanel:selectNum(i)
    self:resetNum()
    self:getNode("icon_choose_bg_n"..i ).isSelect=true
    self:changeTexture("icon_choose_bg_n"..i ,"images/ui_public1/n-di-gou2.png")

    self:replaceRtfString("txt_remain_num",NumsConf[i])
end

function  CardSoulPanel:resetNum()
    for i=1, 3 do
        self:getNode("icon_choose_bg_n"..i ).isSelect=false
        self:changeTexture("icon_choose_bg_n"..i ,"images/ui_public1/n-di-gou1.png")
    end
end


function  CardSoulPanel:getReaminNum()
    local idx=0
    for i=1, 3 do
        if(self:getNode("icon_choose_bg_n"..i ).isSelect)then
            idx=i
        end
    end
    return NumsConf[idx]
end


function  CardSoulPanel:events()
    return {EVENT_ID_REFRESH_CARD_SOUL,
        EVENT_ID_REFRESH_CARD_SOULBUY}
end


function CardSoulPanel:dealEvent(event,data)
    if(event==EVENT_ID_REFRESH_CARD_SOUL)then
        self:initSoulPanel()
        self.isDirty=true

        self:getNode("effect"):setVisible(true)
        local function playEnd()
            self:getNode("effect"):setVisible(false)
        end
        self:getNode("effect").curAction=""
        self:getNode("effect"):playAction("ui_weapon_b",playEnd)

    elseif(event==EVENT_ID_REFRESH_CARD_SOULBUY)then
        self:initBuyPanel()
    end
end



function CardSoulPanel:reset()
    local num=self:getReaminNum()
    local stars=self:getSelectStar()
    
    local items={}
    Data.sortUserCard()
    local ignoreIds={}
    for key, var in pairs(gUserCards) do
    	if(table.getn(ignoreIds)>=6)then
    	   break
    	end
        table.insert(ignoreIds,var)
    end
    for key, item in pairs(self:getNode("scroll").items) do
        local insert=true
        if(item.curData._db.supercard==1)then
            insert=false
        end
        
        for key, var in pairs(ignoreIds) do
            if(var.cardid==item.curData._db.cardid)then
                insert=false
            end
        end
        
        if(insert)then
            table.insert(items,item)
        end
    
    end
    

    for key, item in pairs(items) do
        if(stars[item.curData._db.evolve])then
            item:setRemainNum(num)
        else
            item:setUnSelect()
        end
    end

    self.isDirty=true
end

function CardSoulPanel:onPopback()
    Scene.clearLazyFunc("equipSoul")
end



function CardSoulPanel:resetBtnTexture()
    local btns={
        "btn_soul",
        "btn_buy",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end

end



function CardSoulPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/button_s2-1.png")
    self.isDirty=true


end


function CardSoulPanel:initSoulPanel()
    self:getNode("soul_panel"):setVisible(true)
    Scene.clearLazyFunc("equipSoul")
    self:getNode("scroll"):clear()
    self.curShowItems={}
    self:resetColor()
    self.isDirty=true

    local drawNum=20


    gPreSortCardSoul(gUserSouls)
    for key, var in pairs(gUserSouls) do
        if(var.num>0)then
            local temp=clone(var)
            temp.itemid=ITEM_TYPE_SHARED_PRE+temp.itemid
            table.insert(self.curShowItems,temp)
        end
    end
    table.sort(self.curShowItems,gSortEquipItem2) --排序

    for key, var in pairs(self.curShowItems) do
        local item=WeaponEquipSoulItem.new()
        item.idx=key
        if(drawNum>0)then
            drawNum=drawNum-1
            item:setData(var)
        else
            item:setLazyData(var)
        end

        item.selectItemCallback=function ()
            self.isDirty=true
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
end


function CardSoulPanel:initBuyPanel()
    self:getNode("soul_panel"):setVisible(false)
    Scene.clearLazyFunc("equipSoul")
    self:getNode("scroll"):clear()
    self.curShowItems={}


    local drawNum=20


    gPreSortCardSoul(gUserSouls)
    for key, var in pairs(gUserSouls) do
        local temp=clone(var)
        if(temp.bbnum>0)then
            temp.itemid=ITEM_TYPE_SHARED_PRE+temp.itemid
            table.insert(self.curShowItems,temp)
        end
    end
    table.sort(self.curShowItems,gSortEquipItem) --排序

    for key, var in pairs(self.curShowItems) do
        local item=CardSoulBuyItem.new()
        item.idx=key
        if(drawNum>0)then
            drawNum=drawNum-1
            item:setData(var)
        else
            item:setLazyData(var)
        end

        item.selectItemCallback=function ()
            self.isDirty=true
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
end


function  CardSoulPanel:getSelectStar()
    local rets={}
    for i=1,4 do
        if(self:getNode("icon_choose_"..i ).isSelect)then
            rets[i]=true
        end
    end
    return rets
end

function  CardSoulPanel:resetColor()
    for i=1, 4 do
        self:getNode("icon_choose_"..i ).isSelect=false
        self:changeTexture("icon_choose_"..i ,"images/ui_public1/n-di-gou1.png")
    end
end


function  CardSoulPanel:selectStar(i)
    if(self:getNode("icon_choose_"..i ).isSelect)then
        self:getNode("icon_choose_"..i ).isSelect=false
        self:changeTexture("icon_choose_"..i ,"images/ui_public1/n-di-gou1.png")
    else

        self:getNode("icon_choose_"..i ).isSelect=true
        self:changeTexture("icon_choose_"..i ,"images/ui_public1/n-di-gou2.png")
    end
end



function CardSoulPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif target.touchName=="btn_merge"then
        
        if(NetErr.isDiamondEnough( self:getNode("txt_dia"):getString() )==false   )then
            return
        end
        local items={}
        for key, item in pairs(self:getNode("scroll").items) do
            if(item.curSelectNum>0)then
                table.insert(items,{itemid=item.curSelectItemid,num=item.curSelectNum})
            end
        end
        if(table.getn(items)~=0)then
            Net.sendCardSoulMelt(items)
        end


    elseif target.touchName=="btn_soul"then
        self:selectBtn(target.touchName)
        self:initSoulPanel()
    elseif target.touchName=="btn_buy"then
        self:selectBtn(target.touchName)
        self:initBuyPanel()
    elseif target.touchName=="btn_raise_time"then
        if(self:getNode("time_panel"):isVisible())then
            self:getNode("time_panel"):setVisible(false)
        else
            self:getNode("time_panel"):setVisible(true)
        end

    elseif  target.touchName and string.find(target.touchName,"icon_touch_n")then
        local idx=toint(string.gsub(target.touchName,"icon_touch_n",""))
        self:selectNum(idx)
        self:getNode("time_panel"):setVisible(false)
        self:reset()
    elseif target.touchName and string.find(target.touchName,"icon_touch_")then
        local idx=toint(string.gsub(target.touchName,"icon_touch_",""))
        self:selectStar(idx)
        self:reset()
    end
end

return CardSoulPanel