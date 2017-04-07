GuideStepData={}
GuideStepData.firstAtlas={}

function  GuideStepData.firstAtlas.initGuide() 
    guide={}
    guide.id=GUIDE_ID_ATLAS_FIRST_ENTER_1--主场景点击副本前对话
    step1={
        param=38,
        enterEvent=EVENT_ID_GUIDE_SHOW_STORY,
        exitEvent=EVENT_ID_GUIDE_ENTER_ATLAS
    }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)




    guide={}
    guide.id=GUIDE_ID_ATLAS_FIRST_ENTER_2 --进入副本
    step1={paths={"main_bg",0,"atlas"},storyid=23} --主界面副本icon
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


 


    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE -- 选择关卡
    step1={paths={"panel",PANEL_ATLAS,"1_1"},
        storyid=24}--选关卡按钮
    step2={paths={"panel",PANEL_ATLAS_ENTER,"btn_enter"},storyid=25}--选关卡按钮
    guide.steps={step1,step2}
    table.insert(GuideData.guides,guide)




    guide={}
    guide.id=GUIDE_ID_EDIT_FORMATION--调整阵容
    step1={
        paths={"panel",PANEL_ATLAS_FORMATION,"0_10103"},
        hideBlackBg=1,
        enterEvent=GUIDE_EVENT_ID_START_FORMATION,
        exitEvent=GUIDE_EVENT_ID_END_FORMATION,
        dragTarget={"panel",PANEL_ATLAS_FORMATION,"1_1" },
        storyid=255,
        storyPos=7,
        storyOffsetX=270,
        storyOffsetY=-100,
        effect="v13.mp3", 
    }--部署阵容1
    guide.steps={step1}
    table.insert(GuideData.guides,guide)



    guide={}
    guide.id=GUIDE_ID_START_ATLAS1 --开始副本
    guide.needFlag=true
    step1={paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"} ,storyid=36}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

 



    --手动战斗1
    guide={}
    guide.id=GUIDE_ID_GUIDE_SELECT_GUIDE_BATTLE2_CARD1 
    step1={paths={"battle",0,"2_1"}  }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
 


    guide={}
    guide.id=GUIDE_ID_ATLAS_END --退出副本
    guide.needFlag=true
    step1={paths={"panel",PANEL_ATLAS_FINAL,"btn_win_exit"} ,storyid=26 }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


  --[[  guide={}
    guide.id=GUIDE_ID_ATLAS_END_AFTER_STORY--退出副本后对话
    step1={ 
        param=17,
        enterEvent=EVENT_ID_GUIDE_SHOW_STORY 
    }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
]]
    guide={}
    guide.id=GUIDE_ID_ATLAS_FIRST_ENTER_END --退出副本关卡界面
    step1={paths={"panel",PANEL_ATLAS,"btn_close"} ,storyid=79}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
end


function  GuideStepData.firstAtlas.guide()

    
    --如果打过第一场战斗 不出引导
    if(Data.isPassAtlas(1,1,0))then
        return
    end

    Guide.dispatch(GUIDE_ID_ATLAS_FIRST_ENTER_1)
    Guide.dispatch(GUIDE_ID_ATLAS_FIRST_ENTER_2)
    Guide.dispatch(GUIDE_ID_ATLAS_FIRST_ENTER_3)
    Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE)
    if(gCurGuide<GUIDE_ID_START_ATLAS1)then
        Guide.dispatch(GUIDE_ID_EDIT_FORMATION) 
    end
    Guide.dispatch(GUIDE_ID_START_ATLAS1)
    --Guide.dispatch(GUIDE_ID_MANUAL_FIGHT_1) 
    --Guide.dispatch(GUIDE_ID_MANUAL_FIGHT_2) 
    Guide.dispatch(GUIDE_ID_ATLAS_END)
   -- Guide.dispatch(GUIDE_ID_ATLAS_END_AFTER_STORY)
    Guide.dispatch(GUIDE_ID_ATLAS_FIRST_ENTER_END)

end