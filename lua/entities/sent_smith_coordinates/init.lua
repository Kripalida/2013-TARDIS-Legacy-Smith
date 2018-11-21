AddCSLuaFile( "von.lua" )
AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

util.AddNetworkString("smithInt-Locations-GUI")
util.AddNetworkString("smithInt-Locations-Send")

function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/keyboard.mdl" )
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
	if IsValid(interior) and IsValid(self.smith) and IsValid(self) then
		interior.usecur=CurTime()+1
		if CurTime()>self.usecur then
			self.usecur=CurTime()+1
			if tobool(GetConVarNumber("smith_advanced"))==true then
				interior:UpdateAdv(activator,false)
			end
			net.Start("smithInt-Locations-GUI")
				net.WriteEntity(self.interior)
				net.WriteEntity(self.smith)
				net.WriteEntity(self)
			net.Send(activator)
			if IsValid(self.smith) then
				net.Start("smithInt-ControlSound")
					net.WriteEntity(self.smith)
					net.WriteEntity(self)
					net.WriteString("hoxii/smith/keyboard.wav")
				net.Broadcast()
			end
		end
	end
	
	self:NextThink( CurTime() )
	return true
end

net.Receive("smithInt-Locations-Send", function(l,ply)
	local interior=net.ReadEntity()
	local smith=net.ReadEntity()
	local typewriter=net.ReadEntity()
	if IsValid(interior) and IsValid(smith) and IsValid(typewriter) then
		local pos=Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		local ang=Angle(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		if tobool(GetConVarNumber("smith_advanced"))==true then
			if interior.flightmode==0 and interior.step==0 then
				local success=interior:StartAdv(2,ply,pos,ang)
				if success then
					ply:ChatPrint("Programmable flightmode activated.")
				end
			else
				interior:UpdateAdv(ply,false)
			end
		else
			if not smith.invortex then
				typewriter.pos=pos
				typewriter.ang=ang
				ply:ChatPrint("TARDIS destination set.")
			end
		end
		
		if smith.invortex then
			smith:SetDestination(pos,ang)
			ply:ChatPrint("TARDIS destination set.")
		end
	end
end)