Guide={}
Guide.chainStack={}
Guide.curGuideChain=nil
Guide.curStep=nil
Guide.curClickItem=nil
Guide.curDragToItem=nil
Guide.initedStack=false
Guide.ignoreDoubleClick=nil
Guide.hasPlaySkillVoice=false
Guide.touchTime=0
Guide.mainBgScrolPause=false
Guide.atlasScrolPause=false
Guide.cardScrolPause=false
Guide.guideGroup={ 
    group3={3,93},
    group4={16},
    group5={2060},
    group6={2065},
    group7={69,93},
    
    group20={211},
    group21={212},
    group22={213,214,215},
    group23={216},
    group24={217},
    group25={218,93},
    group26={221},

}
function Guide.getCurGuideChain()
    for i=1, table.maxn(Guide.chainStack) do
        if(Guide.chainStack[i])then
            return Guide.chainStack[i]
        end
    end
    return nil
end

function Guide.isMainScrollPause() 
    if(Guide.isGuiding()==false)then
        return false
    end 
    return  Guide.mainBgScrolPause
end

function Guide.isAtlasScrollPause() 
    if(Guide.isGuiding()==false)then
        return false
    end 
    return  Guide.atlasScrolPause
end

function Guide.isCardScrollPause() 
    if(Guide.isGuiding()==false)then
        return false
    end 
    return  Guide.cardScrolPause
end



function Guide.isForceGuiding()

    if(Data.isPassAtlas(1,3,0))then
        return false
    end
 
    return true
end

function Guide.isGuiding()
    if(Guide.curGuideChain)then
        return true
    end
    return false
end

function Guide.canTouchPanel(item)
    if(item.touchLayer==nil)then
        return false
    end

    if(item.touchLayer.ignoreGuide==true)then
        return true
    end

    return false

end

function Guide.canTouch(item)
    if(Guide.isGuiding()  )then
        if( socket.gettime()>Guide.touchTime+0.6)then
        else
            return false
        end
    end
    if(Guide.canTouchPanel(item))then
        return true
    end
    if(Guide.curClickItem~=nil)then
        if(Guide.curClickItem==item)then
            return true
        else
            return false
        end
    end
    return true
end

function  Guide.clearGuide()
    Guide.chainStack={}
    Guide.ignoreDoubleClick=nil
    Guide.initedStack=false
    Guide.lastStep=nil
    Guide.curClickItem=nil
end

function  Guide.isLastStep()
    if(Guide.curGuideChain==nil)then
        return false
    end
    local size=table.getn(Guide.curGuideChain.steps)

    if(Guide.curGuideChain.steps[size]==Guide.curStep)then
        return true
    else
        return false
    end
end

function Guide.beganClickItem(item)
    if(Guide.curClickItem==item and  Guide.isLastStep() and Guide.curStep and Guide.curStep.clickType=="begin" )then
        Guide.stopCurGuideChain()
    end
end

function Guide.clickItem(item,inRect)
    if ( Guide.curStep and Guide.curStep.clickType=="end" )then
        if(inRect==true)then
            if(  Guide.isLastStep())then
                Guide.stopCurGuideChain()
            end
            return true
        else
            return false
        end
    elseif(   Guide.curClickItem==item and  Guide.isLastStep())then
        Guide.stopCurGuideChain(item)
    end
    return true
end

function Guide.sendCurGuideChain()
    for i=1, table.maxn(Guide.chainStack) do
        local var=Guide.chainStack[i]
        if(var)then
            if var.id==GUIDE_ID_ATLAS_SELECT_STAGE3_END then
                gAccount:finishNewGuid()
            end
            if(var.needFlag==true and var.id>gCurGuide )then
                Net.sendCurGuide(var.id)
                return
            end
        end
    end
end

function Guide.stopCurGuideChain(item)

    for i=1, table.maxn(Guide.chainStack) do
        local var=Guide.chainStack[i]
        if(var)then
            if(var.needFlag==true and var.id>gCurGuide )then
                gCurGuide=var.id
                Guide.ignoreDoubleClick=item
                Net.sendCurGuide(var.id)
            end
            Guide.touchTime=socket.gettime()
            Guide.curClickItem=nil
            Guide.chainStack[i]=nil
            return
        end
    end
end

function  Guide.changeStack()
    Guide.tempStack={}
