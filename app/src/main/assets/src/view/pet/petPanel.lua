local PetPanel=class("PetPanel",UILayer)

local skillPanelEvolve = 1
local skillPanelWakeUp = 2
local skillPanelWakedUp = 3

PetPanelData = {}
function PetPanel:ctor(petIndex)

    if(petIndex == nil)then
        petIndex = 1;
    end
    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/font.plist");

    loadFlaXml("ui_lingshou");

    self:init("ui/ui_pet.map")
    self:getNode("scroll").paddingY = 10;
    --0-未解锁,1--培养,2--技能,3--天赋
    self.status = -1;
    self.feed_info_bg_pos = cc.p(self:getNode("feed_info_bg"):getPosition());
    self.feed_btn_bg_pos = cc.p(self:getNode("feed_btn_bg"):getPosition());
    self.talent_info_bg_pos = cc.p(self:getNode("talent_info_bg"):getPosition());
    self.talent_btn_bg_pos = cc.p(self:getNode("talent_btn_bg"):getPosition());

    self.skill_info_bg_pos = cc.p(self:getNode("skill_info_bg"):getPosition());
    self.unlock_panel_pos = cc.p(self:getNode("unlock_panel"):getPosition());
    self.skill_panel_ui_pos = cc.p(self:getNode("skill_panel_ui"):getPosition());
    self.icon_exp_pos = {};
    for i = 1,5 do
        self.icon_exp_pos[i] = cc.p(self:getNode("icon_exp"..i):getPosition());
    end
    self.lastStNum=0
    self.learnShardNum=0
    self.curPetShard=0
    self:getNode("check_selshar").isSel=false
    self:getNode("feed_panel"):setVisible(true);
    self:getNode("unlock_panel"):setVisible(false);
    self:getNode("skill_panel"):setVisible(false);
    self.starContainerX= self:getNode("star_container"):getPositionX();

    self.selectedIdx=petIndex
    self:initPetList();
    if(not Data.getSysIsEnter(Unlock.system.pet.unlockType))then
        Guide.clearGuide();
    end
    Unlock.checkFirstEnter(SYS_PET);
    self:hideCloseModule();
    gSetLabelScroll(self:getNode("txt_tip"));

    if(self:getNode("skip_ani_bg")) then
        if(Data.getCurLevel() >= Data.pet.skilAniLevel) then
            self:getNode("skip_ani_bg"):setVisible(true);
            self.isSkipAni = Data.getBoolConfig("pet_skip_ani");
        else
            self:getNode("skip_ani_bg"):setVisible(false);
            self.isSkipAni = false;
        end
        self:refreshSkipAni();
    end
end

function PetPanel:hideCloseModule()
    self:getNode("btn_share"):setVisible(self:hasPet(self.curData.petid) and not Module.isClose(SWITCH_SHARE));
    if isBanshuUser() then
        self:getNode("icon_st3"):setVisible(false);
        self:getNode("icon_st3"):getParent():layout();
        self:getNode("btn_talent"):setVisible(false);
    end
end

function PetPanel:onPopup()
    if self.status == 2 then
        Panel.setMainMoneyType(ITEM_PET_SKILL)
    else
        Panel.setMainMoneyType(OPEN_BOX_PET_SOUL)
    end
    self:refreshSkillData();
    local posArray={}
    for i=1,8 do
        posArray[i]=true
    end
    self:refreshTalentData(posArray)
    if(not self:hasPet(self.curData.petid))then
        self:refreshUnlockPetSouldNum();
    end
end

function PetPanel:onPopback()
    AttChange.aniSpeed = 1;
end

function PetPanel:initPetList()
    self:getNode("scroll"):clear()
    local index = 1;
    for key, var in pairs(pet_db) do
        if(var.show==true)then
            local item=PetItem.new()
            local petData=Data.getUserPetById(var.petid)
            if(petData)then
                item:setData(petData,index)
            else
                item:setDBData(var,index)
            end
            self:getNode("scroll"):addItem(item)
            item.selectItemCallback=function (data,idx)
                self:onSelectPet(data,idx)
            end
            if key == self.selectedIdx then
                item:onSelect();
            end
            index = index + 1;
        end
    end
    self:getNode("scroll"):layout()
end

function PetPanel:onSelectPet(data,idx)

    self.selectedIdx = idx;
    for key, var in pairs(self:getNode("scroll").items) do
        if key == idx then
            var:select();
        else
            var:unSelect();
        end
    end

    self:switchPet(data,idx);

-- self:refreshPet();

end

function PetPanel:switchStatus(nextStatus)
    -- print("self.status = "..self.status);
    -- print("nextStatus = "..nextStatus);
    if self.status == nextStatus then
        return;
    end
    self:showSkillSel(nextStatus)

    self.status = nextStatus;
    self:getNode("layout_btn"):setVisible(self.status ~= 0);
    self:handleUnlockPanel(self.status == 0);
    self:handleFeedPanel(self.status == 1);
    self:handleSkillPanel(self.status == 2);
    self:handleTalentPanel(self.status == 3)

    if self.status == 3 then
        self:getNode("btn_relation"):setVisible(false)
        self:getNode("btn_talent_layer"):setVisible(true)
    else
        self:getNode("btn_relation"):setVisible(true)
        self:getNode("btn_talent_layer"):setVisible(false)
    end
    if self.status == 2 then
        Panel.setMainMoneyType(ITEM_PET_SKILL)
    else
        Panel.setMainMoneyType(OPEN_BOX_PET_SOUL)
    end
end

function PetPanel:handleFeedPanel(visible)

    -- local org_visible = self:getNode("feed_panel"):isVisible();
    -- if org_visible == visible then
    --     return;
    -- end

    local needHaned = self:handlePanel("feed_panel",visible);
    if not needHaned then
        return;
    end
    self:runLeftRightAction("feed_info_bg",self.feed_info_bg_pos,visible);
    self:runUpDownAction("feed_btn_bg",self.feed_btn_bg_pos,visible);
    local delaytime = 0;
    for i=1,5 do
        if visible then
            delaytime = math.random()/2;
        end
        self:runUpDownAction("icon_exp"..i,self.icon_exp_pos[i],visible,delaytime);
    end
end

function PetPanel:handleTalentPanel(visible)

    local needHaned = self:handlePanel("talent_panel",visible);
    if not needHaned then
        return;
    end
    self:runLeftRightAction("talent_info_bg",self.talent_info_bg_pos,visible);
    self:runUpDownAction("talent_btn_bg",self.talent_btn_bg_pos,visible);
end


function PetPanel:handleUnlockPanel(visible)

    -- local org_visible = self:getNode("unlock_panel"):isVisible();
    -- if org_visible == visible then
    --     return;
    -- end

    local needHaned = self:handlePanel("unlock_panel",visible);
    if not needHaned then
        return;
    end

    -- self:handlePanel("unlock_panel",visible);
    self:runUpDownAction("unlock_panel",self.unlock_panel_pos,visible);

-- self:getNode("unlock_ani"):removeAllChildren();
-- if visible then
--     self:getNode("role_container"):removeAllChildren();
--     local fla = gCreateFla("ui_lingshou_huzhao_a",1);
--     local replaceFla = gCreateFlaDislpay(self:getPetFlaName(self.curData.petid),1);
--     fla:replaceBoneWithNode({"pet"},replaceFla);
--     gAddChildInCenterPos(self:getNode("unlock_ani"),fla);
-- end
end

function PetPanel:getPetFlaName(petid)
    return "r"..petid.."_pet";
end

