AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/consolesmith.mdl" )
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
	self.viewcur=0
	self.usecur=0
end

function ENT:Use( ply )
	if CurTime()>self.usecur and self.smith and IsValid(self.smith) and ply.smith and IsValid(ply.smith) and ply.smith==self.smith and ply.smith_viewmode and not ply.smith_skycamera then
		if CurTime()>self.smith.viewmodecur then
			self.smith:ToggleViewmode(ply)
			self.usecur=CurTime()+1
			self.smith.viewmodecur=CurTime()+1
		end
	end
end