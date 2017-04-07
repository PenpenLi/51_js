GuideStepData.atlasNotice={}

function  GuideStepData.atlasNotice.initGuide()



end

function  GuideStepData.atlasNotice.findSweepWeapon()
    local equipCardid=0
    local equipCardPos=0
    for key, card in pairs(gUserCards) do
        local cardDb=DB.getCardById(card.cardid)

        for i=0, MAX_CARD_EQUIP_NUM-1 do
            local equQlt=card.equipQuas[i]
            local num=card.equipActives[i]
            local compound= DB.getEquCompound(cardDb["equid"..i],equQlt+1)
            for m=1, 5 do
                local itemid=compound["item"..m]
                if(CardPro.isEquipItemActivate(num,m-1)==false )then

                    if(Data.getEquipItemNum(itemid)==0)then 
                        if( Data.canGetForEquip(itemid) )then 
                            GuideStepData.atlasNotice.initSweepEquipCard(card.cardid,i,m-1)
                            return
                        end 
                    else
                        equipCardid=card.cardid
                        equipCardPos=i
                    end
                end
            end
        end
    end
    
    if(equipCardid~=0)then
        GuideStepData.atlasNotice.initPutEquipCard(equipCardid,equipCardPos)
    end

end

function  GuideStepData.atlasNotice.initPutEquipCard(cardid,equip)
    local guide={}
    guide.id=GUIDE_ID_ALTAS_NOTICE1--装备 
    local step1={paths={"panel",PANEL_CARD,"0_"..cardid} }
    local step2={paths={"panel",PANEL_CARD_INFO,"equip"..equip} }
    local  step3={paths={"panel",PANEL_CARD_INFO,"btn_put"}}
    guide.steps={step1,step2,step3}
    GuideStepData.atlasNotice.insertGuide(guide)
    Guide.dispatch(GUIDE_ID_ALTAS_NOTICE1)
end


function  GuideStepData.atlasNotice.initSweepEquipCard(cardid,equip,pos)
    local guide={}
    guide.id=GUIDE_ID_ALTAS_NOTICE2--装备 
    local step1={paths={"panel",PANEL_CARD,"0_"..cardid} }
    local  step2={paths={"panel",PANEL_CARD_INFO,"equip"..equip} }
    guide.steps={step1,step2}
    GuideStepData.atlasNotice.insertGuide(guide)

    guide={}
    guide.id=GUIDE_ID_ALTAS_NOTICE3--装备  
    local step1={paths={"panel",PANEL_CARD_INFO,"btn_equip"..pos}} 
    guide.steps={step1}
    GuideStepData.atlasNotice.insertGuide(guide)
    
    guide={}
    guide.id=GUIDE_ID_ALTAS_NOTICE4--装备  
    local  step1={paths={"panel",TIP_PANEL_EQUIP_GET,"1"}}
    local  step2={paths={"panel",PANEL_ATLAS_ENTER,"btn_auto"}}
    guide.steps={step1}
    GuideStepData.atlasNotice.insertGuide(guide)
    
    Guide.dispatch(GUIDE_ID_ALTAS_NOTICE2)
    Guide.dispatch(GUIDE_ID_ALTAS_NOTICE3)
    Guide.dispatch(GUIDE_ID_ALTAS_NOTICE4)
end


function GuideStepData.atlasNotice.insertGuide(guide)
    for key, var in pairs( GuideData.guides) do
    	if(var.id==guide.id)then
    	   GuideData.guides[key]=guide
    	   return
    	end
    end
    table.insert(GuideData.guides,guide)
end




function  GuideStepData.atlasNotice.guide()

end