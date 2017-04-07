local ActivityRecruitSharePanel=class("ActivityRecruitSharePanel",UILayer)

function ActivityRecruitSharePanel:ctor(data)
    -- self.appearType = 1;
    self._panelTop = true;
    -- self.isWindow = true;
    -- self:init("ui/ui_hd_zhaomu_share.map") 
    self:init("ui/share/ui_share_zhaomu.map") 
    self.curData=data

    if (gAccount:getPlatformId() == CHANNEL_ANDROID_TENCENT) then
        self:changeTexture("ma_bg","images/ui_share/yyb_download.png")
    else
        self:changeTexture("ma_bg","images/ui_share/web_download.png")
    end

    local sName = "S"..math.mod(gAccount:getCurRole().serverid,1000).."-"..gAccount:getCurServer().name
    local name = Data.getCurName()
    local code = Data.activityRecruitData.uid
    -- local word = gGetWords("activityNameWords.plist","132",sName,name,code)
    -- self.content = gGetWords("activityNameWords.plist","133",sName,name,code)
    -- self:setRTFString("lab_content",word)

    self:setLabelString("txt_uname",name)
    self:setLabelString("txt_server",sName)
    self:setLabelString("txt_code",code)

    self:getNode("lab_no_share"):setVisible(false)
    if(self:getNode("btn_share"))then
        self:getNode("btn_share"):setVisible(false)
    end
    if (not Module.isClose(SWITCH_SHARE)) then
        if(self:getNode("btn_share"))then
            self:getNode("btn_share"):setVisible(true)
        end
    else
        self:getNode("lab_no_share"):setVisible(true)
    end

    if(self:getNode("layout_share"))then
        self:getNode("layout_share"):setVisible(not Module.isClose(SWITCH_SHARE));
    end
    if(self:getNode("share2"))then
        self:getNode("share2"):setVisible(not Module.isClose(SWITCH_SHARE_TWITTER));
    end
    if(self:getNode("share3"))then
        self:getNode("share3"):setVisible(not Module.isClose(SWITCH_SHARE_LINE));
    end

    self:resetLayOut();

    -- local function onNodeEvent(event)
    --     if event == "enter" then
    --         self:onEnter();
    --     end
    -- end
    -- self:registerScriptHandler(onNodeEvent);

    local node = self:getNode("content");
    local pos = cc.p(node:getPosition());
    local anchor = cc.p(node:getAnchorPoint());
    local show = function()
        print("xxxxx");
        self:setVisible(true);
        node:setScale(1.0);
        node:setPosition(pos);
        node:setAnchorPoint(anchor);
        node:setOpacity(0);
    end
    self:setVisible(false);
    gScreenShotNode(self:getNode("content"),false);
    gCallFuncDelay(0.1,self,show);

end

function ActivityRecruitSharePanel:onTouchEnded(target)
    if target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_share")then
        gShare(23);
        -- gShareText(23,self.content.."www.luandoutang.com")
    elseif target.touchName=="share1" then
        local data={}
        data.sharePlatform = "sharePlatform1"
        data.desc = gGetWords("shareWords.plist","recruitShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share2" then
        local data={}
        data.sharePlatform = "sharePlatform2"
        data.desc = gGetWords("shareWords.plist","recruitShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share3" then
        local data={}
        data.sharePlatform = "sharePlatform3"
        data.desc = gGetWords("shareWords.plist","recruitShareDesc");
        gShare(self.shareType,data);
    end
end

function ActivityRecruitSharePanel:dealEvent(event,param)
    -- print("event="..event)
    -- if(event==EVENT_ID_GET_ACTIVITY_RECRUIT_INFO)then
    --     self:setData()
    -- end
end   

return ActivityRecruitSharePanel