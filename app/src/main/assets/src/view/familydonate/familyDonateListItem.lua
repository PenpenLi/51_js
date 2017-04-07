local FamilyDonateListItem=class("FamilyDonateListItem",UILayer)

function FamilyDonateListItem:ctor()

    self.donateAskTime = 0
    self.donateAllAskTime = Data.family.donateAllAskTime
    self.updateDonateListCallback = nil
    self.isMe =  false
    self.cdtime = 0
    self.curSoulNum = 0
    loadFlaXml("ui_kuang_texiao");
    self:init("ui/ui_family_juanzeng_item.map")

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        elseif event == "exit" then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end


function FamilyDonateListItem:onEnter()
    
    local function updatePer()
        self.difftime = gGetCurServerTime()-self.difftime
        if self.donateAskTime>0 then
            local passTime = gGetCurServerTime() - self.donateAskTime
            self:refreshPassTime(passTime)
        end
        if self.cdtime>0 then
            self.cdtime = self.cdtime - self.difftime
        end
        self.difftime = gGetCurServerTime()
    end
    self.difftime = gGetCurServerTime()
    self:scheduleUpdateWithPriorityLua(updatePer,1)

end

function FamilyDonateListItem:onExit()
    self:unscheduleUpdate()
end



function FamilyDonateListItem:onTouchEnded(target)

    if  target.touchName=="btn_donate" then
        if self.isMe  then
            if self.cdtime <= 0  then
                 self.cdtime = 10
                 Net.sendFamilyDonateHelp(self.curData.id)
            else
                gShowNotice(gGetWords("familyWords.plist","family_helpfreq"));
            end
         else
            if self.curSoulNum <=0  then
                gShowNotice(gGetCmdCodeWord("family.dondonate","34"));
                return
            end
            if self.curData.donate ==0 then
                Net.sendFamilyDonateDonate(self.curData.id)
            end
            
        end
        
    end

end

function FamilyDonateListItem:refreshPassTime(time)
    if time >= self.donateAllAskTime  then
        if self.updateDonateListCallback then
            self.updateDonateListCallback(self)
            return
        end
    end

    local hourtime = math.floor(time/3600)
    local minetime = math.floor((time-hourtime*3600)/60)
    self:replaceLabelString("txt_time",hourtime,minetime)
end

function FamilyDonateListItem:setData(data)
    
    self.curData = data
    if self.curData.itemtype == 0 then
        local cardid = data.itemid-ITEM_TYPE_SHARED_PRE
        local curSoulNum=Data.getSoulsNumById(cardid)
        --local cardDb=DB.getCardById(cardid);
        local itemName = DB.getItemName(data.itemid,true)
        self:setLabelString("txt_itemname",itemName)
        self:replaceLabelString("txt_fragnum", curSoulNum)
        self.curSoulNum = curSoulNum
        Icon.setIcon(data.itemid,self:getNode("icon"),DB.getItemQuality(data.itemid),nil,nil,true)
        if(DB.getSoulNeedLight(data.itemid))then
            Icon.addSpeEffectForSoul(self:getNode("icon"));
        end
        
    elseif self.curData.itemtype == 1 then  -- 魔纹
        local treasureId = self.curData.itemid - ITEM_TYPE_SHARED_PRE
        local treasure=DB.getTreasureById(treasureId)
        self:setLabelString("txt_itemname",treasure.name)
        local curSoulNum = Data.getItemNum(self.curData.itemid)
        self:replaceLabelString("txt_fragnum", curSoulNum)
        Icon.setIcon(treasureId,self:getNode("icon"),treasure.quality,nil,true)
        self.curSoulNum = curSoulNum
    end
    
    if self.isMe == true then
        local pMeFlag = cc.Sprite:create("images/ui_family/ME.png");
        pMeFlag:setAnchorPoint(cc.p(1.0,0));
        pMeFlag:setPosition(38,-70);
        self:addChild(pMeFlag,100);
        self:setLabelString("txt_donate",gGetWords("familyWords.plist","family_help"))
    end
    self.donateAskTime = self.curData.time
    local passTime = gGetCurServerTime() - self.donateAskTime
    self:refreshPassTime(passTime)

    local dbDonateItem  = DB.getFamilyDonateItem(data.itemid)
    self:replaceLabelString("txt_recvnum", data.itemnum.."/"..dbDonateItem.max)
    local per=data.itemnum/dbDonateItem.max
    self:setBarPer("bar",per)
    self:setLabelString("txt_name",data.uName)
    self:setLabelString("txt_class",gGetWords("familyMenuWord.plist","title"..data.type));
    if self.isMe==false and (self.curData.donate>0  or self.curSoulNum <=0) then
        self:setTouchEnableGray("btn_donate",false); 
    end
    self:resetLayOut()
end

function  FamilyDonateListItem:refreshData() 
        self:setData(self.curData)
end


return FamilyDonateListItem