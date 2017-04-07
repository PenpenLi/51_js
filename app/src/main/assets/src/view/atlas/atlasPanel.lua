local AtlasPanel=class("AtlasPanel",UILayer)

function AtlasPanel:ctor(data)
    local mapPath="ui/ui_atlas.map"
    self:init(mapPath)
    Scene.addMapTextureCache(mapPath)
    loadFlaXml("ui_atlas")

    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    self:getNode("scroll").touchBeganCallback=function (touch, event)
        return self:onMoveBegan(touch, event)
    end
    self:getNode("scroll").touchMovedCallback=function (touch, event)
        return self:onMoved(touch, event)
    end

    self:getNode("scroll").touchEndedCallback=function (touch, event)
        self:onMoveEnd(touch, event)
    end
    self:getNode("scroll").scroll:setPopBack(false)
    self:getNode("scroll").container:setRotation3D(cc.vec3(-17,0,0))

    self.curData=data
    Data.wantedItem=0
    self.isMainLayerGoldShow=false
    self:getNode("scroll"):setCheckChildrenVisibleEnable(false);
    self:getNode("btn_crusade"):setVisible(false)
    self:getNode("btn_box"):setVisible(false)

    -- 显示副本翻牌入口
    self.eliteAtlasTab = EliteFlop.sortFlopAtlasTab()
    if table.getn(self.eliteAtlasTab) > 0 then
        self:getNode("btn_flop"):setVisible(true)
    else
        self:getNode("btn_flop"):setVisible(false)
    end
    self:hideCloseModule();
    self:resetLayOut()

end

function AtlasPanel:hideCloseModule()
    if(self:getNode("btn_flop"):isVisible())then
        self:getNode("btn_flop"):setVisible(not Module.isClose(SWITCH_ELITE_FLOP));
    end
end

function AtlasPanel:checkBox()
    self:getNode("btn_box"):setVisible(false)

    local hasBox=false

    for mapid=1, self.maxMapid-1 do
        for i=1, 3 do
            local has=Data.hasAtlasGetBox(mapid,i,self.curDiff)
            if(has==false)then
                local chapter=DB.getChapterById(mapid,self.curDiff) 
                if(chapter)then
                    local curStar=Data.getCurAtlasStar(mapid,self.curDiff)
                    local needNum= chapter["num"..i]
                    if(mapid==self.maxMapid-1)then
                        if(curStar>=needNum)then
                            hasBox=true
                        end
                    else
                        hasBox=true
                    end

                end

            end
        end
    end
    if(hasBox)then
        self:getNode("btn_box"):setVisible(true)
    end

    self:resetLayOut();
end

function AtlasPanel:checkScroll()
    if(Guide.isAtlasScrollPause())then
        self:getNode("scroll"):setTouchEnable(false)
    else
        self:getNode("scroll"):setTouchEnable(true)
    end

end

function AtlasPanel:onPopup()
    print("AtlasPanel:onPopup");
    Unlock.system.eliteAtlas.show();
    Unlock.system.bossAtlas.show();

    self:checkScroll()

    if Unlock.isUnlock(SYS_CRUSADE,false) then
        self:getNode("btn_crusade"):setVisible(true)
        Net.sendCrusadeGetNum()
    end

    self:getNode("boss_panel"):setVisible(false)
    if(self.inited~=true)then
        self.inited=true
        if(self.curData)then
            self:showType(self.curData.type,self.curData.mapid)
        else
            self:showType(0)
        end
    else
        if(self.curData)then
            self:reShowType(self.curData.type,self.curData.mapid)
        else
            self:reShowType(0)
        end
        for key, item in pairs( self:getNode("scroll").items) do
            if(item.inited==true)then
                item:refreshPassOne()
            end
        end
    end
    
    if(self.curData and self.curData.type==7)then
        self:getNode("boss_panel"):setVisible(true)
        self:replaceLabelString("txt_boss_num",gAtlas.bossNum)
    end
    

    self:getNode("btn_task"):setVisible(gNewTaskType==1);
    self:resetLayOut();
