local TreasureHuntNoticeItem=class("TreasureHuntNoticeItem",UILayer)

function TreasureHuntNoticeItem:ctor()
    self.inited = false
end

function TreasureHuntNoticeItem:onTouchEnded(target,touch, event)
    if target.touchName=="btn_goto" then
        if self:getNode("btn_goto").type == 0 then
            Net.sendCrotreNotijoin(self.curData.groupId, self.curData.roomId, self.curData.mapId)
        else
            Net.sendCrotreGetrecInfo(self.curData.mapId)
        end
    end
end

function TreasureHuntNoticeItem:initPanel()
    if self.inited then
        return
    end

    self.inited = true
    self:init("ui/ui_treasure_hunt_notice_item.map")
end

function TreasureHuntNoticeItem:setData(data,idx)
    self:initPanel()
    self.curData = data
    self.idx = idx

    local noticeDbInfo = DB.getTreasureHuntNoticeInfo(self.curData.id)
    local noticeWord = gTreasureHunt.getNoticeInfoWord(self.curData)

    self:setRTFString("txt_info", noticeWord)
    self:getNode("txt_info"):layout()

    if noticeDbInfo.type == 0 then
        self:setLabelString("txt_btn_go",gGetWords("btnWords.plist","btn_go_to"))
        self:getNode("btn_goto").type = 0
    else
        self:setLabelString("txt_btn_go",gGetWords("btnWords.plist","btn_detail"))
        self:getNode("btn_goto").type = 1
    end    
end

function  TreasureHuntNoticeItem:setDataLazyCalled()
    self:setData(self.lazyData, self.lazyIdx)
end

function  TreasureHuntNoticeItem:setLazyData(data,idx)
    self.lazyData=data
    self.lazyIdx=idx
    Scene.addLazyFunc(self,self.setDataLazyCalled,"treasureHuntNoticeItem")
end


return TreasureHuntNoticeItem