AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/buttons.mdl" )
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
				net.WriteString("hoxii/smith/buttons.wav")
			net.Broadcast()
		end
	else
		self:SetOn( false )
		if IsValid(self.smith) then
			net.Start("smithInt-ControlSound")
				net.WriteEntity(self.smith)
				net.WriteEntity(self)
				net.WriteString("hoxii/smith/buttons.wav")
			net.Broadcast()
		end
	end
	
	local interior=self.interior
	if IsValid(interior) then
		interior.usecur=CurTime()+1
	end
end