function PetPanel:handleSkillPanel(visible)

    -- local org_visible = self:getNode("skill_panel"):isVisible();
    -- if org_visible == visible then
    --     return;
    -- end

    local needHaned = self:handlePanel("skill_panel",visible);
    if not needHaned then
        return;
    end

    -- self:handlePanel("skill_panel",visible);
    self:runLeftRightAction("skill_info_bg",self.skill_info_bg_pos,visible);
    self:runUpDownAction("skill_panel_ui",self.skill_panel_ui_pos,visible);

    for i=1,5 do
        if visible then
            self:refreshBtnSkill(i,0,math.random()/3);
        else
            self:refreshBtnSkill(i,1,math.random()/3);
        end
    end

end

function PetPanel:handlePanel(nodeVar,visible)

    self:getNode(nodeVar):stopAllActions();
    -- local org_visible = self:getNode(nodeVar):isVisible();
    -- if org_visible == visible then
    --     return false;
    -- end

    local time = 1.0;
    if visible then
        self:getNode(nodeVar):setVisible(true);
    else
        self:getNode(nodeVar):runAction(cc.Sequence:create(
            cc.DelayTime:create(time),
            cc.Hide:create()
        ));
    end

    return true;
end

function PetPanel:runLeftRightAction(nodeVar,nodePos,visible)
    local time = 0.3;
    self:getNode(nodeVar):stopAllActions()
    if visible then
        self:getNode(nodeVar):setPositionX(nodePos.x + 300);
        self:getNode(nodeVar):runAction(cc.Sequence:create(
            cc.Show:create(),
            cc.EaseBackOut:create(cc.MoveTo:create(time,nodePos))
        ));
    else
        self:getNode(nodeVar):setPositionX(nodePos.x);
        self:getNode(nodeVar):runAction(cc.Sequence:create(
            cc.Show:create(),
            cc.EaseBackOut:create(cc.MoveBy:create(time,cc.p(300,0))),
            cc.Hide:create()
        ));
    end
end

function PetPanel:runUpDownAction(nodeVar,nodePos,visible,delay)
    local time = 0.3;
    if delay == nil then
        delay = 0;
    end
    self:getNode(nodeVar):stopAllActions()
    if visible then
        self:getNode(nodeVar):setPositionY(nodePos.y - 200);
        self:getNode(nodeVar):runAction(cc.Sequence:create(
            cc.DelayTime:create(delay),
            cc.Show:create(),
            cc.EaseBackOut:create(cc.MoveTo:create(time,nodePos))
        ));
    else
        self:getNode(nodeVar):setPositionY(nodePos.y);
        self:getNode(nodeVar):runAction(cc.Sequence:create(
            cc.DelayTime:create(delay),
            cc.Show:create(),
            cc.EaseBackOut:create(cc.MoveBy:create(time,cc.p(0,-200))),
            cc.Hide:create()
        ));
    end
end

function PetPanel:switchPet(data,idx)
    -- print("switchPet idx = "..idx);
    self:showPet(data.petid);
    self:changeTexture("pet_name","images/ui_word/pet_name_0"..idx..".png")
    self:setCurPetData(data);
    local nextStatus = 0;
    if self.status == 0 then
        if self:hasPet(self.curData.petid) then
            nextStatus = 1;
        end
    else
        if self:hasPet(self.curData.petid) then
            nextStatus = self.status;
            if nextStatus == -1 then
                nextStatus = 1;
            end
        end
    end
    self:switchStatus(nextStatus);

    if(not Module.isClose(SWITCH_SHARE))then
        self:getNode("btn_share"):setVisible(self:hasPet(self.curData.petid));
    end
end

function PetPanel:setCurPetData(data)
    self.curData = data;
    self:refreshPet(true);
    self:getNode("btn_talent"):setVisible(Data.getCurLevel() >= Data.pet.talentOpenlv)
    if isBanshuUser() then
        self:getNode("btn_talent"):setVisible(false);
    end
end

function PetPanel:refreshPet(isRefreshItem)
    -- print("refreshPet");
    self:initTalentData()
    self:refreshPetLv();
    if self:hasPet(self.curData.petid) then
        self:refreshFeedData();
        self:refreshSkillData();
    else
        self:replaceLabelString("txt_unlock",DB.getPetUnlockLevel(self.curData.petid));
        self:refreshUnlockPetSouldNum();
        -- local soulNum = DB.getPetUnlockSoulNum(self.curData.petid);
        -- self:getNode("txt_unlock_soul"):setVisible(soulNum > 0);
        -- if(soulNum > 0)then
        --     local pet= DB.getPetById(self.curData.petid);
        --     local curSoulNum=Data.getPetSoulsNumById(self.curData.petid)
        --     self:replaceLabelString("txt_unlock_soul",soulNum,pet.name,curSoulNum);
        -- end
        -- self:resetLayOut();
    end

    if isRefreshItem then
        self:refreshPetItem();
    end
end

function PetPanel:refreshUnlockPetSouldNum()
    local soulNum = DB.getPetUnlockSoulNum(self.curData.petid);
    self:getNode("txt_unlock_soul"):setVisible(soulNum > 0);
    if(soulNum > 0)then
        local pet= DB.getPetById(self.curData.petid);
        local curSoulNum=Data.getPetSoulsNumById(self.curData.petid)
        self:replaceLabelString("txt_unlock_soul",soulNum,pet.name,curSoulNum);
    end
    self:resetLayOut();    
end

function PetPanel:refreshPetLv()
    if self.curData.level == nil then
        -- self.curData.level = 1;
        self:getNode("bg_lv_info"):setVisible(false);
        return;
    end
    self:getNode("bg_lv_info"):setVisible(true);
    local grade = Pet.convertToGrade(self.curData.level);--math.floor((self.curData.level-1)/10)+1;
    grade = math.max(1,grade);
    local level = (self.curData.level-1)%10+1;
    level = math.max(1,level);
    self:replaceLabelString("txt_cur_grade",grade);
    self:replaceLabelString("txt_cur_level",level);
end

function PetPanel:refreshPetItem()
    for key,item in pairs(self:getNode("scroll"):getAllItem()) do
        if key == self.selectedIdx then
            if self:hasPet(self.curData.petid) then
                item:setData(self.curData,self.selectedIdx);
            else
                item:setDBData(self.curData,self.selectedIdx);
            end
        end
    end
end

