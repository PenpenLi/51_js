local ServerItem=class("ServerItem",UILayer)

function ServerItem:ctor()
    self:init("ui/ui_server_item.map")

end




function ServerItem:onTouchEnded(target)
 
    if( self.onSelectCallback)then
        self.onSelectCallback()
    end
end
function ServerItem:setStatusIcon(status)
    --[[
        status  0,1,2,3,4,5,6
        "火爆","关闭注册","新服","暂未开启","维护中","隐藏状态" 
    ]]
    if(status==0)then --火爆
        self:changeTexture("icon","images/ui_word/s_huobao.png")
    elseif(status==1)then
        self:changeTexture("icon","images/ui_word/s_zheng.png")

    elseif(status==2)then --新服
        self:changeTexture("icon","images/ui_word/s_xinfu.png")

    elseif(status==3)then
        self:changeTexture("icon","images/ui_word/s_zheng.png")

    elseif(status==4)then --维护
        self:changeTexture("icon","images/ui_word/s_weihu.png")

    elseif(status==5)then
        self:changeTexture("icon","images/ui_word/s_zheng.png")

    elseif(status==6)then
        self:changeTexture("icon","images/ui_word/s_zheng.png")
    end
end

function gGetServerTag(data)
    local tag="S"
    if(data.pub)then
        tag="P"
    end
    return tag
end

function   ServerItem:setData(data)
    self.curData=data
    self:setLabelString("txt_name",data.name)
    local showid= data.showid
    if showid == nil then
         showid = data.id
     end 
    if isBanshuReview() then
        self:setLabelString("txt_num",(showid%1000).."服") 
    else
        

        self:setLabelString("txt_num",gGetServerTag(data)..(showid%1000)) 
    end
    self:setStatusIcon(toint(data.status))
    self.curStaus=toint(data.status)

end



return ServerItem