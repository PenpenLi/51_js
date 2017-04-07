
local FamilyWarMatchDetailPanel=class("FamilyWarMatchDetailPanel",UILayer)

function FamilyWarMatchDetailPanel:ctor(list)
    self:init("ui/ui_family_war_match_detail.map")
    self.list=list
    self.hideMainLayerInfo=true
    self.isWindow = true;
    local function sort(item1,item2)
        return item1.idx*100+item1.pos<item2.idx*100+item2.pos
    end
    local names1={}
    local names2={} 
    table.sort(list,sort)

    for key, var in pairs(list) do
        self:parseName(var,1,names1)
        self:parseName(var,2,names2)

    end
    self.names1=names1
    self.names2=names2

    local var=  Net.sendFamilyMatchDetailParam


    self:setLabelString("txt_name1",var.name1.."(Lv."..var.lv1..")")
    self:setLabelString("txt_name2",var.name2.."(Lv."..var.lv2..")")
    self:setLabelString("txt_name_21",var.name1)
    self:setLabelString("txt_name_22",var.name2)
    self:replaceLabelString("txt_lv2_1",var.lv1)
    self:replaceLabelString("txt_lv2_2",var.lv2)
    Icon.setFamilyIcon(self:getNode("icon2_1"),var.icon1)
    Icon.setFamilyIcon(self:getNode("icon2_2"),var.icon2)
    Icon.setFamilyIcon(self:getNode("icon1_1"),var.icon1)
    Icon.setFamilyIcon(self:getNode("icon1_2"),var.icon2)
    self:resetLayOut()


    if(FamilyWarMatchDetailPanel.isInRecord)then
        self:selectBtn("btn_record")
        self:initRecord()
        FamilyWarMatchDetailPanel.isInRecord=nil
    else 
        self:selectBtn("btn_realtime")
        self:initRealTime()
    end
end
function FamilyWarMatchDetailPanel:parseName(var,pos,names)
    if(var["name"..pos]~="")then
        local hasSame=false
        for key, name in pairs(names) do
            if(var["name"..pos]==name.name)then
                hasSame=true
            end
        end
        if(hasSame==false)then
            table.insert(names,{name=var["name"..pos],icon=var["icon"..pos]})
        end
 
    end
end
function FamilyWarMatchDetailPanel:clearWin()

    self:getNode("effect_container1"):removeAllChildren()
    self:getNode("effect_container2"):removeAllChildren()
end

function FamilyWarMatchDetailPanel:showWin()


    loadFlaXml("ui_battle_win")
    local coverEffect=gCreateFla( "ui_tuanzhan_win",-1)

    if(self:getAliveNum(1)>self:getAliveNum(2))then
        self:getNode("effect_container1"):addChild(coverEffect)
    else

        self:getNode("effect_container2"):addChild(coverEffect)
    end
end

function FamilyWarMatchDetailPanel:getAliveNum(pos)
    local num=0
    for key, item in pairs(self:getNode("scroll"..pos).items) do
        if(item.isDie==false)then
            num=num+1
        end
    end
    return num
end

function FamilyWarMatchDetailPanel:getAliveKey(pos,dir)
    local ret=0
    local count=table.count(self:getNode("scroll"..pos).items)
    if(dir)then
        for i=1, count do
            if( self:getNode("scroll"..pos).items[count-i+1].isDie==false)then
                return  count-i+1
            end
        end
        return 1
    else

        for key, item in pairs(self:getNode("scroll"..pos).items) do
            if(item.isDie==false)then
                return ret
            end
        end
        return count
    end
end

function FamilyWarMatchDetailPanel:refreshName(moveTime)

    self:setLabelString("txt_num1",self:getAliveNum(1))
    self:setLabelString("txt_num2",self:getAliveNum(2))

    local idx1=self:getAliveKey(1,true)-3
    local idx2=self:getAliveKey(2,false)
    --self:getNode("scroll1"):moveItemByIndex(idx1,moveTime)
    --self:getNode("scroll2"):moveItemByIndex(idx2,moveTime)
end
function FamilyWarMatchDetailPanel:getItemByName(name)
    for i=1, 3 do
        if(self:getNode("pos"..i).item.curName==name)then
            return self:getNode("pos"..i).item
        end
    end
    return nil

