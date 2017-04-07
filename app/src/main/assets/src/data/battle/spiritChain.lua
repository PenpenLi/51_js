local SpiritChain=class("SpiritChain")



function SpiritChain:ctor(  mcid,  mpos,  posVec)
    self.masterCardId =mcid ---主体卡牌ID
    self.chainPos={}
    for i=0, 2 do
        self.chainPos[i] =-1
    end
    self.chainPos[0] =mpos;
    for key, var in pairs(posVec) do
        self.chainPos[key] =var;
    end

    self.skillId0 = 0---灵魂状态大招技能
    self.skillId1 = 0---灵魂状态小招技能
    if(self.masterCardId == Card_MIKU)then
        local spcard = DB.getCardById(Card_MIKU_SPIRIT)
        self.skillId0 = spcard.skillid0;
        self.skillId1 = spcard.skillid1;
    end

end

function SpiritChain:isInChain(  pos) 
    for i=0, 2 do
        if(self.chainPos[i] == pos)then
            return true;
        end
    end
    return false;
end

function SpiritChain:getChainAliveNum(  playerCards)
    local count = 0;
    local chainPos=self.chainPos
    for i=0, 2 do
        if(chainPos[i] ~= -1 and playerCards[chainPos[i]] ~= nil and playerCards[chainPos[i]]:isAlive())then
            count=count+1
        end
    end
    return count;
end


return SpiritChain