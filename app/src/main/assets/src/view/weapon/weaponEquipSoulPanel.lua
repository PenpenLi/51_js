local WeaponEquipSoulPanel=class("WeaponEquipSoulPanel",UILayer)

local NumsConf={0,5,10}

function WeaponEquipSoulPanel:ctor(type,data)

    self:init("ui/ui_weapon_equip_soul.map")
    self:getNode("scroll").eachLineNum=5
    self.isMainLayerMenuShow = false;
    self:getNode("scroll").offsetX=3
    self:getNode("scroll").offsetY=0
    self:getNode("scroll").padding=5
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:initBag()
    self:getNode("scroll_content"):layout();
    
    for key, var in pairs(NumsConf) do
        self:replaceRtfString("txt_remain_num"..key,var)
    end

    local function updateNum()
        if(self.isDirty==false)then
            return
        end
        self.isDirty=false

        local totalNum=0
        for key, item in pairs(self:getNode("scroll").items) do
            totalNum=totalNum+item.addRaise*item.curSelectNum
        end
        self:setLabelString("txt_num",math.floor(totalNum))
        if(totalNum==0)then
            self:setTouchEnable("btn_merge",false,true)
        else
            self:setTouchEnable("btn_merge",true,false)
        end
    end
    self:scheduleUpdateWithPriorityLua(updateNum,1)
    Icon.setIcon(OPEN_BOX_EQUIP_SOUL,self:getNode("icon"))
    self:resetColor()
    self:selectNum(1)
end

function  WeaponEquipSoulPanel:resetColor()
    for i=1, 5 do
        self:getNode("icon_choose_bg_c"..i ).isSelect=false
        self:changeTexture("icon_choose_bg_c"..i ,"images/ui_public1/n-di-gou1.png")
    end
end

function  WeaponEquipSoulPanel:selectAllColor(select)
    for i=1, 5 do
        self:getNode("icon_choose_bg_c"..i ).isSelect=select
        if(select)then
            self:changeTexture("icon_choose_bg_c"..i ,"images/ui_public1/n-di-gou2.png")
        else
            self:changeTexture("icon_choose_bg_c"..i ,"images/ui_public1/n-di-gou1.png")
        end
    end
end

function  WeaponEquipSoulPanel:selectColor(i)

    if(i==1)then
        if(self:getNode("icon_choose_bg_c"..i ).isSelect)then
            self:getNode("icon_choose_bg_c"..i ).isSelect=false
            self:selectAllColor(false)
        else

            self:getNode("icon_choose_bg_c"..i ).isSelect=true
            self:selectAllColor(true)
        end
    else
        if(self:getNode("icon_choose_bg_c"..i ).isSelect)then
            self:getNode("icon_choose_bg_c"..i ).isSelect=false
            self:changeTexture("icon_choose_bg_c"..i ,"images/ui_public1/n-di-gou1.png")
        else

            self:getNode("icon_choose_bg_c"..i ).isSelect=true
            self:changeTexture("icon_choose_bg_c"..i ,"images/ui_public1/n-di-gou2.png")
        end
    end
end


function  WeaponEquipSoulPanel:selectNum(i)
    self:resetNum()
    self:getNode("icon_choose_bg_n"..i ).isSelect=true
    self:changeTexture("icon_choose_bg_n"..i ,"images/ui_public1/n-di-gou2.png")

    self:replaceRtfString("txt_remain_num",NumsConf[i])
end

function  WeaponEquipSoulPanel:resetNum()
    for i=1, 3 do
        self:getNode("icon_choose_bg_n"..i ).isSelect=false
        self:changeTexture("icon_choose_bg_n"..i ,"images/ui_public1/n-di-gou1.png")
    end
end

function  WeaponEquipSoulPanel:getSelectColors()
    local rets={}
    for i=2, 5 do
        if(self:getNode("icon_choose_bg_c"..i ).isSelect)then
            rets[i]=true
        end
    end
    return rets
end




function  WeaponEquipSoulPanel:getReaminNum()
    local idx=0
    for i=1, 3 do
        if(self:getNode("icon_choose_bg_n"..i ).isSelect)then
            idx=i
        end
    end 
    return NumsConf[idx]
end


function  WeaponEquipSoulPanel:events()
    return {EVENT_ID_REFRESH_EQUIP_SOUL}
end


function WeaponEquipSoulPanel:dealEvent(event,data)
    if(event==EVENT_ID_REFRESH_EQUIP_SOUL)then
        self:initBag(true)
        self.isDirty=true

        self:getNode("effect"):setVisible(true)
        local function playEnd()
            self:getNode("effect"):setVisible(false)
        end
        self:getNode("effect").curAction=""
        self:getNode("effect"):playAction("ui_weapon_b",playEnd)

    end
end



function WeaponEquipSoulPanel:reset()
    local num=self:getReaminNum()
    local colors=self:getSelectColors()

    for key, item in pairs(self:getNode("scroll").items) do 
        if(colors[item.qua])then
            item:setRemainNum(num)
        else
            item:setUnSelect()
        end
    end

    self.isDirty=true
end

function WeaponEquipSoulPanel:onPopback()
    Scene.clearLazyFunc("equipSoul")
end

function WeaponEquipSoulPanel:initBag(moveup)

    Scene.clearLazyFunc("equipSoul")
    self:getNode("scroll"):clear()
    self.curShowItems={}

    local drawNum=20

    gPreSortEquipItem(gUserShared,5)
    gPreSortEquipItem(gUserEquipItems,1)
    for key, var in pairs(gUserShared) do
        table.insert(self.curShowItems,var)
    end

    for key, var in pairs(gUserEquipItems) do
        table.insert(self.curShowItems,var)
    end
    table.sort(self.curShowItems,gSortEquipItem2) --排序

    for key, var in pairs(self.curShowItems) do
        local item=WeaponEquipSoulItem.new()
        item.idx=key
        if(drawNum>0)then
            drawNum=drawNum-1
            item:setData(var, var.flag)
        else
            item:setLazyData(var, var.flag)
        end

        item.selectItemCallback=function ()
            self.isDirty=true
            self:getNode("time_panel"):setVisible(false)
        end
        self:getNode("scroll"):addItem(item)
    end



    self:getNode("scroll"):layout(moveup)
end



function WeaponEquipSoulPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif target.touchName=="btn_merge"then
        local items={}
        for key, item in pairs(self:getNode("scroll").items) do
            if(item.curSelectNum>0)then
                table.insert(items,{itemid=item.curSelectItemid,num=item.curSelectNum})
            end
        end
        if(table.getn(items)~=0)then
            Net.sendEquMelt(items)
        end
        self:getNode("time_panel"):setVisible(false)
    elseif target.touchName=="btn_raise_time"then
        if(self:getNode("time_panel"):isVisible())then
            self:getNode("time_panel"):setVisible(false)
        else
            self:getNode("time_panel"):setVisible(true)
        end
    
    elseif target.touchName and string.find(target.touchName,"icon_touch_c")then
        local idx=toint(string.gsub(target.touchName,"icon_touch_c",""))
        self:selectColor(idx)
        self:getNode("time_panel"):setVisible(false)
        self:reset()
    elseif  target.touchName and string.find(target.touchName,"icon_touch_n")then
        local idx=toint(string.gsub(target.touchName,"icon_touch_n",""))
        self:selectNum(idx)
        self:getNode("time_panel"):setVisible(false)
        self:reset()
    end
end

return WeaponEquipSoulPanel