function PetPanel:refreshFeedData()

    if not self:hasPet(self.curData.petid) then
        return;
    end

    local attrs={Attr_HP,Attr_PHYSICAL_ATTACK,Attr_PHYSICAL_DEFEND,Attr_MAGIC_DEFEND}


    local expData=DB.getPetExpByLevel(self.curData.level,self.curData.petid)
    if(self.curData.level >= Data.pet.maxLevel) then
        expData.exp = 0;
    end
    local per=self.curData.exp/expData.exp
    self:setBarPer("bar2",per)
    self:setLabelString("txt_pet_point",gUserInfo.petPoint )
    -- self:setLabelString("txt_exp",self.curData.exp.."/"..expData.exp )
    gShowLabStringCurAndMax(self,"txt_exp",self.curData.exp,expData.exp);
    self:setLabelString("txt_feed_num",DB.getPetNormalFeedNum(self.curData.level,self.curData.petid))
    self:setLabelString("txt_feed_dia_num",DB.getPetGoldFeedNum(self.curData.level,self.curData.petid))
    local attrAdd={}
    local nextLevelData=nil
    local isWakedup = self.curData.grade > 5
    local petDBInfo= DB.getPetById(self.curData.petid)
    for key, var in pairs(pet_upgrade_db) do
        if(var.petid==self.curData.petid and var.level<=self.curData.level)then
            if(attrAdd[var.attr_id]==nil)then
                attrAdd[var.attr_id]=0
            end
            local attr_value = var.attr_value
            if isWakedup then
                attr_value = var.attr_value * (1 + petDBInfo.wakeup_attrpercent / 100)
            end
            attrAdd[var.attr_id]=attrAdd[var.attr_id]+attr_value;
        end

        if(var.petid==self.curData.petid and var.level==self.curData.level+1)then
            nextLevelData=var
        end
    end

    local db=DB.getPetById(self.curData.petid)
    if(db and (db["attr_value_grade"..self.curData.grade] or isWakedup))then
        local addStr=    db["attr_value_grade"..self.curData.grade];
        if isWakedup then
            addStr=db["attr_value_grade5"];
        end
        local addData = string.split(addStr,";");
        for key, var in pairs(attrs) do
            if(attrAdd[var]==nil)then
                attrAdd[var]=0
            end
            if isWakedup then
                addData[key] = addData[key] * (1 + petDBInfo.wakeup_attrpercent / 100)
            end
            attrAdd[var]=attrAdd[var]+addData[key]
        end
    end

    if(nextLevelData)then
        self:setLabelString("txt_add_attr_type", CardPro.getAttrName(nextLevelData.attr_id))
        self:setLabelString("txt_add_attr_value","+"..nextLevelData.attr_value)

    else
        self:setLabelString("txt_add_attr_type","")
        self:setLabelString("txt_add_attr_value","")

    end

    for key, attr in pairs(attrs) do
        local baseAttr=0
        local addAttr=0
    
        if(attrAdd[attr]~=nil)then
            addAttr=math.floor(attrAdd[attr])
        end
        
        if(gPetAddAttr~=nil and gPetAddAttr[attr] )then
            baseAttr=math.floor(gPetAddAttr[attr]-addAttr)
        end
        
        self:setLabelString("txt_attr"..attr, baseAttr)
        self:setLabelString("txt_add_attr"..attr, "+"..addAttr)
        self:setLabelString("txt_attr"..attr.."_next","+"..self:getAddAttrByNextGrade(attr,self.curData.petid,self.curData.grade));
    end

    if(self:getNode("layout_next_grade"))then
        self:getNode("layout_next_grade"):setVisible(self.curData.grade < 5)
    end


    self:resetLayOut();
end

function PetPanel:getAddAttrByNextGrade(attr,petid,curGrade)
    local index = 1;
    if(attr == Attr_HP)then
        index = 1;
    elseif(attr == Attr_PHYSICAL_ATTACK)then
        index = 2;
    elseif(attr == Attr_PHYSICAL_DEFEND)then
        index = 3;
    elseif(attr == Attr_MAGIC_DEFEND)then
        index = 4;
    end
    for key,pet in pairs(pet_db) do
        if(toint(pet.petid) == toint(petid))then
            -- print("curGrade = "..curGrade)
            if(curGrade < 5)then
                print_lua_table(pet);
                local curStr = pet["attr_value_grade"..curGrade];
                local nextStr = pet["attr_value_grade"..(curGrade+1)];
                    -- print("curStr = "..curStr);
                    -- print("nextStr = "..nextStr);
                if(curStr and nextStr)then
                    local curData = string.split(curStr,";");
                    local nextData = string.split(nextStr,";");
                    -- print_lua_table(curData);
                    -- print_lua_table(nextData);
                    return toint(nextData[index]) - toint(curData[index]);
                end
            end
        end
    end
    return 0;
end

function PetPanel:addAttrByEvolve()
    local words = {};
    local attrs={Attr_HP,Attr_PHYSICAL_ATTACK,Attr_PHYSICAL_DEFEND,Attr_MAGIC_DEFEND}
    for key, attr in pairs(attrs) do
        local value = self:getAddAttrByNextGrade(attr,self.curData.petid,self.curData.grade-1);
        table.insert(words,gGetWords("cardAttrWords.plist","attr"..attr).."+"..value);
    end
    AttChange.pushAtt(PANEL_PET,words);
end

function PetPanel:refreshSpecTalenIconLock(node,isLock)
    node:removeChildByTag(1001,true);
    if isLock~=nil and isLock==1 then
        local lock = cc.Sprite:create("images/ui_public1/small_lock.png")
        lock:setLocalZOrder(1000)
        gRefreshNode(node,lock,cc.p(0,1),cc.p(18,-22),1000)
    else
        node:removeChildByTag(1000,true);
    end
end

function PetPanel:addSpecTalenUnlock(node)
    if node.isAdd then
        return
    end
    node.isAdd = true
    local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png")
    lock:setLocalZOrder(1001)
    gRefreshNode(node,lock,cc.p(0.5,0.5),nil,1001)

end

function PetPanel:initTalentData()

    local posArray={}
    for i=1,8 do
        local stidNode = self:getNode("icon_skid"..i)
        stidNode.cdTime=0
        stidNode.isOpen=false
        stidNode.isAdd = false
        stidNode:removeAllChildren()
        local ret=cc.Sprite:create("images/ui_lingshou/skill_di2.png")
        gAddCenter(ret, stidNode)
        posArray[i]=true
    end

    self:getNode("check_selshar").isSel = false
    if self:getNode("check_selshar").isSel==false then
        self:changeTexture("check_selshar", "images/ui_public1/gou_2.png")
    else
        self:changeTexture("check_selshar", "images/ui_public1/gou_1.png")
    end

    self:refreshTalentData(posArray)
end

function PetPanel:refreshTalentData(posArray)

    if self.curData.stlocks == nil then
        return
    end
    if self.initTalent ==nil then
        for i,data in pairs(Data.pet.talentExpTable) do
            self:setLabelString("txt_texp"..i,"+"..data.exp)
           self:getNode("icon_st"..i).__touchend=true
        end
        self.initTalent = true
    end
    
    for i,data in pairs(Data.pet.talentExpTable) do
        self:setLabelString("txt_st_num"..i,Data.getItemNum(data.itemid).."/"..data.const)
    end
    local lockNum = 0
    for i=1,8 do
        if self.curData.stlocks[i]~=nil and self.curData.stlocks[i] == 1 then
            lockNum=lockNum+1
        end 
        local stidNode = self:getNode("icon_skid"..i)
        if posArray~=nil and posArray[i]==true and self.curData["stid"..i]>0 then
            Icon.setPetTalentSkillIcon(self.curData["stid"..i],stidNode)
        end
        
        local isOpen = (i<=self.curData.unlockst)
        stidNode.isOpen=isOpen
        if isOpen then
            self:refreshSpecTalenIconLock(stidNode,self.curData.stlocks[i])
        else
            self:addSpecTalenUnlock(stidNode)
        end
    end
    local needLearnExp = Data.pet.learnExpTable[self.curData.unlockst]
    if Data.pet.learnLockExpTable[lockNum] then
        needLearnExp=needLearnExp+Data.pet.learnLockExpTable[lockNum]
    end
    self:setLabelString("txt_talentexp",gUserInfo.stexp.."/"..needLearnExp)
    self:setBarPer2("talent_bar2", gUserInfo.stexp, needLearnExp)
    
    self:setTouchEnableGray("btn_learnTalent", gUserInfo.stexp>=needLearnExp)


    local pet= DB.getPetById(self.curData.petid)
    self.learnShardNum = toint(string.split(pet.stpetsnum,";")[lockNum+1])
    self.curPetShard=Data.getItemNum(self.curData.petid+ITEM_TYPE_SHARED_PRE)
    local strShareNum = self.curPetShard.."/"..self.learnShardNum;
    self:setLabelString("txt_sharenum",strShareNum)
    self:resetLayOut(); 
end



