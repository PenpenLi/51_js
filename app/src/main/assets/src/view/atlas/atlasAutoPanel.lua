local AtlasAutoPanel=class("AtlasAutoPanel",UILayer)

function AtlasAutoPanel:ctor(data,crusade)
    self:init("ui/ui_atlas_saodang1.map")
    self.isMainLayerMenuShow = false;
    for i=1, 7 do
        self:getNode("reward_"..i):setVisible(false)
    end
    self:getNode("crusade_panel"):setVisible(false)
    self.curCrusade=crusade
    -- self:getNode("scroll").oldPosY=self:getNode("scroll"):getPositionY()
    -- self:getNode("scroll").eachLineNum=1
    -- self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll"):setCheckChildrenVisibleEnable(false);
    self.batData=data.batData
    self.curStage=DB.getStageById(self.batData.mapid,self.batData.stageid,self.batData.type)
    self:showRewards(data.rewards)
    self.isMainLayerGoldShow=false
    self.itemShowTime=0.1
    self:setAutoBtn()
    gCreateRoleRunFla(Data.getCurIcon(),self:getNode("bg_my_role"),0.9,nil,nil,Data.getCurWeapon(),Data.getCurAwake());

    self:setTouchEnableGray("btn_batch_auto",false)
    self:setTouchEnableGray("btn_auto",false)

    if(self.batData.type==ATLAS_TYPE_BOSS)then
        self:getNode("panel_auto"):setVisible(false)
    end

    self:getNode("bg_btn_batch_auto"):setVisible(not Module.isClose(SWITCH_VIP));

end


function AtlasAutoPanel:addItems(items)
    for key, item in pairs(items) do
        if(self.rewardItems[item.id]==nil)then
            self.rewardItems[item.id]=item
        else
            self.rewardItems[item.id].num=self.rewardItems[item.id].num+item.num
        end
    end
end


function AtlasAutoPanel:showRewards(data)
    if(data==nil)then
        return
    end


    self.rewardItems={}
    for key, var in pairs(data) do
        local item=AtlasAutoItem.new()
        self:getNode("scroll"):addItem(item)
        if(self.batData.type==ATLAS_TYPE_BOSS)then
            item:setData(var,key,Data.wantedItem,false)
        else
            item:setData(var,key,Data.wantedItem)
        end
        item:setVisible(false)
        -- item:setOpacityEnabled(true);
        -- item:setOpacity(0);
        self:addItems( var.rewards.items)
    end
    -- self:getNode("total_panel"):setVisible(false)
    self:getNode("scroll"):layout()
    local moveTime=0.2
    local passTime=0
    for key, item in pairs(self:getNode("scroll").items) do
        local function onMoved()
            item:setVisible(true)
            -- item:setOpacity(255);
            item:show(moveTime)
            self:getNode("scroll"):moveItemByIndex(key-2,moveTime)
        end
        local func=   cc.CallFunc:create(onMoved)
        local delay=   cc.DelayTime:create(passTime)
        item:runAction( cc.Sequence:create(delay,func ))
        passTime=passTime+moveTime
        passTime=passTime+0.1
        passTime=passTime+table.getn(item.items)*item.itemShowTime
    end


    local function onEnd()
        self.isQuickShow=true
        -- self:getNode("total_panel"):setVisible(true)
        -- self:resizeScroll()
        AtlasAutoItem.show(self,0)
        -- Scene.showLevelUp = true;
        self:sweepEnd();
    end

    self:getNode("total_panel"):runAction( cc.Sequence:create( cc.DelayTime:create(passTime),cc.CallFunc:create(onEnd) ))

    AtlasAutoItem.initItems(self,self.rewardItems,Data.wantedItem,false)

    self:setLabelString("txt_need","")
    self:getNode("txt_need"):setVisible(false)
    for key, item in pairs(self.items) do
        if(item.curData==Data.wantedItem)then
            local num=Data.getItemNum(Data.wantedItem)
            if(num>=Data.wantedItemNum)then
                self:setLabelString("txt_need",gGetWords("labelWords.plist","lb_atlas_num_enough"))
            else

                self:setLabelString("txt_need",gGetWords("labelWords.plist","lb_need_atlas_num",Data.wantedItemNum-num))
            end

            self:getNode("txt_need"):setPositionX(item:getParent():getPositionX())
        end
    end
