GuideStepData.draw={}

function  GuideStepData.draw.initGuide() 
   


    guide={}
    guide.id=GUIDE_ID_DRAW_CARD_GOLD --钻石抽卡 
    step1={paths={"main_bg",0,"dragon"},storyid=27}
    step2={paths={"panel",PANEL_DRAW_CARD,"btn_buy_gold_one"} ,storyid=199}
    guide.steps={step1,step2}
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_DRAW_CARD_DIA --钻石抽卡 
    step1={paths={"main_bg",0,"dragon"},storyid=27}
    step2={paths={"panel",PANEL_DRAW_CARD,"btn_buy_dia_one"} ,storyid=29}
    guide.steps={step1,step2}
    table.insert(GuideData.guides,guide)




    guide={}
    guide.id=GUIDE_ID_DRAW_END_1 --退出抽卡
    step1={ paths={"dragon",PANEL_DRAW_CARD_REWARD,"btn_close"} }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_DRAW_END_2 --退出抽卡
    step1={paths={"panel",PANEL_DRAW_CARD,"btn_close"}  }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

    --抽卡后对话
    GuideData.initStoryGuide(GUIDE_ID_DRAW_END_3,163)  
end


function  GuideStepData.draw.guide()
    --如果孙尚香 就不出这个引导
    
    --有孙尚香
    if(Data.getUserCardById(10005))then
        return
    end
    
    if(Data.getUserCardById(GUID_CARDID))then
        return
    end

    if(Data.getUserCardById(10030)==nil)then
        Guide.dispatch(GUIDE_ID_DRAW_CARD_GOLD)
        Guide.dispatch(GUIDE_ID_DRAW_END_1)
    end

    
    
    
    Guide.dispatch(GUIDE_ID_DRAW_CARD_DIA)
    Guide.dispatch(GUIDE_ID_DRAW_END_1)
    Guide.dispatch(GUIDE_ID_DRAW_END_2)
    Guide.dispatch(GUIDE_ID_DRAW_END_3)

end