function PetPanel:refreshSkillData()

    -- print("refreshSkillData");
    if not self:hasPet(self.curData.petid) then
        return;
    end

    if (self.curData.grade == nil) then
        self.curData.grade = 0
    end
    CardPro:showStar(self,self.curData.grade)

    local skillPanelUIState = self:getSkillPanelUIState()
    if skillPanelUIState == skillPanelWakeUp or 
        skillPanelUIState == skillPanelWakedUp then
        self:getNode("layer_skill_ui"):setVisible(false)
        self:getNode("star_constainer_bg"):setVisible(false)
        self:getNode("star_container"):setVisible(false)
        self:getNode("wakeup_panel_ui"):setVisible(true)
        self:refreshWakeUpPanel()
    else
        self:getNode("layer_skill_ui"):setVisible(true)
        self:getNode("star_constainer_bg"):setVisible(true)
        self:getNode("star_container"):setVisible(true)
        self:getNode("wakeup_panel_ui"):setVisible(false)
    end

    local curSoulNum=Data.getPetSoulsNumById(self.curData.petid)
    local needSoulNum=DB.getPetNeedSoulNum(self.curData.petid,self.curData.grade)
    --升星
    if(curSoulNum<needSoulNum or needSoulNum <= 0)then
        self:setTouchEnable("btn_evolve",false,true)
    else
        self:setTouchEnable("btn_evolve",true,false)
    end



    local per=curSoulNum/needSoulNum
    self:setBarPer("bar1",per)
    -- self:setLabelString("txt_soul",curSoulNum.."/"..needSoulNum)
    gShowLabStringCurAndMax(self,"txt_soul",curSoulNum,needSoulNum);

    if(self.curSkillIdx==nil)then
        self.curSkillIdx=1
    end
    -- print("self.curSkillIdx = "..self.curSkillIdx);
    -- if self.status == 2 then
    self:selectSkill(self.curSkillIdx);
-- end

end

function  PetPanel:changePetid(petid)
    -- print ("changePetid~~")
    if(self.lastPetid~=petid)then
        self.lastPetid=petid
        self:showPet(petid);
    end
end

function PetPanel:showPet(petid)

    local result = loadFlaXml("r"..petid, nil, Pet.getPetAwakeLv(petid))
    self:getNode("unlock_ani"):removeAllChildren();
    if self:hasPet(petid) then
        self:getNode("role_container"):removeAllChildren()
        if(result)then
            local fla=FlashAni.new()
            fla:setPetSkinId(Pet.getPetAwakeLv(petid))
            fla:playAction("r"..petid.."_wait")
            self:getNode("role_container"):addChild(fla)
        end
    else
        local result = loadFlaXml("r"..petid.."_pet")
        -- if visible then
        self:getNode("role_container"):removeAllChildren();
        local fla = gCreateFla("ui_lingshou_huzhao_a",1);
        local replaceFla = gCreateFlaDislpay(self:getPetFlaName(petid),1);
        fla:replaceBoneWithNode({"pet"},replaceFla);
        gAddChildInCenterPos(self:getNode("unlock_ani"),fla);
    -- end
    end
end


function PetPanel:refreshBtnSkill(idx,status,delaytime)
    if delaytime and delaytime > 0 then
        local callback = function()
            self:_refreshBtnSkill(idx,status);
        end
        gCallFuncDelay(delaytime,self,callback);
    else
        self:_refreshBtnSkill(idx,status);
    end
end

function PetPanel:_refreshBtnSkill(idx,status,delaytime)
    --status 0--出现 1--消失 2--选中 3--未选中
    -- print("refreshBtnSkill")
    local fla = nil;
    local replaceBone = {};
    if status == 0 then
        -- if delaytime then
        --     fla = gCreateFlaDelay(delaytime,"ui_lingshou_tubiao_a",0)
        -- else
        fla = gCreateFla("ui_lingshou_tubiao_a",-1);
        -- end
        replaceBone = {"icon1","icon"};
    elseif status == 1 then
        -- if delaytime then
        --     fla = gCreateFlaDelay(delaytime,"ui_lingshou_tubiao_b",0)
        -- else
        fla = gCreateFla("ui_lingshou_tubiao_b",-1);
        -- end
        replaceBone = {"icon1","icon"};
    elseif status == 2 then
        fla = gCreateFla("ui_lingshou_tubiao_c",-1);
        replaceBone = {"icon"};
    elseif status == 3 then
        fla = gCreateFla("ui_lingshou_tubiao_b",-1);
        fla:stopAni();
        replaceBone = {"icon1","icon"};
    end

    if fla then
        local node = self:getSkillOrBuffIcon(self.curData.petid,idx);
        if status == 0 and idx == self.curSkillIdx then
            --出现 接着 选中
            --出现
            local flaAni = FlashAniGroup.new();
            local replaceBoneData = {};
            table.insert(replaceBoneData,{boneTable={"icon1","icon"},node=node});
            flaAni:addFlashAni("ui_lingshou_tubiao_a",true,0,replaceBoneData);

            --选中
            node = self:getSkillOrBuffIcon(self.curData.petid,idx);
            replaceBoneData = {};
            table.insert(replaceBoneData,{boneTable={"icon"},node=node});
            flaAni:addFlashAni("ui_lingshou_tubiao_c",false,0,replaceBoneData);
            flaAni:play();
            self:replaceNode("skill_icon"..idx,flaAni,true);
        else
            fla:replaceBoneWithNode(replaceBone,node);
            self:replaceNode("skill_icon"..idx,fla,true);
        end
    end

    if status == 1 then
        self:getNode("lock_skill_icon"..idx):setVisible(false);
        self:getNode("txt_skill_lv"..idx):setVisible(false);
    else
        local isUnlock = Pet.isSkillUnlock(self.curData.petid,idx);
        self:getNode("lock_skill_icon"..idx):setVisible(not isUnlock);
        self:getNode("txt_skill_lv"..idx):setVisible(isUnlock);
        self:setLabelString("txt_skill_lv"..idx,math.max(self.curData["skillLevel"..idx],1));
    end
end

function PetPanel:getSkillOrBuffIcon(petid,idx)
    local node = cc.Node:create();
    local skillid = self:getSkillOrBuffId(self.curData.petid,idx)
    if 1 == idx then
        Icon.setIcon(skillid,node);
    else
        Icon.setBuffIcon(skillid,node);
    end
    local isUnlock = Pet.isSkillUnlock(self.curData.petid,idx);
    DisplayUtil.setGray(node,not isUnlock);
    node:setAllChildCascadeOpacityEnabled(true);


    return node;
end

function PetPanel:getSkillOrBuffId(petid,idx)
    local pet = DB.getPetById(self.curData.petid)
    if idx == 1 then
        return pet.skillid;
    else
        return pet["buff"..(idx-2)][1];
    end
end

function PetPanel:refreshCurSkillIcon()
    for i=1,5 do
        self:refreshBtnSkill(i,3);
    end
    self:refreshBtnSkill(self.curSkillIdx,2);
end

