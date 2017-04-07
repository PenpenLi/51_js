-- 装备材料双倍掉落
local ActivityItemDropPanel=class("ActivityItemDropPanel",UILayer)

function ActivityItemDropPanel:ctor(data)
    self:init("ui/ui_hd_tongyong1.map")

    local data = DB.getClientParamToTable("STAGE_DOUBLE_EQU_PARAMS")
    
    local odds = 0 --掉落几率
    local quality = 0  --品质
    if table.getn(data) == 2 then
        odds = data[1]
        quality = data[2]
    end
    quality = quality+1
    local quaname = gGetWords("cardAttrWords.plist","quality"..quality)
    local baseQua,detailQua = Icon.convertItemDetailQuality(quality)
    quaname = "\\w{c="..gGetHex(gQuaColor[baseQua][1])..gGetHex(gQuaColor[baseQua][2])..gGetHex(gQuaColor[baseQua][3])..";o=000000ff,0.1}"..quaname
    quaname = quaname.."\\"
    self:setRTFString("txt_info", gGetWords("labelWords.plist","hd_itemdrop_double_dec",odds,quaname))
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end

function ActivityItemDropPanel:onTouchEnded(target)
    if  target.touchName=="btn_go"then
        Panel.popUp(PANEL_ATLAS)
    end
end

return ActivityItemDropPanel