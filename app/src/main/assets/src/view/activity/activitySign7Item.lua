local ActivitySignItem7=class("ActivitySignItem7",UILayer)

function ActivitySignItem7:ctor(type)
    self:init("ui/ui_hd_sign_item7.map")
    self.curType=type
    if(type==ACT_TYPE_97)then
        self:changeIconType("icon",OPEN_BOX_GOLD)
    else
        self:changeIconType("icon",OPEN_BOX_DIAMOND)
    end
end

function ActivitySignItem7:setData(data,consumeData)
    
    self:replaceLabelString("txt_day",data.day)
    self:getNode("icon_pass"):setVisible(false)
    self:getNode("panel_no_reach"):setVisible(false)
    self:getNode("panel_reach"):setVisible(false)
    self:setLabelString("txt_resume",0)
    self:setLabelString("txt_return",0)
    self:setTouchEnable("btn",false,false)
    self:getNode("icon2"):setVisible(false)
    self:getNode("icon_today"):setVisible(data.today)
    if(data.reach)then
        self:getNode("panel_reach"):setVisible(true)
    else
        self:getNode("panel_no_reach"):setVisible(true)
    end
    if(consumeData==nil)then
        return
    end 

    local consumeArr=data.consumeArr
    local returnArr=data.returnArr
    local dayneed=data.dayneed
    local  consumeNum=consumeData.consume
    if( consumeData.rec==true)then
        self:setLabelString("txt_day","")
        self:getNode("icon_pass"):setVisible(true)
        self:getNode("icon_today"):setVisible(false)
    end
    local returnPer=0
    for i=1, 3 do
        if( consumeArr[i] and consumeNum>=consumeArr[i] )then
            returnPer=returnArr[i]
        end
    end
    local retNum=math.floor(consumeNum*returnPer/100)
    if(data.reach and consumeData.rec==false and data.today==false and retNum>0 )then
        self:setTouchEnable("btn",true,false)
        loadFlaXml("ui_kuang_texiao")
        self:getNode("icon2"):removeChildByTag(100)
        local fla=gCreateFla("ui_kuang_xiaoguo",1);
        fla:setTag(100);
        self:getNode("icon2"):setVisible(true)
        gAddChildInCenterPos(self:getNode("icon2"),fla);
        
        if(self.curType==ACT_TYPE_97)then
            Data.redpos.act97.pt=true
        else
            Data.redpos.act98.pt=true
        end
    end

 

    gShowShortNum(self,"txt_resume",consumeNum,100000);
    gShowShortNum(self,"txt_return",retNum,100000);

end


function ActivitySignItem7:onTouchEnded(target)
    if(target.touchName=="btn")then  
        Net.sendActivityRec97Day(self.curType,self.key,self.callback)
    end
end

function ActivitySignItem7:setNoReach()
    self:getNode("panel_no_reach"):setVisible(true)
    self:getNode("panel_reach"):setVisible(false)
end


function ActivitySignItem7:setReach()
    self:getNode("panel_no_reach"):setVisible(false)
    self:getNode("panel_reach"):setVisible(true)
end


return ActivitySignItem7