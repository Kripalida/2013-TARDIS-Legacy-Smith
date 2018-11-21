AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

util.AddNetworkString("smith-SetViewmode")
util.AddNetworkString("smithInt-SetParts")
util.AddNetworkString("smithInt-UpdateAdv")
util.AddNetworkString("smithInt-SetAdv")
util.AddNetworkString("smithInt-ControlSound")

function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/interior.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor(Color(165,165,165,255))
	self:DrawShadow(false)
	
	self.phys = self:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(false)
	end
	
	self:SetNWEntity("smith",self.smith)
	
	self.viewcur=0
	self.throttlecur=0
	self.usecur=0
	self.flightmode=0 //0 is none, 1 is skycamera selection, 2 is idk yet or whatever and so on
	self.step=0
	
	
	if WireLib then
		Wire_CreateInputs(self, { "Demat", "Phase", "Flightmode", "X", "Y", "Z", "XYZ [VECTOR]", "Rot" })
		Wire_CreateOutputs(self, { "Health" })
	end
	
	self:SpawnParts()
	
	if IsValid(self.owner) then
		self:SetNWVector("mainlight",Vector(self.owner:GetInfoNum("smithint_mainlight_r",255),self.owner:GetInfoNum("smithint_mainlight_g",50),self.owner:GetInfoNum("smithint_mainlight_b",0)))
		self:SetNWVector("seclight",Vector(self.owner:GetInfoNum("smithint_seclight_r",0),self.owner:GetInfoNum("smithint_seclight_g",255),self.owner:GetInfoNum("smithint_seclight_b",0)))
		self:SetNWVector("warnlight",Vector(self.owner:GetInfoNum("smithint_warnlight_r",200),self.owner:GetInfoNum("smithint_warnlight_g",0),self.owner:GetInfoNum("smithint_warnlight_b",0)))
	end
end

