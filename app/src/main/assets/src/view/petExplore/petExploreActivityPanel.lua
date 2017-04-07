local PetExploreActivityPanel=class("PetExploreActivityPanel",UILayer)

gcurLongId=0
function PetExploreActivityPanel:ctor(parma1,param2)

    self:init("ui/ui_lingshouhuodong.map")
    self.curData=nil
    self.curPanel = nil
    self.needdia=0

    for id,value in pairs(Data.CaveInfo.eventList) do
        if id>0 then
            value.name=gGetWords("petWords.plist","EventName"..value.etype)
            --value.icon="ui_activity_icon_2_11"
            value.type=99999
            if value.status == nil then
                value.status = true
            end
            --value.showLeftTime = true
            value.icon="pet_explore_event_icon"..value.etype
            local item=ActivityMenuItem.new()
            item:setData(value)
            item.onSelectCallback=function (data)
                self:setCurEvent(data)
            end
            self:getNode("scroll"):addItem(item)
        end
    end
    local sortfunc = function(item1,item2)
        return item1.curData.endtime<item2.curData.endtime
   end
    self:getNode("scroll"):sortItems(sortfunc)
    self:getNode("scroll"):layout()

    local size = table.getn(self:getNode("scroll").items)
    if(size~=0)then
        self:setCurEvent(self:getNode("scroll").items[1].curData)
    end
    if parma1 and parma1.id  then
        for k,item in pairs(self:getNode("scroll").items) do
            if item.curData.id==parma1.id then
                self:setCurEvent(item.curData)
                self:getNode("scroll"):moveItemByIndex(k)
                break
            end
        end
   end
   local lastEndTime = 0
    local function refreshMenuItemLeftTime()
        for k,item in pairs(self:getNode("scroll").items) do
            item:getNode("txt_lefttime"):setVisible(true)
            local lefttime =item.curData.endtime- gGetCurServerTime()
            local eventData=Data.CaveInfo.eventList[gcurLongId]
            if lefttime<=0 and eventData.endFlip==false and gcurLongId == item.curData.id and item.curData.etype == EVENT_TYPE_CARD then
                Data.CaveInfo.eventList[gcurLongId].status=false
                self:initCaveCardInfo()
                eventData.endFlip=true
            end
            if item.curData.status==false or lefttime < 0 then
                lefttime = 0
            end
            if lefttime <=0 then
                item.curData.status=false 
                DisplayUtil.setGray(item,true)
                item:setLabelString("txt_lefttime", gGetWords("petWords.plist","time_end"))
            else
                item:setLabelString("txt_lefttime", gParserHourTime(lefttime))
            end
            if item.curData.status==false and  gcurLongId == item.curData.id  then
                self:setAllBtnStatus(false)
            end
        end
    end
    local function updateMenuItemLeftTime()
        refreshMenuItemLeftTime()
    end
    self:scheduleUpdateWithPriorityLua(updateMenuItemLeftTime,1)
end

--onexit
function PetExploreActivityPanel:onPopBackFromStack()
    self:unscheduleUpdate()
    local btn = self:getNode("hd3_btn")
    if btn then
        btn:unscheduleUpdate()
    end
end

function PetExploreActivityPanel:events()
    return {EVENT_ID_CAVE_EVENT1_INFO,EVENT_ID_CAVE_EVENT1_DEAL,
            EVENT_ID_CAVE_EVENT2_INFO,EVENT_ID_CAVE_EVENT2_DEAL,
            EVENT_ID_CAVE_EVENT3_INFO,EVENT_ID_CAVE_EVENT3_DEAL,
            EVENT_ID_CAVE_EVENT4_INFO,EVENT_ID_CAVE_EVENT4_DEAL,
            EVENT_ID_CAVE_EVENT5_INFO,EVENT_ID_CAVE_EVENT5_DEAL,}
end


function PetExploreActivityPanel:initBusinessManInfo(param1,param2)
        local eventData = Data.CaveInfo.eventList[gcurLongId]
        eventData.nowprice = eventData.nowprice or 1
        eventData.oldprice = eventData.oldprice or 1
        Icon.setDropItem(self:getNode("hd4_icon1"),eventData.itemid,eventData.itemnum)
        self:setLabelString("hd4_oldprice",eventData.oldprice)
        self:setLabelString("hd4_newprice",eventData.nowprice)
        if(gCurLanguage == LANGUAGE_EN)then
            self:replaceLabelString("hd4_discount",(eventData.oldprice-eventData.nowprice)*100/eventData.oldprice)
        else
            self:replaceLabelString("hd4_discount",(eventData.nowprice*10/eventData.oldprice))
        end
