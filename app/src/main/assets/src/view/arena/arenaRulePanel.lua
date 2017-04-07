local ArenaRulePanel=class("ArenaRulePanel",UILayer)

function ArenaRulePanel:ctor()
    self:init("ui/ui_arena_rule.map")
    self.isMainLayerMenuShow = false;
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- self:getNode("scroll").container:setContentSize(self:getNode("bg"):getContentSize()) 
    -- self:getNode("scroll").container:setPositionY(self:getNode("scroll"):getContentSize().height-  self:getNode("bg"):getContentSize().height )

    local conf=DB.getArenaReward(gArena.rank)
    if conf and conf.item1~=0 then
        local words=gGetWords("arenaWords.plist","lab_1",gArena.rank,conf.rank_up,conf.rank_down)
        if conf.rank_up == conf.rank_down then
            words = gGetWords("arenaWords.plist","lab_1_1",gArena.rank);
        end
        self:setLabelString("lab_1",words)
        self:setLabelString("txt_reward1",conf.num1)
        self:setLabelString("txt_reward2",conf.num2)
        self:setLabelString("txt_reward3",conf.num3)

        self:changeIconType("icon_1",conf.item1)
        self:changeIconType("icon_2",conf.item2)
        self:changeIconType("icon_3",conf.item3)

        self:getNode("lab_no"):setVisible(false)
        self:getNode("reward_bg"):setVisible(true)

        if (conf.id>1) then
            local conf_next=DB.getArenaRewardForId(conf.id-1)
            local words=gGetWords("arenaWords.plist","next_1",conf_next.rank_up,conf_next.rank_down)
            if conf_next.rank_up == conf_next.rank_down then
                words = gGetWords("arenaWords.plist","next_2",conf_next.rank_up);
            end
            self:setLabelString("txt_rank_next",words)

            self:setLabelString("txt_reward1_next",conf_next.num1)
            self:setLabelString("txt_reward2_next",conf_next.num2)
            self:setLabelString("txt_reward3_next",conf_next.num3)

            self:changeIconType("icon_1_next",conf_next.item1)
            self:changeIconType("icon_2_next",conf_next.item2)
            self:changeIconType("icon_3_next",conf_next.item3)

        else
            --隐藏
            self:getNode("txt_rank_next"):setVisible(false)
            self:getNode("reward_bg_next"):setVisible(false)
        end
    else
        self:getNode("lab_no"):setVisible(true)
        self:getNode("reward_bg"):setVisible(false)

        local words = gGetWords("arenaWords.plist","lab_1_2",gArena.rank);
        self:setLabelString("lab_1",words)

        --下一目标 排行最后
        local conf_next=DB.getArenaReward_Last()
        if (conf_next) then
            local words=gGetWords("arenaWords.plist","next_1",conf_next.rank_up,conf_next.rank_down)
            if conf_next.rank_up == conf_next.rank_down then
                words = gGetWords("arenaWords.plist","next_2",conf_next.rank_up);
            end
            self:setLabelString("txt_rank_next",words)

            self:setLabelString("txt_reward1_next",conf_next.num1)
            self:setLabelString("txt_reward2_next",conf_next.num2)
            self:setLabelString("txt_reward3_next",conf_next.num3)

            self:changeIconType("icon_1_next",conf_next.item1)
            self:changeIconType("icon_2_next",conf_next.item2)
            self:changeIconType("icon_3_next",conf_next.item3)
        end
    end
    self:replaceRtfString("txt_rank",gArena.highrank)

    self:resetLayOut();
    self:getNode("scroll"):layout();
end


 

function ArenaRulePanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())  
    end
end
 


return ArenaRulePanel