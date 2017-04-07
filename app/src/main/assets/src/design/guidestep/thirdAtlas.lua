GuideStepData.thirdAtlas={}

function  GuideStepData.thirdAtlas.initGuide()  
    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE3 -- 选择关卡
    step1={paths={"main_bg",0,"atlas"}} --主界面副本icon
    step2={paths={"panel",PANEL_ATLAS,"1_3"}}--选关卡按钮
    step3={paths={"panel",PANEL_ATLAS_ENTER,"btn_enter"}}--选关卡按钮
    guide.steps={step1,step2,step3}
    table.insert(GuideData.guides,guide) 




    --手动战斗1
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_ATLAS3_ROLE 
    step1={paths={"battle",0,"2_1"} ,storyid=80}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)



    guide={}
    guide.id=GUIDE_ID_START_ATLAS3 --开始副本
    step1={paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE3_END --退出副本
    guide.needFlag=true
    step1={paths={"panel",PANEL_ATLAS_FINAL,"btn_win_exit"}  }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
end



function  GuideStepData.thirdAtlas.guide()
 
    if(Data.isPassAtlas(1,3,0))then
        return 
    end
    Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE3) 
    Guide.dispatch(GUIDE_ID_START_ATLAS3)
    Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE3_END) 

end