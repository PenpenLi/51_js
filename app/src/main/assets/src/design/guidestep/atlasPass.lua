GuideStepData.atlasPass={}

function  GuideStepData.atlasPass.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_BATTLEAUTO
    guide.steps={
        {paths={"battle",0,"btn_auto"},storyid=89},
    }
    table.insert(GuideData.guides,guide);

    local guide={}
    guide.id=GUIDE_ID_ENTER_ATLASBOX
    guide.steps={
        {paths={"panel",PANEL_ATLAS,"btn_box1"},storyid=76},
        {paths={"panel",PANEL_ATLAS_REWARD_BOX,"btn_get"}}
    }
    table.insert(GuideData.guides,guide);


end

function  GuideStepData.atlasPass.firstEnterAltas(mapid,stageid,type)
    if(type==0 and mapid==1 and stageid==4)then
        if(gIsManualBattle)then
            if(battleLayer)then
                battleLayer:setPause()
            end
            Guide.dispatch(GUIDE_ID_ENTER_BATTLEAUTO,1)
        end
    elseif(type==0 and mapid==2 and stageid==2)then
        if(battleLayer )then
            if( battleLayer.curSpeed==1)then
                battleLayer:setPause()
                Guide.dispatch(GUIDE_ID_ENTER_BATTLESPEEDUP,1)
                Guide.dispatch(GUIDE_ID_ENTER_BATTLESPEEDUP,1)

            elseif( battleLayer.curSpeed==2)then
                battleLayer:setPause()
                Guide.dispatch(GUIDE_ID_ENTER_BATTLESPEEDUP,1)
            end
        end
    end
end


function  GuideStepData.atlasPass.firstExitAltas(mapid,stageid,type)
    if(type==0 and mapid==1 and stageid==4)then
        local has=Data.hasAtlasGetBox(mapid,1,type)
        if(has)then
        
        else
            Guide.dispatch(GUIDE_ID_ENTER_ATLASBOX,1)
        end

    end
end

function  GuideStepData.atlasPass.guide()

end