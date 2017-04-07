GuideStepData.secondAtlas={}

function  GuideStepData.secondAtlas.initGuide() 
    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE2 -- 选择关卡
    step1={paths={"main_bg",0,"atlas"}} --主界面副本icon
    step2={paths={"panel",PANEL_ATLAS,"1_2"}}--选关卡按钮
    step3={paths={"panel",PANEL_ATLAS_ENTER,"btn_enter"}}--选关卡按钮
    guide.steps={step1,step2,step3}
    table.insert(GuideData.guides,guide) 


    local guide={}
    guide.id=GUIDE_ID_ENTER_BATTLESPEEDUP
    guide.steps={
        {paths={"battle",0,"btn_speed"},storyid=77},
    }
    table.insert(GuideData.guides,guide);
    

    guide={}
    guide.id=GUIDE_ID_EDIT_FORMATION2--调整阵容
    guide.needFlag=true
    step1={
        paths={"panel",PANEL_ATLAS_FORMATION,"0_"..GUID_CARDID},
        hideBlackBg=1,
        enterEvent=GUIDE_EVENT_ID_START_FORMATION,
        exitEvent=GUIDE_EVENT_ID_END_FORMATION,
        dragTarget={"panel",PANEL_ATLAS_FORMATION,"1_0"},
        storyid=255,
        storyPos=7,
        storyOffsetX=270,
        storyOffsetY=-100,
    }--部署阵容2
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
    
    
    
    guide={}
    guide.id=GUIDE_ID_EDIT_FORMATION3--调整阵容
    guide.needFlag=true
    step1={
        paths={"panel",PANEL_ATLAS_FORMATION,"0_10030"},
        hideBlackBg=1,
        enterEvent=GUIDE_EVENT_ID_START_FORMATION,
        exitEvent=GUIDE_EVENT_ID_END_FORMATION,
        dragTarget={"panel",PANEL_ATLAS_FORMATION,"1_2"},  
        storyid=255,
        storyPos=7,
        storyOffsetX=270,
        storyOffsetY=-100,
    }--部署阵容2
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_START_ATLAS2 --开始副本
    guide.needFlag=true
    step1={paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"} ,storyid=164}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE2_END --退出副本
    guide.needFlag=true
    step1={paths={"panel",PANEL_ATLAS_FINAL,"btn_win_exit"}  }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
end

function  GuideStepData.secondAtlas.firstEnterAltas(mapid,stageid,type)
    if(type==0 and mapid==1 and stageid==2)then
        if(battleLayer)then
            battleLayer:setPause()
        end 
        Guide.dispatch(GUIDE_ID_ENTER_BATTLESPEEDUP,1)
    end
end
function  GuideStepData.secondAtlas.guide() 

    if(Data.isPassAtlas(1,2,0))then
        return 
    end
    
    Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE2)
    if(gCurGuide<GUIDE_ID_EDIT_FORMATION3)then
        Guide.dispatch(GUIDE_ID_EDIT_FORMATION2) 
    end
    

    if(gCurGuide<GUIDE_ID_START_ATLAS2)then
        Guide.dispatch(GUIDE_ID_EDIT_FORMATION3) 
    end

    Guide.dispatch(GUIDE_ID_START_ATLAS2)
    Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE2_END)   

end