local RulePanel=class("RulePanel",UILayer)

function gShowRulePanel(sys_type)
	Panel.popUpVisible(PANEL_RULE,sys_type);
end

function RulePanel:ctor(sys_type)
	self.appearType = 1;
	self.hideMainLayerInfo = true;
    self:init("ui/ui_rule.map");

    self:setLabelString("txt_title",gGetWords("ruleWords.plist",sys_type.."title"));
    local word = gGetWords("ruleWords.plist",sys_type.."content");
    
    if (SYS_WORLD_BOSS == sys_type and Data.worldBossInfo.bosstype == 1) then
        self:setLabelString("txt_title",gGetWords("ruleWords.plist",sys_type.."title_new"));
        word = gGetWords("ruleWords.plist",sys_type.."content_new");
    end
    -- if (SYS_FAMILY_SPRING == sys_type) then
    -- 	local addDouble = gFamilyInfo.bolDoubleRe and 2 or 1
    -- 	word = gGetWords("ruleWords.plist",sys_type.."content",addDouble*7000);
    -- end

    --TODO: replace params
    local width = self:getNode("scroll"):getContentSize().width;
	local rtf = RTFLayer.new(width);
	rtf:setLineSpace(8);
	rtf:setString(word);
	rtf:setAnchorPoint(cc.p(0,1));
	rtf:layout();

	self:getNode("scroll"):addItem(rtf);
	self:getNode("scroll"):layout();

end

function RulePanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
    	self:onClose();
    end
end
  

return RulePanel