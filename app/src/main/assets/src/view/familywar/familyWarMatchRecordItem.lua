local FamilyWarMatchRecordItem=class("FamilyWarMatchRecordItem",UILayer)

function FamilyWarMatchRecordItem:ctor()
    self:init("ui/ui_family_war_match_record_item.map");
    self:getNode("icon_down1"):setVisible(false)
    self:getNode("icon_down2"):setVisible(false)
    self.powerDownPercent1=0
    self.powerDownPercent2=0
end

function FamilyWarMatchRecordItem:onTouchEnded(target)

    if(target.touchName=="btn_replay")then
        local func = function()
            local function  callback()
                if gMainBgLayer == nil then
                    Scene.enterMainScene();
                end
                FamilyWarMatchDetailPanel.isInRecord=true
                Net.sendFamilyMatchDetail(Net.sendFamilyMatchDetailParam.id)
               
            end
            Net.sendFamilyGetInfo(callback);
        end
         
        Panel.pushRePopupPre(func);
        Net.sendFamilyVedio(self.curData.vid)

        Battle.brief = {}
        Battle.brief.vid= self.curData.vid
        Battle.brief.n1 = self.curData.name1
        Battle.brief.n2 = self.curData.name2
        gBattlePowerDownPercent1=self.powerDownPercent1
        gBattlePowerDownPercent2=self.powerDownPercent2 
    end
end

function FamilyWarMatchRecordItem:setData(data,index)
    self.idx = index;
    self.curData=data;

    local winMaxParam=DB.getClientParam("FAMILY_BATTLE_ATTR_DOWN_MAX")
    local winPercentParam=DB.getClientParam("FAMILY_BATTLE_ATTR_DOWN_PERCENT")
    if(data.winCount1>0)then
        local count=math.min(winMaxParam,data.winCount1)
        self:setLabelString("txt_down1",count*winPercentParam.."%");
        self:getNode("icon_down1"):setVisible(true)
        self.powerDownPercent1=count*winPercentParam
    end
    
    if(data.winCount2>0)then
        local count=math.min(winMaxParam,data.winCount2)
        self:setLabelString("txt_down2",count*winPercentParam.."%");
        self:getNode("icon_down2"):setVisible(true)
        self.powerDownPercent2=count*winPercentParam
    end

    self:setLabelString("txt_name1",data.name1);
    self:setLabelString("txt_name2",data.name2);

    self:setLabelString("txt_power1",data.power1);
    self:setLabelString("txt_power2",data.power2);

    self:replaceLabelString("txt_lv1",data.lv1);
    self:replaceLabelString("txt_lv2",data.lv2);
    Icon.setHeadIcon(self:getNode("icon1"),data.icon1)
    Icon.setHeadIcon(self:getNode("icon2"),data.icon2)
    if(data.win==true)then
        self:changeTexture("win1","images/ui_jingji/shengli.png")
        self:changeTexture("win2","images/ui_jingji/shibai.png")
    else
        self:changeTexture("win2","images/ui_jingji/shengli.png")
        self:changeTexture("win1","images/ui_jingji/shibai.png")
    end
end



return FamilyWarMatchRecordItem