end
function FamilyWarMatchDetailPanel:playWar()
    self:getNode("btn_play"):setVisible(false)

    local actions={}

    local function _initRound(item,round)
        for key, var in pairs(round) do
            self:getNode("pos"..var.pos).item:playRound(var,var.roundNum)
        end
    end

    local function _initRoundRole(item,round)
        for i=1, 3 do
            self:getNode("pos"..i):setVisible(false)
        end
        self:initRoundRole(round,true)
        self:resetLayOut()
    end


    local function _dieRole(item,data)
        local idx=data.key
        local var=data.var
        local item=nil
        if(var.win)then
            item= self:getItemByName(2,var.name2)
        else
            item= self:getItemByName(1,var.name1)
        end
        if(item)then
            item:showDie()
        end
    end

    local function _initRoundEnd(item,data)
        self:refreshName(0.5)
    end

    for key, round in pairs(self.rounds) do
        local firstDelay=0.7
        if(round[1] and round[1].idx==1)then
            firstDelay=0
        end
        local temp={}
        for key, var in pairs(round) do
            var.roundNum=var.rcount
            table.insert(temp,cc.Sequence:create(cc.DelayTime:create(0.5*var.roundNum),cc.CallFunc:create(_dieRole,{key=key,var=var} )))
        end
        table.insert(actions,cc.CallFunc:create(_initRoundRole,round ))
        table.insert(actions,cc.DelayTime:create(firstDelay))
        table.insert(actions,cc.CallFunc:create(_initRound,round ))
        table.insert(actions,cc.Spawn:create(temp))
        table.insert(actions,cc.DelayTime:create(0.6))
        table.insert(actions,cc.CallFunc:create(_initRoundEnd,round ))
    end

    local function _allEnd()
        self:showWin()
    end
    table.insert(actions,cc.CallFunc:create(_allEnd ))
    local action=cc.Sequence:create(actions)
    action:setTag(1)
    self:getNode("btn_play"):runAction(action)

end

function FamilyWarMatchDetailPanel:pauseWar()
    self:getNode("btn_play"):setVisible(true)

end

function FamilyWarMatchDetailPanel:initRoundRole(round,move)

    if(round)then
        for key, var in pairs(round) do
            local item=self:getNode("pos"..var.pos).item
            if(item)then
                local key=item.curKey
                self:getNode("pos"..var.pos):setVisible(true)
                self:getNode("pos"..var.pos).item:setData(var,move)

                if(round[1] and round[1].idx==1)then
                    self:setLabelString("txt_name"..var.pos.."_1",var.name1)
                    self:setLabelString("txt_name"..var.pos.."_2",var.name2)
                    self:setBlood(var.pos,2,var)
                    self:setBlood(var.pos,1,var)
                else
                    self:changeName(var.pos,1, var.name1,var)
                    self:changeName(var.pos,2, var.name2,var)
                end

            end
        end
    end
    self:resetLayOut()
end

function FamilyWarMatchDetailPanel:setBloodInit(key,side,var )
    local hpinit=var["hpinit"..side] 
    local hpall=var["hpall"..side] 
    self:setBarPer("bar_hp"..key.."_"..side,hpinit/hpall,side==2)

end
function FamilyWarMatchDetailPanel:setBlood(key,side,var )
    local hpinit=var["hpinit"..side]
    local hpend=var["hpend"..side] 
    local hpall=var["hpall"..side] 
    self:getNode("bar_hp"..key.."_"..side).oldPerValue=hpinit/ hpall
    self:setBarPerAction("bar_hp"..key.."_"..side,hpinit/hpall,hpend/hpall,nil,side==2,(var.rcount*0.5) *60)

end
function FamilyWarMatchDetailPanel:changeName(key,side,name,var )

    local function onMoveEnd(item,var)
        self:setBlood(key,side,var)
    end
    self:setBloodInit(key,side,var)

    local function onMoveHalf()
        self:setLabelString("txt_name"..key.."_"..side,name)
    end

    if( self:getNode("txt_name"..key.."_"..side).lastName~=name)then
        self:getNode("txt_name"..key.."_"..side).lastName=name
        self:getNode("txt_name"..key.."_"..side):getParent():runAction(
            cc.Sequence:create(
                cc.EaseIn:create(cc.RotateTo:create(0.15,  cc.vec3(180,0,0)),2),
                cc.CallFunc:create(onMoveHalf,var),
                cc.EaseOut:create( cc.RotateTo:create(0.15,  cc.vec3(360,0,0)),2),
                cc.DelayTime:create(0.4),
                cc.CallFunc:create(onMoveEnd,var)
            )
        )
    else

        self:getNode("txt_name"..key.."_"..side):getParent():runAction(
            cc.Sequence:create(
                cc.DelayTime:create(0.7),
                cc.CallFunc:create(onMoveEnd,var)
            )
        )
    end
end

function FamilyWarMatchDetailPanel:initFirstRound(round)
    self:getNode("btn_play"):setVisible(true)
    self:getNode("btn_play"):stopActionByTag(1)
    for i=1, 3 do
        self:getNode("pos"..i):setVisible(false)
        self:getNode("container"..i):removeAllChildren()
        local item=FamilyWarPlayBigItem.new()
        self:getNode("pos"..i).item=item
        item.curKey=i
        self:getNode("container"..i):addChild(item)
    end

    if(round)then
        for key, var in pairs(round) do
            self:getNode("pos"..var.pos):setVisible(true)
            self:getNode("pos"..var.pos).item:setData(var,false)
            self:setLabelString("txt_name"..var.pos.."_1",var.name1)
            self:setLabelString("txt_name"..var.pos.."_2",var.name2)
        end
    end
    self:resetLayOut()

