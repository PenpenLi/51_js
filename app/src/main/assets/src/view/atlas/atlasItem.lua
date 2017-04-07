local AtlasItem=class("AtlasItem",UILayer)

local TAG_TOWER=1
local TAG_FLASH=2
local TAG_SHADOW=3
local TAG_PASS=4

function AtlasItem:getUiMapName(mapid)
    return self.uiMapTable[mapid]
end

function AtlasItem:ctor(atlasPanel,mapid,type,realMapid)
    self.atlasPanel=atlasPanel
    self.type=type
    self.mapid=mapid
    self.realMaxMapid=realMapid

end


function AtlasItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    
    if(self.type==7)then
        self:init("ui/ui_atlas_item_7_"..self.mapid..".map")
    else
        self:init("ui/ui_atlas_item"..self.mapid..".map")

    end

end

function AtlasItem:setStageid(stageid)
    local maxStageNum=30
    for j=1, maxStageNum do
        local i=maxStageNum-j
        local node=self:getNode("pos"..i)
        if(node~=nil)then
            if(node.stagePos==stageid)then
                local parent=node
                if(parent.bill)then
                    parent=parent.bill
                end
                self.arrow=cc.BillBoard:create()
                self.arrow:setMode(1)
                local arrawFlash=FlashAni.new()
                parent:addChild(self.arrow)
                arrawFlash:setPositionX(node:getContentSize().width/2)
                if(node.bill==nil)then
                    arrawFlash:setPositionY(-50)
                end 
                self.arrow.mapid=self.mapid
                self.arrow.type=self.type
                self.arrow.stageid=stageid
                arrawFlash:playAction("ui_atlas_arrow")
                self.arrow:addChild(arrawFlash)
                return
            end
        end
    end

end

function AtlasItem:setLazyData()
    if(self.inited==true)then
        return
    end
    Scene.addLazyFunc(self,self.setData,"atlasitem")
end

function AtlasItem:setData()
    self:initPanel()
    self.towers={}
    self.status={}
    self.uiMapTable=ATLAS_ID_MAP

    local size=cc.Director:getInstance():getWinSize()
    local zeye = cc.Director:getInstance():getZEye()
    local curType=self.type
    if(self.type==1)then
        curType=0
    end
    local stages=DB.getStagesByMapId(self.mapid,curType)


    local function  onCheckInsde(touch,event)
        local target=  event:getCurrentTarget()
        return gCheck3DInsde(touch,target)
    end

    local uiMapid=self:getUiMapName(self.mapid)
    local uiMapName="0"..uiMapid
    if(toint(uiMapid)>=10)then
        uiMapName=uiMapid
    end

    loadFlaXml("ui_atlas_"..uiMapName)
    local bigStageIdx=1
    self:getNode("bg"):playAction("ui_atlas_map"..uiMapid.."_type".. self.type)
    for i, stage in pairs(stages) do
        if(self:getNode("pos"..i)==nil)then
            break
        end


        self:getNode("pos"..i):setLocalZOrder(3000-self:getNode("pos"..i):getPositionY())

        self:getNode("pos"..i).__isTouchInside=onCheckInsde
        self:getNode("pos"..i).__convertToWorldPos=gConvertTo3DWorldPos
        if( self.type==1)then
            self:getNode("pos"..i).stagePos=bigStageIdx
        else
            self:getNode("pos"..i).stagePos=i
        end



        if(stage.node~=0)then
            self:getNode("pos"..i):setCameraMask(cc.CameraFlag.USER8)
            local bill=cc.BillBoard:create()
            self:getNode("pos"..i):addChild(bill)
            self:getNode("pos"..i).bill=bill
            bill.posName= "pos"..i
            bill.stageid=self:getNode("pos"..i).stagePos
            table.insert(self.towers,i,bill)
            bill:setMode(1)

            local spriteSize=self:getNode("pos"..i):getContentSize()
            --魔王副本设置洞
            if(self.type==ATLAS_TYPE_BOSS  and stage.islast==2)then
                local fla=gCreateFla("ui_atlas_monster_wait",1)
                fla:setPositionX(spriteSize.width/2)
                fla:setPositionY(spriteSize.height/2)
                bill:addChild(fla)
                fla:setTag(TAG_TOWER) 
            else
                local sprite=cc.Sprite:create(self:getNode("pos"..i).imagePath)
                if(sprite)then
                    sprite:setAnchorPoint(cc.p(0.5,0))
                    spriteSize=sprite:getContentSize()
                    sprite:setPositionX(spriteSize.width/2)
                    bill:addChild(sprite)
                    sprite:setTag(TAG_TOWER) 
                end

            end
           

            local status= AtlasStatus.new()
            status:setPositionY(status.mapH)
            status:setPositionX(-status.mapW/2+spriteSize.width/2)
            bill:addChild(status,2) 
            bill.spriteSize=spriteSize
            bill.status=status
            table.insert(self.status,i,status)

            self:initStatus(bill,status,stage,i)

            if(bill.isBossStage)then
                bill:setRotation3D(cc.vec3(0,0,0))
            else
                bill:setRotation3D(cc.vec3(-60,0,0))
            end

            local actionName="ui_atlas_"..uiMapName.."_0"..bigStageIdx
            local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(actionName)
            if(animationData )then
                local fla=FlashAni.new()
                fla:setTag(TAG_FLASH)
                fla.actionName=actionName
                fla:playAction(fla.actionName,nil,nil,0)
                bill:addChild(fla)
                fla:setPositionX(spriteSize.width/2)
                fla:setPositionY(spriteSize.height/2)
                fla:setVisible(false)
            end
            bigStageIdx=bigStageIdx+1
        else
            if( self.type==1)then  --精英副本
                self:getNode("pos"..i):setVisible(false)
            else
                local ret=Data.getAtlasStatus(self.mapid,i+1,self.type)
                if(ret~=false)then
                    self:getNode("pos"..i):setVisible(false)
                end
            end
        end

        if(self.type == 0)then
            local pass = Data.isPassAtlas(self.mapid,i,self.type);
            if(not pass)then
                self:showUnlockTip(self.mapid,i);
            end
        end  
    end
    self:refreshPassOne()

    if(self.isItemUp)then
        self.isItemUp=false
        self:onTowerUp()
    else

        self:onTowerDown()
    end

    if(self.maxStageid)then
        self:setStageid(self.maxStageid)
    end
