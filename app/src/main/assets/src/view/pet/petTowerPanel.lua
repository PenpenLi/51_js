local PetTowerPanel=class("PetTowerPanel",UILayer)

function PetTowerPanel:ctor(param)
    --读取合图
    if(cc.FileUtils:getInstance():isFileExist("packer/images_bg_006_bg6_.plist"))then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_bg_006_bg6_.plist")
    end


    self:init("ui/ui_pet_tower.map")


    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll").scroll:setTouchEnabled(false)

    self:getNode("auto_panel"):setVisible(false)
    self:getNode("btn_panel"):setVisible(false)

    local function updateSweepTime()

        self:getNode("auto_panel"):setVisible(false)
        self:getNode("btn_panel"):setVisible(false)
        if(self.curData )then
            if(self.curData.cd>0)then
                local passTime=gGetCurServerTime()-self.curData.cd
                self:getNode("auto_panel"):setVisible(true)
                local curStage,leftTime,totalLeft=self:getCurSweepStage(1,passTime,self.curData.mapid)

                self:moveToStage(curStage,true,true)
                if(totalLeft<=0)then
                    self.curData.cd=0
                    Net.sendPetAtlasSweepReward()
                    self:fightEnd()
                else
                    local word=gGetWords("labelWords.plist","lab_upt_sweep_stage",curStage)
                    self:setLabelString("lab_curstage",word)
                    self:setLabelString("txt_stage_left_time",leftTime)
                    self:setLabelString("txt_stage_left_time2",leftTime)
                    self:setLabelString("txt_stage_total_time",gParserHourTime(totalLeft))

                    if(self.timeBar.lastTime~=leftTime)then
                        self.timeBar.lastTime=leftTime
                        local progressTo=cc.ProgressFromTo:create(1,leftTime*100/self:getStageTime(),(leftTime-1)*100/self:getStageTime())
                        self.timeBar:stopAllActions()
                        self.timeBar:runAction( progressTo)
                    end

                end
                self:resetMonster(curStage)

            else
                self:resetMonster(self.curData.mapid+1)
                self:getNode("btn_panel"):setVisible(true)
            end
            self:updateFocusCenter()
        else
            self:moveToStage(self.lastStage,false,false)
            self:getNode("btn_panel"):setVisible(true)
        end
    end

    self.timeBar=cc.ProgressTimer:create(cc.Sprite:create("images/ui_lingshou/time_di2.png"))
    gAddCenter(self.timeBar,  self:getNode("panel_second"))
    self.timeBar:setLocalZOrder(2)

    self:getNode("panel_second"):setVisible(false)
    self:getNode("effect"):setVisible(false)
    self:scheduleUpdateWithPriorityLua(updateSweepTime,1)
    -- Net.sendPetAtlasInfo()
    self:initStage(param)

    Unlock.checkFirstEnter(SYS_PET_TOWER);
end


function PetTowerPanel:refreshRewards(stage)
    local rewards={}
    local stages=  DB.getPetLastStages()

    local curStage=self.curData.mapid
    for key, reward in pairs(self.curData.rewards) do
        local num=math.floor(reward.itemnum*(stage-1)/curStage)
        if(num>0)then
            rewards[reward.itemid]=num
        end
    end



    local idx=1
    for itemid, num in pairs(rewards) do
        if(itemid~=0 )then
            local container=self:getNode("icon2_"..idx)
            container:removeAllChildren()
            local node=DropItem.new()
            node:setData(itemid)
            node:setNum(num)
            container.dropItem=node
            gAddMapCenter(node,container)
            idx=idx+1
        end
    end

end


function PetTowerPanel:fightEnd()
    self:playIdle()
    if(self.curData)then
        local monster= self:getMonsterByStage(self.curData.mapid)
        if(monster)then
            monster:setVisible(false)
        end

    end

end

function PetTowerPanel:onPopup()
    self:setLabelString("txt_num1",Data.getUserItemNumById(BOX_KEY_ID1))
    self:setLabelString("txt_num2",Data.getUserItemNumById(BOX_KEY_ID2))
    self:setLabelString("txt_num3",Data.getUserItemNumById(BOX_KEY_ID3))
    self:setLabelString("txt_num4",Data.getCurPetMoney());



    if(self.curData)then
        local isFight=false
        local isMove=false
        local curStage=0
        isFight,isMove,curStage=self:isFight()
        self:moveToStage(curStage,isMove ,isFight)
    end
