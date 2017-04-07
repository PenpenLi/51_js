local ConstellationGroupStar=class("ConstellationGroupStar",UILayer)

function ConstellationGroupStar:ctor(circleId,groupId)
    self:init("ui/ui_constellation_group_xingjijiacheng.map")
    self.circleId = circleId
    self.groupId = groupId

    local starGroupInfos = {}
    local groupInfo = DB.getConstellationGroupInfo(self.groupId)
    local curStarLv = gConstellation.getStarNumByGroupMap(self.circleId, self.groupId)
    for i=1,groupInfo.star do
        local starGroupInfo = DB.getCircleGroupStar(self.groupId,i)
        table.insert(starGroupInfos,starGroupInfo)
    end
    for k,data in pairs(starGroupInfos) do
        local item = ConstellationGroupStarItem.new(data,k)
        item:setData(curStarLv)
        self:getNode("scroll"):addItem(item)
    end
    
    self:getNode("scroll"):layout()
end

function ConstellationGroupStar:onTouchEnded(target,touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    end
end

return ConstellationGroupStar
