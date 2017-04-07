local ExpBar=class("ExpBar",UILayer)

function ExpBar:ctor()
    self:init("ui/battle_resule_exp.map")
end
 
function   ExpBar:setExpInfo(lev, exp, addExp)
    if(addExp==nil)then
        addExp=0
    end

    if isBanshuReview() then
        local str = gGetWords("item.plist","item_id_90004")
        self:setLabelString("txt_exp_name",str)
        local px,py = self:getNode("txt_exp_name"):getPosition()
        self:getNode("txt_exp_name"):setPosition(cc.p(px-8,py))
    end
    
    self:setLabelString("txt_exp_value","+"..addExp)
    local preLev,preExp=self:calculatePerLv(lev, exp, addExp) 
    self:showExpUp("bar_exp",preLev, lev, preExp, exp)
    if preLev ~= lev then
        return true
    end
    return false
end

function  ExpBar:calculatePerLv(lv,exp,addExp)
    local preLv = lv
    local preExp = exp
    
    local preExp = exp-addExp
    while(preExp < 0)do
        preLv = preLv-1
        local maxExp = DB.getCardExpByLevel(preLv)
        preExp = preExp + maxExp
    end
    return preLv,preExp
end

function ExpBar:showExpUp(name,preLv,newLv,preExp,newExp) 
    local function checkAdd()
        if(preLv==newLv)then
            local maxExp=DB.getCardExpByLevel(newLv)
            self:setBarPerAction(name,  preExp/maxExp, newExp/maxExp)
        else 
            local maxExp=DB.getCardExpByLevel(preLv)
            self:setBarPerAction(name,  preExp/maxExp, 1,checkAdd)
            preExp=0
            preLv=preLv+1
        end 
    end 
    checkAdd()
end

return ExpBar