end

function AtlasItem:showUnlockTip(mapid,stageid)

    local unlockData = nil;
    for key,teach in pairs(teach_db) do
        if(toint(teach.mapid) == mapid and toint(teach.stageid) == stageid)then
            unlockData = teach;
            break;
        end
    end
    -- or toint(unlockData.teachid) <= 10
    if(unlockData == nil or toint(unlockData.teachid) <= 10)then
        return;
    end

    local name = Unlock.getUnlockName(unlockData.teachid);
    if(name == "")then
        return;
    end

    local layer = UILayer.new()
    layer:init("ui/ui_atlas_unlocktip.map");
    local oldSize = layer:getNode("bg"):getContentSize();
    -- layer:setRTFString("txt_tip",mapid.."-"..stageid);
    layer:replaceRtfString("txt_tip",name);
    local size = layer:getNode("txt_tip"):getContentSize();
    layer:getNode("bg"):setContentSize(cc.size(size.width+30,size.height));
     
    local node = self:getNode("pos"..stageid);
    if(self:getNode("pos"..stageid).bill and self:getNode("pos"..stageid).bill.spriteSize)then
        self:getNode("pos"..stageid).bill:addChild(layer,3);
        local spriteSize=self:getNode("pos"..stageid).bill.spriteSize 
        layer:setPositionX(spriteSize.width/2-oldSize.width/2)
        layer:setPositionY(-10) 
    end
    
--[[
    layer:setAnchorPoint(cc.p(0.5,-0.5));
    layer:ignoreAnchorPointForPosition(false);
    layer:setPosition(cc.pAdd( cc.p(node:getPosition()),gGetNodePositionByAnchorPoint(node,cc.p(0,-0.8)) ));
    self:getNode("pos"..stageid):getParent():addChild(layer); 
    ]]
end


function AtlasItem:onTowerUp()
    
    if(self.isItemUp==true)then
        return
    end
    self.isItemUp=true
    
    if(self.towers==nil)then
        return
    end
    local function opTowerUped()
        for key, tower in pairs(self.towers) do
            if(self.status[key])then
                self.status[key]:setVisible(true)
            end
            local node=tower:getChildByTag(TAG_FLASH)
            local ret=Data.getAtlasStatus(self.mapid,tower.stageid,self.type)
            if( ret~=false)then
                if(node )then
                    local fla= tower:getChildByTag(TAG_FLASH)
                    fla:setVisible(true)
                    fla.curAction=nil
                    fla:playAction(fla.actionName,nil,nil,0)
                    tower:getChildByTag(TAG_TOWER):setVisible(false)
                end
            end

        end
    end

    local isFirst=true
    for key, tower in pairs(self.towers) do
        if(tower.isBossStage==true)then
            if(tower.batNum>0)then
                --魔王副本出现眼睛
                local fla=tower:getChildByTag(TAG_TOWER)
                local function playEnd()
                    fla:playAction("ui_atlas_monster",nil,nil,0) 
                end
                fla:playAction("ui_atlas_monster_appear",playEnd) 
            end
        else
            tower:stopAllActions()
            DisplayUtil.setGray(tower,false)
            local ret=Data.getAtlasStatus(self.mapid,tower.stageid,self.type)
            if( ret==false)then
                DisplayUtil.setGray(tower:getChildByTag(TAG_TOWER),true)
            end
            if(isFirst)then
                isFirst=false
                tower:runAction( cc.Sequence:create(cc.DelayTime:create(getRand(0,300)/1000), cc.EaseBackOut:create( cc.RotateTo:create(0.3,  cc.vec3(0,0,0)) ),cc.CallFunc:create(opTowerUped)) )
            else
                tower:runAction( cc.Sequence:create(cc.DelayTime:create(getRand(0,300)/1000), cc.EaseBackOut:create( cc.RotateTo:create(0.5,  cc.vec3(0,0,0)) )) )
            end
        end
    end

