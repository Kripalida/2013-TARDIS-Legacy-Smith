AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/doorsmith.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_NORMAL )
	self:SetColor(Color(165,165,165,255))
	self.phys = self:GetPhysicsObject()
	self:SetNWEntity("smith",self.smith)
	self.usecur=0
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(false)
	end
end

function ENT:Use( activator, caller, type, value )

	if ( !activator:IsPlayer() ) then return end		-- Who the frig is pressing this shit!?
	
	local smith=self.smith
	local interior=self.interior
	if IsValid(interior) and IsValid(smith) and CurTime()>smith.exitcur then
		smith:PlayerExit(activator)
		interior.usecur=CurTime()+1
		smith.exitcur=CurTime()+1
	end
end