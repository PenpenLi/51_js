local SigninItem=class("SigninItem",UILayer)

function SigninItem:ctor()
    -- self:init("ui/ui_signin_item.map")
    -- self:getNode("btn").__touchend=true
    self:setContentSize(cc.size(117,136));
end

function SigninItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_signin_item.map")

end

function SigninItem:onTouchBegan(target,touch)
    if(self.touch==false)then
        return
    end

    local tip= Panel.popTouchTip(self,TIP_TOUCH_EQUIP_ITEM,self.curData.itemid)
    -- tip:setPositionY(tip:getPositionY()+tip:getContentSize().height)
    self.beganPos = touch:getLocation();
end

function SigninItem:onTouchMoved(target,touch)
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function SigninItem:onTouchEnded(target) 
    self:onSignin();
    Panel.clearTouchTip();
end

function SigninItem:onSignin()
    local index = self.index;
    if self.bCanSign then
        Net.sendSignSign();
    end
end

function SigninItem:setLazyData(data,index)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    self.index = index;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"signinItem")
end
function SigninItem:setLazyDataCalled()
    self:setData(self.curData,self.index);
end

function SigninItem:setData(data,index)
    self:initPanel();
    self.curData=data
    self.index = index;

    Icon.setIcon( data.itemid,self:getNode("icon"),DB.getItemQuality(data.itemid))

    self:getNode("layer_double"):setVisible(false);
    if data.vip > 0 then
        self:getNode("layer_double"):setVisible(true);
        self:replaceLabelString("txt_vip",data.vip);
    end

    self:setLabelString("txt_num",data.num);

    self:refresh();

    -- if(self.curData.itemid == OPEN_BOX_GOLD or self.curData.itemid == OPEN_BOX_DIAMOND)then
    --     self.touch=false
    -- end

end

function SigninItem:refresh()
    local index = self.index;
    local data = self.curData;
    --
    self.bCanSign = false;
    local count = Data.signInfo.count;
    local bSigned = Data.signInfo.bolSign;
    if (count == index and not bSigned) then
        --未签到动作
        self.bCanSign = true;

        
        local fla=gCreateFla("ui_kuang_xiaoguo",1);
        fla:setTag(100);
        gAddChildInCenterPos(self:getNode("icon"),fla);

    else
        --今天已经签到
        self:getNode("icon"):removeChildByTag(100);

    end

    self:getNode("layer_signIn"):setVisible(false);
    if(index < Data.signInfo.count) then
        self:getNode("layer_signIn"):setVisible(true);

    end    
end



return SigninItem