end


function PetTowerPanel:playRun()
    self:getNode("panel_second"):setVisible(false)
    self:getNode("effect"):setVisible(false)
    self.role:playAction("r"..self.role.cardid.."_run")

end


function PetTowerPanel:createNotice(role,callback)
    if(role)then
        local effect=gCreateFla("ui_pet_tower_arraw",0,callback)
        role:addChild(effect)
    end
end


function PetTowerPanel:playIdle(role)

    if(role==nil)then
        role=self.role
        self:getNode("effect"):setVisible(false)
        self:getNode("panel_second"):setVisible(false)
    end

    if(role)then
        role:playAction("r"..role.cardid.."_wait")
    end

end


function PetTowerPanel:playAttack(role)
    if(role==nil)then
        role=self.role
        self:getNode("effect"):setVisible(true)
        self:getNode("panel_second"):setVisible(true)
        local posx,posy=self.role:getPosition()
        if(self.role:getScaleX()>0)then
            posx=posx+50
        else
            posx=posx-50
        end
        self:getNode("effect"):setPosition(cc.p(posx,posy))
        self:getNode("panel_second"):setPosition(cc.p(posx,posy+100))
    end

    role:playAction("r"..role.cardid.."_hited_s")

end


function PetTowerPanel:resetMonster(stage)
    self:clearMonster(stage)
    local curIdx=math.floor(stage/4) +1
    for key, var in pairs(self:getNode("scroll").items) do
        if(var.inited==true)then
            for i=1, 4 do
                if(var["monster"..i] and var["monster"..i]:isVisible())then
                    if(key~=curIdx)then
                        self:playIdle(var["monster"..i])
                    end
                end
            end
        end
    end

end


function PetTowerPanel:clearMonster(stage)
    local curIdx=math.floor(stage/4) +1
    for key, var in pairs(self:getNode("scroll").items) do
        if(var.inited==true)then
            if(key<curIdx)then
                var:clearMonster()
            elseif(key==curIdx)then
                local containerIdx=(stage)%4
                var:clearMonster(containerIdx)
            else
                var:resetMonster()
            end
        end
    end

end


function PetTowerPanel:getMonsterByStage(stage)

    local item=self:getStageItem(stage)
    if(item==nil or item.inited~=true)then
        return
    end
    local containerIdx=(stage)%4+1
    return item["monster"..containerIdx]

end