function PetPanel:selectSkill(idx)

    self.curSkillIdx=idx

    if self.status == 2 then
        self:refreshCurSkillIcon();
    end

    local pet= DB.getPetById(self.curData.petid)
    local curLevel=self.curData["skillLevel"..idx]
    curLevel = math.max(curLevel,1);

    local attackParam=toint( string.split( pet.attack_params,";")[self.curData.grade]) 
    if(idx==1)then
        local skillDb=DB.getSkillById(pet.skillid)
        Icon.setIcon(pet.skillid,self:getNode("skill_icon"))
        self:setLabelString("txt_name",skillDb.name)
        
        
        self:setLabelString("txt_info",gGetSkillDesc( skillDb,curLevel,attackParam))
        self:setLabelString("txt_info2",gGetSkillDesc( skillDb,curLevel+1,attackParam))
    else
        Icon.setBuffIcon(pet["buff"..(idx-2)][1],self:getNode("skill_icon"))
        local bufDb=DB.getBuffById(pet["buff"..(idx-2)][1])
        self:setLabelString("txt_name",bufDb.name)
        self:setLabelString("txt_info",gGetBuffDesc( bufDb,curLevel,attackParam))
        self:setLabelString("txt_info2",gGetBuffDesc( bufDb,curLevel+1,attackParam))
    end

    if(  Pet.isSkillUnlock(pet.petid,idx))then
        self:getNode("skill_upgrade_panel"):setVisible(true)
        self:getNode("skill_unlock_panel"):setVisible(false)

        if(Pet.canSkillUpgrade(pet.petid,idx))then
            self:setTouchEnable("btn_upgrade",true,false)
            self:setLabelString("txt_upgrade_dic","")
        else
            local upSkillLv = curLevel
            if Pet.isAwakeUp(pet.petid) then
                local db = DB.getPetById(pet.petid)
                local deltaLev = pet.wakeup_sklillvmax
                if idx ~= 1 then
                    deltaLev = pet.wakeup_bufflvmax
                end
                upSkillLv = curLevel - deltaLev
            end
            local words=gGetWords("petWords.plist","lab_up_upgrade_skill",(upSkillLv+1)*3+2)
            if(upSkillLv >= 20)then
                words = gGetWords("petWords.plist","14");
                if Pet.isSatisfyWakeUp(self.curData.petid) then
                    local pet= DB.getPetById(self.curData.petid)
                    local upLev = pet.wakeup_sklillvmax
                    if idx ~= 1 then
                        upLev = pet.wakeup_bufflvmax
                    end
                    words = gGetWords("petWords.plist","lab_skill_up_des_wakeup",upLev);
                end
            end

            self:setLabelString("txt_upgrade_dic",words)
            self:setTouchEnable("btn_upgrade",false,true)
        end

    else
        self:getNode("skill_unlock_panel"):setVisible(true)
        self:getNode("skill_upgrade_panel"):setVisible(false)

        local words=gGetWords("petWords.plist","lab_up_unlock_skill",idx)
        self:setLabelString("txt_unlock_dic",words)
    end

    self:setLabelString("txt_level",curLevel)
    local skillData=DB.getPetSkillByLevel(pet.petid,curLevel)
    self.upgradeSkillNeedGold = 0;
    self.upgradeSkillNeedItem = 0;
    if(skillData)then
        self.upgradeSkillNeedGold = skillData["price_skill"..idx];
        self.upgradeSkillNeedItem = skillData["item_skill"..idx];
        self:setLabelString("txt_upgrade_gold",self.upgradeSkillNeedGold)
        self:setLabelString("txt_upgrade_item",self.upgradeSkillNeedItem)
    end

    -- self:getNode("skill_icon"..idx);
    self:resetLayOut();
    self:getNode("scroll_skill_content"):layout();
end


function PetPanel:hasPet(petid)
    local data = Data.getUserPetById(petid);
    if data then
        return true;
    end
    return false;
end


function PetPanel:handleUpgrade(param)

    self.desExp = self.curData.exp;
    self.desLv = self.curData.level;

    self.peiyangMore = true;
    local count = table.getn(param)
    if count == 1 then
        self.aniFrame = 19*2;
        self.peiyangMore = false;
    elseif count >= 5 then
        self.aniFrame = 60;
    elseif count < 5 then
        self.aniFrame = 30;
    end

    if(self.isSkipAni) then
        for key,var in pairs(param) do
            AttChange.pushAttBaoji(PANEL_PET,1,gGetWords("petWords.plist","6").."+"..Data.pet.needExp[var+1],toint(var+1));
            -- self:showAddExpAni(toint(param[key])+1);
            local showAddExpAni = function()
                self:showAddExpAni(toint(param[key])+1);
                if key == count then
                    self:endPetPeiyang();
                end
            end
            gCallFuncDelay(0.05*(key-1),self,showAddExpAni);
        end
        -- self:endPetPeiyang();
    else
        self:startPetPeiyang();
        for key,var in pairs(param) do
            AttChange.pushAttBaoji(PANEL_PET,1,gGetWords("petWords.plist","6").."+"..Data.pet.needExp[var+1],toint(var+1));
            local showAddExpAni = function()
                self:showAddExpAni(toint(param[key])+1);
                if key == count then
                    self:endPetPeiyang();
                end
            end
            gCallFuncDelay(0.2*(key-1),self,showAddExpAni);
        end
    end


end

function PetPanel:startPetPeiyang()
    -- print("startPetPeiyang");
    self.leveluping = true;
    local pet_light = nil
    if self.peiyangMore then
        pet_light = gCreateFla("ui_qiliu_b",1);
    else
        pet_light = gCreateFla("ui_qiliu_a");
    end
    self:getNode("pet_base"):removeChildByTag(100);
    if pet_light then
        pet_light:setTag(100);
        gAddChildInCenterPos(self:getNode("pet_base"),pet_light);
    end
    self:getNode("scroll"):setAllItemTouchEnable(false);
-- self:startLevelUp();
end

function PetPanel:endPetPeiyang()
    -- print("endPetPeiyang");
    self.leveluping = false;
    if self.peiyangMore then
        self:getNode("pet_base"):removeChildByTag(100);
    end
    self:getNode("scroll"):setAllItemTouchEnable(true);
    self:refreshPet(true);
    self.peiyangMore = false;
end

function PetPanel:showAddExpAni(times)
    local ranidx = math.random(1,5);
    -- print("ranidx = "..ranidx);
    if self.lastRanidx == nil then
        self.lastRanidx = ranidx;
    elseif self.lastRanidx == ranidx then
        ranidx = ranidx + 1;
        if ranidx > 5 then
            ranidx = 1;
        end
        self.lastRanidx = ranidx;
    end
    if(not self.isSkipAni)then
        local fla = gCreateFla("ui_lingshou_bao",-1);
        -- fla:setSpeedScale(1.5);
        self:replaceNode("icon_exp"..ranidx,fla);
    end

    self.showCurExp = self.showCurExp + Data.pet.needExp[times];
    -- print("times = "..times);
    -- print("addExp = "..Data.pet.needExp[times]);
    local expData=DB.getPetExpByLevel(self.showCurLv,self.curData.petid);
    local maxExp = expData.exp;
    if self.showCurExp >= maxExp then
        local attrAdd={}
        local nextLevelData=nil
        for key, var in pairs(pet_upgrade_db) do
            if(var.petid==self.curData.petid and var.level<=self.showCurLv)then
                if(attrAdd[var.attr_id]==nil)then
                    attrAdd[var.attr_id]=0
                end
                attrAdd[var.attr_id]=attrAdd[var.attr_id]+var.attr_value
            end
            if(var.petid==self.curData.petid and var.level==self.showCurLv+1)then
                nextLevelData=var
            end
        end

        local attrs={Attr_HP,Attr_PHYSICAL_ATTACK,Attr_PHYSICAL_DEFEND,Attr_MAGIC_DEFEND}
        local db=DB.getPetById(self.curData.petid)
        local isWakedup = self.curData.grade > 5
        if(db and (db["attr_value_grade"..self.curData.grade] or isWakedup))then
            local addStr=    db["attr_value_grade"..self.curData.grade];
            if isWakedup then
               addStr=    db["attr_value_grade5"]; 
            end
            local addData = string.split(addStr,";");
            for key, var in pairs(attrs) do
                if(attrAdd[var]==nil)then
                    attrAdd[var]=0
                end

                if isWakedup then
                    local petDBInfo= DB.getPetById(self.curData.petid)
                    addData[key] = addData[key] * (1 + petDBInfo.wakeup_attrpercent / 100)
                end

                attrAdd[var]=attrAdd[var]+addData[key]
            end
        end

        if(nextLevelData)then
            local table_data = {}
            table_data.attr = nextLevelData.attr_id
            if(attrAdd[nextLevelData.attr_id] == nil)then
                table_data.value = 0
            else
                table_data.value = attrAdd[nextLevelData.attr_id]
            end
            table_data.add = nextLevelData.attr_value
            local petNotice = PetNoticePanel.new(table_data)
            petNotice:setAnchorPoint(cc.p(0.5,-0.5))
            gAddChildByAnchorPos(gShowItemPoolLayer,petNotice,cc.p(0.5,0.5));
        end

        self.showCurExp = self.showCurExp - maxExp;
        self.showCurLv = self.showCurLv + 1;
    end

    expData=DB.getPetExpByLevel(self.showCurLv,self.curData.petid);
    local per=self.showCurExp/expData.exp
    self:setBarPer("bar2",per)
    -- self:setLabelString("txt_pet_point",gUserInfo.petPoint )
    local strExp = self.showCurExp.."/"..expData.exp;
    strExp = getLvReviewName(strExp);
    self:setLabelString("txt_exp",strExp);
    self:getNode("txt_exp"):setVisible(false);
    self:setLabelString("txt_feed_num",DB.getPetNormalFeedNum(self.showCurLv,self.curData.petid))
    self:setLabelString("txt_feed_dia_num",DB.getPetGoldFeedNum(self.showCurLv,self.curData.petid))