end

function PetExploreActivityPanel:dealBusinessMan(param1,param2)

end

function PetExploreActivityPanel:initOldAnimalInfo(param1,param2)
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    for i=1,4 do
        local itemid = Data.petCave.eventAnimalItemId[i]
        local itemnum = Data.petCave.eventAnimalItemNum[i]
        Icon.setDropItem(self:getNode("hd3_icon"..i),itemid,itemnum)
    end

    self:getNode("hd3_info_layer"):setVisible(eventData.status)
    self:setTouchEnableGray("hd3_btn",eventData.status)
    if eventData.status==false then
        return
    end
    local function refreshLeftTime()
         local lefttime = eventData.gettime - gGetCurServerTime()
        if lefttime < 0 then
            lefttime = 0
            local btn = self:getNode("hd3_btn")
            btn:unscheduleUpdate()
        end
        self:setBarPer2("hd3_bar", Data.petCave.caveRewardTime-lefttime, Data.petCave.caveRewardTime)
        self:setLabelString("hd3_txt_time", gParserHourTime(lefttime))
        if lefttime>0 then
            self:setLabelString("hd3_title_explore","lab_exporeing","petWords.plist")
        else
            self:setLabelString("hd3_title_explore","lab_expore_end","petWords.plist")
        end
        self:getNode("hd3_txt_time"):setVisible(lefttime>0)
        self:setTouchEnableGray("hd3_btn", lefttime<=0)
    end
    local btn = self:getNode("hd3_btn")
    btn:unscheduleUpdate()
    local function updatePer()
        refreshLeftTime()
    end
    refreshLeftTime()
    btn:scheduleUpdateWithPriorityLua(updatePer,1)
 end
function PetExploreActivityPanel:dealOldAnimal(param1,param2)

end

function PetExploreActivityPanel:initMagicalBoxInfo(param1,param2)
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    eventData.caveBoxid = eventData.caveBoxid or 1
    local caveBoxDB = DB.getCaveBoxById(eventData.caveBoxid)
    for i=1,4 do
        Icon.setDropItem(self:getNode("hd2_icon"..i),caveBoxDB["item"..i],caveBoxDB["num"..i])
    end
    eventData.opennum = eventData.opennum or 0
    local diamond = Data.petCave.eventDiamond[eventData.opennum+1]
    self:setLabelString("hd2_txt_leftnum",table.count(Data.petCave.eventDiamond)-eventData.opennum)
    diamond = diamond or 0
    self.needdia = diamond
    if diamond==nil or  diamond==0 then
        self:getNode("hd2_txt_free"):setVisible(true)
        self:getNode("hd2_mony_layer"):setVisible(false)
    else
        self:getNode("hd2_txt_free"):setVisible(false)
        self:getNode("hd2_mony_layer"):setVisible(true)
        self:setLabelString("hd2_txt_needdia",diamond)
    end
    self:getNode("hd2_cavebox_btn"):playAction("ls_sqbx")
end

function PetExploreActivityPanel:dealMagicalBox(param1,param2)
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    self:setLabelString("hd2_txt_leftnum",table.count(Data.petCave.eventDiamond)-eventData.opennum)
    local diamond = Data.petCave.eventDiamond[eventData.opennum+1]
    if diamond==0 then
        self:getNode("hd2_txt_free"):setVisible(true)
        self:getNode("hd2_mony_layer"):setVisible(false)
    else
        self:getNode("hd2_txt_free"):setVisible(false)
        self:getNode("hd2_mony_layer"):setVisible(true)
        self:setLabelString("hd2_txt_needdia",diamond)
        self:getNode("hd2_mony_layer"):layout()
    end
    self.needdia = diamond
    self:getNode("hd2_cavebox_btn"):playAction("ls_sqbx")
end

