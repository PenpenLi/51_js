
function Net.sendMailList()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_MAIL_LIST)
end

function Net.rec_mail_list(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    local list = obj:getArray("list")
    Data.mail.list = {}
    if(list) then
        list=tolua.cast(list,"MediaArray")
        for i=0, list:count()-1 do
            local obj1=tolua.cast(list:getObj(i),"MediaObj")
            local mInfo = {};
            mInfo.eId = obj1:getLong("id");
            mInfo.userId = obj1:getLong("userid");
            mInfo.type = obj1:getInt("type");
            mInfo.icon = obj1:getInt("icon");
            mInfo.title = obj1:getString("title");
            mInfo.content = obj1:getString("content");
            mInfo.time = obj1:getInt("ctime");
            if(obj1:getByte("ifread") == 1) then
                mInfo.bolRead = true
            else
                mInfo.bolRead = false
            end
            -- mInfo.bolRead = (obj1:getByte("ifread") == 0 and false) or true;
            
            mInfo.items = {}
            local list2 = obj1:getArray("items");
            list2=tolua.cast(list2,"MediaArray")
            for m=0, list2:count()-1 do
                local obj2 = tolua.cast(list2:getObj(m),"MediaObj")
                local item = {};
                item.itemid = obj2:getInt("item");
                item.num = obj2:getInt("num");
                table.insert(mInfo.items,item)
            end
            table.insert(Data.mail.list,mInfo)
        end
    end
    Net.mail_sort();
    Net.dealRedDot_Mail();
    gDispatchEvt(EVENT_ID_MAIL_LIST);
    gDispatchEvt(EVENT_ID_MAIL_ENTER);
end

function Net.sendMailGet(dbid,isDel)
    local media=MediaObj:create()
    media:setLong("dbid", dbid)
    media:setBool("del", isDel)
    Net.sendExtensionMessage(media, CMD_MAIL_GET)
end

function Net.rec_mail_get(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    Net.updateReward(obj:getObj("reward"),2)

    local eId = obj:getLong("dbid");
    local del = obj:getBool("del");
    for key, var in pairs(Data.mail.list) do
        if(var.eId == eId)then
            var.bolRead = true;
            break;
        end
    end
    if (del) then
        Net.deleteOneEmail(eId);
        gDispatchEvt(EVENT_ID_MAIL_DEL);
    else
        gDispatchEvt(EVENT_ID_MAIL_GET);
    end
    Net.dealRedDot_Mail();
end

function Net.sendMailDel(dbid)
    local media=MediaObj:create()
    media:setLong("dbid", dbid);
    Net.sendExtensionMessage(media, CMD_MAIL_DEL)
end

function Net.rec_mail_del(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local eId = obj:getLong("dbid");
    Net.deleteOneEmail(eId);
    Net.dealRedDot_Mail();
    gDispatchEvt(EVENT_ID_MAIL_DEL);
end

function Net.sendMailRead(dbid)
    local media=MediaObj:create()
    media:setLong("dbid", dbid)
    Net.sendExtensionMessage(media, CMD_MAIL_READ)
end

function Net.rec_mail_read(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local eId = obj:getLong("dbid");
    for key, var in pairs(Data.mail.list) do
        if(var.eId == eId and (var.type == 0 or var.type == 1))then
            var.bolRead = true;
            gDispatchEvt(EVENT_ID_MAIL_READ,var);
            break;
        end
    end
    Net.dealRedDot_Mail();
end

function Net.mail_sort()
    local function sort(a, b)
        if a.bolRead == b.bolRead then
            return a.time > b.time
        elseif b.bolRead then
            return true
        else
            return false
        end
    end
    table.sort(Data.mail.list, sort)
end

function Net.deleteOneEmail(eId)
    for key, var in pairs(Data.mail.list) do
        if(var.eId == eId)then
            table.remove(Data.mail.list,key)
            break;
        end
    end
end

function Net.dealRedDot_Mail()
    for key, var in pairs(Data.mail.list) do
        if (not var.bolRead) then
            Data.redpos.bolNewMail = true
            return
        end
    end
    Data.redpos.bolNewMail = false
    -- EventListener::sharedEventListener()->handleEvent(c_event_redDot_Email);
end