end
function AtlasPanel:onPopback()
    Scene.clearLazyFunc("atlasitem")
   
end

function  AtlasPanel:events()
    return {EVENT_ID_ATLAS_BOX_GOT,EVENT_ID_CRUSADE_GET_NUM,EVENT_ID_ATLAS_BOSS_BUY_TIME,EVENT_ID_USER_DATA_UPDATE,
        EVENT_ID_GUIDE_ENTER_SWEEP,
        EVENT_ID_GUIDE_ATLAS_NEXT_ITEM,
        EVENT_ID_GUIDE_EXIT_SWEEP,
        EVENT_ID_ATLAS_SET_MAPID,
    }
end


function AtlasPanel:dealEvent(event,param)
    print(event)
    if(event==EVENT_ID_ATLAS_BOX_GOT)then
        self:onShowStar()
        self:checkBox()

    elseif(event==EVENT_ID_ATLAS_SET_MAPID)then
        self.lastShowIdx=param
        self.curShowIdx=-1
        self:onShowIndx(false)
    elseif(event==EVENT_ID_CRUSADE_GET_NUM)then
        if(param==0)then
            self:setLabelString("txt_cru_num","")
            self:getNode("ui_fire"):setVisible(false)
        else
            self:setLabelString("txt_cru_num",param)
            self:getNode("ui_fire"):setVisible(true)
        end
    elseif(event==EVENT_ID_ATLAS_BOSS_BUY_TIME or event==EVENT_ID_USER_DATA_UPDATE)then
        self:replaceLabelString("txt_boss_num",gAtlas.bossNum)
    elseif(event==EVENT_ID_GUIDE_EXIT_SWEEP)then
        self:showType(0,2);
    elseif(event==EVENT_ID_GUIDE_ENTER_SWEEP)then
        self:showType(0,1);
    elseif(event==EVENT_ID_GUIDE_ATLAS_NEXT_ITEM)then
        self.lastShowIdx=self.curShowIdx+1
        self:onShowIndx(true)
    end
end


function AtlasPanel:reShowType(type,mapid)
 
    local maxMapid,maxStageid,realMapid=Data.getNewAtlasStage(type)


    if type==0 and maxStageid==1 and gAtlas.showCharpterOpen and self.curShowIdx == realMapid - 1 then
        self:passedEffect()
    end

end

function AtlasPanel:showType(type,mapid)

    if(type == 1)then
        Unlock.checkFirstEnter(SYS_ELITE_ATLAS);
    end

    self.curData={}
    self.curData.type=type
    self.curData.mapid=mapid
    self.curDiff=type
    self:getNode("scroll"):clear()
    self:selectBtn("btn_type"..type)
    self.altals={}
    Scene.clearLazyFunc("atlasitem")
    local lastMapid=1
    local maxMapid,maxStageid,realMapid=Data.getNewAtlasStage(type)

    self.maxMapid=maxMapid
    self.mapType=type

    if(mapid~=nil)then
        lastMapid= mapid
    else
        lastMapid=maxMapid
    end


    for i=0, MAX_ATLAS_NUM-1 do
        local item=AtlasItem.new(self,i+1, self.curDiff,realMapid)
        if(i+1==realMapid)then
            item.maxStageid=maxStageid
        end

        if(math.abs(i+1 -lastMapid )==0)then
            item:setData()
        elseif(math.abs(i+1 -lastMapid )<2)then
            item:setLazyData()
        end
        self:getNode("scroll"):addItem(item)
        table.insert(self.altals,i,item)
    end

    self:getNode("left_bar"):playAction("ui_atlas_bg0_type".. self.curDiff)
    self:getNode("icon_bg"):playAction("ui_atlas_bg1_type".. self.curDiff)

    self:getNode("scroll"):layout()


    self.lastShowIdx=lastMapid-1
    self.curShowIdx=lastMapid-1

    local itemWidth=self:getNode("scroll").itemWidth
    local offsetX=self:getNode("scroll").offsetX
    self:getNode("scroll").container:setPositionX(-(offsetX+itemWidth)*self.lastShowIdx )
    --播放引导音乐
    --[[
    if(self.isPlayedTeach~=true)then
    local _mapid,_stageid=Data.getNewAtlasStage(0)
    if(_mapid==1 )then
    if( _stageid==4 )then
    gPlayTeachSound("v27.wav",true);
    self.isPlayedTeach=true

    elseif( _stageid==5) then
    gPlayTeachSound("v23.wav",true);
    self.isPlayedTeach=true
    end
    end

    end
    ]]


    if type==0 and maxStageid==1 and gAtlas.showCharpterOpen and self.curShowIdx == realMapid - 1 then
        self:passedEffect()
    end
 
    self:onTowerUp()
    self:onShowStar()
    self:checkNextBtn(self.lastShowIdx)
    self:checkBox() 
    self:checkCurAtlas()

    if isBanshuUser() then
        self:getNode("btn_type7"):setVisible(false)
    end
