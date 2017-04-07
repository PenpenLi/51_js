local CrusadeEnterPanel=class("CrusadeEnterPanel",UILayer)

function CrusadeEnterPanel:ctor(data)
    self.appearType = 1; 
    self.isMainLayerGoldShow=false
    self.isMainLayerCrusadeShow=true
    self.isWindow = true;
    self:init("ui/ui_crusade_enter.map")

    self.curData=data

    self:getNode("bar"):setVisible(false)
    local redBar=cc.ProgressTimer:create(cc.Sprite:create("images/ui_crusade/blood_big.png"))  
    self:getNode("bar"):getParent():addChild(redBar,10)
    redBar:setPositionX(self:getNode("bar"):getPositionX() ) 
    redBar:setPositionY(self:getNode("bar"):getPositionY() ) 
    redBar:setRotation(180)
    self.redBar=redBar
 
    self:setData()
end

function CrusadeEnterPanel:setData()
    local data=self.curData
    self:setLabelString("txt_name",data.name.." Lv"..data.lv)
    self:getNode("txt_name"):setColor(gGetItemQualityColor(data.quality))

    self:setLabelString("txt_per",data.hp.."/"..data.hpmax)
    local per=data.hp/data.hpmax 
    self.redBar:setPercentage(per*100) 


    local role = gCreateFlaDislpay("r"..data.cid.."_wait",0,"r"..data.cid.."_wait");
    role:setScale(0.4) 
    self:getNode("icon"):replaceBoneWithNode({"ship","npc" },role);

    local function updateShopTime()
        if(gGetCurServerTime()>self.curData.endtime)then
            Panel.popBack(self:getTag())
        else
            self:setLabelString("txt_time", gParserHourTime( self.curData.endtime-gGetCurServerTime()))
        end
    end
    

    self:scheduleUpdate(updateShopTime,1)

    self:setLabelString("txt_need_num1",CRUSADE_COST_NUM_1)
    self:setLabelString("txt_need_num2",CRUSADE_COST_NUM_2)
    
    
    
    local time1=string.split( DB.getClientParam("CRUSADE_TOKEN_HALVE_TIME"),";") 
    self.halfCost=false

    if(toint(time1[1])<=gGetHourByTime() and toint(time1[2])> gGetHourByTime())then
        self.halfCost=true 
        self:setLabelString("txt_need_num2",CRUSADE_COST_NUM_2*0.5)
    end
    self:setRTFString("txt_info1",  gGetWords("labelWords.plist","crusade_info1",time1[1],time1[2]) )

    local time2=string.split( DB.getClientParam("CRUSADE_EXPLOIT_DOUBLE_TIME"),";")
    self:setRTFString("txt_info2",  gGetWords("labelWords.plist","crusade_info2",time2[1],time2[2]) )
    
    local maxNum=DB.getClientParam("CRUSADE_TOKEN_SHOW_MAX")
    self:setLabelString("txt_num", gCrusadeData.crunum.."/"..maxNum) 
    
    self:resetLayOut();
end

function CrusadeEnterPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function  CrusadeEnterPanel:events()
    return {EVENT_ID_CRUSADE_BUY}
end



function CrusadeEnterPanel:dealEvent(event,param)
    if(event==EVENT_ID_CRUSADE_BUY)then
        self:setData()
    end
end


function CrusadeEnterPanel:onTouchEnded(target)

    local func = function()
        Net.sendCrusadeInfo() 
    end
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
        
    elseif  target.touchName=="btn_more"then
        Panel.popUp(PANEL_CRUSADE_BUY_TIME)
    elseif  target.touchName=="btn_attack1"then
        if(gCrusadeData.crunum<CRUSADE_COST_NUM_1)then
            Panel.popUp(PANEL_CRUSADE_BUY_TIME)
            return
        end
        -- Panel.pushRePopup(func);
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ATLAS_CRUSADE,{id=self.curData.id,type=2})
    elseif  target.touchName=="btn_attack2"then
        local cost=CRUSADE_COST_NUM_2
        if(self.halfCost==true)then
            cost=cost/2
        end
        if(gCrusadeData.crunum<cost)then
            Panel.popUp(PANEL_CRUSADE_BUY_TIME)
            return
        end
        -- Panel.pushRePopup(func);
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ATLAS_CRUSADE,{id=self.curData.id,type=1})
    end

end


return CrusadeEnterPanel