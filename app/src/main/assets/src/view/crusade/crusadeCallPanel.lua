local CrusadeCallPanel=class("CrusadeCallPanel",UILayer)

function CrusadeCallPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true; -- false会关闭父窗体
    self.isMainLayerGoldShow=false
    self.isMainLayerCrusadeShow=true
    self:init("ui/ui_crusade_call.map")

    self.curData=gCrusadeData.callInfo
    self:getNode("scroll").eachLineNum=1 --每行一个item
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self:initItemDatas();

end

-- 窗体弹出时调用（会先调用构造函数）
function CrusadeCallPanel:onPopup()
    self:showFeats()
end

function CrusadeCallPanel:initItemDatas()
    if (crusadeItemDatas == nil) then
        local needEngs = string.split(DB.getClientParam("CRUSADE_CALL_ENERGY"), ";")
        local list = {};
        for key, var in pairs(needEngs) do
            local obj = {};
            obj.need = toint(var);
            table.insert(list, obj);
        end
        crusadeItemDatas = list;
    end
end

function CrusadeCallPanel:getItemDatas()
    local ret={}
    for key, var in pairs(crusadeItemDatas) do
        table.insert(ret,var)
    end
    return ret
end


function  CrusadeCallPanel:events()
    return {EVENT_ID_CRUSADE_CALL}
end



function CrusadeCallPanel:dealEvent(event,param)
    if event==EVENT_ID_CRUSADE_CALL then
        local index=param
        local removeItem = self:getNode("scroll").items[index];
        local actEnd = function ()    


            self.touchEnable=true
            self:sort();

            local function sortFeat(data1,data2)
                local feat1=data1.curData
                local feat2=data2.curData
                if(feat1.sort==feat2.sort)then
                    return feat1.need<feat2.need 
                else
                    return feat1.sort>feat2.sort
                end
            end
            table.sort(self:getNode("scroll").items,sortFeat);
            Data.redpos.bolCrusadeCall=false
            for key, item in pairs(self:getNode("scroll").items) do 
                item:setData(item.curData) 
                if(item.curData.canrec==1 and item.curData.rec~=1)then
                    Data.redpos.bolCrusadeCall=true
                end 
                item.key=key
                gModifyExistNodeAnchorPoint(item,cc.p(0,0)); 
                item:setScale(1)
            end
            self:getNode("scroll"):layout(false);

        end
        self:getNode("scroll"):setCheckChildrenVisible(true);
        --self.touchEnable=false
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
    end
end

-- 窗体关闭时调用
function CrusadeCallPanel:onPopback()
    Scene.clearLazyFunc("callItem")
end


function CrusadeCallPanel:sort()
    self.recNum=0
    local itemDatas = self:getItemDatas();
    for key, var in pairs(itemDatas) do
        if(self.curData.list[key])then
            var.rec=1
        else
            var.rec=0
        end
        var.idx=key-1

        if(self.curData.eng>= var.need)then
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


function CrusadeCallPanel:showFeats()
    Scene.clearLazyFunc("callItem");
    self:getNode("scroll"):clear();
    self:sort();
    self:getNode("panel_onekey"):setVisible(false)
    self:getNode("scroll"):resize(cc.size(600,410))

    local function sortFeat(feat1,feat2)
        if(feat1.sort==feat2.sort)then
            return feat1.need<feat2.need
        else
            return feat1.sort>feat2.sort
        end
    end
    local itemDatas = self:getItemDatas();
    table.sort(itemDatas,sortFeat);


    Data.redpos.bolCrusadeCall=false
    for key, var in pairs(itemDatas) do
        local item=CrusadeCallItem.new()
        item.key=key
        if(key<8)then
            item:setData(var,self.curData.eng)
        else
            item:setLazyData(var,self.curData.eng)
        end
        if(var.canrec==1 and var.rec~=1)then
            Data.redpos.bolCrusadeCall=true
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    end
end




function CrusadeCallPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end


return CrusadeCallPanel