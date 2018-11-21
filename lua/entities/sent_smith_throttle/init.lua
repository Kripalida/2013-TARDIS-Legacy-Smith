AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/throttle.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_NORMAL )
	self:SetUseType( ONOFF_USE )
	self:SetColor(Color(165,165,165,255))
	self.phys = self:GetPhysicsObject()
	self:SetNWEntity("smith",self.smith)
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(false)
	end
end

function ENT:Use( activator, caller, type, value )

	if ( !activator:IsPlayer() ) then return end		-- Who the frig is pressing this shit!?
	if IsValid(self.smith) and self.smith.isomorphic and not (activator==self.owner) then
		return
	end
	
	if ( self:GetIsToggle() ) then

		if ( type == USE_ON ) then
			self:Toggle( !self:GetOn(), activator )
		end
		return;

	end

	if ( IsValid( self.LastUser ) ) then return end		-- Someone is already using this button

	--
	-- Switch off
	--
	if ( self:GetOn() ) then 
	
		self:Toggle( false, activator )
		
	return end

	--
	-- Switch on
	--
	self:Toggle( true, activator )
	self:NextThink( CurTime() )
	self.LastUser = activator
	
end

function ENT:Think()
	if ( self:GetOn() && !self:GetIsToggle() ) then 
	
		if ( !IsValid( self.LastUser ) || !self.LastUser:KeyDown( IN_USE ) ) then
			
			self:Toggle( false, self.LastUser )
			self.LastUser = nil
			
		end	

		self:NextThink( CurTime() )
		return true
	
	end
end

--
-- Makes the button trigger the keys
--
function ENT:Toggle( bEnable, ply )
	if ( bEnable ) then
		self:SetOn( true )
		if IsValid(self.smith) then
			net.Start("smithInt-ControlSound")
				net.WriteEntity(self.smith)
				net.WriteEntity(self)
				net.WriteString("hoxii/smith/throttle.wav")
			net.Broadcast()
		end
	else
		self:SetOn( false )
		if IsValid(self.smith) then
			net.Start("smithInt-ControlSound")
				net.WriteEntity(self.smith)
				net.WriteEntity(self)
				net.WriteString("hoxii/smith/throttle.wav")
			net.Broadcast()
		end
	end
	
	if IsValid(self.interior) then
		self.interior.usecur=CurTime()+1
	end
	
	local smith=self.smith
	local interior=self.interior
	if IsValid(smith) and IsValid(interior) then
		if tobool(GetConVarNumber("smith_advanced"))==true then
			if (interior.flightmode==1 or interior.flightmode==2 or interior.flightmode==3) and interior.step==9 then
				interior:UpdateAdv(ply, true)
			else
				interior:UpdateAdv(ply, false)
			end
		else
			local skycamera=self.interior.skycamera
			local coordinates=self.interior.coordinates
			local pos
			local ang
			if IsValid(skycamera) and skycamera.hitpos and skycamera.hitang then
				pos=skycamera.hitpos
				ang=skycamera.hitang
			end
			if IsValid(coordinates) and coordinates.pos and coordinates.ang then
				pos=coordinates.pos
				ang=coordinates.ang
			end
			if pos and ang then
				local success=self.smith:Go(pos, ang)
				if success then
					ply:ChatPrint("TARDIS moving to set destination.")
					if IsValid(skycamera) and skycamera.hitpos==pos and skycamera.hitang==ang then
						skycamera.hitpos=nil
						skycamera.hitang=nil
					end
					if IsValid(coordinates) and coordinates.pos==pos and coordinates.ang==ang then
						coordinates.pos=nil
						coordinates.ang=nil
					end
				end
			end
			if IsValid(interior.vortexmode) then
				if interior.vortexmode.ready then
					local success=self.smith:DematFast()
					if not success then
						ply:ChatPrint("Error, may be already teleporting.")
					end
					interior.vortexmode.ready=false
				end
			end
		end
		
		if self.smith.moving and self.smith.invortex and self.smith.longflight and not self.smith.reappearing then
			local success=self.smith:LongReappear()
			if success then
				ply:ChatPrint("TARDIS materialising.")
			end
		end
	end
end