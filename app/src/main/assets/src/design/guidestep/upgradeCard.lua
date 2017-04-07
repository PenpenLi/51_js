GuideStepData.upgradeCard={}

function  GuideStepData.upgradeCard.initGuide()  



    guide={}
    guide.id=GUIDE_ID_UPGRADE_CARD_1 
    guide.needFlag=true
    step1={paths={"main",0,"btn_menu"} ,storyid=90,enterEvent=EVENT_ID_GUIDE_SHOW_MAINLAYER_MENU} --主界面btn_hero
    step2={paths={"main",0,"btn_hero"} } --主界面btn_hero
    step3={paths={"panel",PANEL_CARD,"0_10030"} }--选择卡牌
    step4={paths={"panel",PANEL_CARD_INFO,"btn_evolve"},storyid=91}--  
    guide.steps={step1,step2,step3,step4}
    table.insert(GuideData.guides,guide)   

    guide={}
    guide.id=GUIDE_ID_UPGRADE_CARD_2
    guide.needFlag=true
    step1={paths={"panel",PANEL_CARD_UP_QUALITY,"level_up_bg"},hideArrow=true}--  
    guide.steps={step1}
    table.insert(GuideData.guides,guide)   
    
    GuideData.initStoryGuide(GUIDE_ID_UPGRADE_CARD_3,92)

end


function  GuideStepData.upgradeCard.guide()
 
    
end