end


function  AtlasPanel:checkCurAtlas()
    if( self.altals[self.curShowIdx] and  self.altals[self.curShowIdx].arrow)then 
        self:getNode("btn_cur_atlas"):setVisible(true)   
        self:replaceLabelString("txt_cur_atlas",self.altals[self.curShowIdx].arrow.mapid,self.altals[self.curShowIdx].arrow.stageid)
    else 
        self:getNode("btn_cur_atlas"):setVisible(false) 
    end 
    self:resetLayOut()
end


function  AtlasPanel:onMoveBegan(touch, event)
    self.preLocation = touch:getLocation()
    return true
end

function AtlasPanel:onTowerUp()
    if( self.altals[self.curShowIdx])then
        self.altals[self.curShowIdx]:onTowerUp()
    end
end
function AtlasPanel:onTowerDown()
    if( self.altals[self.curShowIdx])then
        self.altals[self.curShowIdx]:onTowerDown()
    end
end


function AtlasPanel:getGuideItem(name)
    local params= string.split(name,"_")
    local atlasIdx=toint(params[1])-1
    if(self.altals[atlasIdx]  and self.altals[atlasIdx].getNode)then
        return    self.altals[atlasIdx]:getNode("pos"..params[2])
    end

    return nil
end


function  AtlasPanel:onMoved(touch, event)

end

function  AtlasPanel:onMoveEnd(touch, event)
    local endLocation = touch:getLocation()
    local next=false
    if(math.abs( endLocation.x-self.preLocation.x)>150)then

        if(endLocation.x>self.preLocation.x)then
            self.lastShowIdx=self.lastShowIdx-1
        else
            self.lastShowIdx=self.lastShowIdx+1
            next=true
        end
    end

    self:onShowIndx(next)

end


function AtlasPanel:onShowStar()
    local mapid=self.curShowIdx+1

    local totalStarNum=DB.getAtlasStageNum(mapid, 1)*3
    local curStar=Data.getCurAtlasStar(mapid, self.curDiff)

    local per=curStar/totalStarNum
    self:setBarPer("bar",per)


    local chapter=DB.getChapterById(mapid, self.curDiff)
    if(chapter)then
        self:setLabelString("txt_title",chapter.name)
        self:setLabelString("txt_title_num",gParseZnNum(mapid)..".")
        self:resetLayOut()
    else
        return
    end
    for i=1, 3 do
        local has=Data.hasAtlasGetBox(mapid,i,self.curDiff)
        local needNum= chapter["num"..i]
        local curStar=Data.getCurAtlasStar(mapid,self.curDiff)
        if(has)then
            self:getNode("btn_box"..i):playAction("ui_atlas_box_3")
            -- self:setTouchEnable("btn_box"..i,false)
        else
            -- self:setTouchEnable("btn_box"..i,true)
            local chapter=DB.getChapterById(mapid,self.curDiff)
            if(chapter)then
                if(curStar>=needNum)then
                    Unlock.system.atlasBox.checkatlasBoxUnlock(true);
                    self:getNode("btn_box"..i):playAction("ui_atlas_box_2")
                else
                    self:getNode("btn_box"..i):playAction("ui_atlas_box_1")
                end
            end
        end
        self:getNode("btn_box"..i):setPositionX(110+self:getNode("bar").oldWidth*(needNum/totalStarNum))
    end
