local ActivityLuckWheelPanel=class("ActivityWishPanel",UILayer)

function ActivityLuckWheelPanel:ctor(data)
    self:init("ui/ui_hd_luck_wheel.map")
    self:getNode("btn_turn"):setVisible(false)


    self:selectBtn("btn_type1")

    self.rewardItems=self:getRewardLog()
    self:initRewardPanel(self.rewardItems)
    self:initNoticeRewardPanel(gLuckWheel.notice)

    local function _updateLuckWheelTime()
        self:updateLuckWheelTime();
    end
    self:scheduleUpdate(_updateLuckWheelTime,1)
    self:resetAdaptNode();
    self:resetLayOut();
end

function ActivityLuckWheelPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end


function ActivityLuckWheelPanel:updateLuckWheelTime()

    local leftTime=gLuckWheel.endTime -gGetCurServerTime() 
    self:setLabelString("txt_left_time",  gParserDayHourTime(leftTime))
    self:resetLayOut()
end

function ActivityLuckWheelPanel:getRewardLog()
    local items=  string.split( cc.UserDefault:getInstance():getStringForKey("luckreward"..gUserInfo.id ),"|")
    local ret={}
    for key, var in pairs(items) do
        local temp= string.split(var,",")
        if(toint(temp[1])~=0)then
            table.insert(ret,{id=toint(temp[1]),num=toint(temp[2])})
        end
    end
    local removeCount=table.getn(ret)-15
    if(removeCount<0)then
        removeCount=0
    end
    for i=1, removeCount do
        table.remove(ret,1)
    end
    return ret
end

function ActivityLuckWheelPanel:getCurMaxNum()
    return DB.getLuckWheelMaxNum(self.curType,Data.getCurVip())
end


function ActivityLuckWheelPanel:getFreeNum()
    return DB.getLuckWheelFreeNum(self.curType)
end


function ActivityLuckWheelPanel:saveRewardLog()
    local saveIdx=table.getn(self.rewardItems)-40
    if(saveIdx<1)then
        saveIdx=1
    end
    local str=""
    for i=saveIdx, table.getn(self.rewardItems) do
        str=str.."|"..(self.rewardItems[i].id..","..self.rewardItems[i].num)
    end
    cc.UserDefault:getInstance():setStringForKey("luckreward"..gUserInfo.id,str)
    cc.UserDefault:getInstance():flush()
end


function ActivityLuckWheelPanel:initNoticeRewardPanel(items)

    for key, var in pairs(items) do
        local item = RTFLayer.new(self:getNode("notice_scroll"):getContentSize().width-5);
        item:setAnchorPoint(cc.p(0,1))
        local quality=DB.getItemQuality(var.id)

        if(var.id==0)then
            quality=5
        end
        local color=gGetItemQualityColor(quality)
        color=gParseRgbNum(color.r,color.g,color.b)
        item:setDefaultConfig(gFont,18,cc.c3b(255,255,255));
        local word=""
        if(var.id==0)then
            word=gGetWords("luckyWheel.plist","flower_"..(var.type+1),
                gParseRgbNum(0,255,246),
                var.name,
                gParseRgbNum(250,210,0),
                color, 
                var.num)
        else
            word=gGetWords("luckyWheel.plist","no_flower_"..(var.type+1),
                gParseRgbNum(0,255,246),
                var.name,
                gParseRgbNum(250,210,0),
                color,
                DB.getItemName(var.id),
                var.num)
        end

        item:setString(word);
        item:layout();
        self:getNode("notice_scroll"):addItem(item)
    end
    self:getNode("notice_scroll"):layout()
    local containerSize=self:getNode("notice_scroll").container:getContentSize()
    local viewSize=self:getNode("notice_scroll").viewSize
    if(viewSize.height<containerSize.height)then
        self:getNode("notice_scroll").container:setPositionY(0)

    end
end

