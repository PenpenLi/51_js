local TownAddAttrItem=class("TownAddAttrItem",UILayer)

function TownAddAttrItem:ctor(data,index)

    self:init("ui/ui_tower_sx_item.map");
    self.curData = data;
    self.index = index;
    self:refreshUI();
end

function TownAddAttrItem:refreshData(data)
    self.curData = data;

    local refreshui = function()
        self:refreshUI();
    end

    local act = cc.Sequence:create(
                cc.EaseIn:create(cc.RotateTo:create(0.15,  cc.vec3(0,180,0)),2),
                cc.CallFunc:create(refreshui),
                cc.EaseOut:create( cc.RotateTo:create(0.15,  cc.vec3(0,360,0)),2)
                -- cc.DelayTime:create(0.4),
                -- cc.CallFunc:create(onMoveEnd,var)
            )

    self:getNode("bg1"):runAction(act);
end

function TownAddAttrItem:chooseAni()

    self:getNode("bg1"):runAction(
        cc.Sequence:create(
            cc.ScaleTo:create(0.1,1.1,1.1),
            cc.Repeat:create(
                    cc.Sequence:create(
                    cc.RotateTo:create(0.05,-5),
                    cc.RotateTo:create(0.05,0),
                    cc.RotateTo:create(0.05,5),
                    cc.RotateTo:create(0.05,0)
                    ),3
                ),
            cc.ScaleTo:create(0.1,1,1)
            )
        );

    gSetCascadeOpacityEnabled(self:getNode("left"),true);
    self:getNode("left"):setOpacity(0);
    self:getNode("left"):runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.3),
            cc.Show:create(),
            cc.FadeTo:create(0.2,255),
            cc.FadeTo:create(0.2,0),
            cc.Hide:create()
            )
        );
end

function TownAddAttrItem:refreshUI()

    self:replaceLabelString("txt_value",self.curData.val);
    self:setLabelString("txt_star",self.curData.star);
    local name = gGetWords("cardAttrWords.plist","attr"..self.curData.attr);
    self:setLabelString("txt_att_name",name);
    self:resetLayOut();

    -- self:getNode("left"):setBlendFunc({src=GL_SRC_ALPHA,dst=GL_ONE});
    -- self:getNode("left"):setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE));
    gSetBlendFuncAll( self:getNode("left"),  cc.blendFunc(gl.SRC_ALPHA, gl.ONE))

end

function TownAddAttrItem:onTouchEnded(target)

    if target.touchName == "btn_touch" then
        if(self.onChoose)then
            self.onChoose(self.curData,self.index);
        end
    end

end

return TownAddAttrItem