local CrusadeFeatPanel=class("CrusadeFeatPanel",UILayer)

function CrusadeFeatPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true;
    self.isMainLayerGoldShow=false
    self.isMainLayerCrusadeShow=true
    self:init("ui/ui_crusade_feat.map")

    self.curData=gCrusadeData.featRec
    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

end



function CrusadeFeatPanel:onPopup()

    local feats=DB.getCrusadeFeatByLevel(self.curData.level)
    self:showFeats(feats)

end


function  CrusadeFeatPanel:events()
    return {EVENT_ID_CRUSADE_FEAT_REC,EVENT_ID_CRUSADE_FEAT_ALL}
end



function CrusadeFeatPanel:dealEvent(event,param)
    if event==EVENT_ID_CRUSADE_FEAT_REC then
        local index=param
        local removeItem = self:getNode("scroll").items[index];
        local actEnd = function ()    


            self.touchEnable=true
            local feats=DB.getCrusadeFeatByLevel(self.curData.level)
            self:sort(feats)

            local function sortFeat(data1,data2)
                local feat1=data1.curData
                local feat2=data2.curData
                if(feat1.sort==feat2.sort)then
                    return feat1.id<feat2.id 
                else
                    return feat1.sort>feat2.sort
                end
            end
            table.sort(self:getNode("scroll").items,sortFeat);
            Data.redpos.bolCrusadeRec=false
            for key, item in pairs(self:getNode("scroll").items) do 
                item:setData(item.curData) 
                if(item.curData.canrec==1 and item.curData.rec~=1)then
                    Data.redpos.bolCrusadeRec=true
                end 
                item.key=key
                gModifyExistNodeAnchorPoint(item,cc.p(0,0)); 
                item:setScale(1)
            end
            self:getNode("scroll"):layout(false);

        end
        self:getNode("scroll"):setCheckChildrenVisible(true);
        self.touchEnable=false
        local action=cc.Sequence:create(cc.ScaleTo:create(0.25,0),cc.CallFunc:create(actEnd) )
        action:setTag(1)
        removeItem:stopActionByTag(1)
        removeItem:runAction(action);
        local prePos = cc.p(removeItem:getPosition());
        gModifyExistNodeAnchorPoint(removeItem,cc.p(0.5,-0.5));


        local count = table.getn(self:getNode("scroll").items);
        for i = index+1,count do
            local item = self:getNode("scroll").items[i];
            local action=cc.Sequence:create( cc.MoveTo:create(0.2,prePos))
            action:setTag(1)
            item:stopActionByTag(1)
            item:runAction(action);
            prePos = cc.p(item:getPosition());
        end 


    elseif(event==EVENT_ID_CRUSADE_FEAT_ALL)then
        
        local feats=DB.getCrusadeFeatByLevel(self.curData.level)
        self:showFeats(feats)
    end
end

function CrusadeFeatPanel:onPopback()
    Scene.clearLazyFunc("featItem")
end


function CrusadeFeatPanel:sort(feats)
    self.recNum=0
    for key, var in pairs(feats) do
        if(self.curData.list[key])then
            var.rec=1
        else
            var.rec=0
        end

        var.idx=key-1

        if(gCrusadeData.feats>= var.need)then
            var.canrec=1
        else
            var.canrec=0
            var.rec=0
            self.curData.list[key]=false
        end


        if(var.rec==1)then
            var.sort=0
        else
            if(var.canrec==1)then
                var.sort=2
                self.recNum=self.recNum+1
            else
                var.sort=1
            end
        end

    end
end


function CrusadeFeatPanel:showFeats(feats)
    Scene.clearLazyFunc("featItem");
    self:getNode("scroll"):clear()
    self:sort(feats)

    local level=DB.getClientParam("CRUSADE_REC_ALL_LEVEL")
    if(self.recNum>=2 and gUserInfo.level>=level)then
        self:getNode("panel_onekey"):setVisible(true)
        self:getNode("scroll"):resize(cc.size(600,328))
    else
        self:getNode("panel_onekey"):setVisible(false)
        self:getNode("scroll"):resize(cc.size(600,410))
    end

    local function sortFeat(feat1,feat2)
        if(feat1.sort==feat2.sort)then
            return feat1.id<feat2.id
        else
            return feat1.sort>feat2.sort
        end
    end
    table.sort(feats,sortFeat);


    Data.redpos.bolCrusadeRec=false
    for key, var in pairs(feats) do
        local item=CrusadeFeatItem.new()
        item.key=key
        if(key<8)then
            item:setData(var)
        else
            item:setLazyData(var)
        end
        if(var.canrec==1 and var.rec~=1)then
            Data.redpos.bolCrusadeRec=true
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    end
end




function CrusadeFeatPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    
    elseif  target.touchName=="btn_onekey"then
        Net.sendCrusadeFeatOneKey() 
    end
end


return CrusadeFeatPanel