function PetExploreActivityPanel:initFightGuard(param1,param2)
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    local changDB=DB.getCaveChallengeInfoByPower(eventData.curpower)
    local ptypeTable = string.split(changDB.ptype,";")
    local pdataTable = string.split(changDB.pdata,";")
    local itemid1Table = string.split(changDB.itemid1,";")
    local itemnum1Table = string.split(changDB.itemnum1,";")

    local sum = table.count(ptypeTable)
    for i=1,sum do
        self:getNode("hd5_item_layer"..i):setVisible(true)
        if toint(ptypeTable[i])==1 then
            self:changeTexture("hd5_ptype"..i, "images/ui_public1/jiantou_green.png")
        else
            self:changeTexture("hd5_ptype"..i, "images/ui_public1/jiantou_red.png")
        end
        self:setLabelString("hd5_txt_addper"..i,pdataTable[i].."%")
        self:setLabelString("hd5_item_num"..i,"X"..itemnum1Table[i])
        Icon.changeItemIcon(self:getNode("hd5_item_icon"..i),itemid1Table[i])
    end
    for i=sum+1,5 do
        self:getNode("hd5_item_layer"..i):setVisible(false)
    end 
    self:setLabelString("hd5_txt_power",eventData.curpower)
    self:selectHd5Item(1)
   
end

function PetExploreActivityPanel:selectHd5Item(index)
    for i=1,5 do
        self:changeTexture("hd5_item_layer"..i, "images/ui_lingshou/kuanga.png")
    end
    self:changeTexture("hd5_item_layer"..index, "images/ui_lingshou/kuangb.png")
    local layerPos = cc.p(self:getNode("hd5_item_layer"..index):getPosition())
    self:getNode("hd5_sel_arrow"):setVisible(true)
    local oldPos = cc.p(self:getNode("hd5_sel_arrow"):getPosition())
    self:getNode("hd5_sel_arrow"):setPosition(oldPos.x, layerPos.y)
    self.hd5SelIndex = index
end

function PetExploreActivityPanel:dealEvent(event,param1,param2)

    if(event == EVENT_ID_CAVE_EVENT1_INFO)then
        self:initCaveCardInfo(param1,param2)
    elseif (event== EVENT_ID_CAVE_EVENT1_DEAL) then
        self:dealCaveCard(param1,param2)

    elseif(event == EVENT_ID_CAVE_EVENT2_INFO)then
        self:initBusinessManInfo(param1,param2)
    elseif  event== EVENT_ID_CAVE_EVENT2_DEAL then
        self:dealBusinessMan(param1,param2)

    elseif(event == EVENT_ID_CAVE_EVENT3_INFO)then
        self:initOldAnimalInfo(param1,param2)
    elseif  event== EVENT_ID_CAVE_EVENT3_DEAL then
        self:dealOldAnimal(param1,param2)

    elseif(event == EVENT_ID_CAVE_EVENT4_INFO)then
        self:initMagicalBoxInfo(param1,param2)
    elseif  event== EVENT_ID_CAVE_EVENT4_DEAL then
        self:dealMagicalBox(param1,param2)
    elseif(event == EVENT_ID_CAVE_EVENT5_INFO)then
        self:initFightGuard(param1,param2)
    elseif(event == EVENT_ID_CAVE_EVENT5_DEAL)then
        --self:initFightGuard(param1,param2)
    end

    local eventData = Data.CaveInfo.eventList[gcurLongId]
     self:setAllBtnStatus(eventData.status)
end


-- EVENT_TYPE_CARD = 1 --事件1 翻牌 
-- EVENT_TYPE_SHOP = 2--事件2 哥布林商人
-- EVENT_TYPE_BEAST = 3--事件3 远古兽骸
-- EVENT_TYPE_BOX = 4--事件4 神奇宝箱
-- EVENT_TYPE_CHALLENGE = 5--事件5 挑战守卫
-- EVENT_TYPE_DIAMOND = 6--事件6 元宝事件
-- EVENT_TYPE_NONE = 7--事件7 无事
-- EVENT_TYPE_GOLD = 8--事件8 金币
-- EVENT_TYPE_SPIRIT = 9--事件9 精灵

