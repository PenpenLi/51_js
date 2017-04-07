local PetTalentReplace=class("PetTalentReplace",UILayer)

function PetTalentReplace:ctor(petid,param2)

    self:init("ui/ui_lingshou_tianfutihuan.map")
    self._panelTop=true
    self.isWindow=true
    loadFlaXml("ui_lingshou");

    self:getNode("scroll1").eachLineNum = 2
    self:getNode("scroll2").eachLineNum = 2

    for i=1,2 do
        self:getNode("txt_name"..i):setVisible(false)
        self:getNode("icon_"..i):setVisible(false)
        self:getNode("icon_"..i).stid=0
    end
    self.petid = petid
    self.pos = 0
    self.rstid =0
    self:initData()
    self:resetLayOut()
end

function PetTalentReplace:reSetData()
    for i=1,2 do
        self:getNode("txt_name"..i):setVisible(false)
        self:getNode("icon_"..i):setVisible(false)
        self:getNode("icon_"..i).stid=0
    end
    self:setLabelString("txt_const",0)
    self:setTouchEnableGray("btn_replace",false)
    self.rstid =0
    self.pos =0
    self:getNode("scroll2"):clear()
    self:getNode("scroll2"):layout()
    for k,item in pairs(self:getNode("scroll1").items) do
        item:setSel(false)
    end
end

function PetTalentReplace:initData()
    local petData = Data.getUserPetById(self.petid)
    for i=1,8 do
        local lock = false
        if petData.stlocks[i]~=nil and petData.stlocks[i] == 1 then
            lock = true
        end 
        local itemid =petData["stid"..i]
        if lock==false and itemid>0 then
            local layerItem = PetTalentReplaceItem.new()
            layerItem:setData({pos=i,itemid=itemid})
            layerItem.selCallBack=function(data)
                if self.pos == data.pos then
                    return
                end
                self:reSetData()
                self.pos = data.pos
                self:getNode("txt_name1"):setVisible(true)
                self:getNode("icon_1"):setVisible(true)
                self:getNode("icon_1").stid=data.itemid

                Net.sendPetStrelist(self.petid,data.pos)
                local stvar=DB.getSpecialTalentById(data.itemid)
                self:setLabelString("txt_name1",stvar.name)
                Icon.setPetTalentSkillIcon(data.itemid,self:getNode("icon_1"))
                for k,item in pairs(self:getNode("scroll1").items) do
                    if item.curData==data then
                        item:setSel(true)
                    else
                        item:setSel(false)
                    end
                end
            end
            self:getNode("scroll1"):addItem(layerItem)
        end
    end
    self:getNode("scroll1"):layout()

    if table.count(self:getNode("scroll1").items)>0 then
        self:getNode("scroll1").items[1]:onTouchEnded()
    end
end

function PetTalentReplace:events()
    return {EVENT_ID_PET_REP_LIST,EVENT_ID_PET_REPLACE}
end


function PetTalentReplace:dealEvent(event,param)
    if EVENT_ID_PET_REP_LIST==event then
        self:getNode("scroll2"):clear()
        for k,itemid in pairs(param) do
            local layerItem = PetTalentReplaceItem.new()
            layerItem:setData({pos=k,itemid=itemid})
            layerItem.selCallBack=function(data)
                self:getNode("txt_name2"):setVisible(true)
                self:getNode("icon_2"):setVisible(true)
                self:setTouchEnableGray("btn_replace",true)


                self.rstid=data.itemid
                local stvar=DB.getSpecialTalentById(data.itemid)
                self:setLabelString("txt_name2",stvar.name)
                Icon.setPetTalentSkillIcon(data.itemid,self:getNode("icon_2"))
                self:getNode("icon_2").stid=data.itemid

                if stvar.petid>0 then
                    self:setLabelString("txt_const",Data.pet.stRepConsts[2])
                else
                    self:setLabelString("txt_const",Data.pet.stRepConsts[1])
                end
                
                for k,item in pairs(self:getNode("scroll2").items) do
                    if item.curData==data then
                        item:setSel(true)
                    else
                        item:setSel(false)
                    end
                end
            end
            self:getNode("scroll2"):addItem(layerItem)
        end
        self:getNode("scroll2"):layout()
    elseif EVENT_ID_PET_REPLACE == event then
         local petData = Data.getUserPetById(self.petid)
         for k,item in pairs(self:getNode("scroll1").items) do
            if item.curData.pos == self.pos  then
                item:showActivityFla()
            end
            local itemid = petData["stid"..item.curData.pos]
            item:setData({pos=item.curData.pos,itemid=itemid})
         end
         self:reSetData()
    end
    self:setLabelString("txt_num",Data.getItemNum(ITEM_TALENT_REP))
end


function PetTalentReplace:onTouchBegan(target,touch, event)
    self.beganPos = touch:getLocation()
    if (string.find(target.touchName,"icon_")) then
        if target.stid>0 then
            local stidDB = DB.getSpecialTalentById(target.stid)
            Panel.popTouchTip(target,TIP_TOUCH_TALENT_SKILL,stidDB) 
        end
    end
end

function PetTalentReplace:onTouchMoved(target,touch)
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function PetTalentReplace:onTouchEnded(target)
     Panel.clearTouchTip()
	if  target.touchName=="btn_close"then
		Panel.popBack(self:getTag())
	elseif target.touchName=="btn_replace"  then
        local constNum = toint(self:getNode("txt_const"):getString())
        local txtName1 = self:getNode("txt_name1"):getString()
        local txtName2 = self:getNode("txt_name2"):getString()
        if NetErr.isItemEnough(ITEM_TALENT_REP,constNum,true) then
            local function onOk()
                 Net.sendPetStre(self.petid,self.pos,self.rstid) --1-8
            end
            local txt =gGetWords("petWords.plist","word_talent_rep",constNum,txtName1,txtName2)
            gConfirmCancel(txt, onOk)
        end
	end

end

return PetTalentReplace