end
--[[
function PetPanel:startLevelUp()

-- print("startLevelUp");
if self.showCurLv < self.desLv then
self.leveluping = true;
local function callback()
self:levelUp();
end
local desExp = DB.getPetExpByLevel(self.showCurLv).exp;
local frame = (desExp - self.showCurExp) / desExp * self.aniFrame;
self:updateBarPer("bar2","txt_exp",self.showCurExp,desExp,desExp,frame,callback);
elseif self.showCurLv == self.desLv and self.showCurExp < self.desExp then
self.leveluping = true;
local maxExp = DB.getPetExpByLevel(self.showCurLv).exp;
local frame = (self.desExp - self.showCurExp) / maxExp * self.aniFrame;
local function callback()
self.leveluping = false;
self.showCurLv = self.desLv;
self.showCurExp = self.desExp;
self:refreshPetItem();
self:refreshPet();
self:endPetPeiyang();
-- print("end startLevelUp")
end
self:updateBarPer("bar2","txt_exp",self.showCurExp,self.desExp,maxExp,frame,callback);
else
self.leveluping = false;
self:endPetPeiyang();
end

end

function PetPanel:levelUp()
-- print("levelUpCallBack");
-- local needExp = DB.getCardExpByLevel(self.showCurLv) - self.showCurExp;
-- self.showLeftExp = self.showLeftExp - needExp;

self.showCurLv = self.showCurLv + 1;
self.showCurExp = 0;
self:refreshPet();
self:refreshPetItem();

self:startLevelUp();
end
]]

function PetPanel:unlockPet()

    UILayer.pauseTouch = false;
    local playend = function()

        local pet = Data.getUserPetById(self.curData.petid);
        self:setCurPetData(pet);
        self:showPet(self.curData.petid);
        self:switchStatus(1);
        self.unlockPeting = false;
        self:getNode("scroll"):setAllItemTouchEnable(true);
    end
    self:getNode("unlock_ani"):removeAllChildren();
    local fla = gCreateFla("ui_lingshou_huzhao_b",0,playend);
    -- print("self.curData.petid = "..self.curData.petid);
    local replaceFla = gCreateFlaDislpay(self:getPetFlaName(self.curData.petid),1);
    fla:replaceBoneWithNode({"pet"},replaceFla);

    replaceFla = gCreateFlaDislpay("r"..self.curData.petid.."_wait",1);
    fla:replaceBoneWithNode({"pet2"},replaceFla);

    gAddChildInCenterPos(self:getNode("unlock_ani"),fla);

    self:getNode("role_container"):removeAllChildren();
    self.unlockPeting = true;
    self:getNode("scroll"):setAllItemTouchEnable(false);
end

function PetPanel:getUnlockSkillIdx()
    return self.curData.grade;
end

function PetPanel:events()
    return {EVENT_ID_PET_UPGRADE,
        EVENT_ID_PET_EVOLVE,
        EVENT_ID_PET_UNLOCK,
        EVENT_ID_PET_REFRESH_DATA,
        EVENT_ID_PET_WAKEUP,
        EVENT_ID_PET_REFRESH_TALENT,
        EVENT_ID_PET_LEAR_TALENT,}
end


function PetPanel:dealEvent(event,param)
    if(event==EVENT_ID_PET_UPGRADE )then
        -- print_lua_table(param);
        self:handleUpgrade(param);
        Unlock.system.petSkill.checkPetSkillUnlock(self.curData);
    elseif (event==EVENT_ID_PET_REFRESH_TALENT) then
        self:refreshTalentData()
    elseif(event==EVENT_ID_PET_LEAR_TALENT)then
        local pet_light = gCreateFla("ui_qiliu_a");
        self:getNode("pet_base"):removeChildByTag(100);
        if pet_light then
            pet_light:setTag(100);
            gAddChildInCenterPos(self:getNode("pet_base"),pet_light);
        end
        
        local stidNode = self:getNode("icon_skid"..param.pos)
        stidNode:removeChildByTag(1111);
        local talent_light = gCreateFla("ui_lingshou_icon_guangdian");
        if talent_light then
            talent_light:setLocalZOrder(1111)
            talent_light:setTag(1111);
            gAddChildInCenterPos(stidNode,talent_light);
        end
        local posArry = {}
        posArry[param.pos]=true
        self:refreshTalentData(posArry)

    elseif(event==EVENT_ID_PET_EVOLVE)then

        self:refreshPetItem();
        self:refreshFeedData();
        self:refreshSkillData();
        self:addAttrByEvolve();
        -- self:refreshCurSkillIcon();

        local unlockSkillIdx = self:getUnlockSkillIdx();
        -- print("unlockSkillIdx = "..unlockSkillIdx);
        local fla = gCreateFla("ui_lingshou_icon_guang");
        fla:setPosition(self:getNode("skill_icon"..unlockSkillIdx):getPosition());
        self:getNode("skill_icon"..unlockSkillIdx):getParent():addChild(fla,10);

    elseif(event==EVENT_ID_PET_UNLOCK)then
        self:unlockPet()
    elseif(event == EVENT_ID_PET_REFRESH_DATA) then
        self:refreshSkillData();
    elseif(event == EVENT_ID_PET_WAKEUP) then
        self:refreshPetItem()
        self:refreshFeedData()
        self:refreshSkillData()
        self:showPet(self.curData.petid)
    end

end

function PetPanel:selectTalentSkill(name)
    local btns ={"talent_btn_skill1","talent_btn_skill2"}
    for k,btn in pairs(btns) do
        self:changeTexture(btn, "images/ui_public1/niuhui.png")
    end
    self:changeTexture(name, "images/ui_public1/niulan.png")
    -- body
end