function ENT:SpawnParts()
	if self.parts then
		for k,v in pairs(self.parts) do
			if IsValid(v) then
				v:Remove()
				v=nil
			end
		end
	end
	
	self.parts={}
	
	//chairs
	local vname="Seat_Airboat"
	local chair=list.Get("Vehicles")[vname]
	self.chair1=self:MakeVehicle(self:LocalToWorld(Vector(-145,-83,104)), Angle(0,-65,0), chair.Model, chair.Class, vname, chair)
	self.chair2=self:MakeVehicle(self:LocalToWorld(Vector(9,-165,104)), Angle(0,0,0), chair.Model, chair.Class, vname, chair)
	self.chair3=self:MakeVehicle(self:LocalToWorld(Vector(160,29,104)), Angle(0,100,0), chair.Model, chair.Class, vname, chair)
	self.chair4=self:MakeVehicle(self:LocalToWorld(Vector(43,155,104)), Angle(0,170,0), chair.Model, chair.Class, vname, chair)
	
	//parts
	self.audio=self:MakePart("sent_smith_audio", Vector(0,0,0), Angle(0,0,0),false)
	self.button2=self:MakePart("sent_smith_button2", Vector(0,9.5,0), Angle(0,0,0),false)
	self.buttons=self:MakePart("sent_smith_buttons", Vector(0,0,0), Angle(0,0,0),false)
	self.catwalklights=self:MakePart("sent_smith_catwalklights", Vector(0,0,0), Angle(0,0,0),false)
	self.console=self:MakePart("sent_smith_console", Vector(0,0,0), Angle(0,0,0),false)
	self.consoledetails=self:MakePart("sent_smith_consoledetails", Vector(0,0,0), Angle(0,0,0),false)
	self.coordinates=self:MakePart("sent_smith_coordinates", Vector(0,0,0), Angle(0,0,0),false)
	self.crank=self:MakePart("sent_smith_crank", Vector(0,0,0), Angle(0,0,0),false)
	self.crank3=self:MakePart("sent_smith_crank3", Vector(0,0,0), Angle(0,0,0),false)
	self.crank4=self:MakePart("sent_smith_crank4", Vector(0,0,0), Angle(0,0,0),false)
	self.crank5=self:MakePart("sent_smith_crank5", Vector(0,0,0), Angle(0,0,0),false)
	self.crank6=self:MakePart("sent_smith_crank6", Vector(0,0,0), Angle(0,0,0),false)
	self.cranks=self:MakePart("sent_smith_cranks", Vector(0,0,0), Angle(0,0,0),false)
	self.cranks=self:MakePart("sent_smith_cranks", Vector(0,0,0), Angle(0,199,0),false)
	self.details=self:MakePart("sent_smith_details", Vector(0,0,0), Angle(0,-0.075,0),false)
	self.details=self:MakePart("sent_smith_details", Vector(0,0,0), Angle(0,198.975,0),false)
	self.door=self:MakePart("sent_smith_door", Vector(0,0,0), Angle(0,0,0),false)
	self.fastreturn=self:MakePart("sent_smith_fastreturn", Vector(0,0,0), Angle(0,0,0),false)
	self.flightlever=self:MakePart("sent_smith_flightlever", Vector(0,0,0), Angle(0,0,0),false)
	self.floor=self:MakePart("sent_smith_floor", Vector(0,0,0), Angle(0,0,0),false)
	self.gears=self:MakePart("sent_smith_gears", Vector(0,0,0), Angle(0,0,0),false)
	self.hads=self:MakePart("sent_smith_hads", Vector(0,0,0), Angle(0,0,0),false)
	self.handbrake=self:MakePart("sent_smith_handbrake", Vector(0,0,0), Angle(0,0,0),false)
	self.hullstruts=self:MakePart("sent_smith_hullstruts", Vector(0,0,0), Angle(0,0,0),false)
	self.intdoors=self:MakePart("sent_smith_intdoors", Vector(0,0,0), Angle(0,0,0),false)
	self.isomorphic=self:MakePart("sent_smith_isomorphic", Vector(0,0,0), Angle(0,0,0),false)
	self.lever3=self:MakePart("sent_smith_lever3", Vector(0,0,0), Angle(0,0,0),false)
	self.lever3=self:MakePart("sent_smith_lever3", Vector(0,0,0), Angle(0,199,0),false)
	self.levers=self:MakePart("sent_smith_levers", Vector(0,0,0), Angle(0,0,0),false)
	self.lights=self:MakePart("sent_smith_lights", Vector(0,0,0), Angle(0,0,0),false)
	self.lock=self:MakePart("sent_smith_lock", Vector(0,0,0), Angle(0,0,0),false)
	self.longflight=self:MakePart("sent_smith_longflight", Vector(0,0,0), Angle(0,0,0),false)
	self.lowertrim=self:MakePart("sent_smith_lowertrim", Vector(0,0,0), Angle(0,0,0),false)
	self.manualmode=self:MakePart("sent_smith_manualmode", Vector(0,0,0), Angle(0,0,0),false)
	self.phasemode=self:MakePart("sent_smith_phasemode", Vector(0,0,0), Angle(0,0,0),false)
	self.phone=self:MakePart("sent_smith_phone", Vector(0,0,0), Angle(0,0,0),false)
	self.physbrake=self:MakePart("sent_smith_physbrake", Vector(0,26.6,0), Angle(0,0,0),false)
	self.power=self:MakePart("sent_smith_power", Vector(0,0,0), Angle(0,0,0),false)
	self.rails=self:MakePart("sent_smith_rails", Vector(0,0,0), Angle(0,0,0),false)
	self.repair=self:MakePart("sent_smith_repair", Vector(0,0,0), Angle(0,0,0),false)
	self.rooms=self:MakePart("sent_smith_rooms", Vector(0,0,0), Angle(0,0,0),false)
	self.roundels=self:MakePart("sent_smith_roundels", Vector(0,0,0), Angle(0,0,0),false)
	self.roundels=self:MakePart("sent_smith_roundels", Vector(0,0,0), Angle(0,100,0),false)
	self.roundels=self:MakePart("sent_smith_roundels", Vector(0,0,0), Angle(0,-100,0),false)
	self.screen=self:MakePart("sent_smith_screen", Vector(0,0,0), Angle(0,0,0),false)
	self.skycamera=self:MakePart("sent_smith_skycamera", Vector(0,0,-350), Angle(90,0,0),false)
	self.sliders=self:MakePart("sent_smith_sliders", Vector(0,0,0), Angle(0,0,0),false)
	self.spinmode=self:MakePart("sent_smith_spinmode", Vector(0,0,0), Angle(0,0,0),false)
	self.switches=self:MakePart("sent_smith_switches", Vector(0,0,0), Angle(0,0,0),false)
	self.switches2=self:MakePart("sent_smith_switches2", Vector(0,0,0), Angle(0,0,0),false)
	self.switches2=self:MakePart("sent_smith_switches2", Vector(0,11.8,0), Angle(0,0,0),false)
	self.throttle=self:MakePart("sent_smith_throttle", Vector(0,0,0), Angle(0,0,0),false)
	self.toggles2=self:MakePart("sent_smith_toggles2", Vector(0,0,0), Angle(0,0,0),false)
	self.trim=self:MakePart("sent_smith_trim", Vector(0,0,0), Angle(0,0,0),false)
	self.vortexmode=self:MakePart("sent_smith_vortexmode", Vector(0,0,0), Angle(0,0,0),false)
	self.walls=self:MakePart("sent_smith_walls", Vector(0,0,0), Angle(0,0,0),false)
	
	timer.Simple(2,function() // delay exists so the entity can register on the client, allows for a ping of just under 2000 (should be fine lol)
		if IsValid(self) and self.parts then
			net.Start("smithInt-SetParts")
				net.WriteEntity(self)
				net.WriteFloat(#self.parts)
				for k,v in pairs(self.parts) do
					net.WriteEntity(v)
				end
			net.Broadcast()
		end
	end)
end

function ENT:StartAdv(mode,ply,pos,ang)
	if self.flightmode==0 and self.step==0 and IsValid(self.smith) and self.smith.power and not self.smith.moving then
		self.flightmode=mode
		self.step=1
		if pos and ang then
			self.advpos=pos
			self.advang=ang
		end
		net.Start("smithInt-SetAdv")
			net.WriteEntity(self)
			net.WriteEntity(ply)
			net.WriteFloat(mode)
		net.Send(ply)
		return true
	else
		return false
	end
end

function ENT:UpdateAdv(ply,success)
	if not (self.flightmode==0) and tobool(GetConVarNumber("smith_advanced"))==true and IsValid(self.smith) and self.smith.power then
		if success then
			self.step=self.step+1
			if self.flightmode==1 and self.step==10 then
				local skycamera=self.skycamera
				if IsValid(self.smith) and not self.smith.moving and IsValid(skycamera) and skycamera.hitpos and skycamera.hitang then
					self.smith:Go(skycamera.hitpos, skycamera.hitang)
					skycamera.hitpos=nil
					skycamera.hitang=nil
				else
					ply:ChatPrint("Error, already teleporting or no coordinates set.")
				end
				self.flightmode=0
				self.step=0
			elseif self.flightmode==2 and self.step==10 then
				if IsValid(self.smith) and not self.smith.moving and self.advpos and self.advpos then
					self.smith:Go(self.advpos, self.advang)
				else
					ply:ChatPrint("Error, already teleporting or no coordinates set.")
				end
				self.advpos=nil
				self.advang=nil
				self.flightmode=0
				self.step=0
			elseif self.flightmode==3 and self.step==10 then
				local success=self.smith:DematFast()
				if not success then
					ply:ChatPrint("Error, may be already teleporting.")
				end
				self.flightmode=0
				self.step=0
			end
		else
			//ply:ChatPrint("Failed.")
			self.flightmode=0
			self.step=0
			self.advpos=nil
			self.advang=nil
		end
		net.Start("smithInt-UpdateAdv")
			net.WriteBit(success)
		net.Send(ply)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:MakePart(class,vec,ang,weld)
	local ent=ents.Create(class)
	ent.smith=self.smith
	ent.interior=self
	ent.owner=self.owner
	ent:SetPos(self:LocalToWorld(vec))
	ent:SetAngles(ang)
	//ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:Spawn()
	ent:Activate()
	if weld then
		constraint.Weld(self,ent,0,0)
	end
	if IsValid(self.owner) then
		if SPropProtection then
			SPropProtection.PlayerMakePropOwner(self.owner, ent)
		else
			gamemode.Call("CPPIAssignOwnership", self.owner, ent)
		end
	end
	table.insert(self.parts,ent)
	return ent
end

function ENT:MakeVehicle( Pos, Ang, Model, Class, VName, VTable ) // for the chairs
	local ent = ents.Create( Class )
	if (!ent) then return NULL end
	
	ent:SetModel( Model )
	
	-- Fill in the keyvalues if we have them
	if ( VTable && VTable.KeyValues ) then
		for k, v in pairs( VTable.KeyValues ) do
			ent:SetKeyValue( k, v )
		end
	end
		
	ent:SetAngles( Ang )
	ent:SetPos( Pos )
		
	ent:Spawn()
	ent:Activate()
	
	ent.VehicleName 	= VName
	ent.VehicleTable 	= VTable
	
	-- We need to override the class in the case of the Jeep, because it 
	-- actually uses a different class than is reported by GetClass
	ent.ClassOverride 	= Class
	
	ent.smith_part=true
	ent:GetPhysicsObject():EnableMotion(false)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetColor(Color(255,255,255,0))
	constraint.Weld(self,ent,0,0)
	if IsValid(self.owner) then
		if SPropProtection then
			SPropProtection.PlayerMakePropOwner(self.owner, ent)
		else
			gamemode.Call("CPPIAssignOwnership", self.owner, ent)
		end
	end
	
	table.insert(self.parts,ent)

	return ent
end

if WireLib then
	function ENT:TriggerInput(k,v)
		if self.smith and IsValid(self.smith) then
			self.smith:TriggerInput(k,v)
		end
	end
end

function ENT:SetHP(hp)
	if WireLib then
		Wire_TriggerOutput(self, "Health", math.floor(hp))
	end
end

function ENT:Explode()
	self.exploded=true
	
	self.fire = ents.Create("env_fire_trail")
	self.fire:SetPos(self:LocalToWorld(Vector(0,0,0)))
	self.fire:Spawn()
	self.fire:SetParent(self)
	
	local explode = ents.Create("env_explosion")
	explode:SetPos(self:LocalToWorld(Vector(0,0,50)))
	explode:Spawn()
	explode:Fire("Explode",0)
	explode:EmitSound("hoxii/smith/explosion.wav", 100, 100 ) //Adds sound to the explosion
end

function ENT:UnExplode()
	self.exploded=false
	
	if self.fire and IsValid(self.fire) then
		self.fire:Remove()
		self.fire=nil
	end
end

function ENT:OnRemove()
	if self.fire then
		self.fire:Remove()
		self.fire=nil
	end
	for k,v in pairs(self.parts) do
		if IsValid(v) then
			v:Remove()
			v=nil
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if self.smith and IsValid(self.smith) then
		self.smith:OnTakeDamage(dmginfo)
	end
end

function ENT:Think()
	if self.smith and IsValid(self.smith) then
		if self.smith.occupants then
			for k,v in pairs(self.smith.occupants) do
				if self:GetPos():Distance(v:GetPos()) > 700 and v.smith_viewmode and not v.smith_skycamera then
					self.smith:PlayerExit(v,true)
				end
			end
		end
	end
end