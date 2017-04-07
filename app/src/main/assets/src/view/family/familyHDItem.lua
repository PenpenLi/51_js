
local FamilyHDItem=class("FamilyHDItem",UILayer)

function FamilyHDItem:ctor(type)
    self:init("ui/ui_family_huodong_item.map")
    
    self.type = type;
    self:changeTexture("icon","images/ui_family/huodong_"..type..".png");
    self:replaceLabelString("tip_level",1);
    self:setLabelString("tip_reward",gGetWords("familyWords.plist","hd_reward"..type))
    self:setLabelString("tip_content",gGetWords("familyWords.plist","hd_content"..type))
    self:setLabelString("tip",gGetWords("familyWords.plist","hd_tip"..type));
    gSetLabelScroll(self:getNode("tip_content"),1);
    self:initTip();

    -- gFamilyInfo.bolDoubleRe = true
    self:getNode("double_sign"):setVisible(false);
    if ((self.type == 1 or self.type == 4) and gFamilyInfo.bolDoubleRe == true) then
        self:getNode("double_sign"):setVisible(true);
    end
end

function FamilyHDItem:initTip()
    if(self.type == 1)then
        self:getNode("tip"):setVisible(not Data.redpos.bolFamilyGu);
    elseif(self.type == 2)then
        self:getNode("tip"):setVisible(not Data.redpos.bolFamilyEgg);
    elseif(self.type == 3)then
        self:getNode("tip"):setVisible(true);
        self:setLabelString("tip",gGetWords("familyWords.plist","hd_tip"..self.type,gFamilyInfo.sevennum));
    elseif(self.type == 4)then
        if(gFamilySpringInfo.callUid <= 0)then
            self:getNode("tip"):setVisible(false);
        elseif(gFamilySpringInfo.callUid == Data.getCurUserId())then
            self:getNode("tip"):setVisible(true);
            self:setLabelString("tip",gGetWords("familyWords.plist","hd_tip4_1"));
        else
           self:getNode("tip"):setVisible(not Data.redpos.bolFamilySpring);
           if(not Data.redpos.bolFamilySpring)then
                local maxNum = DB.getFamilySplv_maxnum(Data.getCurFamilyLv());
                if(gFamilyInfo.drinknum >= maxNum)then
                    self:setLabelString("tip",gGetWords("familyWords.plist","hd_tip4_2"));
                end
           end 
        end
    end    
end


function FamilyHDItem:onTouchEnded(target)

    if  target.touchName=="btn_enter"then
    	if self.type == 1 then
    		Panel.popUp(PANEL_FAMILY_CONTRIBUTION);
    	elseif self.type == 2 then
    		Panel.popUp(PANEL_FAMILY_EGG);
    	elseif self.type == 3 then
    		Net.sendFamilySevenInfo();
    	elseif self.type == 4 then
            Net.sendFamilySpringInfo();
        elseif self.type == 5 then
            Net.sendFamilyMatchInfo()
    	end
    end

end

return FamilyHDItem