function ActivityLuckWheelPanel:initRewardPanel(items)
    for key, var in pairs(items) do
        local item = RTFLayer.new(self:getNode("reward_scroll"):getContentSize().width-5);
        item:setAnchorPoint(cc.p(0,1))
        local quality=DB.getItemQuality(var.id)
        local color=gGetItemQualityColor(quality)
        color=gParseRgbNum(color.r,color.g,color.b)
        item:setDefaultConfig(gFont,18,cc.c3b(255,255,255));
        local word=gGetWords("luckyWheel.plist","9",color,DB.getItemName(var.id),var.num)
        item:setString(word);
        item:layout();
        self:getNode("reward_scroll"):addItem(item)
    end
    self:getNode("reward_scroll"):layout()
    local containerSize=self:getNode("reward_scroll").container:getContentSize()
    local viewSize=self:getNode("reward_scroll").viewSize
    if(viewSize.height<containerSize.height)then
        self:getNode("reward_scroll").container:setPositionY(0)

    end
end


function ActivityLuckWheelPanel:initDataPanel()
    local curData=gLuckWheel["type"..(self.curType-1)]
    if(curData==nil)then
        Net.sendGetLuckWheelInfo(self.curType-1,nil, gLuckWheel.actid,gLuckWheel.curTime)
        return
    end
    
    
    if(curData.closeReward==false)then
        self:getNode("btn_turn"):setVisible(true)
    else 
        self:getNode("btn_turn"):setVisible(false) 
    end
    
    self.userItem=0
    local itemid=curData.itemid
    self:setLabelString("txt_point",gLuckWheel.score)
    self:setLabelAtlas("txt_dia",curData.rewardnum)
    local leftTime=self:getCurMaxNum() -curData.turnnum
    local costItem=DB.getLuckWheelCostItem(self.curType )
    local costType= DB.getLuckWheelPriceType(self.curType )
    local price1= DB.getLuckWheelPrice1(self.curType )
    local price10= DB.getLuckWheelPrice10(self.curType )
    local tenNum=leftTime
    local isUseItem=false
    self:getNode("panel_left_count"):setVisible(true)
    if(itemid~=0)then 
        costItem=itemid
        isUseItem=true 
        self:getNode("panel_left_count"):setVisible(false)
    end
    local num=Data.getItemNum(costItem)

    Panel.setMainMoneyType(MONEY_TYPE_ITEM,costItem)
    local freeMaxNum=self:getFreeNum()

    if(isUseItem or num>0)then
        self.userItem=costItem
        self:getNode("cost_icon1"):setTexture("images/icon/item/"..costItem..".png")
        self:getNode("cost_icon2"):setTexture("images/icon/item/"..costItem..".png")
        tenNum=num
        if(tenNum>10 or  tenNum<=0)then
            tenNum=10
        end
        self:setLabelString("txt_cost1",1)
        self:setLabelString("txt_cost2",tenNum)
        self:getNode("txt_cost2").actionType=3
        self:getNode("txt_cost1").actionType=3
        
        if(freeMaxNum-curData.freenum>0)then
            self:getNode("txt_cost1").actionType=2
            self:setLabelString("txt_cost1","lab_free","labelWords.plist")
        end
    else
        tenNum=10
        self:changeIconType("cost_icon1",costType)
        self:changeIconType("cost_icon2",costType)
        self:setLabelString("txt_cost1",price1)
        self:setLabelString("txt_cost2",price10)

        self:getNode("txt_cost2").actionType=1
        self:getNode("txt_cost1").actionType=1
        if(freeMaxNum-curData.freenum>0)then
            self:getNode("txt_cost1").actionType=2
            self:setLabelString("txt_cost1","lab_free","labelWords.plist")
        end

    end


    self:replaceLabelString("txt_ten",tenNum)
    self:getNode("txt_cost2").num=tenNum


    self:initWheelItems(curData.items)
    self:setLabelString("txt_left_count",leftTime.."/"..self:getCurMaxNum())
    self:resetLayOut()
end

function ActivityLuckWheelPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "btn_type1" then

        self:selectBtn(target.touchName)
    elseif target.touchName == "btn_type2" then

        self:selectBtn(target.touchName)
    elseif target.touchName == "btn_cost1" then
        self:sendTurn( self:getNode("txt_cost1").actionType,1, self:getNode("txt_cost1"):getString())
    elseif target.touchName == "btn_cost2" then
        self:sendTurn( self:getNode("txt_cost2").actionType,self:getNode("txt_cost2").num,self:getNode("txt_cost2"):getString())
    elseif target.touchName == "btn_reward" then
        Net.sendGetLuckWheelRewardInfo()
    elseif target.touchName == "btn_log" then
        Panel.popUp(PANEL_ACTIVITY_LUCK_LOG)
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_LUCK_WHEEL);
    end



