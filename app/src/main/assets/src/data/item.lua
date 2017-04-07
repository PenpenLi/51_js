Icon={}
EquipItem={}

function Icon.setNodeIcon(ret,node)
    if(ret and node)then
        -- gRefreshNode(node,ret,cc.p(0.5,0.5),cc.p(0,0),1);
        local size=node:getContentSize()
        local width=size.width
        local height=size.height
        node:removeChildByTag(1)


        ret:setPositionX(width/2)
        ret:setPositionY(height/2)
        node:addChild(ret,0,1)
    end
end


function Icon.changeCountryIcon(node,country)
    if(node==nil)then
        return
    end
    local url="zhen_+.png"
      if(country==1)then
        url= "zhen_wei.png"
    elseif(country==2)then
        url= "zhen_shu.png"
    elseif(country==3)then
        url= "zhen_wu.png"
    elseif(country==4)then
        url= "zhen_qun.png"
    elseif(country==5)then
        url= "zhen_luan.png"
    elseif(country==13)then
        url= "zhen_three.png"
    elseif(country==30)then
        url= "zhen_shen.png"
    end 
    
    node:setTexture("images/ui_word/"..url)
end



function Icon.changeGoldIcon(node)
    if(node==nil)then
        return
    end
    node:setTexture("images/ui_public1/coin.png")
end

function Icon.setFamilyIcon(node,icon,familyid)
    if(node==nil or icon==nil)then
        return
    end
    if(gFamilyInfo.winId and familyid and gFamilyInfo.winId == familyid)then
        node:setTexture("images/ui_family/bp_icon_11.png")
        loadFlaXml("ui_family_icon")
        local effect=gCreateFla("ui_family_bz_effect",1)
        gAddCenter(effect,node)
    else
        node:setTexture("images/ui_family/bp_icon_"..icon..".png")
    end
end

function Icon.changeHonorIcon(node,level)
    if(node)then
        node:setTexture("images/icon/serverwar/honor_icon"..level..".png");
    end
end

function Icon.changeHonorWord(node,level)
    if(node)then
        node:setTexture("images/ui_word/honor"..level..".png");
    end
end

function Icon.changeDiaIcon(node)
    if(node==nil)then
        return
    end
    node:setTexture("images/ui_public1/gold.png")
end


function Icon.changeFeatIcon(node)
    if(node==nil)then
        return
    end
    node:setTexture("images/icon/sep_item/95002.png")
end

function Icon.changeExploitIcon(node)
    if(node==nil)then
        return
    end
    node:setTexture("images/icon/sep_item/95001.png")
end



function Icon.changeRepuIcon(node)
    -- if(node==nil)then
    --     return
    -- end
    -- node:setTexture("images/icon/sep_item/90005.png")
    Icon.changeSeqItemIcon(node,90005);
end

function Icon.changeDevoteIcon(node)
    -- if(node==nil)then
    --     return
    -- end
    -- node:setTexture("images/icon/sep_item/90014.png")
    Icon.changeSeqItemIcon(node,90014);
end

function Icon.changeCardExoIcon(node)
    -- if(node==nil)then
    --     return
    -- end
    -- node:setTexture("images/icon/sep_item/90017.png")
    Icon.changeSeqItemIcon(node,90017);
end

function Icon.changeEnergyIcon(node)
    if(node==nil)then
        return
    end
    node:setTexture("images/ui_public1/energy.png")
end

function Icon.changePetSoulIcon(node)
    -- if(node==nil)then
    --     return
    -- end
    -- node:setTexture("images/icon/sep_item/90016.png")
    Icon.changeSeqItemIcon(node,90016);
end

function Icon.changeSoulMoneyIcon(node)
    Icon.changeSeqItemIcon(node,90020);
end

function Icon.changeEmoneyIcon(node)
    Icon.changeSeqItemIcon(node,90027);
end

function Icon.changeSnatchIcon(node)
    if(node==nil)then
        return
    end
    node:setTexture("images/ui_public1/90020.png")