function PetTowerPanel:moveToStage(stage,moving,fight,callback)
    if(self.lastStage==stage  )then
        return
    end

    self.lastStage=stage
    if(fight)then
        self:refreshRewards(stage)
    end
    if( self.role==nil)then
        self.role=gCreateRoleFla(Data.getCurIcon(), self:getNode("role_container") ,1,nil,nil,Data.getCurWeapon(),Data.getCurAwake())
        self.role:setScale(0.6)
        local shadow=cc.Sprite:create("images/battle/shade.png")
        shadow:setScaleY(0.5)
        self.role:addChild(shadow)

        local me=cc.Sprite:create("images/ui_family/ME_2.png")
        if(me)then
            me:setPosition(80,160)
            self.role:addChild(me)
        end
        self.role.me=me

        if (Data.getCurHalo()>0) then
            local halolv = Data.getCurHalo()
            loadFlaXml("shouhujingling")
            local name = "shjl_a"
            if (halolv>=3 and halolv<6) then
                name = "shjl_a"
            elseif (halolv>=6 and halolv<9) then
                name = "shjl_b"
            else
                name = "shjl_c"
            end
            local holaFla=gCreateFla(name,1)
            if (holaFla) then
                -- local scale = 0.6
                -- holaFla:setScale(scale)
                gAddCenter(holaFla,self.role)
                -- node:addChild(fla)
                -- local poy = 166+60
                -- local pox = 78+60
                -- poy = poy - (1-scale)*poy
                -- pox = pox - (1-scale)*pox
                -- holaFla:setPositionY(poy)
                -- holaFla:setPositionX(-pox)
            end
            self.role.halo = holaFla
        end
    end

    local curIdx=math.floor(stage/4) +1
    for i=-1, 1 do
        if(self:getNode("scroll").items[curIdx+i])then
            self:getNode("scroll").items[curIdx+i]:setLazyData()
        end
    end
    self:getNode("scroll"):layout(false)

    local monster=self:getMonsterByStage(stage)

    local function onFight()
        self:playAttack()
        self:playAttack(monster)
        self:setRoleZOrder(stage,5)
    end

    local function onReach()
        self:playIdle()
        if(fight)then
            self:createNotice(monster,onFight)
        else
            self:createNotice(monster,callback)
        end
        if(monster:getParent():getPositionX()>self.role:getPositionX())then
            self:setRoleFace(1)
        else
            self:setRoleFace(-1)
        end
        self:createNotice(self.role)
    end


    if(moving~=true)then
        self:setRoleToStageItem(stage)
        self:setStageRole(stage)


        local nextMonster=monster
        if(nextMonster and nextMonster:isVisible()==false)then
            nextMonster=self:getMonsterByStage(stage+1)
        end
        if(nextMonster)then
            if(nextMonster:getParent():getPositionX()>self.role:getPositionX())then
                self:setRoleFace(1)
            else
                self:setRoleFace(-1)
            end
        end

        self:playIdle()
        if(fight)then
            onFight()
        end
        return
    end


    self:playRun()
    local wpos=self:getStageWorldPos(stage-1)
    self:setRoleToStageItem(stage)
    self:setRolePos(wpos)
    self:setRoleZOrder(stage)

    local tpos=self:getStageWorldPos(stage)
    self:setRolePos(tpos,true,onReach)


end

function PetTowerPanel:setRoleZOrder(stage,order)

    local item=self:getStageItem(stage)
    if(item==nil or item.inited~=true)then
        return
    end
    if(order==nil)then
        order=(stage)%4+1
    end
    item:getNode("container"):setLocalZOrder(order)

end

function PetTowerPanel:setStageRole(stage)

    local wpos=self:getStageWorldPos(stage)
    self:setRolePos(wpos)
    self:setRoleZOrder(stage)
end


function PetTowerPanel:getStageItem(stage)
    local curIdx=math.floor(stage/4) +1
    return self:getNode("scroll").items[curIdx]
end


function PetTowerPanel:setToParent(node,parent)

    if(node:getParent()~=parent)then
        node:retain()
        node:removeFromParent()
        parent:addChild(node)
        node:release()
    end

end

function PetTowerPanel:setRoleToStageItem(stage)
    local item=self:getStageItem(stage)
    if(item==nil or item.inited~=true)then
        return
    end
    self:setToParent(self.role,item:getNode("container"))
    self:setToParent(self:getNode("effect"),item:getNode("container"))
    self:setToParent(self:getNode("panel_second"),item:getNode("container"))

end

function PetTowerPanel:resetRoleParent()
    if(self.role==nil)then
        return
    end
    self:setToParent(self.role,self:getNode("role_container"))
    self:setToParent(self:getNode("effect"),self:getNode("role_container"))
    self:setToParent(self:getNode("panel_second"),self:getNode("role_container"))
end



function PetTowerPanel:getStageWorldPos(stage)
    local containerIdx=(stage)%4+1
    local curIdx=math.floor(stage/4) +1
    local item=self:getNode("scroll").items[curIdx]
    if(item and item.inited==true)then
        local node=item:getNode("container"..containerIdx)
        return node:convertToWorldSpaceAR(cc.p(0,0))
    end
    return cc.p(0,0)
end

function PetTowerPanel:setRoleFace(face)

    self.role:setScaleX(0.6*face)
    self.role.me:setScaleX(1*face)

    if(face>0)then
        if (self.role.halo) then self.role.halo:setScaleX(1*face) end
        self.role.me:setPosition(80,160)

        if (self.role.halo) then self.role.halo:setPosition(-80,150) end
    else
        if (self.role.halo) then self.role.halo:setScaleX(-1*face) end
        self.role.me:setPosition(-80,160)

        if (self.role.halo) then self.role.halo:setPosition(80,150) end
    end
end

