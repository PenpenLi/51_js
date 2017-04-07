Switch.module.cardmonth = {}
Switch.module.cardmonth.type = SWITCH_CARD_MONTH;

function Switch.module.cardmonth.handleData()
    for key,var in pairs(iap_db) do
        if (toint(var.iapid) == CARD_TYPE_MON) then
        	table.remove(iap_db,key);
        	break;
        end
    end

   for key,var in pairs(daytask_db) do
        if (toint(var.id) == 15) then
        	table.remove(daytask_db,key);
        	break;
        end
    end 
end

function Switch.module.cardmonth.delActivity()
	for key,var in pairs(Data.activityAll) do
		if (var.type == ACT_TYPE_108) then
			table.remove(Data.activityAll,key);
			break;
		end
	end
end