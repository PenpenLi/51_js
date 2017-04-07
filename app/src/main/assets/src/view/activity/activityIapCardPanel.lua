local ActivityIapPanel=class("ActivityIapPanel",UILayer)

CARD_TYPE_MON=6
CARD_TYPE_LIFE=7

function ActivityIapPanel:ctor(data)

    self:init("ui/ui_hd_card.map")
    self.curData=data

    local monCard= DB.getIapById(CARD_TYPE_MON)
    local yearCard= DB.getIapById(CARD_TYPE_LIFE)
    local monDia = DB.getDiaForMonthCard();
    local yearDia = DB.getDiaForLifeCard();
    self:replaceRtfString("month_tip1",monCard.diamond);
    self:replaceRtfString("month_tip2",monDia);
    self:replaceRtfString("life_tip1",yearCard.diamond);
    self:replaceRtfString("life_tip2",yearDia);

    local word1=gGetWords("labelWords.plist","mcard_help0", monCard.diamond,monDia)
    self:setLabelString("txt_info1",word1)

    local word2=gGetWords("labelWords.plist","mcard_help1", yearCard.diamond,yearDia)
    self:setLabelString("txt_info2",word2)

    self:setLabelString("txt_name1",gUserInfo.name)
    self:setLabelString("txt_name2",gUserInfo.name)

    self:setLabelString("txt_dia1",monCard.diamond)
    self:setLabelString("txt_dia2",yearCard.diamond)

    self:setLabelString("txt_money1",monCard.money)
    self:setLabelString("txt_money2",yearCard.money)
    
    self:setData(nil)
    
    local params=  DB.getClientParam("ENERGY_MAX")
    local exps= string.split(params,";") 
    self:replaceLabelString("txt_12",exps[4])
    self:replaceLabelString("txt_11",DB.getClientParam("MONTHCARD_SWEEP_DOUBLE_RATE"))
    
    
    local times=string.split( DB.getClientParam("RECOVERY_TIME_SKILLPOINT"),";" ) 
    self:replaceLabelString("txt_21",toint(times[1]-times[2])/times[1]*100)
    
    self:replaceLabelString("txt_22",DB.getClientParam("LIFECARD_ADD_SKILLPOINT"))
    
    self:getNode("scroll_card1_content"):layout();
    self:getNode("scroll_card2_content"):layout();
    -- self:getNode("scroll_card1_content").breakTouch=true;
    self:resetLayOut();
end


function ActivityIapPanel:onTouchEnded(target)
    if(target.touchName ==nil)then
        return
    end
    
    if(target.touchName=="btn_buy1")then
        Panel.popUp(PANEL_PAY )
        return
    end
    

    if(target.touchName=="btn_buy2")then
        Panel.popUp(PANEL_PAY )
        return
    end

    if(self.isRotationing)then
        return
    end
    -- self.isRotationing=true
    local function onMoveEnd() 
        self.isRotationing=false
        self:getNode("line2"):setVisible(true)
        self:getNode("line1"):setVisible(true)
    end

    local curIdx=-1
    local changeRotation=90
    if( target.touchName=="card2_front" or target.touchName == "bg_card2_back" or target.touchName == "txt_info2")then
        self.isRotationing=true
        curIdx=2
        changeRotation=90-23
    elseif( target.touchName=="card1_front" or target.touchName == "bg_card1_back" or target.touchName == "txt_info1")then
        self.isRotationing=true
        curIdx=1 
        changeRotation=90+23
    end
    
    
    if(curIdx==-1)then
        return
    end
    self:getNode("line"..curIdx):setVisible(false)
    
    if(self:getNode("card"..curIdx.."_front"):isVisible())then 
        local function onMoveHalf()
            self:getNode("card"..curIdx.."_front"):setVisible(false)
            self:getNode("card"..curIdx.."_back"):setVisible(true)
            self:getNode("card"..curIdx):setRotation3D(cc.vec3(0,-180+changeRotation,0))
        end

        self:getNode("card"..curIdx):runAction(
            cc.Sequence:create(
                cc.RotateTo:create(0.3,  cc.vec3(0,changeRotation,0)),
                cc.CallFunc:create(onMoveHalf),
                cc.RotateTo:create(0.3,  cc.vec3(0,0,0)),
                cc.CallFunc:create(onMoveEnd)
            ) 
        )
    else
        local function onMoveHalf()
            self:getNode("card"..curIdx.."_back"):setVisible(false)
            self:getNode("card"..curIdx.."_front"):setVisible(true)
            self:getNode("card"..curIdx):setRotation3D(cc.vec3(0,-180+changeRotation,0))
        end

        self:getNode("card"..curIdx):runAction(
            cc.Sequence:create(
                cc.RotateTo:create(0.3,  cc.vec3(0,changeRotation,0)),
                cc.CallFunc:create(onMoveHalf),
                cc.RotateTo:create(0.3,  cc.vec3(0,0,0)),
                cc.CallFunc:create(onMoveEnd)
            ) 
        ) 
    end
end

function ActivityIapPanel:dealEvent(event,param)
    if(EVENT_ID_USER_DATA_UPDATE)then
        self:setData(param)
    end

end


function ActivityIapPanel:setData(param)

    if(Data.hasMemberCard(CARD_TYPE_MON))then
        self:getNode("btn_panel1"):setVisible(false) 
        self:getNode("txt_time1"):setVisible(true)  
        local txt=  gGetWords("labelWords.plist","lb_hd_card_time1",gParserDay( gIapBuy["mctime"]))
        self:setLabelString("txt_time1",txt)
      --  self:setTouchEnable("btn_buy1",false,true)
        self:setLabelString("txt_buy1", gGetWords("btnWords.plist","btn_buy_again")) 
    else 
        
        self:getNode("btn_panel1"):setVisible(true)
        self:getNode("txt_time1"):setVisible(false) 
      --  self:setTouchEnable("btn_buy1",true,false)
    end


    if(Data.hasMemberCard(CARD_TYPE_LIFE))then 
        self:getNode("btn_panel2"):setVisible(false) 
        self:getNode("txt_time2"):setVisible(true) 
        self:setTouchEnable("btn_buy2",false,true)
        self:setLabelString("txt_buy2", gGetWords("btnWords.plist","btn_buyed")) 
    else 
        self:getNode("btn_panel2"):setVisible(true)
        self:getNode("txt_time2"):setVisible(false) 
        self:setTouchEnable("btn_buy2",true,false)
    end

end


return ActivityIapPanel