end

function AtlasPanel:checkNextBtn(idx)
    if( Data.isCurAtlasMapPass(  self.mapType,idx+1)==false and idx>=self.maxMapid-1)then
        self:setTouchEnable("btn_next",false,true)
    else
        self:setTouchEnable("btn_next",true,false)
    end

end

function AtlasPanel:onShowIndx(nextMap)
    --

    local mapMapid=self.maxMapid
    local canEnterNext=Data.canEnterNextAtlasMap(self.mapType,self.lastShowIdx+1,true)
    if( canEnterNext==false)then
        mapMapid=self.maxMapid-1
    end
    local scrollBack = false
    if( self.lastShowIdx>mapMapid)then
        scrollBack = true
        self.lastShowIdx=mapMapid
    end

    if(self.lastShowIdx<0) then
        self.lastShowIdx=0
    end 
    self:resetLayOut()


    if(self.lastShowIdx>= table.getn(self:getNode("scroll").items)) then
        self.lastShowIdx=table.getn(self:getNode("scroll").items)-1
    end
    self:checkNextBtn(self.lastShowIdx)

    self:getNode("scroll").container:stopAllActions()
    local itemWidth=self:getNode("scroll").itemWidth
    local offsetX=self:getNode("scroll").offsetX
    local function  onMoveEnd()
        self:onTowerUp()
        self:onShowStar()

        self:checkCurAtlas()
    end


    local funcAction=cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(onMoveEnd))
    if( self.curShowIdx~=self.lastShowIdx)then
      --  self:onTowerDown()
        self.curShowIdx=self.lastShowIdx
        self.curData.mapid=self.curShowIdx+1
        local moveAction =cc.EaseBackOut:create(cc.MoveTo:create(0.5,cc.p(-(offsetX+itemWidth)*self.lastShowIdx,0)))
        self:getNode("scroll").container:runAction( cc.Spawn:create(moveAction,funcAction))

        for key, item in pairs( self:getNode("scroll").items) do
            if(math.abs(self.lastShowIdx+1 -item.mapid )<2)then
                item:setLazyData()
            end
        end

    else
        local moveAction=cc.EaseBackOut:create(   cc.MoveTo:create(0.5,cc.p(-(offsetX+itemWidth)*self.lastShowIdx,0)))
        self:getNode("scroll").container:runAction(  cc.Spawn:create(moveAction,funcAction))
    end

    if nextMap and self.mapType == 0 and gAtlas.showCharpterOpen and (not scrollBack) and self.lastShowIdx >= mapMapid then
        self:passedEffect()
    end

    -- self:getNode("scroll"):startCheckChildrenVisibleUpdate();
end

function AtlasPanel:resetBtnTexture()

    local btns={
        "btn_type7",
        "btn_type1",
        "btn_type0",
    }
    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian3-1.png")
        self:setTouchEnable( btn,true)
    end

end

function AtlasPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian3.png")
    self:setTouchEnable( name,false)
    local type=string.gsub(name,"btn_type","")
    self:changeTexture("btn_cur_atlas","images/ui_main/bu"..type..".png")
    self:getNode("boss_panel"):setVisible(false)
end


function AtlasPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_cur_atlas" then

        if( self.altals[self.curShowIdx] and  self.altals[self.curShowIdx].arrow)then 
            local arrow=  self.altals[self.curShowIdx].arrow
            Panel.popUp(PANEL_ATLAS_ENTER,{mapid=arrow.mapid,stageid=arrow.stageid,type=arrow.type})
        end
    elseif target.touchName=="btn_pre" then

        self.lastShowIdx=self.curShowIdx-1
        self:onShowIndx(false)
    elseif  target.touchName=="btn_next" then
        self.lastShowIdx=self.curShowIdx+1
        self:onShowIndx(true)
    elseif target.touchName=="btn_type0"then
        self:showType(0)
    elseif target.touchName=="btn_type1"then
        self:showType(1)
    elseif target.touchName=="btn_type7"then
        self:showType(7)
        self:getNode("boss_panel"):setVisible(true)
        self:replaceLabelString("txt_boss_num",gAtlas.bossNum)
    elseif target.touchName=="btn_box1"then
        local param={mapid=self.curShowIdx+1, type=self.curDiff}
        Panel.popUpVisible(PANEL_ATLAS_REWARD_BOX,param,1)
    elseif target.touchName=="btn_box2"then
        local param={mapid=self.curShowIdx+1, type=self.curDiff}
        Panel.popUpVisible(PANEL_ATLAS_REWARD_BOX,param,2)
    elseif target.touchName=="btn_box3"then
        local param={mapid=self.curShowIdx+1, type=self.curDiff}
        Panel.popUpVisible(PANEL_ATLAS_REWARD_BOX,param,3)

    elseif target.touchName=="btn_add_boss_time"then

        local callback = function(num)
            Net.sendBuyBossNum(num)
        end
        Data.canBuyTimes(VIP_ATLAS_BOSS_BUY,true,callback);

    elseif target.touchName=="btn_crusade"then
        Net.sendCrusadeInfo()
    elseif target.touchName=="btn_box"then
        Panel.popUpVisible(PANEL_ATLAS_BOX_NOTICE,self.maxMapid,self.curDiff)
    elseif target.touchName == "btn_task" then
        Panel.popUpVisible(PANEL_NEWTASK);
    elseif target.touchName == "btn_flop" then
        local num = table.getn(self.eliteAtlasTab)
        if num > 0 then
            Panel.popUp(PANEL_ATLAS_ELITE_FLOP_TAB,self.eliteAtlasTab)
        end
    end
end

function AtlasPanel:passedEffect()
    gAtlas.showCharpterOpen = false
    local delay1 = cc.DelayTime:create(0.5)
    local callFunc1 = cc.CallFunc:create(function ()
        loadFlaXml("ui_atlas_complete")
        local node = cc.Node:create()
        local bgSprite = cc.Sprite:create("images/ui_atlas/ui/tongguan/11.png")
        node:addChild(bgSprite, -1)
        local mapid = self.lastShowIdx + 1
        local atlasPassedWords = cc.FileUtils:getInstance():getValueMapFromFile("word/atlasPassedWords.plist")
        local title = ""
        for k,v in pairs(atlasPassedWords) do
            if toint(k) == mapid then
                title = v.title
                break
            end
        end
        local label = gCreateWordLabelTTF(title,gCustomFont,24,cc.c3b(255,205,52),cc.size(bgSprite:getContentSize().width,bgSprite:getContentSize().height * 0.75))
        node:addChild(label)
        local newNext = FlashAni.new()
        newNext:playAction("ui_atlas_new", nil,nil,0)
        newNext:replaceBoneWithNode({"11"},node)
        newNext:setAnchorPoint(cc.p(0.5, 0.5))
        newNext:setPosition(self:getContentSize().width / 2, - self:getContentSize().height / 2)
        self:addChild(newNext, 100)
    end)
    self:runAction(cc.Sequence:create(delay1,callFunc1))
end

return AtlasPanel