function PetPanel:onTouchBegan(target,touch, event)
    self.beganPos = touch:getLocation()
    if(string.find(target.touchName,"icon_st"))then
        self.isMoved=false
        self.curDt=0
        self.curPutSpeed=0.5
        local idx=toint( string.gsub(target.touchName,"icon_st",""))
        local function updatePut(dt)
            self.curDt=self.curDt+dt
            if(self.curDt>self.curPutSpeed)then
                self.curDt=self.curDt-self.curPutSpeed 
                self.curPutSpeed=self.curPutSpeed-0.09
                if(self.curPutSpeed<0.1)then
                    self.curPutSpeed=0.1
                end
                self:touchIcon(idx)
            end
        end
        self:scheduleUpdateWithPriorityLua(updatePut,1)

    elseif (string.find(target.touchName,"icon_skid")) then
        local idx=toint(string.gsub(target.touchName,"icon_skid",""))
        local stid = self.curData["stid"..idx]
        if target.isOpen and stid>0 then
            local stidDB = DB.getSpecialTalentById(stid)
            Panel.popTouchTip(target,TIP_TOUCH_TALENT_SKILL,stidDB) 
        end
    end
end

function PetPanel:onTouchMoved(target,touch)
    local offsetX=touch:getDelta().x;
    local offsetY=touch:getDelta().y;
    if(math.sqrt(offsetX*offsetX+offsetY*offsetY)>5)then
        self.isMoved=true
    end
    if(self.isMoved)then
        self:unscheduleUpdate()
    end
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function PetPanel:touchIcon(idx)
    local talentExpTable =  Data.pet.talentExpTable[idx]
    local itemid= talentExpTable.itemid
    local num=Data.getItemNum(itemid)
    if(num<talentExpTable.const)then
        return 
    end

    if(self.lastItem~=itemid and self.lastItem)then
        self:checkSendTalentExp()
    end
    if(self:addStoneExp(idx,1))then 
        self.lastItem=itemid
        self.lastStNum= self.lastStNum+1*talentExpTable.const
        Data.reduceItemNum(itemid,talentExpTable.const)
        self:refreshTalentData()
    end
end


function PetPanel:addStoneExp(idx,num)
    local exp= Data.pet.talentExpTable[idx].exp
    gUserInfo.stexp = gUserInfo.stexp+exp*num

    local particle =  cc.ParticleSystemQuad:create("particle/qp_lizi.plist");
    self:getNode("txt_talentexp"):getParent():addChild(particle,100);
    local toWordPos= self:getNode("icon_st"..idx):convertToWorldSpace(cc.p(0,0))
    local toPos =self:getNode("txt_talentexp"):getParent():convertToNodeSpace(toWordPos)
    toPos.x=toPos.x+self:getNode("icon_st"..idx):getContentSize().width/2
    toPos.y=toPos.y+self:getNode("icon_st"..idx):getContentSize().height/2
    particle:setPosition(toPos)
    local posx,posy=self:getNode("txt_talentexp"):getPosition()
    local function moveEnd()
        particle:removeFromParent()

        loadFlaXml("particle")
        self:getNode("talent_barbg"):removeChildByTag(99)
        local effect=gCreateFla("qp_kapai_lizi_b")
        effect:setTag(99)
        gAddCenter(effect,self:getNode("talent_barbg"))
    end
    
    local callFunc=cc.CallFunc:create(moveEnd)
    particle:runAction(
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(0.4,cc.p(posx,posy)),2),
            callFunc
        )
    )

    return true    
end

function PetPanel:checkSendTalentExp()

    if(self.lastItem and self.lastStNum>0 and self.curData)then 
        Net.sendPetStaddexp(self.curData.petid,self.lastItem,self.lastStNum)
        self.lastItem=nil
        self.lastStNum=0
        Data.checkNum()
   end

end

function PetPanel:showSkillSel(status)
    local selbtn={"btn_train","btn_skill","btn_talent"}
    for k,btn in pairs(selbtn) do
        self:getNode(btn.."_bg"):setVisible(false)
    end
    if selbtn[status] then
        self:getNode(selbtn[status].."_bg"):setVisible(true)
    end
end