function PetTowerPanel:setRolePos(to,move,callback)
    local pos=self.role:getParent():convertToNodeSpace(to)
    if(move)then
        if(self.role:getPositionX()<to.x)then
            self:setRoleFace(1)
        else
            self:setRoleFace(-1)
        end
        self.role:stopAllActions()
        local moveAction=cc.MoveTo:create(1.0,pos)
        if(callback)then
            self.role:runAction( cc.Sequence:create(moveAction, cc.CallFunc:create(callback)))
        else
            self.role:runAction(moveAction)
        end
    else
        self.role:setPosition(pos)
    end

end

function PetTowerPanel:updateFocusCenter()
    if(self.role==nil)then
        return
    end
    local wpos= self.role:convertToWorldSpaceAR(cc.p(0,0))
    local pos=self:getNode("scroll").container:convertToNodeSpace(wpos)
    local posY=self:getNode("scroll"):getContentSize().height-self:getNode("scroll").container:getContentSize().height
    local top=self:getNode("scroll").container:getContentSize().height-pos.y
    self:getNode("scroll").container:setPositionY(posY+top-self:getNode("scroll"):getContentSize().height/2)


end


function PetTowerPanel:onPopback()
    Scene.clearLazyFunc("pettower")
end

function PetTowerPanel:getCurSweepStage(startStage,pass,maxStage)
    if(pass<=0)then
        pass=0
    end
    local stageTime=self:getStageTime()
    local newStage=startStage+ math.floor(pass/stageTime)
    local stageLeftTime=(stageTime- pass%stageTime)
    local totalLeftTime=(maxStage-startStage+1)*stageTime-pass
    if(totalLeftTime<=0)then
        newStage=maxStage
    end
    return  newStage,stageLeftTime,totalLeftTime

end

function PetTowerPanel:getStageTime()
    return DB.getSweepTowerTime()
end

function  PetTowerPanel:events()
    return {EVENT_ID_PET_ATLAS_ENTER_INFO,EVENT_ID_PETTOWER_BUY_SWEEPTIMES}
end


function PetTowerPanel:isFight()
    if(self.curData==nil)then
        return false,false,0
    end

    local isFight=false
    local isMove=false
    local curStage=self.curData.mapid
    if(self.curData.cd >0)then
        local passTime=gGetCurServerTime()-self.curData.cd
        local stage,leftTime,totalLeft=self:getCurSweepStage(1,passTime,self.curData.mapid)
        if(totalLeft>0)then
            isFight=true
            if(math.abs(self:getStageTime()-leftTime)<5)then
                isMove=true
            end
            curStage=stage
        end
    end
    return isFight,isMove,curStage
end



function PetTowerPanel:initStage(param)
    self.lastStage=-1
    self.curData=param
    self.maxTime=1+Data.getUsedTimes(VIP_PETTOWER_SWEEP_TIMES);
    -- self:setLabelString("txt_cur_stage",param.mapid)
    self:replaceRtfString("txt_cur_stage",param.mapid);
    self.remainNum=(self.maxTime-param.batnum)
    self.remainSweepNum=(self.maxTime-param.sweepnum)
 -- self:setLabelString("txt_cur_fight_time",self.remainNum)
    -- self:setLabelString("txt_cur_sweep_time",self.remainSweepNum)
    self:replaceRtfString("txt_cur_sweep_time",self.remainSweepNum)
    Scene.clearLazyFunc("pettower")
    self:resetRoleParent()
    self:getNode("scroll"):clear()
    local stages=  DB.getPetStages(1)
    local curStage=param.mapid

    local isFight=false
    local isMove=false
    isFight,isMove,curStage=self:isFight()
    for i=0, table.getn(stages)/4 do
        local item=PetTowerAtlasItem.new()
        item.onSelectCallback=function(mapid)
            if(self.curData.cd==nil or  self.curData.cd<=0)then
                if(   self.curData.mapid==mapid-1)then
                    self:onFight()
                end
            end
        end
        item.curStages={stages[i*4],stages[i*4+1],stages[i*4+2],stages[i*4+3]}
        if(math.abs(i-math.floor(curStage/4))<=1)then
            item:setData()
        end
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    self:moveToStage(curStage,isMove,isFight)

    local stage= DB.getPetStage(param.mapid+1)
    if(stage)then
        self:getNode("icon1"):removeAllChildren()
        self:getNode("icon2"):removeAllChildren()

        local reward =string.split( stage.first_reward, ";")
        local nums =string.split( stage.first_reward_number, ";")

        for key, rewardId in pairs(reward) do
            if(self:getNode("icon"..key))then
                local node=DropItem.new()
                node:setData(toint(rewardId))
                node:setNum(toint(nums[key]))
                node.touch=false
                node:setPositionY(node:getContentSize().height)
                self:getNode("icon"..key):addChild(node)
            end

        end



    end

    self:updateFocusCenter()