end



function ActivityLuckWheelPanel:sendTurn(type,num,cost)
    if(self.isTurning==true)then
        gShowNotice(gGetWords("luckyWheel.plist","inTurn"))
        return
    end

    local cost=toint(cost)

    if(type==1 and NetErr.isDiamondEnough(cost)==false)then
        return
    end

    local curData=gLuckWheel["type"..(self.curType-1)]
    if(curData==nil)then
        return
    end
    local leftTime=self:getCurMaxNum() -curData.turnnum
    if(type==1)then
        if(leftTime<num)then
            gShowNotice(gGetWords("luckyWheel.plist","notime"))
            return
        end
    elseif(type==2)then
        if(self.curType==1)then
            Data.redpos.bolLuckWheelfree0=false
        end 

        if(self.curType==2)then
            Data.redpos.bolLuckWheelfree1=false
        end 
    elseif(type==3)then
        if(Data.getItemNum(self.userItem)<cost)then
            gShowNotice(gGetWords("luckyWheel.plist","noitem"))
            return
        end
    end

    Net.sendTurnLuckWheel(self.curType-1,type, num,cost)
end


function ActivityLuckWheelPanel:initWheelItems(items)

    self.items=items
    self.luckyWheelItems = {}
    local radius = 180
    local luckyWheelCount=table.count(items)
    for i = 1, luckyWheelCount do
        if(self.luckyWheelItems[i])then
            self.luckyWheelItems[i]:removeAllChlidren()
        end
        local luckItem = items[i]
        if luckItem.id == 0 then
            self.luckyWheelItems[i] = cc.Sprite:create("images/ui_digmine/luckywheel_0.png")
        else
            local quality  = DB.getItemQuality(luckItem.id)
            if quality >= 5 then
                quality = 5
            end
            self.luckyWheelItems[i] = cc.Sprite:create("images/ui_digmine/luckywheel_"..quality..".png")
        end
        local angle = 360 / luckyWheelCount * (i - 1)
        self.luckyWheelItems[i]:setRotation(90 - angle)
        self.luckyWheelItems[i]:setAnchorPoint(cc.p(0.5,0.5))
        local x = math.cos(math.rad(angle)) * radius
        local y = math.sin(math.rad(angle)) * radius
        gAddChildByAnchorPos(self:getNode("container"), self.luckyWheelItems[i], cc.p(0.5, 0.5), cc.p(x,y))


        local map=nil
        if(luckItem.reward)then
            map="ui/ui_drop_luck.map"
        end
        local node = DropItem.new(nil,map)
        node.tipType=TIP_TOUCH_DESC
        node.tipTypeData=luckItem.rewarddes
        node:setData(luckItem.id)
        node:setLabelString("txt_num",luckItem.numdes)
        if(luckItem.icon1~=0)then
            Icon.setItemIcon(luckItem.icon1,node:getNode("icon"),5)
        end

        if(luckItem.reward)then
            node:changeTexture("icon","images/ui_public1/ka_luck.png")
        end
        node:setScale(0.7)
        node:setAnchorPoint(cc.p(0.5,-0.5))
        node:setTag(99)
        gAddChildByAnchorPos(self.luckyWheelItems[i], node, cc.p(0.5, 0.5), cc.p(0, 0))
    end
end

function  ActivityLuckWheelPanel:events()
    return {EVENT_ID_LUCK_WHEEL_INFO,EVENT_ID_LUCK_WHEEL_TURN}
end

function ActivityLuckWheelPanel:dealEvent(event,data)

    if(event==EVENT_ID_LUCK_WHEEL_INFO)then
        self:initDataPanel()
        self:initNoticeRewardPanel(data)
    elseif(event==EVENT_ID_LUCK_WHEEL_TURN)then
        self:initDataPanel()
        self:initNoticeRewardPanel(data.notice)
        self.result=data.result

        for key, var in pairs(data.result) do
            table.insert(self.rewardItems,var)
        end
        self:saveRewardLog()
        self:showResult()
    end
