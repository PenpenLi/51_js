Unlock.system.mine = {}
Unlock.system.mine.unlockType = SYS_MINE;
local Unlockdbid = 24;
local unlockType = Unlock.system.mine.unlockType;
function Unlock.system.mine.isUnlock(isShowNotice)
    --这里用的是神器的
    if(Data.getSysIsUnlock(SYS_WEAPON))then
        return true;
    end
    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.mine.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.mine.unlockType]
    --         ,gGetWords("unlockWords.plist","name"..Unlock.system.mine.unlockType));
    --     gShowNotice(word);
    -- end

    -- return false;
end

function Unlock.system.mine.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.mine.guideEnter();
    end
end

function Unlock.system.mine.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_MINE1
    guide.steps={
                    {paths={"main_bg",0,"wakuang"},storyid=174}, --TODO
                }
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_ENTER_MINE2
    guide.steps={
                    {paths={"panel",PANEL_DIG_MINE,"1_4"},storyid=175},
                }
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_ENTER_MINE3
    guide.steps={
                    {paths={"panel",PANEL_DIG_MINE,"btn_rule"},storyid=176},
                }
    table.insert(GuideData.guides,guide)
end

function Unlock.system.mine.guide()
end

function Unlock.system.mine.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_MINE2);
    Guide.dispatch(GUIDE_ID_ENTER_MINE3); 
end
function Unlock.system.mine.show()
    Unlock.showMainBgEnter(Unlock.system.mine.unlockType,Unlock.system.mine.isUnlock())
end


