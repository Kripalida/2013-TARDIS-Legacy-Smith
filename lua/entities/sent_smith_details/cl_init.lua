include('shared.lua')

function ENT:Draw()
	if LocalPlayer().smith==self:GetNWEntity("smith", NULL) and LocalPlayer().smith_viewmode and not LocalPlayer().smith_render then
		self:DrawModel()
	end
end