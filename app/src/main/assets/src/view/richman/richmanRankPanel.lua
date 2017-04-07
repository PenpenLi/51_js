local RichmanRankPanel=class("RichmanRankPanel",UILayer)

function RichmanRankPanel:ctor(type)
    self:init("ui/ui_richman_rank.map")
    self._panelTop = true;
    -- print("type="..type);

    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll").scrollBottomCallBack = function()
        self:onMoveDown();
    end
    self.iShowIndex = 0;
    self.iShowMax = 100;
    self.iShowSize = 10;
    self.ranks = nil;
    self:selectBtn("btn_rank")
    self:initRankArena(gRichman.ranks)
end



function RichmanRankPanel:resetBtnTexture()
    local btns={
        "btn_reward",
        "btn_rank",
    }

    for key, btn in pairs(btns) do
        self:getNode(btn.."_panel"):setVisible(false)
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end

end
function RichmanRankPanel:selectBtn(name)
    self:resetBtnTexture()
    self:getNode(name.."_panel"):setVisible(true)
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function  RichmanRankPanel:events()
    return { }
end
function RichmanRankPanel:dealEvent(event,param)

end


function RichmanRankPanel:initRankArena(data)
    self:getNode("scroll"):clear()


    self.ranks = gRichman.ranks;
    self.iShowMax = table.getn(self.ranks);
    self.iShowIndex = 0;
    self:onMoveDown();

    self:replaceLabelString("txt_score",gRichman.lastscore)
    self:replaceLabelString("txt_rank",gRichman.lastrank)

end

function RichmanRankPanel:onMoveDown()
    if (self.iShowIndex>=self.iShowMax) then
        return;
    end
    for i=1+self.iShowIndex,self.iShowSize+self.iShowIndex do
        local key = i
        if (key<=table.getn(self.ranks)) then
            local var = self.ranks[key]
            local item=RichmanRankItem.new()
            item:setData(var,key)
            self:getNode("scroll"):addItem(item)
        end
    end
    self:getNode("scroll"):layout(self.iShowIndex==0)
    self.iShowIndex = self.iShowIndex + self.iShowSize;
    self.iShowIndex = math.min(self.iShowIndex,self.iShowMax)

end


function  RichmanRankPanel:showReward()
    if(self.rewardInited==true)then
        return 
    end
    self.rewardInited=true
    self:getNode("scroll_reward"):clear()
    
    local preData=nil
    for key, var in pairs(richmanrankreward_db) do
 
        local item=RichmanRankReward.new()
        item:setData(var,preData,key)
        preData=var
        self:getNode("scroll_reward"):addItem(item)
    end
    self:getNode("scroll_reward"):layout()

end

function RichmanRankPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_reward"then
        self:selectBtn("btn_reward")
        self:showReward()
    elseif  target.touchName=="btn_rank"then
        self:selectBtn("btn_rank")
    end
end



return RichmanRankPanel