GuideStepData.onlineGift={}

function  GuideStepData.onlineGift.initGuide()  


 
    guide={}
    guide.id=GUIDE_ID_ONLINE_GIFT_1 
    guide.needFlag=true
    step1={paths={"main",0,"btn_online_gift"}}
    step2={paths={"panel",PANEL_ONLINE_GIFT,"btn_get"}  }
    guide.steps={step1,step2}
    table.insert(GuideData.guides,guide)
    
    GuideData.initSmallStoryGuide(GUIDE_ID_ONLINE_GIFT_2,114,3)
 
end


function  GuideStepData.onlineGift.guide() 

    if(gCurGuide>=GUIDE_ID_ONLINE_GIFT_1)then
        return
    end
    
    if(Data.m_onlineInfo.bolOnline ==false)then
        return
    end
    
    Guide.dispatch(GUIDE_ID_ONLINE_GIFT_1) 
    Guide.dispatch(GUIDE_ID_ONLINE_GIFT_2) 
end