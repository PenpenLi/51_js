local GuideLayer=class("GuideLayer",UILayer)

function GuideLayer:ctor(type)
    self:init("ui/ui_guide.map")


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)


    self:getNode("mask_black_bg_clip"):setInverted(true)

    self:getNode("icon_circle"):setVisible(false)
    self:getNode("mask_black_bg"):setVisible(false)
    self:getNode("mask_black_bg"):setScale(15)
    self:getNode("txt_words").initX=self:getNode("txt_words"):getPositionX()
    self:getNode("txt_words").initY=self:getNode("txt_words"):getPositionY()
    
    self:getNode("bg_scale9").initHeight=self:getNode("bg_scale9"):getContentSize().height
    self:getNode("bg_scale9").initWidth=self:getNode("bg_scale9"):getContentSize().width
    
end
function GuideLayer:hideHand(circle)
    if(circle)then
        self:getNode("icon_circle"):playAction("ui_guide_circle2")
    else 
        self:getNode("icon_circle"):setOpacity(0)
    end 
    
end
 

function GuideLayer:showHand()
    self:getNode("icon_circle"):playAction("ui_guide_circle")
    self:getNode("icon_circle"):setOpacity(255)
end

function GuideLayer:noticeClick()
    self:getNode("mask_black_bg"):stopAllActions()
    local function actionEnd()
        self:getNode("mask_black_bg"):setScale(15)
    end
    self:getNode("mask_black_bg"):runAction( cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.7,1),2), cc.CallFunc:create(actionEnd)) )

end

function GuideLayer:getStoryPosSide(pos)
    if(pos==nil)then
        return nil
    end
    if(pos==1 or pos==4 or pos==7)then
        return -1
    end

    if(pos==2 or pos==5 or pos==8)then
        return 0
    end
     
    if(pos==3 or pos==6 or pos==9)then
        return 1
    end
end

function GuideLayer:update()
    if(Guide.curClickItem==nil)then
        return
    end

    local targetPos= nil
    if(Guide.curClickItem.__convertToWorldPos)then
        targetPos=Guide.curClickItem.__convertToWorldPos(Guide.curClickItem)
    else
        targetPos= Guide.curClickItem:convertToWorldSpaceAR(cc.p(0,0))
    end

    local pos= self:convertToNodeSpace(targetPos)

    local winSize=cc.Director:getInstance():getWinSize()
    local anchor= Guide.curClickItem:getAnchorPoint()
    local size=nil
    if Guide.curClickItem.__getContentSize then
        size = Guide.curClickItem:__getContentSize()
    else
        size = Guide.curClickItem:getContentSize()
    end

    if(Guide.curClickItem.aabb_min==nil)then--不是3d
        pos.x=pos.x-size.width*(anchor.x-0.5)
        pos.y=pos.y+size.height*(0.5-anchor.y)
    end

    self:getNode("icon_circle"):setPosition(pos)
    self:getNode("mask_black_bg"):setPosition(pos)
    self:getNode("icon_circle"):setVisible(true)
    self:getNode("mask_black_bg"):setVisible(true)
    if(Guide.curClickItem.storyid)then
        self:getNode("story_panel"):setVisible(true)
        local storyX=0
        local storyY=0
        self:getNode("head_icon_left"):setVisible(false)
        self:getNode("head_icon_right"):setVisible(false)
        local offsetX=0
        local offsetY=0
        if(Guide.curClickItem.storyOffsetX)then
            offsetX=Guide.curClickItem.storyOffsetX
        end
        if(Guide.curClickItem.storyOffsetY)then
            offsetY=Guide.curClickItem.storyOffsetY
        end
        local storySide=self:getStoryPosSide(Guide.curClickItem.storyPos)
        local curSide=0
        if(targetPos.x>winSize.width/2)then
            curSide=-1
        else
            curSide=1
        end
        
        if(storySide)then
            curSide=storySide
        end
        
        if(curSide<0)then
            self:getNode("head_icon_left"):setVisible(true) 
        else
            self:getNode("head_icon_right"):setVisible(true)
        end

        storyX=pos.x+300*curSide

        if(targetPos.y<150)then
            storyY=pos.y+80
        elseif(targetPos.y>winSize.height-250) then
            storyY=pos.y-220
        else
            storyY=pos.y 
        end
        
        
        self:getNode("story_panel"):setPosition(cc.p(storyX+offsetX,storyY+offsetY))
    else
        self:getNode("story_panel"):setVisible(false)
    end
    if(self:getNode("head_icon_right"):isVisible())then
        self:getNode("txt_words"):setPositionX(self:getNode("txt_words").initX-60)
    else
        self:getNode("txt_words"):setPositionX(self:getNode("txt_words").initX)
    end


    if(self.lastClickItemStoryId~=Guide.curClickItem.storyid)then
        self.lastClickItemStoryId=Guide.curClickItem.storyid
        if(Guide.curClickItem.storyid)then
            local story=  Story.getStory(Guide.curClickItem.storyid)
            if(story and story.talks[1] )then
                if story.talks[1].dialogsound then
                    gPlayTeachSound(story.talks[1].dialogsound,true);
                end
                self:setLabelString( "txt_words",Story.getStoryWord(story.talks[1] .dialogkey))


            end
        end
    end
    local minHeight = 69;
    local height = self:getNode("txt_words"):getContentSize().height;
    if height > minHeight then
        local extendH = height - minHeight;
        local size = cc.size( self:getNode("bg_scale9").initWidth,self:getNode("bg_scale9").initHeight+extendH) 
        self:getNode("bg_scale9"):setContentSize(size);
        self:getNode("txt_words"):setPositionY(self:getNode("txt_words").initY-extendH/2)
    else

        self:getNode("txt_words"):setPositionY(self:getNode("txt_words").initY)
        self:getNode("bg_scale9"):setContentSize(cc.size( self:getNode("bg_scale9").initWidth,self:getNode("bg_scale9").initHeight))
    
    end
end

function GuideLayer:onTouchEnded(target)
    print(target.touchName)
end

return GuideLayer