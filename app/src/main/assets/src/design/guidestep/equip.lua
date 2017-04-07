GuideStepData.equip={}

function  GuideStepData.equip.initGuide() 

    --装备前对话
    GuideData.initStoryGuide(GUIDE_ID_EQUIP_ITEM_1,40) 

    guide={}
    guide.id=GUIDE_ID_EQUIP_ITEM_2--装备 
    guide.needFlag=true
    step1={paths={"main",0,"btn_menu"},storyid=30} --主界面btn_hero
    step2={paths={"main",0,"btn_hero"},storyid=31} --主界面btn_hero
    step3={paths={"panel",PANEL_CARD,"0_1"},storyid=32}--选择卡牌
    step4={paths={"panel",PANEL_CARD_INFO,"equip0"},storyid=33}-- 
    step5={paths={"panel",PANEL_CARD_INFO,"btn_put"},storyid=37}-- 
    guide.steps={step1,step2,step3,step4,step5}
    table.insert(GuideData.guides,guide)



    --进阶前对话
    GuideData.initStoryGuide(GUIDE_ID_EQUIP_UPQUALITY_1,21) 
    guide={}
    guide.id=GUIDE_ID_EQUIP_UPQUALITY_2--进阶 
    guide.needFlag=true
    step1={paths={"main",0,"btn_menu"},storyid=30} --主界面btn_hero
    step2={paths={"main",0,"btn_hero"},storyid=31} --主界面btn_hero
    step3={paths={"panel",PANEL_CARD,"0_1"},storyid=32}--选择卡牌
    step4={paths={"panel",PANEL_CARD_INFO,"equip0"},storyid=33}-- 
    step5={paths={"panel",PANEL_CARD_INFO,"btn_upquality"},storyid=34}
    guide.steps={step1,step2,step3,step4,step5}
    table.insert(GuideData.guides,guide)  
    --进阶后对话
    GuideData.initStoryGuide(GUIDE_ID_EQUIP_UPQUALITY_3,22)





    --强化装备
    guide={}
    guide.id=GUIDE_ID_UPGRADE_EQUIP_ITEM_1--强化    
    guide.needFlag=true
    step1={paths={"main",0,"btn_menu"},storyid=30} --主界面btn_hero
    step2={paths={"main",0,"btn_hero"},storyid=31} --主界面btn_hero
    step3={paths={"panel",PANEL_CARD,"0_1"},storyid=32}--选择卡牌
    step4={paths={"panel",PANEL_CARD_INFO,"equip0"},storyid=33}-- 
    step5={paths={"panel",PANEL_CARD_INFO,"var:equipPanel/btn_upgrade"},storyid=81}
    guide.steps={step1,step2,step3,step4,step5}
    table.insert(GuideData.guides,guide) 


    --强化装备后对话
    GuideData.initStoryGuide(GUIDE_ID_UPGRADE_EQUIP_ITEM_2,82)
    GuideData.initExitCardGuide()

 
end


function  GuideStepData.equip.guide()

    if(gCurGuide>=GUIDE_ID_UPGRADE_EQUIP_ITEM_1)then
        return
    end
    
    local card=Data.getUserCardById(10103)
    if(card==nil)then
        return 
    end
    

    if(gCurGuide<GUIDE_ID_EQUIP_ITEM_2)then 
        Guide.dispatch(GUIDE_ID_EQUIP_ITEM_1)
        Guide.dispatch(GUIDE_ID_EQUIP_ITEM_2)
   else 
        Net.hasRecEquipActivateOneKey=true 
    end


    if(card.equipQuas[0]==0 and gCurGuide<GUIDE_ID_EQUIP_UPQUALITY_2)then 
        Guide.dispatch(GUIDE_ID_EQUIP_UPQUALITY_1) 
        Guide.dispatch(GUIDE_ID_EQUIP_UPQUALITY_2)
        Guide.dispatch(GUIDE_ID_EQUIP_UPQUALITY_3)
    end



    if(gCurGuide<GUIDE_ID_UPGRADE_EQUIP_ITEM_1)then 
        Guide.dispatch(GUIDE_ID_UPGRADE_EQUIP_ITEM_1)
        Guide.dispatch(GUIDE_ID_UPGRADE_EQUIP_ITEM_2) 
    end


    Guide.dispatch(GUIDE_ID_EQUIP_EXIT)
    Guide.dispatch(GUIDE_ID_CARD_LIST_EXIT) 
end