end

-- function AtlasAutoPanel:resizeScroll()
--     local offsetY=self:getNode("total_panel"):getContentSize().height-10
--     local viewSize=self:getNode("scroll").viewSize
--     viewSize.height=viewSize.height-offsetY
--     self:getNode("scroll"):resize(viewSize)
--     self:getNode("scroll"):setPositionY(self:getNode("scroll").oldPosY+offsetY/2)
--     self:getNode("scroll"):moveItemByIndex(table.getn(self:getNode("scroll").items)-2+0.15)
-- end

function AtlasAutoPanel:quickShow()
    if(self.isQuickShow)then
        return
    end
    self.isQuickShow=true
    for key, item in pairs(self:getNode("scroll").items) do
        item:stopAllActions()
        item:setVisible(true)
        item:quickShow()
    end

    for key, item in pairs(self.items) do
        item:setOpacity(255)
        item:setScale(1)
        item:stopAllActions()
    end

    self:getNode("total_panel"):stopAllActions()
    -- self:getNode("total_panel"):setVisible(true)
    -- self:resizeScroll()
    -- Scene.showLevelUp = true;
    self:sweepEnd();
end

function AtlasAutoPanel:sweepEnd()
    Scene.showLevelUp = true;
    self:openShop()

    self:getNode("txt_need"):setVisible(true)
    self:getNode("att_effect"):removeFromParent();
    self:getNode("att_effect1"):removeFromParent();
    gCreateRoleFla(Data.getCurIcon(),self:getNode("bg_my_role"),0.9,nil,nil,Data.getCurWeapon(),Data.getCurAwake());
    local flaEnd = gCreateFla("ui_saodang_over",-1);
    self:replaceNode("sweep_end",flaEnd);

    self:setTouchEnableGray("btn_batch_auto",true)
    self:setTouchEnableGray("btn_auto",true)



    if(self.curCrusade )then
        self:setCrusade(self.curCrusade)
        self.curCrusade=nil
        --Panel.popUp(PANEL_CRUSADE_NEW,self.curCrusade)
    end

end
function AtlasAutoPanel:setCrusade(data)
    loadFlaXml("ui_crusade")
    self:getNode("bg_my_role"):setAllChildCascadeOpacityEnabled(true)
    self:getNode("crusade_ui"):setAllChildCascadeOpacityEnabled(true)
    self:getNode("bg_my_role"):runAction(cc.FadeOut:create(0.3))
    self:getNode("sweep_end"):setVisible(false)
    self:getNode("crusade_panel"):setVisible(true)
    self:getNode("crusade_ui"):setOpacity(0)
    self:getNode("crusade_ui"):runAction(cc.FadeIn:create(0.5))
    self:getNode("btn_shared"):setVisible(false)
    local color=gGetItemQualityColor(data.quality)
    color=gParseRgbNum(color.r,color.g,color.b)
    data.name = gGetMonsterName(data.mid,data.name)
    local word=gGetWords("labelWords.plist","find_crucash",color,data.name,data.level)
    self:setRTFString("txt_info",word)
    local fla=FlashAni.new()
    fla:playAction("ui_crusade_effect",nil ,nil ,0)
    local role = gCreateFlaDislpay("r"..data.cid.."_wait",0,"r"..data.cid.."_wait");
    fla:replaceBoneWithNode({"ship","ship","npc" },role);
    gAddCenter(fla, self:getNode("crusade_effect"))
    self:getNode("crusade_effect"):setScale(0)
    self:getNode("crusade_effect"):runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.5,0.7)))
    self:getNode("btn_share").id=data.id