end

function PetTowerPanel:refreshSweepTimes(sweepnum)
    self.maxTime=1+Data.getUsedTimes(VIP_PETTOWER_SWEEP_TIMES);
    self.remainSweepNum=(self.maxTime-sweepnum)
    self:replaceRtfString("txt_cur_sweep_time",self.remainSweepNum)
end

function PetTowerPanel:dealEvent(event,param)
    if(event==EVENT_ID_PET_ATLAS_ENTER_INFO)then
        self:initStage(param)
    elseif(event == EVENT_ID_PETTOWER_BUY_SWEEPTIMES)then
        self:refreshSweepTimes(param);
    end
end


function PetTowerPanel:onFight()
    --[[if(self.remainNum<=0)then
        gShowNotice(gGetWords("labelWords.plist","lb_pet_tower_no_time"))
        return
    end]]
    local function callback()
        if(self.curData)then
            Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ATLAS_PET_TOWER,self.curData.mapid+1)
        end
    end

    self:moveToStage(self.curData.mapid+1,true ,false,callback)
end

function PetTowerPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_box"then
        Panel.popUp(PANEL_PET_TOWER_BOX)
    elseif  target.touchName=="btn_shop"then
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_PET);
    elseif  target.touchName=="btn_auto"then

        if(self.remainSweepNum<=0)then
            gShowNotice(gGetWords("labelWords.plist","lb_pet_tower_no_time_sweep"))
            return
        end
        if(self.curData and self.curData.mapid==0)then
            gShowNotice(gGetWords("labelWords.plist","lb_pet_tower_no_pass"))
            return
        end
        Net.sendPetAtlasSweep()
    elseif  target.touchName=="btn_fight"then
        if(self.curData.mapid>=DB.getPetStageMaxMapid())then
            gShowNotice(gGetWords("noticeWords.plist","no_pet_tower_item"))
            return
        end
        self:onFight()
    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_PET_TOWER)
    elseif target.touchName == "btn_add_times"then
        if(self.curData and self.curData.mapid==0)then
            gShowNotice(gGetWords("labelWords.plist","lb_pet_tower_no_pass2"))
            return
        end
        local needPrice = self:getBuySweepTimesPrice();
        print("needPrice = "..needPrice);
        local callback = function(num)
            Net.sendBuyPetAtlasSweepTimes(num);
        end
        Data.vip.petTower.setNeedPrice(needPrice);
        Data.canBuyTimes(VIP_PETTOWER_SWEEP_TIMES,true,callback);
        -- if(NetErr.isDiamondEnough(needPrice))then
            -- Net.sendBuyPetAtlasSweepTimes();
        -- end
    elseif target.touchName == "btn_finish" then
        local onOk = function()
            if(NetErr.isDiamondEnough(Data.petTower.sweepFinishprice))then
                Net.sendPetAtlasSweepFinish();
            end
        end
        gConfirmCancel(gGetWords("noticeWords.plist","pettower_finish_sweep",Data.petTower.sweepFinishprice),onOk)
    end
end

function PetTowerPanel:getBuySweepTimesPrice()
    local price = 0;
    if(self.curData.mapid <= 20)then
        price = Data.petTower.sweepprice[1];
    elseif(self.curData.mapid <= 50)then
        price = Data.petTower.sweepprice[1] + (self.curData.mapid - 20)*Data.petTower.sweepprice[2];
    else
        price = Data.petTower.sweepprice[1] + 30*Data.petTower.sweepprice[2] + (self.curData.mapid - 50)*Data.petTower.sweepprice[3];
    end
    return price;
end

return PetTowerPanel