end

function FamilyWarMatchDetailPanel:initRealTime()

    self:initNames(self.names1,self.names2)
    self:refreshName(0)
    local rounds={}
    for key, var in pairs(self.list) do
        if(var.vid~=0)then
            if(rounds[var.idx]==nil)then
                rounds[var.idx]={}
            end
            table.insert(rounds[var.idx],var)
        end
    end
    self.rounds=rounds
    local firstRound= rounds[1]
    self:initFirstRound(firstRound)
end

function FamilyWarMatchDetailPanel:getItemByName(pos,name)

    for key, item in pairs(self:getNode("scroll"..pos).items) do
        if(item.curData and item.curData.name==name)then
            return item
        end
    end
    return nil
end

function FamilyWarMatchDetailPanel:initNames(names1,names2)

    self:getNode("scroll1"):clear()
    self:getNode("scroll1").eachLineNum=6
    self:getNode("scroll1").itemScale=0.4
    self:getNode("scroll2"):clear()
    self:getNode("scroll2").eachLineNum=6
    self:getNode("scroll2").itemScale=0.4
    --[[ for i=  1,table.getn(names1) do
    local data=names1[table.getn(names1)-i+1]
    local item=FamilyWarPlaySmallItem.new()
    item:setData(data)
    self:getNode("scroll1"):addItem(item)
    end
    self:getNode("scroll1"):layout()
    self:getNode("scroll1"):setCheckChildrenVisibleEnable(false)
    ]]
    local maxNum=24
    local idx=0
    for key, data in pairs(names1) do
        local item=FamilyWarPlaySmallItem.new()
        item:setData(data)
        self:getNode("scroll1"):addItem(item)
        idx=idx+1
    end

    for i=idx, maxNum-1 do
        local item=self:createIndex(i+1)
        self:getNode("scroll1"):addItem(item);
    end
    self:getNode("scroll1"):layout()

    idx=0
    for key, data in pairs(names2) do
        local item=FamilyWarPlaySmallItem.new()
        item:setData(data)
        self:getNode("scroll2"):addItem(item)
        idx=idx+1
    end
    for i=idx, maxNum-1 do
        local item=self:createIndex(i+1)
        self:getNode("scroll2"):addItem(item);
    end
    self:getNode("scroll2"):layout()
end

function FamilyWarMatchDetailPanel:createIndex(idx)
    local node=cc.Node:create()
    local sprite=cc.Sprite:create("images/ui_family/war_team_di.png")
    sprite:setPositionX(55)
    sprite:setPositionY(-55)
    node:addChild(sprite)

    local ttfConfig = {}
    ttfConfig.fontFilePath = gCustomFont
    ttfConfig.fontSize = 34
    local ret= gCreateWordLabelTTF(tostring(idx),gCustomFont,34,cc.c3b(104,41,41)) --cc.Label:createWithTTF(ttfConfig,idx);
    ret.ttfConfig = ttfConfig;
    ret.font = gCustomFont;
    ret.fontsize = 34;
    ret:setColor(cc.c3b(104,41,41))
    node:addChild(ret)
    ret:setPositionX(55)
    ret:setPositionY(-55)
    return node
end

function FamilyWarMatchDetailPanel:initRecord()
    self:getNode("scroll"):clear()
    for key, var in pairs(self.list) do
        if(var.vid~=0)then
            local item=FamilyWarMatchRecordItem.new()
            item:setData(var)
            self:getNode("scroll"):addItem(item)
        end
    end
    self:getNode("scroll"):layout()
end


function FamilyWarMatchDetailPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();
    elseif  target.touchName=="btn_realtime"then
        self:selectBtn(target.touchName)
        self:initRealTime()
        self:clearWin()
    elseif  target.touchName=="btn_record"then
        self:selectBtn(target.touchName)
        self:getNode("btn_play"):stopActionByTag(1)
        self:initRecord()
        self:clearWin()

    elseif  target.touchName=="btn_play"then
        self:playWar()

    end
end



function FamilyWarMatchDetailPanel:resetBtnTexture()
    local btns={
        "btn_realtime",
        "btn_record",
    }

    for key, btn in pairs(btns) do
        self:getNode(btn.."_panel"):setVisible(false)
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end

end
function FamilyWarMatchDetailPanel:selectBtn(name)
    self:resetBtnTexture()
    self:getNode(name.."_panel"):setVisible(true)
    self:changeTexture( name,"images/ui_public1/button_s2-1.png")
end




return FamilyWarMatchDetailPanel