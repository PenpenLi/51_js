GuideStepData.recurit={}

function  GuideStepData.recurit.initGuide()  
    local guide={}
    guide.id=GUIDE_ID_RECURIT_1
    guide.needFlag=true
    guide.steps={
        {paths={"main",0,"btn_menu"},storyid=84,enterEvent=EVENT_ID_GUIDE_SHOW_MAINLAYER_MENU},
        {paths={"main",0,"btn_hero"}}, 
        {paths={"panel",PANEL_CARD,"0_10027/btn_comp_card"},storyid=85} 
        
    } 
    table.insert(GuideData.guides,guide);  
    

    local guide={}
    guide.id=GUIDE_ID_RECURIT_2 
    guide.steps={
        {paths={"panel",PANEL_NEW_CARD,"level_up_bg"},hideArrow=true},  
    } 
    table.insert(GuideData.guides,guide);  
    
    GuideData.initStoryGuide(GUIDE_ID_RECURIT_3,86)


    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE5 -- 选择关卡
    step1={paths={"main_bg",0,"atlas"}} --主界面副本icon
    step2={paths={"panel",PANEL_ATLAS,"1_5"}}--选关卡按钮
    step3={paths={"panel",PANEL_ATLAS_ENTER,"btn_enter"}}--选关卡按钮
    guide.steps={step1,step2,step3}
    table.insert(GuideData.guides,guide) 


    guide={}
    guide.id=GUIDE_ID_EDIT_FORMATION4--调整阵容 
    step1={
        paths={"panel",PANEL_ATLAS_FORMATION,"2_"},
        hideBlackBg=1,
        enterEvent=GUIDE_EVENT_ID_START_FORMATION,
        exitEvent=GUIDE_EVENT_ID_END_FORMATION,
        dragTarget={"panel",PANEL_ATLAS_FORMATION,"1_2"}
    }--部署阵容3
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
    


    guide={}
    guide.id=GUIDE_ID_START_ATLAS5 --开始副本
    guide.needFlag=true
    step1={paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"} }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE5_END --退出副本
    guide.needFlag=true
    step1={paths={"panel",PANEL_ATLAS_FINAL,"btn_win_exit"}  }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
end


function  GuideStepData.recurit.guide()

 

end