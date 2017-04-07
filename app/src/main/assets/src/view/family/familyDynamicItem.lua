local FamilyDynamicItem=class("FamilyDynamicItem",UILayer)

function FamilyDynamicItem:ctor()
   
end

function FamilyDynamicItem:initPanel() 
    self:init("ui/ui_family_dynamic_item.map");
    self.inited = true;
end

function FamilyDynamicItem:onTouchEnded(target)


    if  target.touchName=="icon_bg"then
        -- self.onAgree(self.curData);
        Net.sendBuddyTeam(self.curData.uid);
    end

end

function FamilyDynamicItem:setLazyData(data)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"familyDynamicItem")
end
function FamilyDynamicItem:setLazyDataCalled()
    self:setData(self.curData);
end

function FamilyDynamicItem:setData(data) 
    self:initPanel();
    self.curData=data;

    self:setLabelString("txt_name",data.sName);
    self:replaceLabelString("txt_lv",data.level);
    self:setLabelString("txt_power",data.price);
    gShowLoginTime(self,"lab_time",gGetCurServerTime() - data.iTime,false);
    Icon.setHeadIcon(self:getNode("icon_bg"),data.icon)

    self:setLabelString("dyn_type",gGetWords("familyMenuWord.plist","dyn_type"..data.iType))
    
    self:getNode("layout_get"):setVisible(false);
    self:getNode("layout_spend"):setVisible(false);
    self:getNode("layer_fexp"):setVisible(false);
    self.hasSpend = false;
    self.hasGet = false;
    self.hasFExp = false;
    --消耗
    local iSpendType = data.iCurrenCy;
    if iSpendType > 0 and data.iValue > 0 then
        self:getNode("layout_spend"):setVisible(true);
        Icon.changeSeqItemIcon(self:getNode("layout_spend_icon"),iSpendType);
        -- Icon.setIcon(iSpendType,self:getNode("layout_spend_icon"));
        self:replaceLabelString("layout_spend_txt",self:getItemName(iSpendType),data.iValue);
        self.hasSpend = true;
    end


    for key,reward in pairs(data.rewardList) do
        --活跃度
        if(reward.id == OPEN_BOX_FAMILY_EXP)then
            self:getNode("layer_fexp"):setVisible(true);
            self:setLabelString("txt_fexp",reward.iNum);
            self.hasFExp = true;
        else
            self:getNode("layout_get"):setVisible(true);
            Icon.setIcon(reward.id,self:getNode("layout_get_icon"));
            self:replaceLabelString("layout_get_txt",self:getItemName(reward.id),reward.iNum);
            self.hasGet = true;
        end
    end
    -- 131,216,41
    -- 83,d8,26
    -- data.iType = 1;
    -- iSpendType = 0;
    -- data.parame1 = 2;
    -- self.hasGet = false;
    -- self.hasSpend = false;

    local colorstr = "\\w{c=83d826}@\\";
    local content = gGetWords("familyMenuWord.plist","dyn_info"..data.iType);
    if(data.iType == 7)then
        local title = gGetWords("familyMenuWord.plist","title"..data.parame1);
        content = gReplaceParam(content,gReplaceParam(colorstr,title));
    elseif(data.iType == 11)then
        content = gReplaceParam(content,gReplaceParam(colorstr,data.parame1));
    elseif(data.iType == 13 or data.iType  == 14)then
        local buff = DB.getBuffById(data.parame1);
        if(buff)then
            content = gReplaceParam(content,gReplaceParam(colorstr,buff.name),gReplaceParam(colorstr,data.parame2));
        end
    elseif(data.iType == 18)then
        local title = gGetWords("familyMenuWord.plist","rank"..data.parame1);
        if(data.parame1 == 99)then
            content = gGetWords("familyMenuWord.plist","dyn_info"..data.iType.."_1");
        end
        content = gReplaceParam(content,gReplaceParam(colorstr,title));    
    end
    self:setRTFString("txt_content",content);

    self:getNode("layer_action"):setVisible(false);
    self:getNode("layer_fexp"):setVisible(false);
    self:getNode("txt_content"):setVisible(false);
    self:getNode("txt_content1"):setVisible(false);
    if(data.class == 1)then
        --活动类
        self:getNode("layer_action"):setVisible(true);
        self:getNode("layer_fexp"):setVisible(true);

        if(not self.hasGet and not self.hasSpend)then
            --封魔协助
            self:setRTFString("txt_content1",content);
            self:getNode("txt_content1"):setVisible(true);
        end

    elseif(data.class == 2)then
        --任命类
        self:getNode("txt_content"):setVisible(true);
    elseif(data.class == 3)then
        --升级类
        self:getNode("txt_content"):setVisible(true);
    elseif(data.class == 4)then
        --成员变动类
        self:getNode("txt_content"):setVisible(true);
    else
        self:getNode("txt_content"):setVisible(true); 
    end
    -- Icon.setHeadIcon(self:getNode("icon_bg"),data.iCoat);
    -- self:setLabelAtlas("txt_vip",data.iVip);
    
    self:resetLayOut();
end

function FamilyDynamicItem:getItemName(itemid)
    if(gIsZhLanguage())then
        return DB.getItemName(itemid);
    end
    return "";
end


return FamilyDynamicItem