end


function  Guide.isInGuiding(id)
    if(Guide.getCurGuideChain() )then
        if( Guide.curGuideChain.id==id)then
            return true
        end
    end
    return false
end


function  Guide.resetStack()
    for i=1, table.maxn(Guide.chainStack) do
        local var=Guide.chainStack[i]
        if(var)then
            table.insert(Guide.tempStack,var)
        end
    end
    Guide.chainStack=Guide.tempStack
    Guide.tempStack=nil
end



function Guide.dispatch(id,queue)

    local guide=  GuideData.getGuide(id)
    if(guide)then
        if( Guide.tempStack)then
            table.insert(Guide.tempStack,guide)
            return
        end

        if(queue)then
            table.insert(Guide.chainStack,queue,guide)
        else
            table.insert(Guide.chainStack,guide)
        end
    end
end

function Guide.getContentNode(path,parentNode)
    local node = nil;
    local layerParams = string.split(path,":");
    if(layerParams[1] == "scroll") then
        node = parentNode:getNode(layerParams[2]);
    elseif(layerParams[1] == "var") then
        node = parentNode[layerParams[2]];
    elseif(layerParams[1] == "varname") then
        node = parentNode:getNode(layerParams[2]);
    end
    return node;
end

function Guide.parserPath(path,parentNode)
    local clickItem = nil;
    if parentNode == nil then
        return nil;
    end
    local params = string.split(path,"/");
    if string.find(params[1],":") then
        local node = Guide.getContentNode(params[1],parentNode);
        local leftPath = string.sub(path,string.len(params[1])+2);
        -- print("leftPath = "..leftPath);
        return Guide.parserPath(leftPath,node);
    else
        if parentNode.__cname == "ScrollLayer" then
            parentNode:setTouchEnable(false)
            local item = parentNode:getItem(toint(params[1]));
            if item then
                clickItem = item:getNode(params[2]);
            end
        elseif parentNode.__cname == "LayOutLayer" then
            -- print_lua_table(params);
            local item = parentNode:getNode(toint(params[1]));
            if item then
                -- print("aaaa params[2] = "..params[2]);
                clickItem = item:getNode(params[2]);
            end    
        else
            clickItem = parentNode:getNode(params[1]);
        end
    end

    return clickItem;
end

function Guide.getItemByPath(paths)
    if(paths==nil)then
        return nil
    end

    if(paths[1]=="panel")then
        local panel=Panel.getPanelByType( paths[2])
        if(panel)then
            local clickItem = nil;
            if(string.find(paths[3],"/")) then
                clickItem = Guide.parserPath(paths[3],panel);  
            else
                clickItem=  panel:getNode(paths[3])
            end

            if(clickItem==nil and panel.getGuideItem)then
                clickItem=  panel:getGuideItem(paths[3])

            end

            if(clickItem)then
                if(toint(paths[2])==PANEL_ATLAS)then 
                    Guide.atlasScrolPause=true
                    panel:checkScroll()
                elseif(toint(paths[2])==PANEL_CARD)then 
                    Guide.cardScrolPause=true
                    panel:checkScroll()
                end
                return clickItem
            end
        end
    elseif(paths[1]=="main_bg")then
        local panel=gMainBgLayer
        if(panel)then
            local clickItem=  panel:getGuideItem(paths[3])
            if(clickItem)then
                Guide.mainBgScrolPause=true 
                return clickItem
            end
        end
    elseif(paths[1]=="main")then
        local panel=gMainMoneyLayer
        if(panel)then
            local clickItem=  panel:getNode(paths[3])
            if(clickItem)then
                return clickItem
            end
        end

        local panel=gMainLayer
        if(panel)then
            local clickItem=  panel:getNode(paths[3])
            if(clickItem)then
                return clickItem
            end
        end
    elseif(paths[1]=="dragon")then
        local panel=gDragonPanel
        if(panel)then
            panel=panel.dragonUi
            local clickItem=  panel:getNode(paths[3])
            if(clickItem)then
                return clickItem
            end
        end
    elseif(paths[1]=="battle")then
        local panel = battleLayer;
        if panel then
            local ret= panel:getNode(paths[3]);
            if(ret)then
                return ret
            else
                return panel:getGuideItem(paths[3])
            end
        end
    elseif(paths[1]=="guidePanel")then
        if(paths[2] and Panel.getPanelByType( paths[2])==nil)then
            return nil
        end
        Guide.showGuide()
        if gGuidePanel then
            local ret= gGuidePanel:getNode(paths[3]);
            return ret
        end
    end


    return nil


