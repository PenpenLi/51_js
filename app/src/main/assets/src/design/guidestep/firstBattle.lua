GuideStepData.firstBattle={}

function  GuideStepData.firstBattle.initGuide()  
    --[[





]]

    --幕府教学  194
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD1  
    step1={ paths={"battle",0,"2_0"} ,storyid=194}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

    --春丽教学   195
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD2  
    step1={paths={"battle",0,"2_4"},storyid=195}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

    --草泥马      196
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD3_1 
    step1={paths={"battle",0,"2_3"},storyid=196}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD3_2 
    step1={paths={"battle",0,"2_4"}}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
    

    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD3_3 
    step1={paths={"battle",0,"2_5"}}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


    --东方         197
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD4
    step1={paths={"battle",0,"2_4"},storyid=197}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
    
    --大剑豪      198
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD5
    step1={paths={"battle",0,"2_4"},storyid=198}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
    
    
    --合体技      208
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE1_CARD6
    step1={paths={"battle",0,"2_4"},storyid=208}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
    
    guide={}
    guide.id=GUIDE_ID_COOPERATE_SKILL_4
    step1={paths={"battle",0,"touch_mode"},storyid=94,storyPos=6}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

end


function  GuideStepData.firstBattle.guide() 
 
end