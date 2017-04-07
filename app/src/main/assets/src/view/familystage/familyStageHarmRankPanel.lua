local FamilyStageHarmRankPanel=class("FamilyStageHarmRankPanel",UILayer)

function FamilyStageHarmRankPanel:ctor()
    self:init("ui/ui_family_stage_harm_rank.map")
    self._panelTop = true
   
    self:getNode("scroll").eachLineNum=1 
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll").scrollBottomCallBack = function()
       self:onMoveDown()
    end

    self.iShowIndex = 0
    self.iShowMax = 100
    self.iShowSize = 10

    self.ranks = nil
    self.event = nil

    self:initRank()
end

function  FamilyStageHarmRankPanel:events()
    return {

}
end


function FamilyStageHarmRankPanel:dealEvent(event,param)

end


function FamilyStageHarmRankPanel:initRank()
    self:getNode("scroll"):clear()
    
    local infoWord = ""
    local infoWord_pw = ""
    local infoWord_uf = gGetWords("arenaWords.plist","11")
    local rank = 0
    local pw = -1

    local infoWord = ""
    if gFamilyStageInfo.myHarmValue > 0 then
        infoWord = gGetWords("arenaWords.plist","12-7",gFamilyStageInfo.myHarmValue)
    else
        infoWord = gGetWords("arenaWords.plist","12-8")
    end
    self:setLabelString("txt_pw", infoWord)

    table.sort(gFamilyStageInfo.harmRanks, function(lHarm, rHarm)
        if lHarm.harm > rHarm.harm then
            return true
        end

        return false
    end)
    self:initMyRankInfo()
    self.iShowMax = table.getn(gFamilyStageInfo.harmRanks)
    self.iShowIndex = 0

    self:onMoveDown()
end

function FamilyStageHarmRankPanel:onMoveDown()
    if (self.iShowIndex>=self.iShowMax) then
        return
    end
    for i=1+self.iShowIndex,self.iShowSize+self.iShowIndex do
        local key = i
        if (key <= self.iShowMax) then
            local var = gFamilyStageInfo.harmRanks[key]
            local item=ArenaRankItem.new()
            item:setData(var,EVENT_ID_RANK_FAMILY_STAGE_HARM,key)
            self:getNode("scroll"):addItem(item)
        end
    end
    self:getNode("scroll"):layout(self.iShowIndex==0)
    self.iShowIndex = self.iShowIndex + self.iShowSize
    self.iShowIndex = math.min(self.iShowIndex,self.iShowMax)
end

function FamilyStageHarmRankPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        self:onClose()  
    end
end

function FamilyStageHarmRankPanel:initMyRankInfo()
    local rank = 0
    for i,harmItem in ipairs(gFamilyStageInfo.harmRanks) do
        if harmItem.id == Data.getCurUserId() then
            rank = i
        end
    end

    if rank > 0 then
        self:replaceLabelString("txt_rank", rank)
    else
        self:replaceLabelString("txt_rank",gGetWords("arenaWords.plist","lab_no"))
    end
end
 


return FamilyStageHarmRankPanel