local LevelUpPanel=class("LevelUpPanel",UILayer)

function LevelUpPanel:ctor(type)
    loadFlaXml("lev_zhanduishengji_zi");
    loadFlaXml("lev_zhanduishengji");

    -- gUserInfo.level = 54;

    self._panelTop = true;
    self:init("ui/ui_levelup.map")
    self:addFullScreenTouchToClose();

    --战力升级
    local aniGroup = FlashAniGroup.new();
    aniGroup:addFlashAni("lev-zhanduishengji",true);
    aniGroup:addFlashAni("lev_b_zhanduishengji",false);
    aniGroup:playDelay(0.1);
    self:replaceNode("flag_title",aniGroup);

    --旗子
    local aniGroup2 = FlashAniGroup.new();
    aniGroup2:addFlashAni("lev_qi_1",true);
    aniGroup2:addFlashAni("lev_qi_2",false);
    aniGroup2:playDelay(0.1);
    -- local playEnd = function()
    --     self:addFullScreenTouchToClose();
    -- end
    -- aniGroup2:setPlayEndCallBack(playEnd);
    self:replaceNode("flag_qizi",aniGroup2);

    if Data.getCurLevel() == 2 then
        gPlayTeachSound("v41.wav",true);
    elseif Data.getCurLevel() == 3 then
        gPlayTeachSound("v39.wav",true);   
    end

    self.initTime = os.time();
    -- self.curFormation=clone(Data.getUserTeam(TEAM_TYPE_ATLAS))
    -- self.curFormation[MAX_TEAM_NUM-1]=nil
    -- for key, cardid  in pairs(self.curFormation) do
    -- 	if(cardid==0)then
    -- 	   self.curFormation[key]=nil
    -- 	end
    -- end
    
    -- local totalNum=table.count(self.curFormation)
    -- local idx=1 
    
    -- self:getNode("panel_card_"..totalNum):setVisible(true) 
    
    -- for key, cardid in pairs(self.curFormation) do
    --     if(cardid~=0)then
    --         local node=self:getNode("card"..totalNum.."_"..idx)
    --         if(node)then 
    --             local result= loadFlaXml("r"..cardid)
    --             if(result)then
    --                 local fla=FlashAni.new()
    --                 if(getRand(0,10)<7 and key~=PET_POS)then 
    --                     fla:playAction("r"..cardid.."_win") 
    --                 else  
    --                     fla:playAction("r"..cardid.."_wait") 
    --                 end
    --                 node:addChild(fla)
    --             end 
    --             idx=idx+1
    --         end 
    --     end

    -- end
    self.isMainLayerGoldShow=false

    self:setLabelString("txt_lv_pre",gUserInfo.level-1)  
    self:setLabelString("txt_lv_next",gUserInfo.level)  
    
    self:setLabelString("txt_card_lv_pre",gUserInfo.level-1)  
    self:setLabelString("txt_card_lv_next",gUserInfo.level)  
    if (TDGAAccount) then
        TDGAAccount:setLevel(gUserInfo.level)
    end
    self:setLabelString("txt_eng_next",gUserInfo.energy)  
    local levelData=DB.getUserExpByLevel(gUserInfo.level-1)
    if(levelData)then 
        self:setLabelString("txt_eng_pre",gUserInfo.energy-levelData.energy)  
    end

    self:setLabelString("txt_max_eng_pre",  DB.getMaxEnergy(gUserInfo.level-1))  
    self:setLabelString("txt_max_eng_next",  DB.getMaxEnergy(gUserInfo.level)) 
    
    -- self:showOtherUnlockInfo();
    self:hideCloseModule();

    gCallFuncDelay(0.5,self,self.showOtherUnlockInfo);
end

function LevelUpPanel:hideCloseModule()
    self:getNode("btn_share"):setVisible(not Guide.isGuiding() and not Module.isClose(SWITCH_SHARE));
end

function LevelUpPanel:showOtherUnlockInfo()

    local count = table.getn(Unlock.stack);
    if(gUserInfo.level >= 28 and count <= 0)then

        Guide.clearGuide();
        
        local showData = {};
        for key,data in pairs(Data.levelup) do
            if(Unlock.isUnlock(data.unlocktype,false) and toint(data.level) >= gUserInfo.level)then
                local isAdd = true;
                if(data.unlocktype == SYS_PET)then
                    local curSoulNum=Data.getPetSoulsNumById(data.petid);
                    if(curSoulNum<data.unlocksoul)then
                        isAdd = false;
                    end
                end
                if(isAdd)then
                    table.insert(showData,data);
                    if #showData >= 3 then
                        break;
                    end
                end
            end
        end

        local sortlevel = function(d1,d2)
            return toint(d1.level) > toint(d2.level);
        end
        table.sort( showData, sortlevel );
        -- print_lua_table(showData);

        if( #showData > 0)then

            local bg = self:getNode("layout");
            for key,data in pairs(showData) do
                local item = LevelUpItem.new(data);
                item.onGoto = function(unlocktype,idx)
                    self:onGoto(unlocktype,idx);
                end
                bg:addNode(item);

                if(data.unlocktype == SYS_PET and toint(data.level) == gUserInfo.level)then
                    -- print("sys pet unlock");
                    Unlock.system.pet.guideForLevelUp();
                end
            end
            bg:layout();

            local time = 0.2;
            local dis = 230;
            bg:setCascadeOpacityEnabled(true);
            bg:setOpacity(0);
            bg:runAction(
                cc.Spawn:create(
                    cc.MoveBy:create(time,cc.p(dis+60,0)),
                    cc.FadeTo:create(time,255)
                ));

            self:getNode("levelup_node"):runAction(
                    cc.MoveBy:create(time,cc.p(-dis+60,0))
                );
        end

    end

end

function LevelUpPanel:onGoto(unlocktype,idx)
    Panel.popBack(self:getTag());
    if(unlocktype == SYS_XUNXIAN)then
        -- gEnterFromLevelup = true;
        Net.sendSpiritInit(0)
    elseif(unlocktype == SYS_ACT_GOLD or unlocktype == SYS_ACT_EXP or unlocktype == SYS_ACT_PETSOUL or unlocktype == SYS_ACT_EQUSOUL)then
        gEnterFromLevelup = true;
        local showIndex = nil;
        if(unlocktype == SYS_ACT_EQUSOUL)then
            showIndex = 3;
        end
        Panel.popUp(PANEL_ACTIVITY,showIndex);
    elseif(unlocktype == SYS_PET)then
        -- gEnterFromLevelup = true;
        Panel.popUp(PANEL_PET,idx+1);         
    end
end

function LevelUpPanel:onTouchEnded(target)

    if os.time() - self.initTime < 2 then
        return;
    end

    if(target.touchName == "btn_share")then
        Panel.popUpVisible(PANEL_SHARE_LEVELUP,{formationType = TEAM_TYPE_ATLAS,shareType = SHARE_TYPE_LEVEL});
    elseif target.touchName=="btn_close" or target.touchName=="level_up_bg" or target.touchName == "full_close" then
        Panel.popBack(self:getTag())        
        -- Unlock.checkUnlock();
        -- Unlock.show();
        -- self:setNodeAppear("test");
    -- elseif  target.touchName=="level_up_bg"then
    --     Panel.popBack(self:getTag())
    end

end

return LevelUpPanel