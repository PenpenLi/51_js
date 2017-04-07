GuideStepData.taskReward={}

function  GuideStepData.taskReward.initGuide()


    guide={}
    guide.id=GUIDE_ID_GET_NEW_TASK_REWARD1
    guide.steps={
        {paths={"main_bg",0,"atlas"}},
        {paths={"panel",PANEL_ATLAS,"btn_task"},storyid=200},
        {paths={"panel",PANEL_NEWTASK,"btn_get"},  exitEvent=EVENT_ID_PLAY_SOUND,param="v30.mp3",},
    }
    table.insert(GuideData.guides,guide)



    guide={}
    guide.id=GUIDE_ID_GET_NEW_TASK_REWARD2
    guide.steps={
        {paths={"main_bg",0,"atlas"}},
        {paths={"panel",PANEL_ATLAS,"btn_task"},storyid=201},
        {paths={"panel",PANEL_NEWTASK,"btn_get"},  exitEvent=EVENT_ID_PLAY_SOUND,param="v31.mp3",},
    }
    table.insert(GuideData.guides,guide)



    guide={}
    guide.id=GUIDE_ID_GET_NEW_TASK_REWARD3
    guide.steps={
        {paths={"main_bg",0,"atlas"}},
        {paths={"panel",PANEL_ATLAS,"btn_task"},storyid=203},
        {paths={"panel",PANEL_NEWTASK,"btn_get"},  exitEvent=EVENT_ID_PLAY_SOUND,param="v34.mp3",},
    }
    table.insert(GuideData.guides,guide)



    guide={}
    guide.id=GUIDE_ID_GET_NEW_TASK_REWARD4
    guide.steps={
        {paths={"main_bg",0,"atlas"}},
        {paths={"panel",PANEL_ATLAS,"btn_task"}},
        {paths={"panel",PANEL_NEWTASK,"btn_get"},storyid=205 },
    }
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_GET_NEW_TASK_CLOSE
    guide.steps={
        {paths={"main_bg",0,"atlas"}},
        {paths={"panel",PANEL_ATLAS,"btn_task"}},
        {paths={"panel",PANEL_NEWTASK,"btn_go"}},
    }
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_GET_NEW_TASK_CLOSE2
    guide.steps={
        {paths={"main_bg",0,"atlas"}},
        {paths={"panel",PANEL_ATLAS,"btn_task"}},
        {paths={"panel",PANEL_NEWTASK,"btn_close"}}, 
    }
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_GET_NEW_TASK_CLOSE3 --退出英雄列表
    step1={
        paths={"panel",PANEL_CARD,"btn_close"} ,
        exitEvent=EVENT_ID_GUIDE_ATLAS_NEXT_ITEM
    }
    guide.steps={step1}
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE4 -- 选择关卡
    step1={paths={"main_bg",0,"atlas"}} --主界面副本icon
    step2={paths={"panel",PANEL_ATLAS,"1_4"}}--选关卡按钮
    guide.steps={step1,step2}
    table.insert(GuideData.guides,guide)


    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE6 -- 选择关卡
    step1={paths={"main_bg",0,"atlas"}} --主界面副本icon
    step2={paths={"panel",PANEL_ATLAS,"1_6"}}--选关卡按钮
    guide.steps={step1,step2}
    table.insert(GuideData.guides,guide)



    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE8 -- 选择关卡
    step1={paths={"main_bg",0,"atlas"}} --主界面副本icon
    step2={paths={"panel",PANEL_ATLAS,"1_8"}}--选关卡按钮
    step3={paths={"panel",PANEL_ATLAS_ENTER,"btn_enter"}}--选关卡按钮
    guide.steps={step1,step2,step3}
    table.insert(GuideData.guides,guide)
    

    guide={}
    guide.id=GUIDE_ID_EDIT_FORMATION8--调整阵容
    step1={
        paths={"panel",PANEL_ATLAS_FORMATION,"2_"},
        hideBlackBg=1,
        enterEvent=GUIDE_EVENT_ID_START_FORMATION,
        exitEvent=GUIDE_EVENT_ID_END_FORMATION,
        dragTarget={"panel",PANEL_ATLAS_FORMATION,"1_3" }, 
    }--部署阵容1
    guide.steps={step1}
    table.insert(GuideData.guides,guide)

    
    guide={}
    guide.id=GUIDE_ID_ATLAS_SELECT_STAGE21 -- 选择关卡
    step1={paths={"main_bg",0,"atlas"}} --主界面副本icon
    step2={paths={"panel",PANEL_ATLAS,"2_1"}}--选关卡按钮
    guide.steps={step1,step2}
    table.insert(GuideData.guides,guide)
    

    GuideData.initStoryGuide(GUIDE_ID_ATLAS_SELECT_STAGE21_STORY,216)  

end


function  GuideStepData.taskReward.guide()

    if( Data.redpos.bolNewTask and gNewTaskType == 1)then

        Guide.changeStack()
        if(Data.isPassAtlas(1,4,0)==false)then
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_REWARD1,1)
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_CLOSE);
        elseif(Data.isPassAtlas(1,6,0)==false)then
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_REWARD2,1)
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_CLOSE);
        elseif(Data.isPassAtlas(1,8,0)==false)then
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_REWARD3)
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_CLOSE2);
            Guide.dispatch(GUIDE_ID_RECURIT_1)
            Guide.dispatch(GUIDE_ID_RECURIT_2)
            Guide.dispatch(GUIDE_ID_RECURIT_3) 
            Guide.dispatch(GUIDE_ID_CARD_LIST_EXIT)
            Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE8)
            Guide.dispatch(GUIDE_ID_EDIT_FORMATION8)

        elseif(Data.isPassAtlas(2,1,0)==false)then
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_REWARD4)
            Guide.dispatch(GUIDE_ID_UPGRADE_CARD_1);
            Guide.dispatch(GUIDE_ID_UPGRADE_CARD_2);
            Guide.dispatch(GUIDE_ID_UPGRADE_CARD_3);
            Guide.dispatch(GUIDE_ID_EQUIP_EXIT)
            Guide.dispatch(GUIDE_ID_GET_NEW_TASK_CLOSE3)
            Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE21)
            Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE21_STORY)
            

        end

        Guide.resetStack()
    end
end