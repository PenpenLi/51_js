local CrusadeItem=class("CrusadeItem",UILayer)

function CrusadeItem:ctor()
    self:init("ui/ui_crusade_item.map") 
    self:getNode("info_panel"):setVisible(false)

    self:getNode("btn_shared"):setVisible(false)
    self:getNode("btn_share"):setVisible(false)
    self:getNode("txt_per"):setVisible(false)
    self:getNode("bar"):setVisible(false)
    self:getNode("icon"):setVisible(false)
    self:getNode("btn_fight"):setVisible(false)
    

    local redBar=cc.ProgressTimer:create(cc.Sprite:create("images/ui_crusade/blood_big.png"))  
    self:getNode("bar"):getParent():addChild(redBar,10)
    redBar:setPositionX(self:getNode("bar"):getPositionX() ) 
    redBar:setPositionY(self:getNode("bar"):getPositionY() ) 
    redBar:setRotation(180)
    self:getNode("btn_fight").oldX=self:getNode("btn_fight"):getPositionX()
    self.redBar=redBar
end

function CrusadeItem:setData(data)
    --[[
    ——id        long    叛军ID
    ——cid       int 卡牌ID
    ——name      String  叛军名称
    ——lv        int 等级
    ——hp        int 当前血量
    ——hpmax     int 血量上限
    ——fid       long    发现者ID
    ——fname     String  发现者名称
    ——share     bool    是否分享
    ——endtime       int 叛军逃跑时间
    ]] 
    data.name = gGetMonsterName(data.mid,data.name)
    self:getNode("icon"):setVisible(true)
    self:getNode("info_panel"):setVisible(true)
    self:getNode("txt_per"):setVisible(true)
    self:getNode("btn_fight"):setVisible(true)
    self.curData=data
    self:replaceLabelString("txt_fname",data.fname)
   -- self:setLabelString("txt_fname",data.fname)
    self:setLabelString("txt_name",data.name.." Lv"..data.lv)
    self:getNode("txt_name"):setColor(gGetItemQualityColor(data.quality))

    self:setLabelString("txt_per",data.hp.."/"..data.hpmax)
    local per=data.hp/data.hpmax

    self.redBar:setPercentage(per*100)
    

    local role = gCreateFlaDislpay("r"..data.cid.."_wait",0,"r"..data.cid.."_wait");
    role:setScale(0.4) 
    self:getNode("icon"):replaceBoneWithNode({"ship","npc" },role);
     

    self:setTouchEnable("btn_shared",false,true)
    
    
    if(self.curData.fid==gUserInfo.id)then

        if(data.share)then
            self:getNode("btn_shared"):setVisible(true)
            self:getNode("btn_share"):setVisible(false)
        else
            self:getNode("btn_shared"):setVisible(false)
            self:getNode("btn_share"):setVisible(true)
        end
    else
        self:getNode("btn_shared"):setVisible(false)
        self:getNode("btn_share"):setVisible(false)
        self:getNode("btn_fight"):setPositionX(self:getNode("btn_fight").oldX-40)
    end

end


function CrusadeItem:onTouchEnded(target)

    if  target.touchName=="btn_share"then
        Net.sendCrusadeShare(self.curData.id)
    elseif target.touchName=="btn_show" or  target.touchName=="btn_fight" then
        if(self.curData==nil)then
            return
        end
        Panel.popUp(PANEL_CRUSADE_ENTER,self.curData)
    end

end


return CrusadeItem