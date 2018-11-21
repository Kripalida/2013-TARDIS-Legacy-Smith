include('shared.lua')

function ENT:Draw()
	if LocalPlayer().smith==self:GetNWEntity("smith", NULL) and LocalPlayer().smith_viewmode and not LocalPlayer().smith_render then
		self:DrawModel()
	end
end

function ENT:Initialize()
	self.PosePosition = 0
end

function ENT:Think()
	if LocalPlayer().smith==self:GetNWEntity("smith", NULL) and LocalPlayer().smith_viewmode then
		local TargetPos = 0.0;
		if ( self:GetOn() ) then TargetPos = 1.0; end
		self.PosePosition = math.Approach( self.PosePosition, TargetPos, FrameTime() * 1.5 )
		self:SetPoseParameter( "switch", self.PosePosition )
		self:InvalidateBoneCache()
		
	end
end