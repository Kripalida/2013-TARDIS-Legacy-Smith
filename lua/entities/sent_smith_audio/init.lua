AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

util.AddNetworkString("smithInt-Gramophone-GUI")
util.AddNetworkString("smithInt-Gramophone-Bounce")
util.AddNetworkString("smithInt-Gramophone-Send")

function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/audiosystemsmith.mdl" )
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
	if IsValid(self.smith) and ((self.smith.isomorphic and not (activator==self.owner)) or not self.smith.power) then
		return
	end
	
	local interior=self.interior
	local smith=self.smith
	if IsValid(self) and IsValid(interior) and IsValid(smith) then
		interior.usecur=CurTime()+1
		if CurTime()>self.usecur then
			self.usecur=CurTime()+1
			net.Start("smithInt-Gramophone-GUI")
				net.WriteEntity(self)
				net.WriteEntity(smith)
				net.WriteEntity(interior)
			net.Send(activator)
		end
	end
	
	self:NextThink( CurTime() )
	return true
end

net.Receive("smithInt-Gramophone-Bounce", function(l,ply)
	local gramophone=net.ReadEntity()
	local smith=net.ReadEntity()
	local interior=net.ReadEntity()
	local play=tobool(net.ReadBit())
	local choice=net.ReadFloat()
	local custom=tobool(net.ReadBit())
	local customstr
	if custom then
		customstr=net.ReadString()
	end
	if IsValid(gramophone) and IsValid(smith) and IsValid(interior) then
		net.Start("smithInt-Gramophone-Send")
			net.WriteEntity(gramophone)
			net.WriteEntity(smith)
			net.WriteEntity(interior)
			net.WriteBit(play)
			if play then
				net.WriteFloat(choice)
			end
			if custom then
				net.WriteBit(true)
				net.WriteString(customstr)
			else
				net.WriteBit(false)
			end
		net.Send(smith.occupants)
	end
end)