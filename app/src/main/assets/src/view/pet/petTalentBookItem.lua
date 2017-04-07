local PetTalentBookItem=class("PetTalentBookItem",UILayer)

function PetTalentBookItem:ctor(parma1,param2)

end


function PetTalentBookItem:setData(data)
	if self.init~=true then
		self:init("ui/ui_lingshou_tianfudaquan_item.map")
	end
	local des = ""
	local param1 = "("
	local param2 = "("
	for k,var in pairs(data) do

		local buffbd1 = DB.getBuffById(var.bufid1)
		local buffbd2 = DB.getBuffById(var.bufid2)
		if k==1 then
			self:setLabelString("txt_name",var.name)
			des=var.des
			if var.petid>0 then
				self:replaceLabelString("txt_tip",DB.getPetById(var.petid).name,var.needstar)
			else
				self:getNode("txt_tip"):setVisible(false)
			end
			Icon.setPetTalentSkillIcon(var.id,self:getNode("icon"),true)
			--Icon.setIcon(var.icon,self:getNode("icon"))
		end
		if buffbd1 then
			if buffbd1.rate>0 then
				param1= param1 ..string.format("%s%%/",buffbd1.rate)
			else
				if buffbd1.type==48 then
	                param1=param1 ..string.format("%s%%/",buffbd1.attr_value1)
	            else
	            	param1= param1 ..string.format("%s/",CardPro.getAttrValue(buffbd1.attr_id0,buffbd1.attr_value0))
	            end
			end
		end
		if buffbd2 then
			if buffbd2.rate>0 then
				param2= param2 ..string.format("%s%%/",buffbd2.rate)
			else
				if buffbd2.type==48 then
	                param2=param2 ..string.format("%s%%/",buffbd2.attr_value1)
	            else
					param2= param2 ..string.format("%s/",CardPro.getAttrValue(buffbd2.attr_id0,buffbd2.attr_value0))
				end
			end
		end
		if k==table.count(data) then
			param1=param1.."a)"
			param2=param2.."a)"
		end
	end
	param1 = string.gsub(param1,"/a","")
	param2 = string.gsub(param2,"/a","")
	self:setRTFString("txt_des", gReplaceParam(des,param1,param2))
end

function  PetTalentBookItem:setDataLazyCalled()
    self:setData(self.lazyData)
end

function  PetTalentBookItem:setLazyData(data)
    self.curData=data
    self.lazyData=data
    Scene.addLazyFunc(self,self.setDataLazyCalled,"PetTalentBookItem")
end


return PetTalentBookItem