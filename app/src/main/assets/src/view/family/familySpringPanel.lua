
local FamilySpringPanel=class("FamilySpringPanel",UILayer)

function FamilySpringPanel:ctor(type)
    -- self.appearType = 1;
    -- self.isMainLayerMenuShow = false;
    -- loadFlaXml("ui_family_xianquan");
    self:init("ui/ui_family_xianquan.map")
    self.isBlackBgVisible=false  

    self.pCallRoleBg = self:getNode("call_role_bg");
    self.pDrinkRoleBg = self:getNode("call_drink_bg");
    self.pTitleBg = self:getNode("title_bg");
    self.pTitleBg:setVisible(false);
    self.pLayerDiaBg = self:getNode("layer_dia_bg");

    -- self.pBtnLabCall = tolua.cast(self:getNodeByVar("btn_lab_call"),"CCLabelTTF");
    if (gFamilySpringInfo.callUid>0) then
        if (gFamilySpringInfo.callUid ~= Data.getCurUserId()) then
            local str = gGetWords("familyWords.plist", "4");
            self:setLabelString("btn_lab_call",str);
        end
    end

    self:setLabelString("lab_dia",""..gFamilySpringInfo.callDiamond);

    -- for i=1,4 do
    --     self.pQizi = self:getNode("qizi"..i);
    --     self.pQizi:setScaleX(-1);
    -- end

    --动画
    -- self.pSpringAct = self:getNodeByVar("act_bg");
    self.iStatus = (gFamilySpringInfo.callUid>0 and 2 or 1);
    self:createSpringAct(self.iStatus);

    self:refreshUi(false);
    self:setLabelString("txt_fexp1",Data.family.springCallFExp);
    self:setLabelString("txt_fexp2",Data.family.springDrinkFExp);
    self:resetLayOut();
end

function  FamilySpringPanel:events()
    return {EVENT_ID_FAMILY_SPRING_CALL,
            EVENT_ID_FAMILY_SPRING_DRINK}
end

function FamilySpringPanel:dealEvent(event,param)
	if(event == EVENT_ID_FAMILY_SPRING_CALL) then
        self.iStatus = 2;
        self:createSpringAct(self.iStatus);
        self:refreshUi(true)
    elseif (event == EVENT_ID_FAMILY_SPRING_DRINK) then
        gCreateRoleFla(Data.convertToIcon(Data.getCurIcon()),self.pDrinkRoleBg,1,nil,nil,Data.getCurWeapon(),Data.getCurAwake(),Data.getCurHalo());
        self:refreshUi(true);
	end
end

function FamilySpringPanel:createSpringAct(index)
    -- body
    -- self.pSpringAct:removeAllChildrenWithCleanup(true);
    -- local pAni = ActionSprite:spriteWithActionFile("ui-yinquan"..index..".act");
    -- if (index == 2) then
    --     pAni:setNextAction("ui-yinquan3.act",2);
    --     pAni:playAni(3,1);
    -- else
    --     pAni:playAni(2);
    -- end
    -- addChildByAnchorPos(self.pSpringAct, pAni, ccp(0.5, 0.5));
-- print("index="..index)
    loadFlaXml("ui_family_xianquan")
    local upStarBg = FlashAni.new()
    upStarBg:playAction("ui_family_xianquan_bg_"..index, nil, nil, 0)
    self:replaceNode("act_bg",upStarBg)

end

function FamilySpringPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();
    elseif target.touchName == "btn_call" then
        self:onCall();
    elseif target.touchName == "btn_rule" then
        self:onHelp();
    end
end

function FamilySpringPanel:onHelp()
    gShowRulePanel(SYS_FAMILY_SPRING); 
end

function FamilySpringPanel:onCall()
    print("gFamilySpringInfo.callDiamond="..gFamilySpringInfo.callDiamond)
    if (gFamilySpringInfo.callUid<=0) then --召唤
        local callback = function()
            if (NetErr.isDiamondEnough(gFamilySpringInfo.callDiamond) == false) then
               return;
            end
            Net.sendFamilyCallSpring();
            if (TDGAItem) then
                gLogPurchase("family_call_spring",1,gFamilySpringInfo.callDiamond)
            end
        end
        local addDouble = gFamilyInfo.bolDoubleRe and 2 or 1
        gConfirmCancel(gGetWords("familyWords.plist","29",gFamilySpringInfo.callDiamond,addDouble*7000,addDouble*200),callback)
    else
        if (gFamilySpringInfo.isdrink==false) then
            Net.sendFamilyDrinkSpring();
        else
            --提示已经饮过泉水
            local sWord = gGetWords("familyWords.plist","spring_drink_ok");
            gShowNotice(sWord)
        end
    end
end

function FamilySpringPanel:refreshUi(showAct)
    if (gFamilySpringInfo.callUid>0) then
        self.pTitleBg:setVisible(true);
        gCreateRoleFla(Data.convertToIcon(gFamilySpringInfo.callIcon),self.pCallRoleBg,1,nil,nil,gFamilySpringInfo.show.wlv,gFamilySpringInfo.show.wkn,gFamilySpringInfo.show.halo);
        -- print("gFamilySpringInfo.callUid="..gFamilySpringInfo.callUid)
        -- print("Data.getCurUserId()="..Data.getCurUserId())
        local strName = gFamilySpringInfo.callName;
        self:setLabelString("lab_name",strName);
        self.pLayerDiaBg:setVisible(false);--隐藏钻石
        if (gFamilySpringInfo.callUid == Data.getCurUserId()) then
            self:setTouchEnableGray("btn_call",false);
            self.pLayerDiaBg:setVisible(true);--显示钻石
        end
        -- gCreateRoleFla(Data.convertToIcon(Data.getCurIcon()),self.pDrinkRoleBg,1);
    end
    --人数
    self:setDrinkIng();
end

function FamilySpringPanel:setDrinkIng()
    -- Data.getCurFamilyLevel()
    -- DB.getFamilySplv_maxnum
    local lv=Data.getCurFamilyLevel();
    local maxNum = DB.getFamilySplv_maxnum(lv);--Data.getCurFamilyLevel(lv);
    print("lv="..lv.."maxNum="..maxNum.." gFamilySpringInfo.drink="..gFamilySpringInfo.drink);
    self:setLabelString("lab_num",gFamilySpringInfo.drink.."/"..maxNum);
    if (gFamilySpringInfo.drink>=maxNum) then
        self:setTouchEnableGray("btn_call",false);
    end
end

return FamilySpringPanel