end


function Guide.isParentIsVisible(  node)
    if(node)then
        local parent =node:getParent()
        if(parent and node:isVisible()) then
            return Guide.isParentIsVisible(parent)

        else
            return node:isVisible()
        end
    end


    return false
end

function Guide.passErrorGuide()

    if( Guide.curGuideChain==nil)then
        return
    end

    if(Guide.curGuideChain.id==GUIDE_ID_EQUIP_UPQUALITY_2)then
        local card=Data.getUserCardById(10103)
        if(card==nil)then
            Guide.stopCurGuideChain()
            return
        end


        if(CardPro.isEquipItemAllActivate(card.equipActives[0])==false)then
            Guide.stopCurGuideChain()
            return
        end

        if(card.equipQuas[0]~=0)then
            Guide.stopCurGuideChain()
            return
        end

    elseif(Guide.curGuideChain.id==GUIDE_ID_EQUIP_ITEM_2)then
        local card=Data.getUserCardById(10103)
        if(card==nil)then
            Guide.stopCurGuideChain()
            return
        end


        if(CardPro.isEquipItemAllActivate(card.equipActives[0])==true)then
            Guide.stopCurGuideChain()
            return
        end

    elseif(Guide.curGuideChain.id==GUIDE_ID_RECURIT_1)then
        local card=Data.getUserCardById(10027)
        if(card~=nil)then
            Guide.stopCurGuideChain()
            return
        end

    end

end

function Guide.updateGame()
    Guide.curGuideChain=Guide.getCurGuideChain()
    Guide.curStep=nil
    Guide.mainBgScrolPause=false 
    Guide.atlasScrolPause=false
    Guide.cardScrolPause=false
    Guide.curClickItem=nil
    Guide.curDragToItem=nil
    if(  Guide.pause==true)then
        Guide.hideGuide()
        return
    end

    if( Guide.curGuideChain~=nil)then
        local maxStep= table.getn( Guide.curGuideChain.steps)
        for i=1,maxStep do
            local step= Guide.curGuideChain.steps[maxStep-i+1]
            if(step~=nil)then
                if(step.paths~=nil)then
                    Guide.curClickItem= Guide.getItemByPath(step.paths)
                    if( Guide.isParentIsVisible(Guide.curClickItem)==false)then
                        Guide.curClickItem=nil
                    end

                    if(Guide.curClickItem)then
                        Guide.curDragToItem= Guide.getItemByPath(step.dragTarget)
                        Guide.curStep=step
                        Guide.curClickItem.storyid=step.storyid
                        Guide.curClickItem.storyPos=step.storyPos
                        Guide.curClickItem.hideArrow=step.hideArrow
                        Guide.curClickItem.storyOffsetX=step.storyOffsetX
                        Guide.curClickItem.storyOffsetY=step.storyOffsetY
                        
                        break
                    end
                else
                    Guide.curStep=step
                end
            end
        end
    end

    if(gStoryLayer and gStoryLayer:getChildrenCount()~=0)then
    --  Guide.curStep=nil
    --  Guide.curClickItem=nil
    end
    

    if(Guide.curStep and Guide.curStep.paths )then
        Guide.showGuide()
        if(  Guide.curStep.hideBlackBg==1)then
            gGuidePanel:getNode("black_bg"):setVisible(false)
        else
            gGuidePanel:getNode("black_bg"):setVisible(true)
        end
        gGuidePanel:update()

        if(Guide.hasClick==true)then
            Guide.hasClick=false
            if( Guide.clickRight~=true)then
                Guide.noticeClick()
            end
        end
        Guide.clickRight=false
    else
        Guide.hideGuide()
    end
    
    if(Guide.curClickItem and  Guide.curClickItem.hideArrow)then
        Guide.hideGuide()
    end


    if(Guide.lastStep~=Guide.curStep)then

        if(Guide.curStep and Guide.curStep.effect)then
            gPlayTeachSound(Guide.curStep.effect,true);
        end

        if(Guide.lastStep and Guide.lastStep.exitEvent)then
            print("exit event "..Guide.lastStep.exitEvent)
            gDispatchEvt(Guide.lastStep.exitEvent,Guide.lastStep.param)
        end

        if(Guide.curStep and Guide.curStep.enterEvent )then
            print("enter event "..Guide.curStep.enterEvent)
            gDispatchEvt(Guide.curStep.enterEvent,Guide.curStep.param)
        end
        Guide.lastStep=Guide.curStep
    end
    Guide.hasClick=false
    Guide.passErrorGuide()

    
