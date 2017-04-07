local UnlockPanel=class("UnlockPanel",UILayer)

function UnlockPanel:ctor(unlockSys)
    loadFlaXml("ui_newopen");

    -- self.appearType = 1;
    self:init("ui/ui_unlock.map");
    self._panelTop=true;
    if(unlockSys~=SYS_PET)then
        self.ignoreGuide = true;
    end
    self.unlockSys = unlockSys;
    -- self:changeTexture("icon","images/ui_unlock/unlock"..unlockSys..".png");
    self:setLabelString("tip",gGetWords("unlockWords.plist",tostring(unlockSys)));
    -- self:changeTexture("title","images/ui_word/unlock"..unlockSys..".png");

    --背景动画
    local replaceBoneData = {};
    table.insert(replaceBoneData,{boneTable={"word"},nodePath="images/ui_word/unlock"..unlockSys..".png"});
    table.insert(replaceBoneData,{boneTable={"icon","icon"},nodePath="images/ui_unlock/unlock"..unlockSys..".png"});
    local aniGroup = FlashAniGroup.new();
    aniGroup:addFlashAni("ui_newopen_a",true,0,replaceBoneData);
    aniGroup:addFlashAni("ui_newopen_b",false,1,replaceBoneData);
    aniGroup:play();
    self:replaceNode("flag_act",aniGroup);

    gPlayTeachSound("v42.wav",true);
    Unlock.preGuide(self.unlockSys);

    self:setOpacityEnabled(true);

    self:getNode("btn_go"):runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.Repeat:create(
                    cc.Sequence:create(
                        cc.ScaleTo:create(0.1,0.9),
                        cc.ScaleTo:create(0.1,1.0)
                    ),3
                ),
                cc.DelayTime:create(1)
            )
        )
    )
end

-- function  UnlockPanel:events()
--     return {EVENT_ID_GIFT_BAG_GOT}
-- end


-- function UnlockPanel:dealEvent(event,param)
--     if(event==EVENT_ID_GIFT_BAG_GOT)then
--         self:initGift()
--     end
-- end


function UnlockPanel:onTouchEnded(target)

    print("target.touchName = " .. target.touchName);

    local callback = function(func)
        if(gIsAndroid())then
            if(func)then
                func();
            end
        else
            local ani = gCreateFla("ui_newopen_c",0,func);
            print("self.unlockSys is:",self.unlockSys)
            ani:replaceBone({"word"},"images/ui_word/unlock"..self.unlockSys..".png");
            ani:replaceBone({"icon","icon"},"images/ui_unlock/unlock"..self.unlockSys..".png");
            self:replaceNode("flag_act",ani);
            self:setTouchEnable("bg",false,false);
            self:setTouchEnable("btn_go",false,false);
            self:setTouchEnable("btn_cancel",false,false);

            self:setOpacityEnabled(true);
        end
    end

    if target.touchName == "btn_go"then
        function playEnd()
            Unlock.guide(self.unlockSys);
            if(self.unlockSys == SYS_ELITE_ATLAS or self.unlockSys == SYS_SWEEP_ONE)then
                Panel.popBack(self:getTag());
            else
                if gMainLayer then
                    Panel.popBackAll();
                else
                    Panel.clearRepopup()
                    Scene.enterMainScene(); 
                end
                Unlock.initEnter();
            end
        end
        callback(playEnd);
    elseif target.touchName == "btn_cancel"then
        function playEnd()
            Panel.popBack(self:getTag());
        end
        callback(playEnd);
    end

    -- if  target.touchName=="bg"then
    --     function playEnd()
    --         Unlock.guide(self.unlockSys);
    --         Panel.popBack(self:getTag());
    --     end
    --     local ani = gCreateFla("ui_newopen_c",0,playEnd);
    --     print("self.unlockSys is:",self.unlockSys)
    --     ani:replaceBone({"word"},"images/ui_word/unlock"..self.unlockSys..".png");
    --     ani:replaceBone({"icon","icon"},"images/ui_unlock/unlock"..self.unlockSys..".png");
    --     self:replaceNode("flag_act",ani);
    --     self:setTouchEnable("bg",false,false);
    -- end
end

return UnlockPanel