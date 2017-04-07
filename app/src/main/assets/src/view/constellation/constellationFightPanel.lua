local ConstellationFightPanel=class("ConstellationFightPanel",UILayer)

function ConstellationFightPanel:ctor(constellationId)
    self:init("ui/ui_constellation_fight.map")
    self:initPanel(constellationId)
    self:initSchedule()
end

function ConstellationFightPanel:events()
    return {
            EVENT_ID_CONSTELLATION_FIGHT_REFRESH,
            EVENT_ID_CONSTELLATION_REDPOS_REFRESH,
            EVENT_ID_USER_DATA_UPDATE,
        }
end

function ConstellationFightPanel:dealEvent(event, param)
    if event == EVENT_ID_CONSTELLATION_FIGHT_REFRESH then
        self:initPanel(param)
    elseif event == EVENT_ID_CONSTELLATION_REDPOS_REFRESH then
        self:showBtnRedpos()
    elseif event == EVENT_ID_USER_DATA_UPDATE then
        self:showFightInfo()
    end
end

function ConstellationFightPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_exchange" then
        Panel.popUpVisible(PANEL_SHOP, SHOP_TYPE_CONSTELLATION)
    elseif target.touchName=="btn_bag" then
        Panel.popUp(PANEL_CONSTELLATION_BAG)
    elseif target.touchName=="btn_hunt"then
        Net.sendCircleHuntInfo()
    elseif target.touchName == "btn_change" then
        if isBanshuUser() and 
            gConstellation.getFreeLeftChangeNum() == 0 then
            return 
        end
        if gConstellation.getFreeLeftChangeNum() == 0 and
           gConstellation.getConstellationFightBuyPrice() > Data.getCurDia() then
           NetErr.noEnoughDia()
           return
        end

        Net.sendCircleChfigter()
    elseif target.touchName == "btn_fight" then
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_CONSTELLATION)
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_CONSTELLATION_FIGHT)
    end
end

function ConstellationFightPanel:initPanel(constellationId)
    self.constellationId = constellationId
    -- 人物显示
    self:showCard()
    --换可挑战的人
    self:showChangeInfo()
    --可能掉落
    self:showDropItem()
    --挑战次数
    self:showFightInfo()

    self:showBtnRedpos()
end

function ConstellationFightPanel:parseFlaActions()
    self.flaAction={}
    self.curFlaActionIdx=0
    local actions=string.split(self.cardDb.actlist,",")
    for key, actionid in pairs(actions) do

        if(actionid=="0")then
            table.insert(self.flaAction,"wait")
        elseif(actionid=="1")then
            table.insert(self.flaAction,"run")
        elseif(actionid=="2")then
            table.insert(self.flaAction,"win")
        elseif(actionid=="3")then
            table.insert(self.flaAction,"attack_s")
        elseif(actionid=="4")then
            table.insert(self.flaAction,"attack_b")
        end
    end
end

function ConstellationFightPanel:nextFlaAction()

    self.curFlaActionIdx=self.curFlaActionIdx+1
    if(self.curFlaActionIdx>table.getn(self.flaAction))then
        self.curFlaActionIdx=1
    end

    self:playFlaAction( self.flaAction[self.curFlaActionIdx])
end

function ConstellationFightPanel:playFlaAction(action)
    if(self.fla)then
        if(action==nil)then
            action="wait"
        end
        local function onCallBack()
            if(action=="run")then
                self.fla:playAction( "r"..self.lastFlaId.."_run" ,onCallBack)
            else
                self.fla:playAction( "r"..self.lastFlaId.."_wait" ,onCallBack)
            end
        end

        if(action=="wait" )then
            if(self.lastSoundId)then
                gStopEffect(self.lastSoundId)
            end
            if isBanshuReview() == false then
                self.lastSoundId= gPlayEffect("sound/card/"..self.cardDb.cardid..".mp3")
            end
        end
        self.fla:playAction("r"..self.lastFlaId.."_"..action ,onCallBack)
    end
end

