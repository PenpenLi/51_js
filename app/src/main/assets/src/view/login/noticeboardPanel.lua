local NoticeboardPanel=class("NoticeboardPanel",UILayer)
NoticeboardPanel.data = {};
NoticeboardPanel.data.first = true;

function gEnterNoticeBoard(serverid)

    if (Module.isClose(SWITCH_NOTICE)) then
        return;
    end

    if(serverid == nil)then
        serverid = 0;
    end

    print("@@@@@serverid = "..serverid);

    function callback(ret)

        -- print("notice call back ");
        -- print_lua_table(ret);
        if ret == nil then
            return;
        end
        if(type(ret.function_client)=="table") then
            -- print("function_client");
            local switchs = {};
            local data = Net.parserOneModuleSwitch(ret.function_client.id,ret.function_client.version,ret.function_client.platform,ret.function_client.open);
            table.insert(switchs,data);
            -- print_lua_table(switchs);
            Module.updateSwitch(switchs);
        end

        gDispatchEvt(EVENT_ID_NOTICE);
        
        if (Module.isClose(SWITCH_NOTICE)) then
            print("return notice");
            return;
        end

        Panel.popUp(PANEL_NOTICEBOARD,ret); 
    end
    gAccount:getNoticeList(callback,serverid);
end

function NoticeboardPanel:ctor(ret) 
    self.appearType = 1;
    self:init("ui/ui_noticeboard.map")
    self._panelTop = true;
    Data.redpos.bolNotice = false;
    -- print_lua_table(ret);
    if ret.ret == 0 and ret.noticelist ~= nil then
        self:createList(ret.noticelist);
    end
    -- local function callback(ret)
    --     -- print_lua_table(ret);
    -- 	if ret.ret == 0 then
    -- 		self:createList(ret.noticelist);
    -- 	end
    -- end
    -- gAccount:getNoticeList(callback);
    NoticeboardPanel.data.first = false;
end

function NoticeboardPanel:createList(data)
    gNotices = data;
    -- print_lua_table(gNotices);
    local sort2 = function(data1,data2)
        if toint(data1.sortid) > toint(data2.sortid) then
            return true;
        end
        return false;
    end
    table.sort(data,sort2);
    -- print_lua_table(data);
    if nil ~= data then
        for key,var in pairs(data) do
            local item = NoticeboardItem.new(var,key);
            self:getNode("scroll"):addItem(item);
            item.click = function(index)
                self:onClickOneNotice(index);
            end
        end
        self:getNode("scroll"):layout();
    end
end

function NoticeboardPanel:onClickOneNotice(index)
	local choosedItem = self:getNode("scroll"):getItem(index-1);
    if (choosedItem.isExtend == false) then 
        gLogEvent("click_noticeboard")
    end 
	local offH,time = choosedItem:onBg();
	-- self:getNode("scroll"):layout(false);
	local count = table.getn(self:getNode("scroll"):getAllItem());
	for i = index,count-1 do
		local item = self:getNode("scroll"):getItem(i);
		item:runAction(cc.MoveBy:create(time,cc.p(0,offH)));
	end
	local function moveEnd()
		self:getNode("scroll"):layout(false);
		-- local posY = self:getNode("scroll").container:getPositionY();
		-- self:getNode("scroll").container:setPositionY(posY+offH);
	end
	self:runAction(cc.Sequence:create(
						cc.DelayTime:create(time),
						cc.CallFunc:create(moveEnd)
		));

end



function NoticeboardPanel:onTouchEnded(target)

    if  target.touchName=="btn_ok"then
        Panel.popBack(self:getTag()) 
    end
end

return NoticeboardPanel