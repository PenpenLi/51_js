local NoticeLayer=class("NoticeLayer",UILayer)

function NoticeLayer:ctor()
    self:init("ui/ui_notice.map") 


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)
 
    self.updateDirty = false;
    self.noticeStack={}
    --self:getNode("bg").__notice=true
    self.targetPosY= self:getNode("bg"):getPositionY()
    local function _update()
        self:update()
    end 

    self:getNode("bg"):setCascadeOpacityEnabled(true)
    self.bgWidth = self:getNode("bg"):getContentSize().width;

    self:scheduleUpdateWithPriorityLua(_update,1)
    self:setVisible(false);
end

 
function NoticeLayer:showNotice(txt)
    if(string.len( txt)==0)then
        return
    end
    table.insert( self.noticeStack,txt)
    self.updateDirty = true;
end


function NoticeLayer:update()

    if(self.updateDirty == false)then
        return;
    end
    
    if(table.getn( self.noticeStack)==0)then
        return
    end
    
    if(self.isShowing)then
        return
    end
    
    -- print("NoticeLayer:update");

    local inTime=0.2
    local outTime=0.1
    local delayTime=0.4
    if(table.getn( self.noticeStack)>1)then 
        outTime=0
        inTime=inTime/2
        delayTime=delayTime/4
    end
    
    self.isShowing=true
    local txt=  self.noticeStack[1]
    table.remove(self.noticeStack,1)
    local wordWith = 0;
    local labShow = nil;
    if string.find(txt,"\\") then
        self:getNode("txt_info"):setVisible(false);
        self:getNode("rtf_info"):setVisible(true);
        self:setRTFString("rtf_info",txt);
        labShow = self:getNode("rtf_info");
        wordWith = self:getNode("rtf_info"):getContentSize().width;
    else
        self:getNode("txt_info"):setVisible(true);
        self:getNode("rtf_info"):setVisible(false);
        self:setLabelString("txt_info",txt);
        labShow = self:getNode("txt_info");
        wordWith = self:getNode("txt_info"):getContentSize().width;
    end

    -- self:getNode("txt_info"):setString(txt) 
    self:getNode("bg"):setCascadeOpacityEnabled(true)
    self:getNode("bg"):setOpacity(0);
    -- cc.Director:getInstance():getScheduler():setTimeScale(0.1)
    self:setVisible(true)
    local function onOut()
        self.isShowing=false
        self:setVisible(false)
    end
    
    self:getNode("bg"):setPositionY(self.targetPosY-60)
    local posX= self:getNode("bg"):getPositionX()
    
    local faceIn=cc.FadeIn:create(inTime)
    local inAction=cc.Spawn:create(faceIn, cc.EaseOut:create(   cc.MoveTo:create(inTime*2,cc.p(posX,self.targetPosY)),1))
    local delay=cc.DelayTime:create(delayTime*2)
    local faceOut=cc.FadeOut:create(outTime)
    local outAction=cc.Spawn:create(faceOut, cc.EaseOut:create(   cc.MoveTo:create(outTime*2,cc.p(posX,self.targetPosY+60)),1))
    self:getNode("bg"):runAction(cc.Sequence:create(inAction,delay,outAction, cc.CallFunc:create(onOut)))
    
    -- local size=self:getNode("txt_info"):getContentSize()
    local bgWidth = self.bgWidth;
    if wordWith > bgWidth then
        bgWidth = wordWith + 100;
    end

    local height=self:getNode("bg"):getContentSize().height
    self:getNode("bg"):setContentSize(cc.size(bgWidth,height)) 
    labShow:setPositionX(bgWidth/2);

    if(table.getn( self.noticeStack)==0)then
        self.updateDirty = false;
    end
end

return NoticeLayer