Switch.module.cardyear = {}
Switch.module.cardyear.type = SWITCH_CARDYEAR;

function Switch.module.cardyear.handleData()
    for key,var in pairs(iap_db) do
        if (toint(var.iapid) == CARD_TYPE_LIFE) then
        	table.remove(iap_db,key);
        	break;
        end
    end

   for key,var in pairs(daytask_db) do
        if (toint(var.id) == 21) then
        	table.remove(daytask_db,key);
        	break;
        end
    end 
end

function Switch.module.cardyear.delActivity()
	for key,var in pairs(Data.activityAll) do
		if (var.type == ACT_TYPE_108) then
			table.remove(Data.activityAll,key);
			break;
		end
	end
end