end

function AtlasAutoPanel:openShop()
    if (Data.limit_open) then
        Data.limit_open = false
        local param={type=Data.limit_stype}
        Panel.popUpVisible(PANEL_SHOP_NOTICE,param)
    end
end







function  AtlasAutoPanel:setAutoBtn()
    local showCount = self.batData.batNum;
    self:replaceLabelString("btn_txt_batch_auto",self:getRemainBatNum())
    if self.batData.type == 0 then
        showCount = gGetWords("labelWords.plist","normalAtlasTimes");
    elseif self.batData.type == ATLAS_TYPE_BOSS then
        showCount =1
        if(self.batData.batNum and self.batData.batNum<=0)then
            showCount =0
        end
    end
    self:setLabelString("txt_remain_bat_num",showCount)



end
function AtlasAutoPanel:getRemainBatNum()
    if(self.batData.type==ATLAS_TYPE_BOSS)then
        return 0
    end
    if self.batData.type == 0 then
        return 10;
    end

    local ret= self.batData.batNum
    if(ret>ATLAS_SWEEP_REAMIN_TIME)then
        return ATLAS_SWEEP_REAMIN_TIME
    else
        return ret
    end
end

function AtlasAutoPanel:isEnoughTimes()

    if self.batData.type== 1 and self:getRemainBatNum()==0 then

        local word=gGetWords("noticeWords.plist","arena_no_time")
        local function onBuyTime()
            self:buyTimes();
        end
        gConfirmAll(word,onBuyTime);
        return false;
    end

    return true;
end


function  AtlasAutoPanel:events()
    return {EVENT_ID_ATLAS_ENTER_INFO}
end


function AtlasAutoPanel:dealEvent(event,param)
    if(event==EVENT_ID_ATLAS_ENTER_INFO )then
        self.batData=param
        self:setAutoBtn()
    end
end



function AtlasAutoPanel:buyTimes()
    Data.vip.atlasreset.setUsedTimes(self.batData.buyNum);
    Data.vip.atlasreset.setBuyCount(self.curStage.day_num);

    local callback = function(num)
        Net.sendBuyBatNum(self.batData.mapid, self.batData.stageid, self.batData.type,num)
    end

    if (Data.activityAtlasSaleoff.val) then
        Data.canBuyTimes(VIP_STAGERESET,true,callback,Data.activityAtlasSaleoff.val);
    else
        Data.canBuyTimes(VIP_STAGERESET,true,callback);
    end
end

function AtlasAutoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
        Scene.showLevelUp = true;
        self:openShop()
    elseif  target.touchName=="btn_share"then
        self:getNode("btn_share"):setVisible(false)
        self:getNode("btn_shared"):setVisible(true)
        Net.sendCrusadeShare(target.id)
    elseif  target.touchName=="btn_fight"then
        Net.sendCrusadeInfo()
        if (TalkingDataGA) then
            gLogEvent("rebel.fight")
        end


    elseif  target.touchName=="btn_batch_auto"then
        if(Scene.needLevelup)then
            Scene.showLevelUp = true;
            self:quickShow()
            return;
        end
        if self:isEnoughTimes() then
            if Unlock.isUnlock(SYS_SWEEP,true) then
                Net.sendAtlasSweep( self.batData.mapid, self.batData.stageid, self.batData.type,self:getRemainBatNum())
            end
        end
    elseif  target.touchName=="btn_auto"then
        if(Scene.needLevelup)then
            Scene.showLevelUp = true;
            self:quickShow()
            return;
        end
        if self:isEnoughTimes() then
            Net.sendAtlasSweep( self.batData.mapid, self.batData.stageid, self.batData.type,1)
        end
    elseif  target.touchName=="touch_node"then
        self:quickShow()
    end
end

return AtlasAutoPanel