local StoryLayer=class("StoryLayer",UILayer)

function StoryLayer:ctor(type)
    self:init("ui/ui_story.map")

    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self:getNode("bg").__story=true
    self.oldBgPosY= self:getNode("bg_container"):getPositionY()
    self:getNode("bg"):setContentSize(cc.size(winSize.width ,self:getNode("bg"):getContentSize().height))
    self:getNode("txt_info"):setDimensions( winSize.width-200,0)
    self:getNode("bg_container"):setPositionY(self.oldBgPosY  -200)
    self:getNode("pos1").initX=self:getNode("pos1"):getPositionX()
    self:getNode("pos2").initX=self:getNode("pos2"):getPositionX()
end

function StoryLayer:setStory(id,callback)
    self.callback=callback
    self.curStory=Story.getStory(id)
    self:showTalk(1)
end

function StoryLayer.getMyName()
    if(gUserInfo.name==nil or string.len(gUserInfo.name)==0)then
        return "神秘少年"
    end
    return gUserInfo.name
end

function StoryLayer:onEnd()
    if(self.callback)then
        self.callback()
        self.callback=nil
    end
    self:getNode("bg_container"):setPositionY(self.oldBgPosY  -200)
    Story.finish()
end

function StoryLayer:showTalk(idx)
    self.curTalkIdx=idx
    if(self.curStory==nil)then
        self:onEnd()
    end
    local talk= self.curStory.talks[self.curTalkIdx]

    if(talk==nil)then
        self:onEnd()
        return
    end

    if talk.dialogsound then
        gPlayTeachSound(talk.dialogsound,true);
    end

    local talkWords=Story.getStoryWord(talk.dialogkey)
    self:setLabelString("txt_info",talkWords)

    local cardid=toint(talk.headid)%100000
    local wakeLv=math.floor(toint(talk.headid)/100000)
    local card=DB.getCardById(cardid)

    self:getNode("left_bg"):setVisible(false)
    self:getNode("right_bg"):setVisible(false)
    self:getNode("name_left"):setVisible(false)
    self:getNode("name_right"):setVisible(false)

    local result= loadFlaXml("r"..cardid,wakeLv)

    self:getNode("bg_container"):stopAllActions()
    local posx=self:getNode("bg_container"):getPositionX()
    self:getNode("bg_container"):runAction(cc.EaseOut:create( cc.MoveTo:create(0.2, cc.p(posx,self.oldBgPosY) ),2))

    local roleScale=2
    local isMyRole=false
    if(toint(talk.headid)==1)then
        isMyRole=true
        roleScale=1.2
    end

    self:getNode("pos1"):stopAllActions()
    self:getNode("pos2"):stopAllActions()

    local flaName=""
    if(isMyRole)then
        loadFlaXml("my_role")
        flaName="my_role_1"
    else
        flaName="r"..cardid.."_wait"
    end


    if(result or isMyRole)then
        local scaleX=nil
        local posX=0
        local curPosNode=nil
        local otherPosNode=nil
        if(toint(talk.headside)==1)then
            curPosNode=self:getNode("pos2")
            otherPosNode=self:getNode("pos1") 
            
            self:getNode("right_bg"):setVisible(true)
            self:getNode("name_right"):setVisible(true)
            scaleX=-roleScale
            posX=200
            otherPosNode:runAction(cc.MoveTo:create(0.2,cc.p(otherPosNode.initX-60,otherPosNode:getPositionY())))
        else
            curPosNode=self:getNode("pos1")
            otherPosNode=self:getNode("pos2")
             
            self:getNode("left_bg"):setVisible(true)
            self:getNode("name_left"):setVisible(true)
            scaleX=roleScale
            posX=-200 
            otherPosNode:runAction(cc.MoveTo:create(0.2,cc.p(otherPosNode.initX+60,otherPosNode:getPositionY())))
        end
        
        otherPosNode:runAction(cc.ScaleTo:create(0.2,0.8))
        
        if(curPosNode.flaName==flaName)then
            curPosNode:runAction(cc.ScaleTo:create(0.2,1)) 
            curPosNode:runAction(cc.MoveTo:create(0.2,cc.p(curPosNode.initX,otherPosNode:getPositionY())))
            
        else 
            fla=FlashAni.new()
            fla:setSkinId(wakeLv)
            fla:playAction(flaName) 
            fla:setPositionX(posX)
            fla:setScaleX(scaleX)
            fla:setScaleY(roleScale)
            
            curPosNode.flaName=flaName
            curPosNode:setScale(1)
            curPosNode:removeAllChildren()
            curPosNode:addChild(fla)
            curPosNode:setPositionX(curPosNode.initX)
            fla:runAction(cc.EaseBackOut:create( cc.MoveTo:create(0.4, cc.p(0,0 ))))
        end
        
        

        if(isMyRole)then 
            self:setLabelString("txt_name",StoryLayer.getMyName())
            self:setLabelString("txt_name2",StoryLayer.getMyName())
        else
            self:setLabelString("txt_name",card.name)
            self:setLabelString("txt_name2",card.name)
        end
    end

end


function StoryLayer:onTouchEnded(target)
   
    if( Guide.curGuideChain~=nil and Guide.curGuideChain.id==GUIDE_ID_EQUIP_UPQUALITY_1)then
        if(Net.hasRecEquipActivateOneKey~=true )then 
            return
        end
    end
    if( self.curTalkIdx >=table.getn(self.curStory.talks))then
        self:onEnd()
    else
        self:showTalk( self.curTalkIdx+1)


    end
end

return StoryLayer