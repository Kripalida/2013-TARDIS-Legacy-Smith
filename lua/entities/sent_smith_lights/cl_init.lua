include('shared.lua')

function ENT:Draw()
	if LocalPlayer().smith==self:GetNWEntity("smith", NULL) and LocalPlayer().smith_viewmode and not LocalPlayer().smith_render then
		self:DrawModel()
	end
end

function ENT:Initialize()
	self.PosePosition = 0.5
end

function ENT:Think()
	local smith=self:GetNWEntity("smith",NULL)
	if IsValid(smith) and LocalPlayer().smith_viewmode and LocalPlayer().smith==smith then
			if smith.health and smith.health > 0 and not smith.repairing and smith.power then
	                          self:SetColor(Color(255,255,255))
                        else
                                  self:SetColor(Color(50,50,50))
			end
        end
end