function PetPanel:onTouchEnded(target)
    Panel.clearTouchTip()
    if self.unlockPeting then
        return;
    end

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_talentrp" then
        local num = 0
        for i=1,8 do
            local lock = false
            local itemid =self.curData["stid"..i]
            if self.curData.stlocks[i]~=nil and self.curData.stlocks[i] == 1 then
                lock = true
            end
            if lock==false and itemid>0 then
                 num = num +1
             end 
        end
        if num<=0 then
            gShowNotice(gGetWords("petWords.plist","lab_no_talentReplace"))
            return
        end
        Panel.popUpVisible(PANEL_PET_TALENT_REPLACE,self.curData.petid)
    elseif target.touchName=="check_selshar" then
        if gUserSharTipTable==nil then
            gUserSharTipTable={}
        end
        if gUserSharTipTable[self.curData.petid]==nil then
           gUserSharTipTable[self.curData.petid]=false
        end
        local function okCallBack()
            self:getNode(target.touchName).isSel = not self:getNode(target.touchName).isSel 
            if self:getNode(target.touchName).isSel==false then
                self:changeTexture("check_selshar", "images/ui_public1/gou_2.png")
            else
                self:changeTexture("check_selshar", "images/ui_public1/gou_1.png")
            end
            gUserSharTipTable[self.curData.petid]=true
        end
        if gUserSharTipTable[self.curData.petid]==true then
            okCallBack()
        else
            gConfirmCancel(gGetWords("petWords.plist","will_use_shard"),okCallBack)
        end
        
        
    elseif string.find(target.touchName,"icon_st") then
        local idx=toint(string.gsub(target.touchName,"icon_st",""))
        local talentExpTable =  Data.pet.talentExpTable[idx]
        local itemid= talentExpTable.itemid
        if( itemid == OPEN_BOX_DIAMOND  )then
            NetErr.isDiamondEnough(talentExpTable.const)
        end
        self:touchIcon(idx)
        self:unscheduleUpdate()
        self:checkSendTalentExp()
    elseif string.find(target.touchName,"icon_skid") then
        local idx=toint(string.gsub(target.touchName,"icon_skid",""))
        if target.isOpen == false then
            if self.curData.level<100 then
                if idx == self.curData.unlockst+1 then
                    gShowNotice(gGetWords("petWords.plist","unlock_"..9))
                else
                    gShowNotice(gGetWords("petWords.plist","unlock_"..idx))
                end
            else
                gShowNotice(gGetWords("petWords.plist","unlock_"..idx))
            end
            --gShowNotice(gGetWords("petWords.plist","unlock_"..idx))
            --gShowRulePanel(SYS_PET_TALENT)
        end
    elseif target.touchName=="btn_locktalent" then
        Panel.popUp(PANNEL_TALENT_LOCK,self)
    elseif target.touchName=="btn_talentBook" then
        Panel.popUp(PANEL_PET_TALENT_BOOK,self.curData)
    elseif target.touchName=="btn_learnTalent" then
        if (self:getNode("check_selshar").isSel and self.curPetShard<self.learnShardNum) then
             local data={}
            data.itemid=self.curData.petid
            Panel.popUpVisible(PANEL_ATLAS_DROP,data)
            return
        end
        local sssTip = false
        for i=1,8 do
             local stid=self.curData["stid"..i]
            if stid>0 then
                local stidDB = DB.getSpecialTalentById(stid)
                if stidDB.quality==sssQuality and self.curData.stlocks[i]~=nil and self.curData.stlocks[i] == 0 then
                    sssTip = true
                    break
                end
            end
        end
        local function okCallBack()
            Net.sendPetStlearn(self.curData.petid,self:getNode("check_selshar").isSel)
        end
        if sssTip==true then
            gConfirmCancel(gGetWords("petWords.plist","learn_talent_sss"),okCallBack,nil,true)
        else
            okCallBack()
        end
    elseif target.touchName=="btn_skill" then
            self:switchStatus(2);
    elseif target.touchName=="btn_train" then
            self:switchStatus(1);
    elseif target.touchName=="btn_talent" then
            self:switchStatus(3);
            self:initTalentData()
    elseif target.touchName=="btn_talent_rule" then
            gShowRulePanel(SYS_PET_TALENT)
    elseif target.touchName=="talent_btn_skill1" then
            gShowNotice(gGetWords("labelWords.plist","will_open"))
    elseif target.touchName=="talent_btn_skill2" then
            --self:selectTalentSkill(target.touchName)
    elseif  target.touchName=="btn_upgrade"then
        if NetErr.petUpgradeSkill(self.upgradeSkillNeedGold,self.upgradeSkillNeedItem) then
            Net.sendPetUpgradeSkill(self.curData.petid,self.curSkillIdx)
        end
    elseif  target.touchName=="btn_evolve"then
        Net.sendPetEvolve(self.curData.petid)
        -- gDispatchEvt(EVENT_ID_PET_EVOLVE);
    elseif  target.touchName=="btn_feed1"then
        if self.leveluping == true and self.peiyangMore then
            return;
        end
        self.showCurExp = self.curData.exp;
        self.showCurLv = self.curData.level;
        Net.sendPetUpgrade(self.curData.petid,0)

        -- self.curData.exp = 100;
        -- self.curData.level = self.curData.level + 1;
        -- local param = {};
        -- for i=1,1 do
        --     local times = math.random(0,4);
        --     -- self.showCurExp = self.showCurExp + Data.pet.needExp[times+1];
        --     table.insert(param,times);
        -- end
        -- gDispatchEvt(EVENT_ID_PET_UPGRADE,param);

    elseif  target.touchName=="btn_feed2"then
        if self.leveluping == true then
            return;
        end
        self.showCurExp = self.curData.exp;
        self.showCurLv = self.curData.level;
        Net.sendPetUpgrade(self.curData.petid,1)

        -- self.curData.exp = 100;
        -- self.curData.level = self.curData.level + 1;
        -- local param = {};
        -- for i=1,10 do
        --     local times = math.random(0,4);
        --     -- self.curData.exp = self.curData.exp + Data.pet.exp[times+1];
        --     table.insert(param,times);
        -- end
        -- gDispatchEvt(EVENT_ID_PET_UPGRADE,param);

    elseif  target.touchName=="btn_unlock"then
       
        local curSoulNum=Data.getPetSoulsNumById(self.curData.petid)
        local soulNum = DB.getPetUnlockSoulNum(self.curData.petid);
        if NetErr.noEnoughLevel(DB.getPetUnlockLevel(self.curData.petid)) and NetErr.isPetSoulEnough(self.curData.petid,curSoulNum,soulNum) then
            Net.sendPetUnlock(self.curData.petid,0)
            UILayer.pauseTouch = true;
        end

        -- local pet={}
        -- pet.petid= self.curData.petid;
        -- pet.grade= 1;
        -- pet.level= 1;
        -- pet.exp=0
        -- pet.skillLevel1=0
        -- pet.skillLevel2=0
        -- pet.skillLevel3=0
        -- pet.skillLevel4=0
        -- pet.skillLevel5=0
        -- Data.updateUserPet(pet);
        -- self.curData = pet;
        -- gDispatchEvt(EVENT_ID_PET_UNLOCK);

    elseif target.touchName == "btn_add_pet_soul" or target.touchName == "btn_shard_get" then
        -- Net.sendPetAtlasInfo()
        -- Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_PET);
        local data={}
        data.itemid=self.curData.petid
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)
    elseif  string.find( target.touchName,"btn_skill_icon")    then
        local idx=toint(string.sub(target.touchName,15,string.len(target.touchName)))
        -- print("idx = "..idx);
        self:selectSkill(idx)
    elseif target.touchName == "btn_rule" then
      gShowRulePanel(SYS_PET);
    elseif target.touchName == "btn_share"then
        Panel.popUpVisible(PANEL_SHARE_PET,self.curData.petid);
    elseif target.touchName == "wakeup_need_icon1" then
        local data={}
        data.itemid=self.curData.petid
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)
    elseif target.touchName == "wakeup_need_icon2" then
        local pet= DB.getPetById(self.curData.petid)
        local data={}
        data.itemid=pet.wakeup_itemid
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)
    elseif target.touchName == "btn_wakeup" then
        Net.sendPetWakeUp(self.curData.petid)
    elseif target.touchName == "btn_wakeup_look" then
        Panel.popUpVisible(PANEL_PET_AWAKEUP_PREVIEW,self.curData.petid)
    elseif target.touchName == "btn_relation" then
        Panel.popUp(PANEL_PET_RELATION)
    elseif target.touchName == "skip_ani_bg" then
        self.isSkipAni = not self.isSkipAni;
        Data.saveBoolConfig("pet_skip_ani",self.isSkipAni);
        self:refreshSkipAni();
    end
end

function PetPanel:refreshSkipAni()
    if(self.isSkipAni)then
        self:changeTexture("skip_ani","images/ui_public1/n-di-gou2.png")
        AttChange.aniSpeed = 2;
    else
        self:changeTexture("skip_ani","images/ui_public1/n-di-gou1.png")
        AttChange.aniSpeed = 1;
    end
end

function PetPanel:getSkillPanelUIState()
    local skillPanelState = skillPanelEvolve
    local needSoulNum=DB.getPetNeedSoulNum(self.curData.petid,self.curData.grade)
    -- 如果grade等于5并且所需soulNum为0，表示未觉醒
    if self.curData.grade == 5 and needSoulNum <= 0 then
        skillPanelState = skillPanelWakeUp
    elseif self.curData.grade > 5 then
        skillPanelState = skillPanelWakedUp
    end

    return skillPanelState
end

function PetPanel:refreshWakeUpPanel()
    local isLimit = false
    local pet= DB.getPetById(self.curData.petid)
    Icon.setIcon(self.curData.petid + ITEM_TYPE_SHARED_PRE,self:getNode("wakeup_need_icon1"),DB.getItemQuality(self.curData.petid))
    local curSoulNum=Data.getPetSoulsNumById(self.curData.petid)
    local needSoulNum = pet.wakeup_soulnum
    self:setLabelString("wakeup_need_txt1", string.format("%d/%d",curSoulNum, needSoulNum))
    
    local curItemNum = Data.getItemNum(pet.wakeup_itemid)
    Icon.setIcon(pet.wakeup_itemid,self:getNode("wakeup_need_icon2"),DB.getItemQuality(pet.wakeup_itemid))
    self:setLabelString("wakeup_need_txt2", string.format("%d/%d",curItemNum, pet.wakeup_itemnum))

    if curSoulNum < needSoulNum or
        curItemNum < pet.wakeup_itemnum or
        self.curData.grade > 5 then --已经觉醒
        isLimit = true
    end

    local bgStar = self:getNode("star_container_ex")
    bgStar:removeAllChildren()
    CardPro:showNewStar(bgStar,self.curData.grade,self.curData.awakeLv)
    self:setTouchEnable("btn_wakeup", not isLimit, isLimit)
    self:getNode("txt_maxwakeup"):setVisible(false)
    self:getNode("btn_wakeup"):setVisible(true)

    if isLimit and self.curData.grade > 5 then
        self:setLabelString("wakeup_need_txt1", curSoulNum.."/Max")
        self:setLabelString("wakeup_need_txt2", curItemNum.."/Max")
        self:getNode("txt_maxwakeup"):setVisible(true)
        self:getNode("btn_wakeup"):setVisible(false)
    end
    
end

return PetPanel