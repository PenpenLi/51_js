local LevelUpItem=class("LevelUpItem",UILayer)

function LevelUpItem:ctor(data)
    self:init("ui/ui_levelup_item.map")
    self.unlocktype = data.unlocktype;
    self.curData = data;
    self:setLabelString("txt_name",data.name);
    self:setLabelString("txt_content",data.content);
    self:replaceLabelString("txt_level",data.level);
    self:changeTexture("icon","images/ui_unlock/unlock"..data.unlocktype..".png");

    local isunlock = Data.getCurLevel() == toint(data.level);
    self:getNode("txt_level"):setVisible(not isunlock);
    self:getNode("btn_goto"):setVisible(isunlock);
    self:getNode("txt_open"):setVisible(isunlock);

end

function LevelUpItem:onTouchEnded(target)

    if(target.touchName == "btn_goto")then

        if(self.onGoto)then
            self.onGoto(self.unlocktype,self.curData.id);
        end

    end

end

return LevelUpItem