end



function Guide.showGuide()
    gGuideLayer:setVisible(true)
    if(gGuideLayer:getChildrenCount()~=0)then
        return
    end

    gGuideLayer:removeAllChildren()
    gGuidePanel=GuideLayer.new()
    gGuideLayer:addChild(gGuidePanel)
end

function Guide.events()
    return {
        EVENT_ID_GUIDE_SHOW_STORY,
        EVENT_ID_GUIDE_SET_NAME,
        EVENT_ID_GUIDE_ENTER_ATLAS,
        EVENT_ID_GUIDE_SHOW_MAINLAYER_MENU,
        EVENT_ID_GUIDE_FINISH_SKILL_UPGRADE,
        EVENT_ID_GUIDE_SHOW_SMALL_STORY,
        EVENT_ID_GUIDE_SHOW_HAND,
        EVENT_ID_GUIDE_HIDE_HAND,
    }
end

function Guide.dealEvent(event,param)
    if(event==EVENT_ID_GUIDE_SHOW_STORY)then
        local storyCallback=function()
            Guide.stopCurGuideChain()
        end
        Story.showStory(param,storyCallback)
    elseif(event==EVENT_ID_GUIDE_SET_NAME)then
        local panel= Panel.popUp(PANEL_SET_NAME)
        if(panel)then
            panel.closeCallback= function()
                Guide.initChainStackByPhaseID()
                if (gOnAdCreateRole) then
                    gOnAdCreateRole(gUserInfo.name)
                end
            end
        end
    elseif(event==EVENT_ID_GUIDE_ENTER_ATLAS)then

    elseif(event == EVENT_ID_GUIDE_SHOW_MAINLAYER_MENU) then
        gMainMoneyLayer:downBtns();
    elseif(event == EVENT_ID_GUIDE_FINISH_SKILL_UPGRADE) then
        gPlayTeachSound("v18.wav",true);
    elseif(event == EVENT_ID_GUIDE_SHOW_HAND) then
        Guide.showHand()
    elseif(event==EVENT_ID_GUIDE_SHOW_SMALL_STORY)then
        Guide.hideHand()
    end


end

function Guide.hideHand(circle)
    if(gGuidePanel)then
        gGuidePanel:hideHand(circle)
    end
end
function Guide.showHand()
    if(gGuidePanel)then
        gGuidePanel:showHand()
    end
end

function Guide.noticeClick()
    if(gGuidePanel)then
        gGuidePanel:noticeClick()
    end
end


function Guide.hideGuide()
    if(gGuideLayer)then
        gGuideLayer:setVisible(false)
    end
end

function Guide.initGuideData()
    GuideData.initGuideData()
end


function Guide.initArena()

    Guide.dispatch(GUIDE_ID_ENTER_ARENA)
    Guide.dispatch(GUIDE_ID_ENTER_ARENA1)
    Guide.dispatch(GUIDE_ID_ENTER_ARENA2)
end

function Guide.initPet()

    Guide.dispatch(GUIDE_ID_ENTER_PET)
    Guide.dispatch(GUIDE_ID_ENTER_PET1)
end


function Guide.initChainStackByPhaseID()
    --

    --领取礼包就完成引导
    if(Guide.isForceGuiding()==false)then
        return
    end

    if(Guide.initedStack==true)then
        return
    end
    -- Unlock.showUnlockPanel(SYS_SKILL)
    Guide.initedStack=true
    GuideStepData.firstAtlas.guide()
    GuideStepData.draw.guide()
    GuideStepData.secondAtlas.guide()
    GuideStepData.equip.guide()
    GuideStepData.thirdAtlas.guide()
   --[[ 
    GuideStepData.recurit.guide() 
    GuideStepData.upgradeCard.guide()
    GuideStepData.onlineGift.guide()
    ]]

    --   Unlock.system.upgradeCard.guide()


end
 