end



function AtlasItem:onTowerDown()
    if(self.isItemUp==false)then
        return
    end
    self.isItemUp=false
    if(self.towers==nil)then
        return
    end

    local function opTowerDowned()
        for key, tower in pairs(self.towers) do
            if(tower:getChildByTag(TAG_TOWER))then
                tower:getChildByTag(TAG_TOWER):setVisible(true)
            end
            local node=tower:getChildByTag(TAG_FLASH)
            if(node)then
                tower:getChildByTag(TAG_FLASH):setVisible(false)
            end
        end
    end

    local isFirst=true
    for key, tower in pairs(self.towers) do

        if(tower.isBossStage==true)then 
            local fla=tower:getChildByTag(TAG_TOWER) 
            fla:playAction("ui_atlas_monster_wait") 
       else
            tower:stopAllActions()
            if(self.status[key])then
                self.status[key]:setVisible(false)
            end
            DisplayUtil.setGray(tower,true)

            if(isFirst)then
                isFirst=false
                tower:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.RotateTo:create(0.5,  cc.vec3(-60,0,0))),cc.CallFunc:create(opTowerDowned) ) )
            else
                tower:runAction( cc.EaseBackOut:create( cc.RotateTo:create(0.5,  cc.vec3(-60,0,0)) ))
            end

        end
    end

end



function AtlasItem:initStatus(bill,status,stage,i)
    local stageid=bill.stageid
    status:getNode("icon_unlock"):setVisible(false)
    status:getNode("panel_star"):setVisible(false)
    local ret=Data.getAtlasStatus(self.mapid,stageid,self.type)
    local isBossStage=false
    bill.batNum=1
    if(self.type==ATLAS_TYPE_BOSS  and stage.islast==2)then
        isBossStage=true
    end 
    bill.isBossStage=isBossStage
    if(ret==nil)then
        return
    end
    

    if(ret==false)then
        if(isBossStage==false)then
            status:getNode("icon_unlock"):setVisible(true)
        else
            bill:setVisible(false)
        end
        return
    end

    bill.batNum=ret.batNum

    if(isBossStage)then

    else
        status:getNode("panel_star"):setVisible(true)
        local num=ret.num
        for i=1, 3 do
            local node=status:getNode("icon_star"..i)
            if(i<=num)then
                status:changeTexture("icon_star"..i,"images/ui_public1/star1.png")
            end
        end

      
    end
end

function AtlasItem:refreshPassOne()
    --一天只打一次魔王副本
    if(self.type==ATLAS_TYPE_BOSS)then
        for key, bill in pairs(self.towers) do
            local ret=Data.getAtlasStatus(self.mapid,bill.stageid,self.type)
            if(bill.isBossStage==false and ret and ret~=false and ret.batNum<=0)then
                if(bill:getChildByTag(TAG_PASS)==nil)then
                    local tag=cc.Sprite:create("images/ui_atlas/ui/ko.png")
                    tag:setTag(TAG_PASS)
                    bill:addChild(tag,100)
                    tag:setPosition(cc.p(bill.status:getPositionX()+50,60))
                end
            end
        end
       
    end
end


function AtlasItem:onTouchEnded(target)
    if  string.find( target.touchName,"pos")then
        local pos=target.stagePos
        local ret=Data.getAtlasStatus(self.mapid,pos,self.type)
        if(ret==nil or ret==false)then
            return
        end

        if(self.type==ATLAS_TYPE_BOSS and  ret.batNum<=0)then
            if(target.bill.isBossStage)then
              --  gShowNotice(gGetWords("noticeWords.plist","atlas_boss_fight_limit_one2"))
            else
                gShowNotice(gGetWords("noticeWords.plist","atlas_boss_fight_limit_one"))
            end
            return
        end

        local ret=Data.canAtlasFight(self.mapid,pos,self.type)
        if(ret==nil or ret==false)then
            gShowNotice(gGetWords("noticeWords.plist","atlas_type"..self.type.."_no_pass"))
            return
        end
        Scene.cacheAtlasMap(self.mapid,self.type)
        Panel.popUp(PANEL_ATLAS_ENTER,{mapid=self.mapid,stageid=pos,type=self.type})
    end
end

return AtlasItem