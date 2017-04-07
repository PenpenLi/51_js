local ActivityShareItem=class("ActivityShareItem",UILayer)

function ActivityShareItem:ctor(data)
    self:init("ui/ui_hd_share_item.map")
    -- self.type = data;
    -- print("self.type="..self.type)
end

function ActivityShareItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        if (self.curData.rec==false) then
            Net.sendActivityShareRec(self.curData.id)
        end
    elseif(target.touchName=="btn_share") then
        if( self.curData.id == 1)then
            local data = {};
            data.level = gUserInfo.level;
            -- Panel.popUpVisible(PANEL_SHARE_FORMATION,{formationType = TEAM_TYPE_ATLAS,shareType = SHARE_TYPE_LEVEL,shareData = data});
            Panel.popUpVisible(PANEL_SHARE_LEVELUP,{formationType = TEAM_TYPE_ATLAS,shareType = SHARE_TYPE_LEVEL});
        elseif(self.curData.id == 2)then
            local data = {};
            data.star = 3;
            data.mapid = 1;
            data.stageid = 1;
            Panel.popUpVisible(PANEL_SHARE_FORMATION,{formationType = TEAM_TYPE_ATLAS,shareType = SHARE_TYPE_ATLAS,shareData = data});
        elseif(self.curData.id == 3 or self.curData.id == 4)then
            local data = {};
            data.rank = gUserInfo.rank;
            Panel.popUpVisible(PANEL_SHARE_FORMATION,{formationType = TEAM_TYPE_ARENA_DEFEND,shareType = SHARE_TYPE_ARENA,shareData = data});  
        elseif(self.curData.id == 5 or self.curData.id == 6)then
            local cardid = 0;
            for key,card in pairs(gUserCards) do
                if(self.curData.id == 5)then
                    if(card.grade >= 4)then
                        cardid = card.cardid;
                    end
                elseif(self.curData.id == 6)then
                    if(card.grade >= 3)then
                        cardid = card.cardid;
                    end
                end
            end
            Panel.popUpVisible(PANEL_SHARE_NEWCARD,cardid);
        end
    end
end

function ActivityShareItem:getShareData(id)
    for k,v in pairs(share_db) do
        if (id == v.id) then
            return v
        end
    end
    return nil
end

function   ActivityShareItem:setData(key,data)
    self.curData=data

    -- print_lua_table(data)
    -- local shareData = self:getShareData(data.id)
    -- if (shareData) then
    --     data.items = cjson.decode(shareData.reward)
    -- end

    if (data.items) then
        local title = data.des
        self:setLabelString("lab_title",title)
        if (data.id == 3) then--特殊处理
            self:setLabelString("lab_count",data.plan.."/"..data.request)
        else
            self:getNode("lab_count"):setVisible(false)
        end

        local size = (#data.items)
        -- print("size = "..size)
        for i=1,4 do
            self:getNode("icon"..i):setVisible(false)
            if (size>=i) then
                self:getNode("icon"..i):setVisible(true)
                local info = data.items[i]
                local node=DropItem.new() 
                node:setData(info.id)
                node:setNum(info.num)  
                node:setPositionY(node:getContentSize().height)
                gAddMapCenter(node, self:getNode("icon"..i)) 
            end
        end

        self:getNode("btn_get"):setVisible(false)
        self:getNode("btn_share"):setVisible(false)
        self:getNode("btn_go"):setVisible(false)
        self:getNode("sign_get"):setVisible(false)
        self:getNode("sign_no"):setVisible(false)

        if (not data.achieve) then --未达成
            self:getNode("sign_no"):setVisible(true)
        else
            if (data.finish and data.share) then 
                if (not data.rec) then
                    self:getNode("btn_get"):setVisible(true)--可领取
                else
                    self:getNode("sign_get"):setVisible(true)--已领完
                end
            else
                if (not data.share) then
                    if (data.id == 3) then
                        if (data.plan>=data.request) then
                            self:getNode("btn_share"):setVisible(true)--可分享
                        else
                            self:getNode("sign_no"):setVisible(true)
                        end
                    else
                        self:getNode("btn_share"):setVisible(true)--可分享
                    end
                else
                    --未完成
                    self:getNode("sign_no"):setVisible(true)
                end
            end
        end
        self:getNode("item_lay"):layout()
    end
    
end

function   ActivityShareItem:refreshData()
    self:setData(0,self.curData)
end


return ActivityShareItem