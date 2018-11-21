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
	local smith=self:GetNWEntity("smith", NULL)
	if IsValid(smith) and LocalPlayer().smith==smith and LocalPlayer().smith_viewmode then
		local mode=self:GetMode()
		if (smith.flightmode or smith.moving) and not (mode==0) then
			local TargetPos
			if ( mode==-1 ) then
				TargetPos = 1.0
				if self.PosePosition==1 then
					self.PosePosition=0
				end
			elseif ( mode==1 ) then
				TargetPos = 0.0
				if self.PosePosition==0 then
					self.PosePosition=1
				end
			end
			self.PosePosition = math.Approach( self.PosePosition, TargetPos, FrameTime() * 1 )
			self:SetPoseParameter( "switch", self.PosePosition )
			self:InvalidateBoneCache()
		end
		
	end
end