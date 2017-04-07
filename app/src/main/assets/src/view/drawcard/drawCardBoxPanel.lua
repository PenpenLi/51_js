local DrawCardBoxPanel=class("DrawCardBoxPanel",UILayer)

function DrawCardBoxPanel:ctor(taskDB,status)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")
    self:getNode("txt_tip"):setVisible(true);
    self:setLabelString("txt_tip",gGetWords("drawCardWords.plist","11",Data.drawCard.soulluck));
    local word = gGetWords("drawCardWords.plist","10",Data.drawCardParams.maxLuck);
    self:setLabelString("txt_need_num",word);
    self:getNode("reward1"):setVisible(false);
    self:getNode("reward3"):setVisible(false);

    local itemid = toint("1"..Data.drawCard.soul["soul1"]);
    Icon.setDropItem(self:getNode("reward2"),itemid,
        Data.drawCardParams.drawLuckCardNum);

    self:setTouchEnableGray("btn_get",Data.drawCard.soulluck >= Data.drawCardParams.maxLuck);
end

 

function DrawCardBoxPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_get"then
        if gIsVipExperTimeOver(VIP_DRAWCARD_SOUL) then
            return
        end
        Net.sendDrawSluckybox();
        Panel.popBack(self:getTag())
    end
end


return DrawCardBoxPanel