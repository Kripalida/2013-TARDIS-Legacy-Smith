ENT.Type = "anim"
if WireLib then
	ENT.Base 			= "base_wire_entity"
else
	ENT.Base			= "base_gmodentity"
end 
ENT.PrintName		= "2013 TARDIS Interior"
ENT.Author			= "Dr. Matt"
ENT.Contact			= "mattjeanes23@gmail.com"
ENT.Instructions	= "Don't spawn this!"
ENT.Purpose			= "Time and Relative Dimension in Space's Interior"
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Category		= "Doctor Who"
ENT.smith_part		= true

hook.Add("PhysgunPickup", "smithInt-PhysgunPickup", function(_,e)
	if e.smith_part then
		return false
	end
end)

hook.Add("OnPhysgunReload", "smithInt-OnPhysgunReload", function(_,p)
	local e = p:GetEyeTraceNoCursor().Entity
	if e.smith_part then
		return false
	end
end)

local modes={
	"remover"
}
hook.Add("CanTool", "smithInt-CanTool", function(ply,tr,mode)
	local e=tr.Entity
	if table.HasValue(modes,mode) and IsValid(e) and e.smith_part then
		return false
	end
end)

hook.Add("CanProperty", "smithInt-CanProperty", function(ply,property,e)
	if e.smith_part then
		return false
	end
end)

hook.Add("InitPostEntity", "smithInt-InitPostEntity", function()
	if pewpew and pewpew.NeverEverList then // nice and easy, blocks pewpew from damaging the interior.
		table.insert(pewpew.NeverEverList, "sent_smith_interior")
		hook.Add("PewPew_ShouldDamage","smithInt-BlockDamage",function(pewpew,e,dmg,dmgdlr)
			if e.smith_part then
				return false
			end
		end)
	end
	if ACF and ACF_Check then // this one is a bit hacky, but ACFs internal code is shockingly bad.
		local original=ACF_Check
		function ACF_Check(e)
			if IsValid(e) then
				local class=e:GetClass()
				if class=="sent_smith_interior" or e.smith_part then
					if not e.ACF then ACF_Activate(e) end
					return false
				end
			end
			return original(e)
		end
	end
	if XCF and XCF_Check then // this one is also a bit hacky, but XCFs internal code is shockingly bad.
		local original=XCF_Check
		function XCF_Check(e,i)
			if IsValid(e) then
				local class=e:GetClass()
				if class=="sent_smith_interior" or e.smith_part then
					if not e.ACF then ACF_Activate(e) end
					return false
				end
			end
			return original(e,i)
		end
	end
end)