end

function Icon.changeSeqItemIcon(node,itemid)
    if(node==nil)then
        return
    end

    if itemid == ID_SPIRIT_FRAGMENT then
        node:setTexture("images/ui_soullife/soul_fra.png")
    elseif itemid == OPEN_BOX_DIAMOND then
        Icon.changeDiaIcon(node);
    elseif itemid == OPEN_BOX_GOLD then
        Icon.changeGoldIcon(node);
    elseif itemid == OPEN_BOX_SNATCH_MONEY then
        Icon.changeSnatchIcon(node);
    else
        node:setTexture("images/icon/sep_item/"..itemid..".png")
    end
end

function Icon.changeItemIcon(node,itemid)
    if(node==nil)then
        return
    end
    node:setTexture("images/icon/item/"..itemid..".png") 
end

function Icon.setAtlasIcon(itemid,node)
    local ret=FlashAni.new()
    Icon.setNodeIcon(ret,node)
    ret:playAction("ui_icon_atlas_"..itemid)
    return ret
end

function Icon.setItemSourceIcon(itemid,node)
    local ret=cc.Sprite:create("images/icon/itemsource/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    return ret
end

function Icon.setPetIcon(itemid,node,awakeLv)
    local maxAwakeId = gGetMaxPetAwakeId(itemid)
    local iconName = itemid
    if awakeLv ~= nil and awakeLv > 0 and maxAwakeId > 0 then
        iconName = string.format("%d_a%d",itemid, awakeLv)
    end
    local ret=cc.Sprite:create("images/icon/pet/"..iconName..".png")
    Icon.setNodeIcon(ret,node)
    return ret
end

function Icon.setPetIcon2(itemid,node,awakeLv)
    local maxAwakeId = gGetMaxPetAwakeId(itemid)
    local iconName = itemid.."_2"
    if awakeLv ~= nil and awakeLv > 0 and maxAwakeId > 0 then
        iconName = string.format("%s_a%d",iconName, awakeLv)
    end
    node:setTexture("images/icon/pet/"..iconName..".png")
    -- local ret=cc.Sprite:create("images/icon/pet/"..iconName..".png")
    -- Icon.setNodeIcon(ret,node)
    return node
end

function Icon.setBoxIcon(itemid,node)
    local box=DB.getBoxById(itemid) 
    if(box)then
        local ret=cc.Sprite:create("images/icon/box/"..box.iconid..".png")
        Icon.setNodeIcon(ret,node)
        local qua = Icon.getBoxQua(itemid);
        Icon.setQuality(node,qua)
        return ret
    end
end

function Icon.setSpeIcon(itemid,node)
    local ret=cc.Sprite:create("images/icon/sep_item/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    return ret
end

function Icon.setItemIcon(itemid,node,qua)
    local ret=cc.Sprite:create("images/icon/item/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    if(qua==nil)then 
       local data=DB.getItemById(itemid)
        if(data)then
            qua=data.quality
       end
    end

    Icon.setQuality(node,qua)
    return ret 
end


function Icon.setTreasureIcon(itemid,node,qua)
    local ret=cc.Sprite:create("images/icon/treasure/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    if(qua==nil)then 
        local data=DB.getTreasureById(itemid)
        if(data)then
            qua=data.quality
        end
    end

    Icon.setQuality(node,qua)
    return ret 
end

function  Icon.setCardIcon(cardid,node,qua,awakeLv)
    -- local ret=cc.Sprite:create("images/icon/head/"..itemid..".png")
    -- Icon.setNodeIcon(ret,node)

    -- if(qua==nil)then 
    --     local data=Data.getUserCardById(itemid)
    --     if(data)then
    --         qua=data.quality
    --     end
    -- end
    -- Icon.setQuality(node,qua)

    -- return ret

    local maxWeaponId=nil
    local maxAwakeId=nil 
    maxWeaponId,maxAwakeId= gGetMaxWeaponAwakeId(cardid)
    local awakeId = gParseCardAwakeId(awakeLv,maxAwakeId);
    if(awakeId == nil)then
        awakeId = 0;
    end
    local showIcon = cardid;
    
    if(awakeId > 0  )then
        showIcon = showIcon.."_a"..awakeId;
    end

    local ret=cc.Sprite:create("images/icon/head/"..showIcon..".png")
    Icon.setNodeIcon(ret,node)

    if(qua==nil)then 
        local data=Data.getUserCardById(cardid)
        if(data)then
            qua=data.quality
        end
    end
    Icon.setQuality(node,qua)

    return ret

end

function  Icon.setWeaponIcon(itemid,node,qua)
    local ret=cc.Sprite:create("images/icon/weapon/"..itemid..".png")
    Icon.setNodeIcon(ret,node) 
    Icon.setQuality(node,qua)

    return ret
end



function Icon.setMonsterIcon(monsterid,node)
    local monster=DB.getMonsterById(monsterid)
    if(monster==nil)then
        return nil
    end
    local qua=monster.quality
    local waken=monster.waken
    local showIcon = monster.cardid
    if waken > 0 then
        showIcon = showIcon.."_a1"
    end
    local ret=cc.Sprite:create("images/icon/head/"..showIcon..".png")
    if ret == nil then
        ret=cc.Sprite:create("images/icon/head/"..monster.cardid..".png")
    end
    Icon.setNodeIcon(ret,node)
    Icon.setQuality(node,qua)
    return ret
end


function Icon.setEquipmentIcon(itemid,node,qua)
    local ret=cc.Sprite:create("images/icon/equipment/"..itemid..".png")
    Icon.setNodeIcon(ret,node)


    Icon.setQuality(node,qua)
    return ret
end

function  Icon.setEquipItemIcon(itemid,node)
    local item=DB.getEquipItemById(itemid)
    if(item==nil)then
        return
    end
    local ret=nil
    local qua=item.quality
    if(item.type==1)then
        ret=cc.Sprite:create("images/ui_public1/juanzhou"..qua..".png")
        icon=cc.Sprite:create("images/icon/equipment/"..item.icon..".png")
        if(icon and ret) then
            icon:setScale(0.7)
            ret:addChild(icon)
            icon:setPositionX(ret:getContentSize().width/2)
            icon:setPositionY(ret:getContentSize().height/2)
        end
    else
        ret=cc.Sprite:create("images/icon/equipitem/"..item.icon..".png")
    end

    Icon.setNodeIcon(ret,node)
    Icon.setQuality(node,qua)
    return ret
end


function  Icon.setSkillIcon(itemid,node)
    local ret=cc.Sprite:create("images/icon/skill/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    return ret
end



function  Icon.setTaskIcon(itemid,node)
    if(itemid == 21 and not Module.isClose(SWITCH_REPLACE_CARDYEAR))then
        itemid = "21_1";
    end
    local ret=cc.Sprite:create("images/icon/task/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    return ret
end

function  Icon.setAchieveIcon(itemid,node)
    local ret=cc.Sprite:create("images/icon/achievement/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    return ret
end

function  Icon.setBuffIcon(itemid,node)
    local db=DB.getBuffById(itemid)
    if(db==nil)then
        return
    end
    local ret=cc.Sprite:create("images/icon/skill/"..db.icon..".png")
    Icon.setNodeIcon(ret,node)
    return ret
end

function Icon.setPetTalentSkillIcon(itemid,node,notQuality)
    local stvar=DB.getSpecialTalentById(itemid)
    local ret =nil
    if(stvar)then
        ret=cc.Sprite:create("images/icon/skill/"..stvar.icon..".png")
        if ret==nil then
            return
        end
        ret:setScale(1.1)
        Icon.setNodeIcon(ret,node)
        local offPos = cc.p(-2,-2)
        ret:setPosition(cc.pAdd(cc.p(ret:getPosition()),offPos))
        if notQuality==nil or notQuality==false then
            --stvar.quality = sssQuality
            local quality = cc.Sprite:create("images/ui_num/ptq_"..stvar.quality..".png")
            quality:setAnchorPoint(cc.p(1,0.5))
            quality:setScale(1.4)
            quality:setLocalZOrder(2)
            gRefreshNode(node,quality,cc.p(1,0),cc.p(0,18),2)

            if stvar.petid>0 then
                local zuanshu = cc.Sprite:create("images/ui_word/zuanshu.png")
                zuanshu:setAnchorPoint(cc.p(1,1))
                zuanshu:setScale(1.3)
                zuanshu:setLocalZOrder(3)
                gRefreshNode(node,zuanshu,cc.p(1,1),cc.p(-5,-5),3)
            else
                node:removeChildByTag(3)
            end
            if stvar.quality==sssQuality then
                loadFlaXml("ui_lingshou");
                 local sss_light = gCreateFla("ui_lingshou_sss",1);
                quality:removeChildByTag(100);
                if sss_light then
                    sss_light:setTag(100);
                    gAddChildInCenterPos(quality,sss_light);
                end
            end 
        end
    end
    return ret
end

function Icon.setQuality(node,qua)
    if(qua and node.setTexture)then
        node:setTexture("images/ui_public1/ka_d"..(qua+1)..".png")
    end
end

function Icon.setIapIcon(node,idx)
    local iconMap={1,2,3,4,7,8,5,6,4}
    local icon = iconMap[idx+1];
    if(icon == 6 and not Module.isClose(SWITCH_REPLACE_CARDYEAR))then
        icon = "6_1";
    end
    node:setTexture("images/ui_huodong/g_0"..icon..".png")
end


function Icon.isAttrItem(itemid)

    if(itemid==OPEN_BOX_DIAMOND or
        itemid==OPEN_BOX_GOLD or
        itemid==OPEN_BOX_COUPON or
        itemid==OPEN_BOX_EXP or
        itemid==OPEN_BOX_ENERGY or
        itemid==OPEN_BOX_REPU or
        itemid==OPEN_BOX_SPIRIT or
        itemid==OPEN_BOX_ARENE or
        itemid==OPEN_BOX_CARDEXP or
        itemid==OPEN_BOX_ARENAEXP or
        itemid==OPEN_BOX_CARDSOUL or
        itemid==OPEN_BOX_PET_SOUL or
        itemid==OPEN_BOX_PETMONEY or
        itemid==OPEN_BOX_EQUIP_SOUL or
        itemid==OPEN_BOX_SKILLPOINT or
        itemid==OPEN_BOX_CARDEXP_ITEM or
        itemid==OPEN_BOX_FEAT or
        itemid==OPEN_BOX_EXPLOIT or
        itemid==OPEN_BOX_SOULMONEY or
        itemid==OPEN_BOX_FAMILY_DEVOTE or
        itemid==OPEN_BOX_FAMILY_EXP or
        itemid==OPEN_BOX_SERVERBATTLE or
        itemid==OPEN_BOX_DRAGON_BALL or
        itemid==OPEN_BOX_VIPSCORE or
        itemid==OPEN_BOX_EMOTION_MONEY or
        itemid==OPEN_BOX_TOWERMONEY or
        itemid==OPEN_BOX_FAMILY_MONEY or
        itemid==OPEN_BOX_FOOD or
        itemid==OPEN_BOX_ITEMAWAKE or
        
        (itemid >= LOST_STRENGTHEN_RECRUIT and itemid <= LOST_STRENGTHEN_PETTRAIN) or
        ITEMTYPE_SPIRIT == DB.getItemType(itemid)) then
        return true
    end 
     
    
    return false 
end
function Icon.setOtherIcon(itemid,node)
    local ret=nil
    local isShowQua = true
    if(itemid==OPEN_BOX_DIAMOND)then
        ret=cc.Sprite:create("images/ui_public1/gold.png")
     
    elseif(itemid==OPEN_BOX_GOLD)then
        ret=cc.Sprite:create("images/ui_public1/coin.png")
    elseif(itemid==OPEN_BOX_ENERGY)then
        ret=cc.Sprite:create("images/ui_public1/energy.png")
    elseif (itemid==LOST_STRENGTHEN_RECRUIT) then
        ret=cc.Sprite:create("images/ui_fight/guide_recruit.png")
        isShowQua = false
    elseif (itemid==LOST_STRENGTHEN_EQUIP) then
        ret=cc.Sprite:create("images/ui_fight/guide_equip.png")
        isShowQua = false
    elseif (itemid==LOST_STRENGTHEN_STARUP) then
        ret=cc.Sprite:create("images/ui_fight/guide_star_up.png")
        isShowQua = false
    elseif (itemid==LOST_STRENGTHEN_SKILLUP) then
        ret=cc.Sprite:create("images/ui_fight/guide_skill_up.png")
        isShowQua = false
    elseif (itemid==LOST_STRENGTHEN_PETTRAIN) then
        ret=cc.Sprite:create("images/ui_fight/guide_pet_train.png")
        isShowQua = false
    elseif (itemid==OPEN_BOX_FEAT) then
        ret=cc.Sprite:create("images/icon/sep_item/95002.png")
        isShowQua = true

    elseif (itemid==OPEN_BOX_EXPLOIT) then
        ret=cc.Sprite:create("images/icon/sep_item/95001.png")
        isShowQua = true
    elseif (itemid==OPEN_BOX_ITEMAWAKE) then
        ret=cc.Sprite:create("images/icon/item/42.png")
        isShowQua = true
    elseif (itemid==OPEN_BOX_FOOD) then
        ret=cc.Sprite:create("images/icon/sep_item/95005.png")
        isShowQua = true
        
    elseif (ITEMTYPE_SPIRIT == DB.getItemType(itemid)) then
        ret=Icon.setSpiritItemIcon(itemid)
        isShowQua = true
    else
        ret=cc.Sprite:create("images/icon/sep_item/"..itemid..".png")
    end  
    if(ret)then
        if isShowQua then
            if ITEMTYPE_SPIRIT == DB.getItemType(itemid) then
                Icon.setSpiritQuality(node,itemid)
            else
                Icon.setQuality(node,5)
            end
        end
        Icon.setNodeIcon(ret,node)
        return true 
    end
    return false
end

function Icon.setGetFlag(node,isGeted)
    node:removeChildByTag(50);
    if node and isGeted then
        local flag = cc.Sprite:create("images/ui_word/xget.png");
        gRefreshNode(node,flag,cc.p(0.5,0.5),cc.p(0,0),50);
    end
end

function Icon.getBoxQua(boxid)
    local boxdb = DB.getBoxById(boxid)
    if nil ~=boxdb and boxdb.quality and boxdb.quality ~= 99 then
        return  boxdb.quality
    end
    if(boxid == 23007)then
        return 2;
    elseif(boxid == 23008)then
        return 3;   
    elseif(boxid == 23009)then
        return 4;
    elseif(boxid == 23010)then
        return 5;
    elseif(boxid == 23100)then
        return 8;       
    end
    return 5;
end

function Icon.setIcon(itemid,node,qua,awakeLv,shardIcon,needReplaceItem)
    if(node==nil)then
        return nil
    end

    if(needReplaceItem == nil)then
        needReplaceItem = true;
    end

    if(needReplaceItem)then
        itemid = DB.checkReplaceItem(itemid);
    end
    
    if(Icon.isAttrItem(itemid) )then
        if(node)then
            node:removeChildByTag(2)
        end
        return  Icon.setOtherIcon(itemid,node)
    end
    local itemData = DB.getItemData(itemid)
    --矿石资源
    if nil ~= itemData and itemData.type == ITEMTYPE_MINE then
        if(node)then
            node:removeChildByTag(2)
        end
        return Icon.setMineIcon(itemid,node,qua)
    end
    
    local  type=  DB.getItemType(itemid)
    local ret=nil
    if(shardIcon==nil)then
        shardIcon=false
    end 
    if(type==ITEMTYPE_ITEM)then
        ret=Icon.setItemIcon(itemid,node,qua)
    elseif(type==ITEMTYPE_CARD)then
        ret=Icon.setCardIcon(itemid,node,qua,awakeLv)
    elseif(type==ITEMTYPE_EQU)then
        ret=Icon.setEquipItemIcon(itemid,node)
    elseif(type==ITEMTYPE_SKILL)then
        ret=Icon.setSkillIcon(itemid,node)
    elseif(type==ITEMTYPE_PET)then
        ret=Icon.setPetIcon(itemid,node,awakeLv)
    elseif(type==ITEMTYPE_PET_SOUL)then
        ret=Icon.setPetIcon(itemid-ITEM_TYPE_SHARED_PRE,node)
        shardIcon=true
    elseif(type==ITEMTYPE_BOX)then
        qua = Icon.getBoxQua(itemid);
        ret=Icon.setBoxIcon(itemid,node)
    -- elseif(type==ITEMTYPE_BUFF)then  --buff icon的设置单独调用
    --     ret=Icon.setBuffIcon(itemid,node)
    elseif(type==ITEMTYPE_CARD_SOUL)then
        ret=Icon.setCardIcon(itemid-ITEM_TYPE_SHARED_PRE,node)
        shardIcon=true
    elseif(type==ITEMTYPE_EQU_SHARED)then
        ret=Icon.setEquipItemIcon(itemid-ITEM_TYPE_SHARED_PRE,node)
        shardIcon=true
    elseif(type==ITEMTYPE_SPECIAL)then
        ret=Icon.setSpeIcon(itemid,node);
    elseif(type==ITEMTYPE_MINE) then
        ret=Icon.setMineIcon(itemid,node,qua);
    elseif(type==ITEMTYPE_TREASURE) then
        ret=Icon.setTreasureIcon(itemid,node,qua);
    elseif(type==ITEMTYPE_TREASURE_SHARED)then
        ret=Icon.setTreasureIcon(itemid-ITEM_TYPE_SHARED_PRE,node)
        shardIcon=true
    elseif type==ITEMTYPE_CONSTELLATION then
        ret=Icon.setConstellationIcon(itemid,node)
    elseif type==ITEMTYPE_TALENT_SKILL then
        ret=Icon.setPetTalentSkillIcon(itemid,node)
    end

    if(shardIcon)then

        node:removeChildByTag(2)
        local pIcon=cc.Sprite:create("images/ui_public1/suipian_icon.png")
        node:addChild(pIcon)
        pIcon:setTag(2)
        pIcon:setPositionX((node:getContentSize().width-pIcon:getContentSize().width/2-10))
        pIcon:setPositionY((node:getContentSize().height-pIcon:getContentSize().height/2-10))
    else
        if(node)then
            node:removeChildByTag(2)
        end
    end

    -- if qua == nil then
    --     qua = DB.getItemQuality(itemid);
    -- end

    Icon.setQuality(node,qua)
    return ret,type

end

function Icon.addSpeEffectForSoul(node)
    local fla=gCreateFla("ui_kuang_guang",1);
    fla:setTag(100);
    fla:setLocalZOrder(100);
    gAddChildByAnchorPos(node,fla,cc.p(0.5,0.5));
    -- gAddChildInCenterPos(self,fla);
end

function Icon.setCardBg(node,cardid,qua)

    if(qua==nil)then 
        local data=Data.getUserCardById(cardid)
        if(data)then
            qua=data.quality
        end
    end

    if(qua)then
        -- print("qua = "..qua);
        local baseQua = Icon.convertItemDetailQuality(qua+1);
        -- print("baseQua = "..baseQua);
        node:setTexture("images/ui_public1/npc_k_0"..(baseQua)..".png")
    end

end

function Icon.setCardNameBg(node,cardid,qua)

    if(qua==nil)then 
        local data=Data.getUserCardById(cardid)
        if(data)then
            qua=data.quality
        end
    end

    if(qua)then
        local baseQua = Icon.convertItemDetailQuality(qua+1);
        node:setTexture("images/ui_public1/npc_k_0"..(baseQua).."_1.png")
    end

end

function Icon.setCardCountry(node,country)
    if node then
        if country == nil then
            country = 0;
        end
        node:setTexture("images/ui_word/card_z_"..country..".png");
    end
end

function Icon.convertItemDetailQuality(qua)
    if qua == 1 then
        return 1,0;
    elseif qua <=3 then
        return 2,qua - 2;
    elseif qua <= 5 then
        return 3,qua - 4;
    elseif qua <= 8 then
        return 4,qua - 6;
    elseif qua <= 11 then
        return 5,qua - 9;
    else
        return 6,qua - 12;
    end
end



function Icon.getHeadIconParam(icon_frame)
    local icon = math.mod(icon_frame,100000);
    local frame = math.floor(icon_frame/100000);
    local awakeLv = 0;
    if(frame>=100)then
        awakeLv = math.floor(frame/100);
        frame = math.mod(frame,100);

        local maxWeaponId=nil
        local maxAwakeId=nil 
        maxWeaponId,maxAwakeId= gGetMaxWeaponAwakeId(icon)
        local awakeId = gParseCardAwakeId(awakeLv,maxAwakeId);
         
        if(awakeId and awakeId >= 1 )then 
            icon = icon.."_a"..awakeId;
        end
        -- print("icon = "..icon);
    end
    return icon ,frame
end

function Icon.setHeadIcon(node,icon_frame)
    if(icon_frame==nil)then
        return 
    end
    local icon , frame =Icon.getHeadIconParam(icon_frame)
    
    -- print("before width = "..node:getContentSize().width.." height = "..node:getContentSize().height);
    node:setTexture("images/icon/head/frame"..frame..".png");
    -- print("after width = "..node:getContentSize().width.." height = "..node:getContentSize().height);
    Icon.setCardIcon(icon,node,false);
    local frameConvert = cc.Sprite:create("images/icon/head/frame"..frame.."_1.png");
    node:removeChildByTag(100);
    gRefreshNode(node,frameConvert,cc.p(0.5,0.5),cc.p(0,0),100);
end

function Icon.setDropItem(node,itemid,itemnum,quality)
    node:removeChildByTag(1000);
    local item=DropItem.new()
    item:setData(itemid,quality)
    item:setNum(itemnum)
    item:setTag(1000);
    node:setOpacity(0);
    gAddChildByAnchorPos(node,item,cc.p(0,1),cc.p(0,0));
    -- gAddChildInCenterPos(node,item);
    gSetCascadeOpacityEnabled(node,false);
    return item;
end

function Icon.showTip(itemid)
    local type = DB.getItemType(itemid)
end

function Icon.setSpiritIcon(iType, node)
    loadFlaXml("ui_soullife")
    local spiritType = iType
    if spiritType == SPIRIT_TYPE.DOUBLE_ATTR then
        spiritType = SPIRIT_TYPE.DOUBLE_ATTR - 1
    else
        spiritType = spiritType + 1
    end
    local spiritIcon = gCreateFla("xian_soul_"..spiritType, 1)
    spiritIcon:setScale(0.7)
    if nil ~= spiritIcon then
        Icon.setNodeIcon(spiritIcon, node)
        spiritIcon:setLocalZOrder(0)
    end
end

function Icon.setSpiritItemIcon(itemid)
    loadFlaXml("ui_soullife")
    local spiritIcon = nil
    if itemid == ID_SPIRIT_FRAGMENT then
        spiritIcon = cc.Sprite:create("images/ui_soullife/soul_fra.png")
    else
        local spiritType = math.floor((itemid % 10000)/1000)
        if spiritType == SPIRIT_TYPE.DOUBLE_ATTR then
            spiritType = SPIRIT_TYPE.DOUBLE_ATTR - 1
        else
            spiritType = spiritType + 1
        end
        spiritIcon = gCreateFla("xian_soul_"..spiritType, 1)
    end

    return spiritIcon
end

function Icon.setSpiritQuality(node,spiritid)
    if spiritid == ID_SPIRIT_FRAGMENT then
        Icon.setQuality(node,5)
    else
        local spiritType = math.floor((spiritid % 10000)/1000)
        if spiritType == SPIRIT_TYPE.GUI then
            Icon.setQuality(node,0)
        elseif spiritType == SPIRIT_TYPE.REN then
            Icon.setQuality(node,1)
        elseif spiritType == SPIRIT_TYPE.DI then
            Icon.setQuality(node,3)
        elseif spiritType == SPIRIT_TYPE.SHEN then
            Icon.setQuality(node,5)
        elseif spiritType == SPIRIT_TYPE.TIAN then
            Icon.setQuality(node,8)
        elseif spiritType == SPIRIT_TYPE.DOUBLE_ATTR then
            Icon.setQuality(node,11)
        end
    end
end

function Icon.setMineIcon(itemid,node,qua)
    local ret=cc.Sprite:create("images/icon/mine/"..itemid..".png")
    Icon.setNodeIcon(ret,node)
    if(qua==nil)then 
       local data=DB.getItemById(itemid)
        if(data)then
            qua=data.quality
       end
    end

    Icon.setQuality(node,qua)
    return ret 
end

function Icon.setSecOfSeverBattle(node,secLev)
    if(node==nil)then
        return
    end

    local secType = DB.getServerBattleSecTypeByLv(secLev)
    if nil ~= secType then
        node:setTexture("images/ui_severwar/badge_"..secType..".png")
    end    
end

function Icon.setSpiritExpIcon(node,scale)
    loadFlaXml("ui_soullife")
    local spiritIcon = gCreateFla("xian_soulexp", 1)
    if nil ~= scale then
        spiritIcon:setScale(scale)
    end
    if nil ~= spiritIcon then
        Icon.setNodeIcon(spiritIcon, node)
    end
end

function EquipItem.getSellPrice(itemid)
    local  type=  DB.getItemType(itemid)
    if(type==ITEMTYPE_ITEM)then
        local data=DB.getItemData(itemid)
        return data.sell_money
    elseif(type==ITEMTYPE_EQU)then
        local data=DB.getItemData(itemid)
        return data.sell_money
    elseif(type==ITEMTYPE_CARD_SOUL)then
        return DB.getCardSharedPrice()
    elseif(type==ITEMTYPE_EQU_SHARED)then
        local data=DB.getItemData(itemid-ITEM_TYPE_SHARED_PRE)
        if(data.com==0)then
            return data.sell_money
        else
            return math.rint( data.sell_money/data.com_num)
        end
    end

end

function Icon.changeMinePointItemIcon(node)
    Icon.changeSeqItemIcon(node,90019); 
end

function Icon.setConstellationIcon(itemid,node,qua)
    local iconid = DB.getConstellationsItemInfo(itemid)["icon"]
    local ret=cc.Sprite:create("images/icon/head/"..iconid..".png")
    if iconid > 50000 and iconid < 50100 then
        ret =cc.Sprite:create("images/icon/pet/"..iconid..".png")
    end
    
    Icon.setNodeIcon(ret,node)
    if(qua==nil)then
        qua = DB.getConstellationItemQuality(itemid)
    end
    local frame = 1
    if qua == 8 then
        frame = 3
    elseif qua == 5 then
        frame = 2
    elseif qua == 11 then
        frame = 4
    end
    local frameConvert = cc.Sprite:create("images/ui_soullife/k_"..frame..".png")
    node:removeChildByTag(100)
    gRefreshNode(node,frameConvert,cc.p(0.5,0.5),cc.p(0,0),100)

    Icon.setQuality(node,qua)
    return ret 
end

--判断能不能合成
function EquipItem.canCompound(itemid)
    local item=DB.getEquipItemById(itemid)
    if(item and item.com_num>0)then
        return true
    end

    return false

end