function  PetExploreActivityPanel:setCurEvent(data)

    for key, item in pairs(self:getNode("scroll").items) do
        if(item.curData.id==data.id)then
            item:setSelect(true)
            self.curData= item.curData
            gcurLongId = self.curData.id
        else
            item:setSelect(false)
        end
    end

    self:getNode("target_card"):unscheduleUpdate()
    if data.etype == EVENT_TYPE_CARD then
        Net.sendCaveEvent1Info(data.id)
        self:getNode("hd_layer1"):setVisible(true)
        self:getNode("hd_layer2"):setVisible(false)
        self:getNode("hd_layer3"):setVisible(false)
        self:getNode("hd_layer4"):setVisible(false)
        self:getNode("hd_layer5"):setVisible(false)
        self.curPanel=self:getNode("hd_layer1")

    elseif data.etype == EVENT_TYPE_SHOP then
        Net.sendCaveEvent2Info(data.id)
        self:getNode("hd_layer1"):setVisible(false)
        self:getNode("hd_layer2"):setVisible(false)
        self:getNode("hd_layer3"):setVisible(false)
        self:getNode("hd_layer4"):setVisible(true)
        self:getNode("hd_layer5"):setVisible(false)
        self.curPanel=self:getNode("hd_layer4")
    elseif data.etype == EVENT_TYPE_BEAST then
        Net.sendCaveEvent3Info(data.id)
        self:getNode("hd_layer1"):setVisible(false)
        self:getNode("hd_layer2"):setVisible(false)
        self:getNode("hd_layer3"):setVisible(true)
        self:getNode("hd_layer4"):setVisible(false)
        self:getNode("hd_layer5"):setVisible(false)
        self.curPanel=self:getNode("hd_layer3")
    elseif data.etype == EVENT_TYPE_BOX then
        Net.sendCaveEvent4Info(data.id)
        self:getNode("hd_layer1"):setVisible(false)
        self:getNode("hd_layer2"):setVisible(true)
        self:getNode("hd_layer3"):setVisible(false)
        self:getNode("hd_layer4"):setVisible(false)
        self:getNode("hd_layer5"):setVisible(false)
        self.curPanel=self:getNode("hd_layer2")
    elseif data.etype == EVENT_TYPE_CHALLENGE then
        Net.sendCaveEvent5Info(data.id)
        self:getNode("hd_layer1"):setVisible(false)
        self:getNode("hd_layer2"):setVisible(false)
        self:getNode("hd_layer3"):setVisible(false)
        self:getNode("hd_layer4"):setVisible(false)
        self:getNode("hd_layer5"):setVisible(true)
        self.curPanel=self:getNode("hd_layer5")
    end

end

function PetExploreActivityPanel:setAllBtnStatus(enable)
    self:setTouchEnableGray("hd4_btn_buy", enable)
    self:setTouchEnableGray("hd3_btn", enable)
    self:setTouchEnableGray("hd5_btn_get", enable)
    self:setTouchEnableGray("hd2_cavebox_btn", enable)
    if enable==false then
       self:getNode("hd2_cavebox_btn"):playAction("ls_sqbx_3")
    end
    self:getNode("hd3_info_layer"):setVisible(enable)
end



function PetExploreActivityPanel:onTouchEnded(target)
 	if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "hd4_btn_buy" then
         Net.sendCaveEvent2Deal(self.curData.id)
    elseif target.touchName == "hd3_btn" then
        Net.sendCaveEvent3Deal(self.curData.id)
    elseif target.touchName == "hd5_btn_get" then
        local param = {}
        param.dbid = self.curData.id
        param.index = self.hd5SelIndex-1
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_CAVE,param)

        --Net.sendCaveEvent5fight(self.curData.id,self.hd5SelIndex)
    elseif target.touchName =="hd2_cavebox_btn" then
        
        if NetErr.isDiamondEnough(self.needdia) then
            Panel.popUpVisible(PANNEL_PET_CAVE_OPENBOX,self.curData.id)
        end
        
    elseif target.touchName=="hd1_card1" or target.touchName=="hd1_card2" or target.touchName=="hd1_card3"  then
        self.clickIdx=toint( string.gsub(target.touchName,"hd1_card",""))
        Net.sendCaveEvent1Deal(self.curData.id)
    elseif (string.find(target.touchName,"hd5_item_layer")) then
        local idx=toint(string.gsub(target.touchName,"hd5_item_layer",""))
        self:selectHd5Item(idx)
    end
end

return PetExploreActivityPanel