function ConstellationFightPanel:showCard()
    self.curStage = DB.getConstellationStageById(self.constellationId)
    if nil == self.curStage then
        return
    end

    self:setLabelString("txt_name", self.curStage.name)
    local itemInfo = gConstellation.getBagById(self.curStage.stage_id)
    local txtColor = cc.c3b(255, 144, 0)
    if itemInfo.star == 2 then
        txtColor = cc.c3b(255, 120, 247)
    elseif itemInfo.star == 1 then
        txtColor = cc.c3b(8, 200, 255)
    end
    self:getNode("txt_name"):setColor(txtColor)

    local cardId = DB.getConstellationsItemInfo(self.constellationId)["icon"]
    self.cardDb=DB.getCardById(cardId)
    self:parseFlaActions()
    self.lastFlaId=cardId
    local scale = 0.8
    if cardId==11000 then
        scale=0.3
    end
    self.fla=gCreateRoleFla(cardId, self:getNode("role_container") ,scale,true)

    self:nextFlaAction()
end

function ConstellationFightPanel:showChangeInfo()
    local freeLeftChangeNum = gConstellation.getFreeLeftChangeNum()
    if freeLeftChangeNum > 0 then
        self:setLabelString("txt_free_change_num", gGetMapWords("ui_constellation_fight.plist", "11", freeLeftChangeNum))
        self:getNode("txt_free_change_num"):setVisible(true)
        self:getNode("layout_cost"):setVisible(false)
    else
        local price = gConstellation.getConstellationFightBuyPrice()
        self:setLabelString("txt_price", price)
        self:getNode("layout_cost"):layout()
        self:getNode("txt_free_change_num"):setVisible(false)
        self:getNode("layout_cost"):setVisible(true)
    end

    if isBanshuUser() then
        self:setLabelString("txt_free_change_num", gGetMapWords("ui_constellation_fight.plist", "11", freeLeftChangeNum))
        self:getNode("txt_free_change_num"):setVisible(true)
        self:getNode("layout_cost"):setVisible(false)
    end
end

function ConstellationFightPanel:showDropItem()
    for i = 1, 6 do
        self:getNode("reward"..i):removeChildByTag(199)  
    end

    local drops= string.split(self.curStage.passrew,";")
    for i, dropId in pairs(drops) do
        if toint(dropId) ~= 0 then
            local pSize=self:getNode("reward"..i):getContentSize()
            local node=DropItem.new()
            local dropId=toint(dropId)
            node:setData(dropId)
            node:setPositionY(pSize.height/2+node:getContentSize().height/2)
            node:setPositionX(pSize.width/2-node:getContentSize().width/2)
            self:getNode("reward"..i):addChild(node)
            node:setTag(199)
            node:setLabelString("txt_num","")
        end
    end
end

function ConstellationFightPanel:showFightInfo()
    local leftFightNum = gConstellation.getLeftFightNum()
    self:setLabelString("txt_fight", string.format("%d/%d", leftFightNum, DB.getConstellationFightMaxNum()))
    if leftFightNum == 0 then
        self:setTouchEnable("btn_fight", false, true)
    end
end

function ConstellationFightPanel:showBtnRedpos()
    if Data.redpos.constellationhunt then
        RedPoint.add(self:getNode("btn_hunt"), cc.p(0.8,0.8))
    else
        RedPoint.remove(self:getNode("btn_hunt"))
    end
end

function ConstellationFightPanel:initSchedule()
    -- local function update()
    --     if gConstellation.getLeftFightNum() < DB.getConstellationFightMaxNum() then
    --         local curServerTime = gGetCurServerTime()
    --         local lastRecoveryTime = gConstellation.getLeftFightRecoveryTime()
    --         local fightRecoveryTime = DB.getConstellationFightRecovery()
    --         local leftTime = lastRecoveryTime + fightRecoveryTime - curServerTime
    --         if leftTime < 0 then
    --             leftTime = 0
    --         end
    --         self:setLabelString("txt_recover_time", gParserHourTime(leftTime))
    --         self:getNode("layout_recover_time"):layout()
    --         self:getNode("layout_recover_time"):setVisible(true)
    --     else
    --         self:getNode("layout_recover_time"):setVisible(false)
    --     end
    -- end

    -- self:scheduleUpdate(update, 1)
end

function ConstellationFightPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

return ConstellationFightPanel
