local ArenaRecordPanel=class("ArenaRecordPanel",UILayer)

function ArenaRecordPanel:ctor(recordType,data)
    self:init("ui/ui_arena_record.map")
   
    self:getNode("scroll").eachLineNum=1 
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.recordType = recordType
    local visible = self.recordType == SERVERBATTLE_RECORD_TYPE
    self:getNode("btn_attack"):setVisible(visible)
    self:getNode("btn_defend"):setVisible(visible)
    self:getNode("txt_log_title"):setVisible(not visible)
    self:setDefendRedpos(visible)
    self:initArenaRecord(data)
end


function  ArenaRecordPanel:events()
    return {EVENT_ID_ARENA_RECORD,EVENT_ID_SERVERBATTLE_RECORD}
end


function ArenaRecordPanel:dealEvent(event,param)
    if(event==EVENT_ID_ARENA_RECORD)then
        self:initArenaRecord(param)
    elseif (event == EVENT_ID_SERVERBATTLE_RECORD) then
        self:initServerBattleRecord(param)
    end
end


function ArenaRecordPanel:initArenaRecord(data)
-- print_lua_table(data.records)
    self:clearLazyFunc()
    table.sort(data.records,function(a,b) return a.time<b.time end) --从小到大排序
    self:getNode("scroll"):clear()
    if self.recordType == ARENA_RECORD_TYPE then
        local maxLoaded = 8
        for key, var in pairs(data.records) do 
           local item=ArenaRecordItem.new(self.recordType)
           if key <= maxLoaded then
                item:setData(var)
           else
                item:setLazyData(var)
           end
           self:getNode("scroll"):addItem(item)
        end
        self:getNode("scroll"):layout() 
    else
        self:initServerBattleRecord(data)
    end
end 

function ArenaRecordPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_attack" then
        self:selectBtn("btn_attack")
    elseif target.touchName=="btn_defend" then
        self:selectBtn("btn_defend")
        Data.redpos.warlose = false
        self:setDefendRedpos(true)
    end
end
 
function ArenaRecordPanel:onPopback()
    self:clearLazyFunc()
end

function ArenaRecordPanel:clearLazyFunc()
    if self.recordType == ARENA_RECORD_TYPE then
        Scene.clearLazyFunc("arenaRecordItem")
    elseif self.recordType == SERVERBATTLE_RECORD_TYPE then
        Scene.clearLazyFunc("serverbattleRecordItem")
    end
end

function ArenaRecordPanel:initServerBattleRecord(data)
    self:getNode("scroll"):clear()
    self.serverBattleData = data.records
    self:selectBtn("btn_attack")
end

function ArenaRecordPanel:selectBtn(name)
    Scene.clearLazyFunc("serverbattleRecordItem")
    self:getNode("scroll"):clear()
    self:resetBtnTex()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
    self:setServerBattleScroll(name)
end

function ArenaRecordPanel:resetBtnTex()
    local btns={
        "btn_attack",
        "btn_defend",
    }

    for _, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function ArenaRecordPanel:setServerBattleScroll(name)
    local maxLoaded = 8
    local idx = 0
    for _, var in pairs(self.serverBattleData) do
        if name == "btn_attack" and var.atk then
            local item = ArenaRecordItem.new(self.recordType)
            idx = idx + 1
            if idx <= maxLoaded then
                item:setData(var)
            else
                item:setLazyData(var)
            end
            self:getNode("scroll"):addItem(item)
        elseif name == "btn_defend" and not var.atk then
            local item = ArenaRecordItem.new(self.recordType)
            idx = idx + 1
            if idx <= maxLoaded then
                item:setData(var)
            else
                item:setLazyData(var)
            end
            self:getNode("scroll"):addItem(item)
        end
        self:getNode("scroll"):layout()
    end
end

function ArenaRecordPanel:setDefendRedpos(visible)
    if (not visible) then
        return
    end

    if Data.redpos.warlose then
        RedPoint.add(self:getNode("btn_defend"))
    else
        RedPoint.remove(self:getNode("btn_defend"))
    end
end

return ArenaRecordPanel