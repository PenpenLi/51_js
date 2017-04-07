local NoticeboardItem=class("NoticeboardItem",UILayer)

function NoticeboardItem:ctor(data,index) 
    self:init("ui/ui_noticeboard_item.map")
    self.index = index;
    -- local txtTitle = self:getNode("txt_title");
    -- print_lua_table(data);
    local title = gCreateWordLabelTTF(data.title,gCustomFont,data.titlefontsize,cc.c3b(data.titlecolor_r,data.titlecolor_g,data.titlecolor_b));
    self:replaceNode("txt_title",title);

    self:getNode("flag_status"):setVisible(false);
    if toint(data.status) == 1 then
        self:getNode("flag_status"):setVisible(true);
        self:changeTexture("flag_status","images/ui_word/s_new.png");
    elseif toint(data.status) == 2 then
        self:getNode("flag_status"):setVisible(true);
        self:changeTexture("flag_status","images/ui_word/s_huo.png");
    end
    -- title:setPosition(txtTitle:getPosition());
    -- title:setAnchorPoint(txtTitle:getAnchorPoint());
    -- txtTitle:getParent():addChild(title);
    -- txtTitle:setVisible(false);
    -- self:setLabelString("txt_title",data.title);
    -- self:getNode("txt_title"):setColor(cc.c3b(data.titlecolor_r,data.titlecolor_g,titlecolor_b));
    
    self.txtContent = self:getNode("txt_content");
    self.txtContent:setDefaultConfig(gFont,data.cntfontsize,cc.c3b(data.cntcolor_r,data.cntcolor_g,data.cntcolor_b));
    -- data.cnt = "亲爱的玩家，您现在正在体验的是\\w{c=ff0000}《乱斗堂》\\安卓版全球首服不删档内测版本。由于当前游戏还处于测试阶段，在游戏过程中可能会出现bug和不稳定的现象，为了让游戏得到更好、更快速的完善，官方希望各位玩家在参与游戏测试时，能将各种BUG情况详细且真实的反馈给我们。";
    self:getNode("txt_content"):setLineSpace(3);
    self:setRTFString("txt_content",data.cnt);
    self.bgContent = self:getNode("bg_content");
    self.bgContent:setContentSize(self.bgContent:getContentSize().width,self.txtContent:getContentSize().height+20);
    self.txtContent:setPosition(self.bgContent:getContentSize().width/2,self.bgContent:getContentSize().height/2);
    self.bgWidth = self:getContentSize().width;
    self.bgMinHeight = self:getContentSize().height;
    self.bgMaxHeight = self:getContentSize().height + self.txtContent:getContentSize().height + 20;


    self.bgContent:setScaleY(0);
    self.bgContent:setVisible(false);
    self.isExtend = false;
    -- self:setContentSize(cc.size(self.bgWidth,self.bgMaxHeight));
    -- self:show()
    
end

function NoticeboardItem:show()
    if self.isExtend then
        return;
    end

    local time = (1-self.txtContent:getScaleY())/10*1;
    self.bgContent:runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.ScaleTo:create(time,self.bgContent:getScaleX(),1)
        ));
    self.isExtend = true;
    self:setContentSize(cc.size(self.bgWidth,self.bgMaxHeight));
    return time;
end

function NoticeboardItem:hide()
    if not self.isExtend then
        return;
    end
    local time = self.txtContent:getScaleY()/10*1;
    self.bgContent:runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.ScaleTo:create(time,self.bgContent:getScaleX(),0),
        cc.Hide:create()
        ));
    self.isExtend = false;
    self:setContentSize(cc.size(self.bgWidth,self.bgMinHeight));
    return time;
end

function NoticeboardItem:onBg()
    if self.isExtend then
        local time = self:hide();
        return self.txtContent:getContentSize().height + 20,time;
    else
        local time = self:show();
        return -(self.txtContent:getContentSize().height + 20),time;
    end
end

function NoticeboardItem:onTouchEnded(target)

    if target.touchName=="bg" then
        self.click(self.index);
    end
end

return NoticeboardItem