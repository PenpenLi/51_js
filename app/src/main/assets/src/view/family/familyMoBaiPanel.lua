local FamilyMoBaiPanel=class("FamilyMoBaiPanel",UILayer)

function FamilyMoBaiPanel:ctor() 
    self.appearType = 1;
    self:init("ui/ui_family_mobai.map")
    self.isMainLayerMenuShow = false;

    Panel.setMainMoneyType(OPEN_BOX_ENERGY);
    
    self:setLab();
end

--EVENT_ID_FAMILY_MOBAI

function FamilyMoBaiPanel:setLab()
    self:replaceRtfString("lab_m1",gFamilyInfo.mobai_price,gFamilyInfo.mobai_uname);
    self:replaceRtfString("lab_m2",gFamilyInfo.mobai_eng_get);
    self:replaceRtfString("lab_m3",gFamilyInfo.mobai_num-gFamilyInfo.worship);
end

function FamilyMoBaiPanel:onTouchEnded(target)

    if  target.touchName=="two_btn_confirm" then
        if (gFamilyInfo.worship<gFamilyInfo.mobai_num) then
            if (NetErr.isGoldEnough(gFamilyInfo.mobai_price) == false) then
               return;
            end
            Net.sendFamilyWorship(gFamilyInfo.mobai_uid)
            Panel.popBack(self:getTag())
        else
            local sWord = gGetWords("familyWords.plist","mobai_no_num");
            gShowNotice(sWord)
        end
    elseif  target.touchName=="btn_close" or target.touchName=="two_btn_cancel"then
        Panel.popBack(self:getTag()) 
    end
end

return FamilyMoBaiPanel