end


function ActivityLuckWheelPanel:showResult()
    if(table.getn(self.result)==0)then
        return
    end
    local result=self.result[1]
    table.remove(self.result,1)
    self:turnWheel(result,7)
end
function ActivityLuckWheelPanel:turnWheel(result,time)
    self.isTurning = true

    local selectItem = self.luckyWheelItems[result.idx+1]
    if nil == selectItem then
        self.isTurning = false
        return
    end

    local angle = -selectItem:getRotation()
    angle = angle - math.mod(self:getNode("container"):getRotation(), 360)
    local lapCount = math.random(3,5)
    while  angle < 360 * (lapCount - 1) do
        angle = angle + 360
    end

    while angle >= 360 * lapCount do
        angle = angle - 360
    end

    local action1 = cc.RotateBy:create(angle / 500, angle)
    local action2 = cc.EaseElasticOut:create(action1,time)
    local callback = cc.CallFunc:create(function()
        self:showRewardEffect(result.id,result.num,result.flower)
        self.isTurning = false
        self:showResult()
    end)
    self:getNode("container"):runAction(cc.Sequence:create(action2, callback))
end


function ActivityLuckWheelPanel:showRewardEffect(id,num,flower)

    loadFlaXml("ui_zhuanpan")
    if(flower)then
        self:getNode("flower_container"):removeAllChildren()
        local fla=gCreateFla("ui_zp_caidai")
        self:getNode("flower_container"):addChild(fla)
    end
    local item=cc.Node:create()
    local node = DropItem.new()
    node:setData(id)
    node:setNum(num)
    local fla=gCreateFla("ui_zp_juhuazhuan") 
    gAddCenter( fla,item)

    node:setPositionX(-node:getContentSize().width/2)
    node:setPositionY( node:getContentSize().height/2)
    item:addChild(node)
    self:getNode("pos_container"):addChild(item)
    item:setPosition(self:getNode("pos1"):getPosition())
    local callback = cc.CallFunc:create(function()
        item:removeFromParent()
        local result={}
        result.id=id
        result.num=num
        self:initRewardPanel({result})
    end)
    item:setScale(0.1)
    local action1 =cc.Spawn:create(
        cc.MoveTo:create(0.3,cc.p(self:getNode("pos2"):getPosition())),
        cc.EaseBackOut:create(cc.ScaleTo:create(0.7,1))
    )
    local action2=cc.DelayTime:create(0.5)
    local action3 = cc.Spawn:create(
        cc.MoveTo:create(0.5,cc.p(self:getNode("pos3"):getPosition())),
        cc.ScaleTo:create(0.5,0)
    )
    item:runAction(cc.Sequence:create(action1,action2,action3, callback))
end

function ActivityLuckWheelPanel:resetBtnTexture()
    local btns={
        "btn_type1",
        "btn_type2",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end

    for i=1, 2 do
        self:getNode("btn_type"..i.."_arrow"):setVisible(false)
    end

end
function ActivityLuckWheelPanel:selectBtn(name)
    if(self.isTurning==true)then
        gShowNotice(gGetWords("luckyWheel.plist","inTurn"))
        return
    end
    self:resetBtnTexture()
    self:getNode(name.."_arrow"):setVisible(true)
    self.curType=toint(string.gsub(name,"btn_type",""))
    self:changeTexture( name,"images/ui_public1/button_s2-1.png")
    self:initDataPanel()
end



function ActivityLuckWheelPanel:createFlaReplaceItem(id)
    local  ret = nil
    if id == OPEN_BOX_GOLD then
        ret = cc.Sprite:create("images/ui_public1/coin.png")
    elseif id == OPEN_BOX_PET_SOUL then
        ret = cc.Sprite:create("images/icon/sep_item/"..id..".png")
    else
        ret = cc.Sprite:create("images/icon/mine/"..id..".png")
    end

    return ret
end
return ActivityLuckWheelPanel
