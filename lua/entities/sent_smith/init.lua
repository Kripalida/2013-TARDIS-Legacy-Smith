AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

util.AddNetworkString("Player-Setsmith")
util.AddNetworkString("smith-SetHealth")
util.AddNetworkString("smith-Go")
util.AddNetworkString("smith-Stop")
util.AddNetworkString("smith-Explode")
util.AddNetworkString("smith-UnExplode")
util.AddNetworkString("smith-Flightmode")
util.AddNetworkString("smith-TakeDamage")
util.AddNetworkString("smith-FlightPhase")
util.AddNetworkString("smith-DoubleTrace")
util.AddNetworkString("smith-SpawnOffset")
util.AddNetworkString("smith-AdvancedMode")
util.AddNetworkString("smith-TeleportLock")
util.AddNetworkString("smith-LongFlight")
util.AddNetworkString("smith-PhysDamage")
util.AddNetworkString("smith-Phase")
util.AddNetworkString("smith-UpdateVis")
util.AddNetworkString("smith-SetInterior")
util.AddNetworkString("smith-SetViewmode")
util.AddNetworkString("smith-PlayerEnter")
util.AddNetworkString("smith-PlayerExit")
util.AddNetworkString("smith-SetLocked")
util.AddNetworkString("smith-SetRepairing")
util.AddNetworkString("smith-BeginRepair")
util.AddNetworkString("smith-FinishRepair")
util.AddNetworkString("smith-SetLight")
util.AddNetworkString("smith-SetStaticLight")
util.AddNetworkString("smith-SetPower")
util.AddNetworkString("smith-StopLong")
util.AddNetworkString("smith-Reappear")
util.AddNetworkString("smith-Materialize")
util.AddNetworkString("smith-SetVortex")
util.AddNetworkString("smith-NoCollideTeleport")

net.Receive("smith-TakeDamage", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_takedamage", net.ReadFloat())
	end
end)

net.Receive("smith-FlightPhase", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_flightphase", net.ReadFloat())
	end
end)

net.Receive("smith-DoubleTrace", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_doubletrace", net.ReadFloat())
	end
end)

net.Receive("smith-SpawnOffset", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_spawnoffset", net.ReadFloat())
	end
end)

net.Receive("smith-AdvancedMode", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_advanced", net.ReadFloat())
	end
end)

net.Receive("smith-TeleportLock", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_teleportlock", net.ReadFloat())
	end
end)

net.Receive("smith-NoCollideTeleport", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_nocollideteleport", net.ReadFloat())
	end
end)

net.Receive("smith-PhysDamage", function(len,ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		RunConsoleCommand("smith_physdamage", net.ReadFloat())
	end
end)

//make the player name invisible while TARDIS is invisible
hook.Add("EV_ShowPlayerName", "smith-EV_ShowPlayerName", function(ply)
	if ply.smith and IsValid(ply.smith) and not ply.smith.visible then
		return false
	end
end)

//stop pewpew damaging when main damage is off
hook.Add("PewPew_ShouldDamage","smith-PewPew_ShouldDamage",function(_,ent,dmg)
	if ent and IsValid(ent) and ent:GetClass()=="sent_smith" then
		if ent:ShouldTakeDamage() then
			ent:TakeHP(dmg/32)
		end
		return false
	end
end)

function ENT:SpawnFunction( ply, tr, ClassName )
	if (  !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	local ang=Angle(0,(ply:GetPos()-SpawnPos):Angle().y,0)
	ent:SetAngles( ang )
	ent.owner=ply
	ent:Spawn()
	ent:Activate()	

	return ent
end
 
function ENT:Initialize()
	self:SetModel( "models/hoxii/smith/exteriorlegsmith.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	self.phys = self:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
	end
	
	self.a=255 // alpha
	self.cur=0
	self.curdelay=0.01
	self.exitcur=0
	self.flightcur=0
	self.flightmode=false
	self.health=1000
	self.exploded=false
	self.visible=true
	self.locked=false
	self.physlocked=false
	self.isomorphic=false
	self.reappearing=false
	self.longflight=false
	self.power=false
	self.hads=false
	self.autolongflight=false
	self.invortex=false
	self.phasecur=0
	self.interiorcur=0
	self.viewmodecur=0
	self.repaircur=0
	self.repairdelay=0.5
	self.spinmode=-1
	self.explodedshift=0
	self.tracknotifycur=0
	self.physlocknotifycur=0
	self.tpspeed=1
	self.tpspeed_mode=0
	self.tpsound=0
	self.tpsound_mode=0
	self.a=255
	self.ta=255
	self.step=1
	self.extcol=Color(255,255,255)
	self.demat=false
	self.mat=false
	self.lastpos=self:GetPos()
	self.lastang=self:GetAngles()
	self.occupants={}
	if WireLib then
		self.wirepos=Vector(0,0,0)
		self.wireang=Angle(0,0,0)
		Wire_CreateInputs(self, { "Demat", "Phase", "Flightmode", "X", "Y", "Z", "XYZ [VECTOR]", "Rot" })
		Wire_CreateOutputs(self, { "Health" })
	end
	
	// this is a bit hacky but from testing it seems to work well
	local trdata={}
	trdata.start=self:GetPos()+Vector(0,0,99999999)
	trdata.endpos=self:GetPos()
	trdata.filter={self}
	local trace=util.TraceLine(trdata)
	//another trace is run here incase the mapper has placed the 3d skybox above the map
	if tobool(GetConVarNumber("smith_doubletrace"))==true then
		local trdata={}
		trdata.start=trace.HitPos+Vector(0,0,-6000)
		trdata.endpos=trace.HitPos
		trdata.filter={self}
		trace=util.TraceLine(trdata)
		//this trace can sometimes fail if the map has a low skybox, hence why its an admin option
	end
	local offset=0
	offset=GetConVarNumber("smith_spawnoffset")
	self.interior=ents.Create("sent_smith_interior")
	self.interior:SetPos(trace.HitPos+Vector(0,0,-600+offset))
	self.interior.smith=self
	self.interior.owner=self.owner
	self.interior:Spawn()
	self.interior:Activate()
	if IsValid(self.owner) then
		if SPropProtection then
			SPropProtection.PlayerMakePropOwner(self.owner, self.interior)
		else
			gamemode.Call("CPPIAssignOwnership", self.owner, self.interior)
		end
		self.extcol=Color(self.owner:GetInfoNum("smith_extcol_r",255),self.owner:GetInfoNum("smith_extcol_g",255),self.owner:GetInfoNum("smith_extcol_b",255))
		self:SetNWVector("extcol", Vector(self.extcol.r,self.extcol.g,self.extcol.b))
	end
	self:SetNWEntity("interior",self.interior)
	self:SetHP(1000)
	self.light = self:SpawnLight()
	self.light2 = self:SpawnStaticLight()
	self:SetLight(false)
	
	net.Start("smith-SetInterior")
		net.WriteEntity(self)
		net.WriteEntity(self.interior)
	net.Broadcast()
	
	self.dematvalues={
		150,
		200,
		100,
		150,
		50,
		100,
		0
	}
	self.matvalues={
		100,
		50,
		150,
		100,
		200,
		150,
		255
	}
end

function ENT:EmergencyLand()
	if not self.moving or not self.invortex or not self.longflight or self.reappearing then
		return false
	end
	
	self:LongReappear()
end

function ENT:FastReturn()
	if self.lastpos and self.lastang then
		//if (self.tpspeed != 1) or (self.tpspeed_mode != 0) or (self.tpsound != 0) then return false end
		//self:SetTPSpeed(1.5,2)
		//self:SetTPSound(2,2)
		local success=self:Go(self.lastpos,self.lastang,true)
		if success then
			return true
		else
			//self:ResetTPSpeed()
			//self:ResetTPSound()
			return false
		end
	end
	return false
end

function ENT:ResetTPSound()
	self:SetTPSound(0,0)
end

function ENT:SetTPSound(n,mode)
	self.tpsound=n // 0=normal, 1=hads, 2=fast return
	self.tpsound_mode=mode // 0=dont change, 1=on demat completion, 2=on remat completion
end

function ENT:ResetTPSpeed()
	self:SetTPSpeed(1,0)
end

function ENT:SetTPSpeed(n,mode)
	self.tpspeed=n
	self.tpspeed_mode=mode // 0=dont change, 1=on demat completion, 2=on remat completion
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:DematFast() //TODO: why isnt this called FastDemat?
	if not self.longflight then
		local success=self:ToggleLongFlight()
		if not success then
			return false
		end
		self.autolongflight=true
	end
	if (self.tpspeed != 1) or (self.tpspeed_mode != 0) or (self.tpsound != 0) then return false end
	self:SetTPSpeed(1.75,1)
	self:SetTPSound(1,1)
	local success=self:Go()
	if success then
		return true
	else
		self:ResetTPSpeed()
		self:ResetTPSound()
		return false
	end
end

function ENT:ToggleHADS()
	self.hads=(not self.hads)
	return true
end

function ENT:SetTrackingEnt(ent)
	if IsValid(ent) and not (ent==self) and not (ent==game.GetWorld()) and not (ent.smith_part) then
		self.tracking=true
		self.trackingent=ent
		self.trackingoffset=ent:WorldToLocal(self:GetPos())
		self.trackingyawoffset=(ent:GetAngles()-self:GetAngles()).y
		return true
	else
		self.tracking=false
		self.trackingent=nil
		self.trackingoffset=nil
		self.trackingyawoffset=0
		return true
	end
	return false
end

function ENT:SetSpinMode(n)
	self.spinmode=(math.Clamp(n,-1,1))
end

function ENT:ToggleLongFlight()
	if self.moving then
		return false
	else
		self.longflight=(not self.longflight)
		return true
	end
end

function ENT:IsomorphicToggle(ply)
	if ply==self.owner and self.power then
		if self.isomorphic then
			self.isomorphic=false
		else
			self.isomorphic=true
		end
		return true
	else
		return false
	end
end

function ENT:ToggleRepair()
	if not self.repairing then
		return self:StartRepair()
	elseif self.repairing and self.repairwait then
		return self:EndRepair()
	end
	return false
end

function ENT:StartRepair()
	if self.repairing or self.health > 999 or self.moving or self.flightmode then
		return false
	end
	self.repairing=true
	net.Start("smith-SetRepairing")
		net.WriteEntity(self)
		net.WriteBit(true)
		if IsValid(self.interior) then
			net.WriteEntity(self.interior)
		end
	net.Broadcast()
	self.repairwait=true
	self.repairoccupants=table.Copy(self.occupants)
	for k,v in pairs(self.occupants) do
		v:ChatPrint("TARDIS self-repair initiated, all occupants must exit to start.")
	end
	return true
end

function ENT:BeginRepair()
	self.repairwait=nil
	self.repairfinish=CurTime()+((85-self.health)*self.repairdelay)
	net.Start("smith-BeginRepair")
		net.WriteEntity(self)
	net.Broadcast()
end

function ENT:EndRepair()
	if not self.repairing then return false end
	if self.repairoccupants then
		for k,v in pairs(self.repairoccupants) do
			if IsValid(v) then
				if self.repairwait then
					v:ChatPrint("TARDIS self-repair cancelled.")
				else
					v:ChatPrint("TARDIS self-repair completed.")
				end
			end
		end
		self.repairoccupants=nil
	end
	if not self.repairwait then
		self:SetHP(1000)
		net.Start("smith-FinishRepair")
			net.WriteEntity(self)
		net.Broadcast()
		self:FlashLight(1.5)
	end
	self.repairing=nil
	self.repairwait=nil
	self.repairfinish=nil
	net.Start("smith-SetRepairing")
		net.WriteEntity(self)
		net.WriteBit(false)
		if IsValid(self.interior) then
			net.WriteEntity(self.interior)
		end
	net.Broadcast()
	return true
end

function ENT:SetLocked(locked,silent)
	if self.power then
		if locked then
			self.locked=true
		else
			self.locked=false
		end
		if self.visible and not self.exploded then
			net.Start("smith-SetLocked")
				net.WriteEntity(self)
				net.WriteEntity(self.interior or NULL)
				net.WriteBit(self:GetLocked())
				if silent then
					net.WriteBit(false)
				else
					net.WriteBit(true)
				end
			net.Broadcast()
			if not silent then
				self:FlashLight(0.5)
			end
		end
		return true
	else
		return false
	end
end

function ENT:ToggleLocked()
	if self.power then
		self:SetLocked(not self:GetLocked())
		return true
	else
		return false
	end
end

function ENT:GetLocked()
	return self.locked
end

function ENT:ShouldTakeDamage()
	return tobool(GetConVarNumber("smith_takedamage"))
end

function ENT:Explode()
	if not self:ShouldTakeDamage() then return end
	
	if not self.visible then
		self:TogglePhase()
	end
	
	if self.physlocked then
		self:TogglePhysLock()
	end
	
	self.exploded=true
	self:SetLight(false)	
	
	net.Start("smith-Explode")
		net.WriteEntity(self)
	net.Broadcast()
	
	if not self.invortex then
		self:CreateFire()
		
		local explode = ents.Create("env_explosion")
		explode:SetPos( self:LocalToWorld(Vector(0,0,50)) ) //Puts the explosion where you are aiming
		explode:SetOwner( self ) //Sets the owner of the explosion
		explode:Spawn()
		explode:SetKeyValue("iMagnitude","175") //Sets the magnitude of the explosion
		explode:Fire("Explode", 0, 0 ) //Tells the explode entity to explode
		explode:EmitSound("hoxii/smith/explosion.wav", 100, 100 ) //Adds sound to the explosion
	end
	
	self:SetColor(Color(255,190,100,self:GetColor().a))
	
	if self.interior and IsValid(self.interior) then
		self.interior:Explode()
	end
	
	if self.invortex then
		self:EmergencyLand()
	end
end

function ENT:UnExplode()
	if not self:ShouldTakeDamage() then return end
	self.exploded=false
	if (self.moving or self.flightmode) and self.visible then
		self:SetLight(true)
	end
	
	net.Start("smith-UnExplode")
		net.WriteEntity(self)
	net.Broadcast()
	
	self:RemoveFire()
	
	self:SetColor(Color(255,255,255))
	
	if self.interior and IsValid(self.interior) then
		self.interior:UnExplode()
	end
end

function ENT:CreateFire()
	self.fire = ents.Create("env_fire_trail")
	self.fire:SetPos(self:LocalToWorld(Vector(0,0,50)))
	self.fire:Spawn()
	self.fire:SetParent(self)
end

function ENT:RemoveFire()
	if self.fire and IsValid(self.fire) then
		self.fire:Remove()
		self.fire=nil
	end
end

function ENT:CreateSmoke()
	local smoke = ents.Create("env_smokestack")
	smoke:SetPos(self:LocalToWorld(Vector(0,0,80)))
	smoke:SetAngles(self:GetAngles()+Angle(-90,0,0))
	smoke:SetKeyValue("InitialState", "1")
	smoke:SetKeyValue("WindAngle", "0 0 0")
	smoke:SetKeyValue("WindSpeed", "0")
	smoke:SetKeyValue("rendercolor", "50 50 50")
	smoke:SetKeyValue("renderamt", "170")
	smoke:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
	smoke:SetKeyValue("BaseSpread", "2")
	smoke:SetKeyValue("SpreadSpeed", "2")
	smoke:SetKeyValue("Speed", "50")
	smoke:SetKeyValue("StartSize", "30")
	smoke:SetKeyValue("EndSize", "70")
	smoke:SetKeyValue("roll", "20")
	smoke:SetKeyValue("Rate", "15")
	smoke:SetKeyValue("JetLength", "40")
	smoke:SetKeyValue("twist", "5")
	smoke:Spawn()
	smoke:SetParent(self)
	smoke:Activate()
	self.smoke=smoke
end

function ENT:RemoveSmoke()
	if self.smoke and IsValid(self.smoke) then
		self.smoke:Remove()
		self.smoke=nil
	end
end

function ENT:SetHP(hp)
	if not hp or not self:ShouldTakeDamage() then return end
	hp=math.Clamp(hp,0,1000)
	net.Start("smith-SetHealth")
		net.WriteEntity(self)
		net.WriteFloat(hp)
	net.Broadcast()
	self.health=hp
	if WireLib then
		Wire_TriggerOutput(self, "Health", math.floor(self.health))
		if self.interior and IsValid(self.interior) then
			self.interior:SetHP(self.health)
		end
	end
	if not self.exploded and hp==0 then
		self:Explode()
	elseif self.exploded and hp>0 then
		self:UnExplode()
	end
	if IsValid(self.smoke) and hp>=251 then
		self:RemoveSmoke()
	elseif not IsValid(self.smoke) and hp<=250 and not self.invortex then
		self:CreateSmoke()
	end
end

function ENT:TakeHP(hp)
	if not hp or not self:ShouldTakeDamage() or (self.repairing and not self.repairwait) then return end
	self:SetHP(self.health-hp)
	if self.interior and IsValid(self.interior) then
		sound.Play("Default.ImpactSoft",self.interior:LocalToWorld(Vector(-308,0,98)))
		util.ScreenShake(self.interior:GetPos(),math.Clamp(hp,0,16),5,0.5,700)
	end
	if self.hads and (hp>=0.5) then
		self:DematFast()
	end
end

function ENT:AddHP(hp)
	if not hp or not self:ShouldTakeDamage() then return end
	self:SetHP(self.health+hp)
end

function ENT:OnTakeDamage(dmginfo)
	if not self:ShouldTakeDamage() then return end
	local hp=dmginfo:GetDamage()
	self:TakeHP(hp/32) //takes 32th of normal damage a player would take
end

function ENT:SetLight(on)
	if on and (not self.visible or self.exploded or self.invortex) then
		return
	end
	if on then
		self.light:Fire("showsprite","",0)
		self.light.on=true
	else
		self.light:Fire("hidesprite","",0)
		self.light.on=false
	end
	net.Start("smith-SetLight")
		net.WriteEntity(self)
		net.WriteBit(self.light.on)
	net.Broadcast()
end

function ENT:SetStaticLight(on)
	if on and (not self.visible or self.exploded or self.invortex) then
		return
	end
	if on then
		self.light2:Fire("showsprite","",0)
		self.light2.on=true
	else
		self.light2:Fire("hidesprite","",0)
		self.light2.on=false
	end
	net.Start("smith-SetStaticLight")
		net.WriteEntity(self)
		net.WriteBit(self.light2.on)
	net.Broadcast()
end

function ENT:ToggleLight()
	if self.light.on then
		self:SetLight(false)
	else
		self:SetLight(true)
	end
end

function ENT:FlashLight(time)
	if not self.visible then return end
	self:SetLight(true)
	timer.Simple(time,function()
		if IsValid(self) and not self.flightmode and not self.moving then
			self:SetLight(false)
		end
	end)
end

function ENT:SetDestination(vec,ang)
	if self.exploded then
		local randvec=VectorRand()*1000
		randvec.z=0
		self.vec=self:GetPos()+randvec
		self.ang=self:GetAngles()+AngleRand()
	else
		if vec then
			self.vec=vec
		else
			self.vec=self:GetPos()
		end
		
		if ang then
			self.ang=ang
		else
			self.ang=self:GetAngles()
		end
	end
end

function ENT:Go(vec,ang,nolongflight)
	if not self.moving and not self.repairing and self.power then
		if not ((self.tpspeed != 1) or (self.tpspeed_mode != 0) or (self.tpsound != 0)) then
			if self.exploded then
				self:SetTPSpeed(1.1,2)
			end
		end
		if nolongflight then
			self.nolongflight=true
		end
		if tobool(GetConVarNumber("smith_nocollideteleport"))==true then
			self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		end
		self.moving=true
		self:Dematerialize()
		self.lastpos=self:GetPos()
		self.lastang=self:GetAngles()
		if vec then
			self.vec=vec
		else
			self.vec=self:GetPos()
		end
		if ang then
			self.ang=ang
		else
			self.ang=self:GetAngles()
		end
		self.attachedents = constraint.GetAllConstrainedEntities(self)
		if self.attachedents then
			for k,v in pairs(self.attachedents) do
				if v.smith_part or v==self then
					self.attachedents[k]=nil
				end
			end
			for k,v in pairs(self.attachedents) do
				local a=v:GetColor().a
				if not (a==255) then
					v.tempa=a
				end
			end
		end
		if self.exploded then
			self:SetDestination()
		end
		if self.visible and not self.exploded then
			self:SetLight(true)
		end
		if IsValid(self.interior) then
			util.ScreenShake(self.interior:GetPos(),2,5,1,700)
		end
		net.Start("smith-Go")
			net.WriteEntity(self)
			net.WriteEntity(self.interior)
			net.WriteBit(tobool(self.exploded))
			net.WriteBit(self.longflight and not self.nolongflight)
			net.WriteFloat(self.tpsound)
			net.WriteVector(self:GetPos())
			if self.vec then
				net.WriteVector(self.vec)
			end
		net.Broadcast()
		return true
	else
		return false
	end
end

function ENT:Stop()
	if self.moving then
		if tobool(GetConVarNumber("smith_nocollideteleport"))==true then
			self:SetCollisionGroup( COLLISION_GROUP_NONE )
		end
		self.moving=false
		self.vec=nil
		self.ang=nil
		self.nolongflight=nil
		if self.tpspeed_mode==2 then
			self:ResetTPSpeed()
		end
		if self.tpsound_mode==2 then
			self:ResetTPSound()
		end
		if not self.flightmode and self.visible then
			self:SetLight(false)
		end
		if IsValid(self.interior) then
			util.ScreenShake(self.interior:GetPos(),1,5,1,700)
		end
		net.Start("smith-Stop")
			net.WriteEntity(self)
		net.Broadcast()
		self.step=1
		self.demat=false
		self.mat=false
		self.ta=255
		if self.attachedents then
			for k,v in pairs(self.attachedents) do
				if IsValid(v) and v.tempa then
					local col=v:GetColor()
					col=Color(col.r,col.g,col.b,v.tempa)
					v:SetColor(col)
					v.tempa=nil
				end
			end
		end
		self.attachedents=nil
		local col=self:GetColor()
		col=Color(col.r,col.g,col.b,255)
		self:SetColor(col)
		if self.autolongflight and self.longflight then
			self.autolongflight=false
			self:ToggleLongFlight()
		end
	end
end

function ENT:Disappear()
	self:RemoveRotorWash()
	self.invortex=true
	net.Start("smith-SetVortex")
		net.WriteEntity(self)
		net.WriteBit(true)
	net.Broadcast()
	self:SetLight(false)
	self:RemoveFire()
	self:RemoveSmoke()
	self:SetSolid(SOLID_NONE)
	self:GetPhysicsObject():EnableMotion(false)
	if self.tpspeed_mode==1 then
		self:ResetTPSpeed()
	end
	if self.tpsound_mode==1 then
		self:ResetTPSound()
	end
	if self.attachedents then
		for k,v in pairs(self.attachedents) do
			if IsValid(v) and not IsValid(v:GetParent()) then
				local phys=v:GetPhysicsObject()
				if phys and IsValid(phys) then
					if not phys:IsMotionEnabled() then
						v.frozen=true
					end
					phys:EnableMotion(false)
					v:SetSolid(SOLID_NONE)
				end
			end
		end
	end
	if not self.longflight or self.nolongflight then
		self:Reappear()
	end
end

function ENT:LongReappear()
	if self.moving and self.invortex and self.longflight and self.vec then
		self.reappearing=true
		net.Start("smith-Reappear")
			net.WriteEntity(self)
			net.WriteEntity(self.interior)
			net.WriteBit(self.exploded)
			net.WriteFloat(self.tpsound)
			net.WriteVector(self.vec)
		net.Broadcast()
		timer.Simple(self.exploded and 7.65 or 8.5,function() // a good enough approximation
			if IsValid(self) then
				self.reappearing=false
				self:Reappear()
			end
		end)
		return true
	else
		return false
	end
end

function ENT:Reappear()
	if self.vec then
		if self.attachedents then
			for k,v in pairs(self.attachedents) do
				if IsValid(v) and not IsValid(v:GetParent()) then
					v.telepos=v:GetPos()-self:GetPos()
					if v:GetClass()=="gmod_hoverball" then // fixes hoverballs spazzing out
						v:SetTargetZ( (self.vec-self:GetPos()).z+v:GetTargetZ() )
					end
				end
			end
		end
		self:SetPos(self.vec)
		if self.ang then
			self:SetAngles(self.ang)
		end
		for k,v in pairs(player.GetAll()) do
			if (self:GetPos():Distance(v:GetPos()) < 45) and not (v.smith and not v.smith_viewmode) then
				self:PlayerEnter(v,true)
			end
		end
		for k,v in pairs(ents.GetAll()) do
			if v:IsNPC() and IsValid(self.interior) and (self:GetPos():Distance(v:GetPos()) < 45) then
				v:SetPos(self.interior:LocalToWorld(Vector(-308,0,98)))
			end
		end
		if self.attachedents then
			for k,v in pairs(self.attachedents) do
				if IsValid(v) and not IsValid(v:GetParent()) then
					if v:IsRagdoll() then
						for i=0,v:GetPhysicsObjectCount() do
							local bone=v:GetPhysicsObjectNum(i)
							if IsValid(bone) then
								bone:SetPos(self:GetPos()+v.telepos)
							end
						end
					end
					v:SetPos(self:GetPos()+v.telepos)
					v.telepos=nil
					local phys=v:GetPhysicsObject()
					if phys and IsValid(phys) then
						if not v.frozen and not v.physlocked then
							phys:EnableMotion(true)
						end
						v:SetSolid(SOLID_VPHYSICS)
					end
					v.frozen=nil
					v.nocollide=nil
				end
			end
		end
		if not self.physlocked then
			self:GetPhysicsObject():EnableMotion(true)
		end
		self:SetSolid(SOLID_VPHYSICS)
		if self.visible then
			self:CreateRotorWash()
		end
		self.invortex=false
		self:Materialize()
		net.Start("smith-SetVortex")
			net.WriteEntity(self)
			net.WriteBit(false)
		net.Broadcast()
		self:SetLight(true)
		if self.exploded then
			self:CreateFire()
		end
		if self.health<=20 then
			self:CreateSmoke()
		end
		timer.Simple(8.5,function()
			if IsValid(self) then
				self:Stop()
			end
		end)
	else
		print("CRITICAL ERROR: Vector not found.")
	end
end

function ENT:Dematerialize()
	self.step=1
	self.moving=true
	self.demat=true
	self.mat=false
	self.ta=self:GetTargetAlpha()
end

function ENT:Materialize()
	self.step=1
	self.moving=true
	self.demat=false
	self.mat=true
	self.ta=self:GetTargetAlpha()
end

function ENT:GetTargetAlpha()
	if self.demat and not self.mat then
		return self.dematvalues[self.step]
	elseif self.mat and not self.demat then
		return self.matvalues[self.step]
	else
		return 255
	end
end

function ENT:UpdateAlpha()
	if self.a==self.ta then
		if self.demat then
			if self.step+1==8 then
				self.demat=false
				self:Disappear()
				return
			else
				self.step=self.step+1
			end
		elseif self.mat then
			if self.step+1==8 then
				self:Stop()
				return
			else
				self.step=self.step+1
			end
		end
		self.ta=self:GetTargetAlpha()
	end
	self.a=math.Approach(self.a,self.ta,FrameTime()*66*self.tpspeed)
	local maincol=self:GetColor()
	maincol=Color(maincol.r,maincol.g,maincol.b,self.a)
	self:SetColor(maincol)
	if self.attachedents then
		for k,v in pairs(self.attachedents) do
			if IsValid(v) then
				local col=v:GetColor()
				col=Color(col.r,col.g,col.b,self.a)
				if not (v.tempa==0) then
					if not (v:GetRenderMode()==RENDERMODE_TRANSALPHA) then
						v:SetRenderMode(RENDERMODE_TRANSALPHA)
					end
					v:SetColor(col)
				end
			end
		end
	end
end

if WireLib then
	function ENT:TriggerInput(k,v)
		if k=="Demat" and v==1 and self.wirepos and self.wireang and not self.moving then
			self:Go(self.wirepos, self.wireang)
		elseif k=="Phase" and v==1 then
			self:TogglePhase()
		elseif k=="Flightmode" and v==1 then
			self:ToggleFlight()
		elseif k=="X" then
			self.wirepos.x=v
		elseif k=="Y" then
			self.wirepos.y=v
		elseif k=="Z" then
			self.wirepos.z=v
		elseif k=="XYZ" then
			self.wirepos=v
		elseif k=="Rot" then
			self.wireang.y=v
		end
	end
end

function ENT:SpawnLight()
	// cheers to 'Doctor Who Dev Team' for this
	local col=tostring(self.extcol.r).." "..tostring(self.extcol.g).." "..tostring(self.extcol.b)
	local light = ents.Create("env_sprite")
	light:SetPos(self:GetPos() + self:GetUp() * 123)
	light:SetAngles(self:GetAngles())
	light:SetKeyValue("renderfx", 4)
	light:SetKeyValue("rendermode", 3)
	light:SetKeyValue("renderamt", "200")
    light:SetKeyValue("rendercolor", col)
    light:SetKeyValue("model", "sprites/light_glow01.spr")
    light:SetKeyValue("scale", 1)
	light:SetKeyValue("glowproxysize", 9)
    light:Spawn()
	light:SetParent(self)
	return light
end

function ENT:SpawnStaticLight()
	local col=tostring(self.extcol.r).." "..tostring(self.extcol.g).." "..tostring(self.extcol.b)
	local light2 = ents.Create("env_sprite")
	light2:SetPos(self:GetPos() + self:GetUp()*123)
	light2:SetAngles(self:GetAngles())
	light2:SetKeyValue("rendermode", 3)
	light2:SetKeyValue("renderamt", "150")
        light2:SetKeyValue("rendercolor", col)
        light2:SetKeyValue("model", "sprites/light_glow01.spr")
        light2:SetKeyValue("scale", 1)
	light2:SetKeyValue("glowproxysize", 4)
        light2:Spawn()
	light2:SetParent(self)
	return light2
end
 
function ENT:Use( ply, caller )
	if CurTime()>self.exitcur then
		self.exitcur=CurTime()+1
		self:PlayerEnter(ply)
	end
end

function ENT:PlayerEnter( ply, override )
	if self.occupants then
		for k,v in pairs(self.occupants) do
			if ply==v and (not ply.smith_viewmode or ply.smith_skycamera) then return end
		end
	end
	if tobool(GetConVarNumber("smith_teleportlock"))==true and self.moving and not override then
		return
	end
	if self.locked and not override then
		ply:ChatPrint("This TARDIS is locked.")
		return
	end
	if self.repairing then
		if self.repairfinish then
			ply:ChatPrint("This TARDIS is self-repairing, completion in "..math.floor(self.repairfinish-CurTime()).." seconds.")
		else
			ply:ChatPrint("This TARDIS is self-repairing.")
		end
		return
	end
	if ply.smith and IsValid(ply.smith) then
		ply.smith:PlayerExit( ply )
	end
	ply.smith=self
	
	net.Start("Player-Setsmith")
		net.WriteEntity(ply)
		net.WriteEntity(self)
	net.Broadcast()
	ply.smith_viewmode=true
	net.Start("smith-SetViewmode")
		net.WriteBit(true)
	net.Send(ply)
	if self.interior and IsValid(self.interior) then
		ply:SetPos(self.interior:LocalToWorld(Vector(-308,0,98)))
		local ang=(ply:EyeAngles()-self:GetAngles())+self.interior:GetAngles()+Angle(0,180,0)
		ply:SetEyeAngles(Angle(ang.p,ang.y,0))
	end
	table.insert(self.occupants,ply)
	if ply:KeyDown(IN_WALK) or (self.interior and not IsValid(self.interior)) then
		self:ToggleViewmode(ply,true)
		self.viewmodecur=CurTime()+1
	end
	net.Start("smith-PlayerEnter") 
		net.WriteEntity(self)
		if self.interior and IsValid(self.interior) then
			net.WriteEntity(self.interior)
		end
	net.Broadcast()
end

function ENT:OnRemove()
	if self.occupants then
		for k,v in pairs(self.occupants) do
			if !v.smith_viewmode then
				self:ToggleViewmode(v,true)
			end
			self:PlayerExit(v,true)
		end
	end
	self.light:Remove()
	self.light=nil
	if self.interior and IsValid(self.interior) then
		self.interior:Remove()
		self.interior=nil
	end
end

function ENT:PlayerExit( ply, override )
	if tobool(GetConVarNumber("smith_teleportlock"))==true and self.moving and not override then
		return
	end
	if self.invortex and not override then return end
	if ply:InVehicle() then ply:ExitVehicle() end
	if self.locked and not override then
		ply:ChatPrint("This TARDIS is locked.")
		return
	end
	net.Start("Player-Setsmith")
		net.WriteEntity(ply)
		net.WriteEntity(NULL)
	net.Broadcast()
	net.Start("smith-SetViewmode")
		net.WriteBit(false)
	net.Send(ply)
	ply.smith=nil
	ply.smith_viewmode=false
	ply.smithint_pos=nil
	ply.smithint_ang=nil
	net.Start("smith-SetViewmode")
		net.WriteBit(tobool(ply.smith_viewmode))
	net.Send(ply)
	ply:SetPos(self:GetPos()+self:GetForward()*60)
	local ang=ply:EyeAngles()+(self:GetPos()-ply:GetPos()):Angle()+Angle(0,0,0)
	ply:SetEyeAngles(Angle(ang.p,ang.y,0))
	if self.occupants then
		for k,v in pairs(self.occupants) do
			if v==ply then
				if override then
					self.occupants[k]=nil
				else
					table.remove(self.occupants,k)
				end
			end
		end
	end
	if ply==self.pilot then // not sure how, but failsafes
		self.pilot=nil
	end
	net.Start("smith-PlayerExit") 
		net.WriteEntity(self)
		if self.interior and IsValid(self.interior) then
			net.WriteEntity(self.interior)
		end
	net.Broadcast()
end

hook.Add("PlayerSpawn", "smith_PlayerSpawn", function( ply )
	local smith=ply.smith
	if smith and IsValid(smith) then
		if ply.smith_viewmode and smith.interior and IsValid(smith.interior) then
			ply:SetPos(smith.interior:LocalToWorld(Vector(-308,0,98)))
			local ang=smith.interior:GetAngles()+Angle(0,0,0)
			ply:SetEyeAngles(Angle(ang.p,ang.y,0))
		else
			smith:PlayerExit(ply)
		end
	end
end)

hook.Add("PlayerInitialSpawn", "smith_PlayerInitialSpawn", function( ply )
	timer.Simple(5,function()
		if not IsValid(ply) then return end
		for k,v in pairs(ents.FindByClass("sent_smith")) do
			if v and IsValid(v) then
				net.Start("smith-UpdateVis")
					net.WriteEntity(v)
					net.WriteBit(tobool(v.visible))
				net.Send(ply)
			end
		end
	end)
end)

function ENT:PhysicsUpdate( ph )
	local pos=self:GetPos()
	if self.flightmode and self.power then		
		local phm=FrameTime()*66
		
		local up=self:GetUp()
		local ri2=self:GetRight()
		local left=ri2*-1
		local fwd2=self:GetForward()
		local ang=self:GetAngles()
		local angvel=ph:GetAngleVelocity()
		local vel=ph:GetVelocity()
		local vell=ph:GetVelocity():Length()
		local cen=ph:GetMassCenter()
		local mass=ph:GetMass()
		local lev=ph:GetInertia():Length()
		local force=15
		local vforce=5
		local rforce=2
		local tforce=400
		local tilt=0
		
		if self.tracking and not self.exploded then
			if IsValid(self.trackingent) then
				local e=self.trackingent
				local tvel=e:GetVelocity()
				local tfwd=tvel:Angle():Forward()
				local target=e:LocalToWorld(self.trackingoffset)+(tfwd*tvel:Length())
				ph:ApplyForceCenter((target-pos)*mass)
				ph:ApplyForceCenter(-vel*mass)
				if self.pilot and IsValid(self.pilot) and not self.pilot.smith_viewmode then
					local p=self.pilot
					if CurTime()>self.tracknotifycur and (p:KeyDown(IN_FORWARD) or p:KeyDown(IN_BACK) or p:KeyDown(IN_MOVELEFT) or p:KeyDown(IN_MOVERIGHT)) then
						self.tracknotifycur=CurTime()+2
						p:ChatPrint("Tracking currently active, press jump key to disable.")
					end
					if p:KeyDown(IN_JUMP) then
						self:SetTrackingEnt()
						p:ChatPrint("Tracking disabled.")
					end					
				end
			else
				self:SetTrackingEnt(nil)
			end
		else
			if self.pilot and IsValid(self.pilot) and not self.pilot.smith_viewmode then
				local p=self.pilot
				local eye=p:EyeAngles()
				local fwd=eye:Forward()
				local ri=eye:Right()
				
				if CurTime()>self.physlocknotifycur and self.physlocked and (p:KeyDown(IN_FORWARD) or p:KeyDown(IN_BACK) or p:KeyDown(IN_MOVELEFT) or p:KeyDown(IN_MOVERIGHT)) then
					self.physlocknotifycur=CurTime()+2
					p:ChatPrint("WARNING: Physical lock active.")
				end
				
				if self.exploded then
					if p:KeyDown(IN_ATTACK2) and CurTime()>self.explodedshift then
						ph:AddVelocity(AngleRand():Forward()*(vell))
						self.explodedshift=CurTime()+1
					end
				elseif not self.exploded then
					if p:KeyDown(IN_SPEED) then
						force=force*2.5
						tilt=5
					end
					if p:KeyDown(IN_FORWARD) then
						ph:AddVelocity(fwd*force*phm)
						tilt=tilt+5
					end
					if p:KeyDown(IN_BACK) then
						ph:AddVelocity(-fwd*force*phm)
						tilt=tilt+5
					end
					if p:KeyDown(IN_MOVERIGHT) then
						if p:KeyDown(IN_WALK) then
							ph:AddAngleVelocity(Vector(0,0,-rforce))
						else
							ph:AddVelocity(ri*force*phm)
							tilt=tilt+5
						end
					end
					if p:KeyDown(IN_MOVELEFT) then
						if p:KeyDown(IN_WALK) then
							ph:AddAngleVelocity(Vector(0,0,rforce))
						else
							ph:AddVelocity(-ri*force*phm)
							tilt=tilt+5
						end
					end
					
					if p:KeyDown(IN_DUCK) then
						ph:AddVelocity(-up*vforce*phm)
					elseif p:KeyDown(IN_JUMP) then
						ph:AddVelocity(up*vforce*phm)
					end
				end
			end
		end
		
		if self.spinmode==0 then
			tilt=0
		elseif self.spinmode==1 then
			tforce=-tforce
		end
		
		
		if not self.exploded then
			ph:ApplyForceOffset( up*-ang.p,cen-fwd2*lev)
			ph:ApplyForceOffset(-up*-ang.p,cen+fwd2*lev)
			if self.tracking and IsValid(self.trackingent) and self.spinmode==0 then
				local e=self.trackingent
				local a=e:WorldToLocalAngles(ang+Angle(0,self.trackingyawoffset,0))
				ph:ApplyForceOffset( ri2*-a.y,cen-fwd2*lev)
				ph:ApplyForceOffset(-ri2*-a.y,cen+fwd2*lev)
			end
			ph:ApplyForceOffset( up*-(ang.r-tilt),cen-ri2*lev)
			ph:ApplyForceOffset(-up*-(ang.r-tilt),cen+ri2*lev)
		end
		
		if not self.exploded then
			if not (self.spinmode==0) then
				local twist=Vector(0,0,vell/tforce)
				ph:AddAngleVelocity(twist)
			end
			local angbrake=angvel*-0.015
			ph:AddAngleVelocity(angbrake)
			local brake=vel*-0.01
			ph:AddVelocity(brake)
		elseif self.exploded and vell<1500 then
			local speed=vel*0.01
			ph:AddVelocity(speed)
			local angle=AngleRand():Forward()*75
			ph:AddAngleVelocity(angle)
		end
		
		if ph:IsGravityEnabled() then // this is for when certain things force gravity on, e.g. horizon/spacebuild
			ph:AddVelocity(Vector(0,0,9.015))
		end
	end
	
	if self.hads then
		if self:WaterLevel() >= 2 then
			self:DematFast()
		end
	end
	
	if self.occupants then
		for k,v in pairs(self.occupants) do
			if not v.smith_viewmode then
				v:SetPos(pos)
			end
		end
	end
end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed and data.Speed>200 then
		local n=math.Clamp(data.Speed*0.01,0,16)
		if tobool(GetConVarNumber("smith_physdamage"))==true then
			self:TakeHP(n*0.1) // approximately 1hp for a moderate hit
		end
	end
end

function ENT:ToggleFlight()
	local flightphase=tobool(GetConVarNumber("smith_flightphase"))==true
	if not (CurTime()>self.flightcur) or self.repairing or not self.power or (not flightphase and not self.visible) then return false end
	self.flightcur=CurTime()+1
	self.flightmode=(not self.flightmode)
	if self.flightmode then
		if !self.RotorWash and self.visible then
			self:CreateRotorWash()
		end		
	else
		if not self.moving and self.visible then
			self:RemoveRotorWash()
		end
	end
	if self.phys and IsValid(self.phys) then
		self.phys:EnableGravity(not self.flightmode)
	end
	if self.visible and not self.moving and not self.exploded then
		self:SetLight(self.flightmode)
	end
	net.Start("smith-Flightmode")
		net.WriteEntity(self)
		net.WriteBit(tobool(self.flightmode))
	net.Broadcast()
	return true
end

function ENT:CreateRotorWash()
	if not self.visible or self.invortex then return end
	if IsValid(self.RotorWash) then return end
	self.RotorWash = ents.Create("env_rotorwash_emitter")
	self.RotorWash:SetPos(self:GetPos())
	self.RotorWash:SetParent(self)
	self.RotorWash:Activate()
end

function ENT:RemoveRotorWash()
	if IsValid(self.RotorWash) then
		self.RotorWash:Remove()
		self.RotorWash=nil
	end
end

function ENT:TogglePhase()
	local flightphase=tobool(GetConVarNumber("smith_flightphase"))==true
	if CurTime()>self.phasecur and not self.exploded and not self.repairing and self.power then
		if self.flightmode and not flightphase then return false end
		self.phasecur=CurTime()+2
		self.visible=(not self.visible)
		net.Start("smith-Phase")
			net.WriteEntity(self)
			net.WriteEntity(self.interior)
			net.WriteBit(tobool(self.visible))
		net.Broadcast()
		self:DrawShadow(self.visible)
		if self.visible and (self.moving or self.flightmode) then
			self:SetLight(true)
		else
			self:SetLight(false)
		end
		if not self.visible then
			self:RemoveRotorWash()
		elseif self.visible then
			self:CreateRotorWash()
		end
		return true
	end
	return false
end

function ENT:ToggleViewmode(ply,deldata)
	ply.smith_viewmode=(not ply.smith_viewmode) // true = inside, false = third-person view
	net.Start("smith-SetViewmode")
		net.WriteBit(tobool(ply.smith_viewmode))
	net.Send(ply)
	if ply.smith_viewmode then
		ply:UnSpectate()
		ply:DrawViewModel(true)
		ply:DrawWorldModel(true)
		ply:Spawn()
		if ply.weps then
			for k,v in pairs(ply.weps) do
				ply:Give(tostring(v))
			end
		end
		if ply.ammo then
			for k,v in pairs(ply.ammo) do
				ply:SetAmmo(v,k)
			end
		end
		ply.weps=nil
		ply.ammo=nil
		if self.pilot and IsValid(self.pilot) and self.pilot==ply then
			self.pilot=nil
			local tbl={}
			for k,v in pairs(self.occupants) do
				if not v.smith_viewmode then
					table.insert(tbl,v)
				end
			end
			if not self.isomorphic and #tbl>0 then
				local newpilot=tbl[math.random(#tbl)]
				if self.owner.smith==self and not self.owner.smith_viewmode then
					newpilot=self.owner
				end
				if newpilot and IsValid(newpilot) and newpilot:IsPlayer() then
					self.pilot=newpilot
					self.pilot:ChatPrint("You are now the pilot.")
					for k,v in pairs(tbl) do
						if not (v==self.pilot) then
							v:ChatPrint(self.pilot:Nick().." is now the pilot.")
						end
					end
				end
				ply:ChatPrint(self.pilot:Nick().." is now the pilot.")
			else
				ply:ChatPrint("You are no longer the pilot.")
			end
		end
		if self.interior and IsValid(self.interior) then
			if not deldata and ply.smithint_pos and ply.smithint_ang then
				ply:SetPos(self.interior:LocalToWorld(ply.smithint_pos))
				ply:SetEyeAngles(ply.smithint_ang)
				ply.smithint_pos=nil
				ply.smithint_ang=nil
			else
				ply:SetPos(self.interior:GetPos()+Vector(-308,0,98))
				local ang=self.interior:GetAngles()+Angle(0,0,0)
				ply:SetEyeAngles(Angle(ang.p,ang.y,0))
			end
		end
	else
		if not deldata then
			ply.smithint_pos=self.interior:WorldToLocal(ply:GetPos())
			ply.smithint_ang=ply:EyeAngles()
		end
		ply.weps={}
		ply.ammo={}
		for k,v in pairs(ply:GetWeapons()) do
			table.insert(ply.weps, v:GetClass())
			local p=v:GetPrimaryAmmoType()
			local s=v:GetSecondaryAmmoType()
			if p != -1 then
				ply.ammo[p]=ply:GetAmmoCount(p)
			end
			if s != -1 then
				ply.ammo[s]=ply:GetAmmoCount(s)
			end
		end
		ply:Spectate( OBS_MODE_ROAMING )
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)
		ply:CrosshairDisable(true)
		ply:StripWeapons()
		if self.pilot then
			ply:ChatPrint(self.pilot:Nick().." is the pilot.")
		elseif not self.pilot and ((self.isomorphic and self.owner==ply) or not self.isomorphic) then
			self.pilot=ply
			self.pilot:ChatPrint("You are now the pilot.")
		end
	end
end

function ENT:TogglePhysLock()
	if self.exploded or not self.power or self.invortex then
		return false
	else
		if self.physlocked then
			self:GetPhysicsObject():EnableMotion(true)
			self.physlocked=false
		else
			self:GetPhysicsObject():EnableMotion(false)
			self.physlocked=true
		end
		return true
	end
end

function ENT:TogglePower()
	if not self.moving and not self.repairing then
		if self.power then
			if self:GetLocked() then
				self:SetLocked(false,true)
				self.waslocked=true
			end
			if self.physlocked then
				self:TogglePhysLock()
				self.wasphyslocked=true
			end
			if self.flightmode then
				self:ToggleFlight()
				self.wasflying=true
			end
		end
		self.power=(not self.power)
		net.Start("smith-SetPower")
			net.WriteEntity(self)
			net.WriteBit(self.power)
			if IsValid(self.interior) then
				net.WriteEntity(self.interior)
			end
		net.Broadcast()
		if self.power then
			if self.waslocked then
				self:SetLocked(true,true)
				self.waslocked=nil
			end
			if self.wasphyslocked then
				self:TogglePhysLock()
				self.wasphyslocked=nil
			end
			if self.wasflying then
				self:ToggleFlight()
				self.wasflying=nil
			end
		end
		return true
	end
	return false
end

function ENT:Think()
        if self.health and self.health > 20 and self.visible and self.power and not self.moving and tobool(GetConVarNumber("smith_dynamiclight"))==true then
                self:SetStaticLight(true)
        else
                self:SetStaticLight(false)
        end
	if self.demat or self.mat then
		self:UpdateAlpha()
	end

	if self.pilot and not IsValid(self.pilot) then
		self.pilot=nil
	end
	
	if self.repairing and not self.repairwait and self.repairfinish and CurTime()>self.repairfinish then
		self:EndRepair()
	end

	if self.occupants then
		if self.repairwait and #self.occupants==0 then
			self:BeginRepair()
		end
		for k,v in pairs(self.occupants) do
			if not IsValid(v) then
				self.occupants[k]=nil
				continue
			end
			if CurTime()>self.viewmodecur and v:KeyDown(IN_USE) and not v.smith_viewmode then
				self:ToggleViewmode(v)
				self.viewmodecur=CurTime()+1
				if v:KeyDown(IN_WALK) or (self.interior and not IsValid(self.interior)) then
					self:PlayerExit(v)
					self.exitcur=CurTime()+1
				end
			end
		end
	end
	
	if self.moving then
		local a1=self:GetPos()
		for k,v in pairs(ents.FindInSphere(self:GetPos(),150)) do
			if v:GetClass()=="prop_physics" then
				local a2=v:GetPos()
				local force=5
				local vec=a2-a1
				vec:Normalize()
				v:GetPhysicsObject():AddVelocity(vec*force)
			end
		end
		if not self.invortex and self.visible then
			self:CreateRotorWash()
		end
	elseif not self.flightmode and self.visible then
		self:RemoveRotorWash()
	end
	
	if self.phys and IsValid(self.phys) then
		self.phys:Wake()
	end
	
	if CurTime() > self.flightcur and self.pilot and IsValid(self.pilot) and self.pilot:KeyDown(IN_RELOAD) and not self.pilot.smith_viewmode and self.power then
		self:ToggleFlight()
		if self.flightmode and self.physlocked then
			self.pilot:ChatPrint("WARNING: Physical lock active.")
		end
		if self.flightmode and self.tracking then
			self.pilot:ChatPrint("WARNING: Tracking active.")
		end
	end
	
	if CurTime() > self.phasecur and self.pilot and IsValid(self.pilot) and self.pilot:KeyDown(IN_ATTACK2) and not self.pilot.smith_viewmode and self.power then
		self:TogglePhase()
	end
	
	if self.moving and self.invortex and not self.reappearing and self.pilot and IsValid(self.pilot) and self.pilot:KeyDown(IN_ATTACK) then
		self:LongReappear()
	end
	
	if not self.moving and not self.repairing and self.pilot and IsValid(self.pilot) and self.pilot:KeyDown(IN_ATTACK) and not self.pilot.smith_viewmode and self.power then
		if self.pilot.linked_smith and self.pilot.linked_smith==self and self.pilot.smith_vec and self.pilot.smith_ang then
			self:Go(self.pilot.smith_vec, self.pilot.smith_ang)
			self.pilot.smith_vec=nil
			self.pilot.smith_ang=nil
			self.pilot:ChatPrint("TARDIS moving to set destination.")
		else
			local filter=table.Copy(self.occupants)
			table.insert(filter,self)
			local trace = util.QuickTrace( self.pilot:EyePos(), self.pilot:GetAimVector() * 9999999, filter)
			local angle=trace.HitNormal:Angle()
			angle:RotateAroundAxis( angle:Right( ), -90 )
			self:Go(trace.HitPos, angle)
			self.pilot:ChatPrint("TARDIS moving to AimPos.")
		end
	end
	
	if string.lower(gmod.GetGamemode().Name)=="horizon" then
		for k,v in pairs(self.occupants) do
			if v.suitAir and v.suitCoolant and v.suitPower then
				if v.suitAir<5 then
					v.suitAir=v.suitAir+1
				end
				if v.suitCoolant<5 then
					v.suitCoolant=v.suitCoolant+1
				end
				if v.suitPower<5 then
					v.suitPower=v.suitPower+1
				end
			end
		end
	end
	
	if CAF and CAF.GetAddon("Spacebuild") then
		for k,v in pairs(self.occupants) do
			if v.LsResetSuit then
				v:LsResetSuit()
			end
		end
	end

	// this bit makes it all run faster and smoother
    self:NextThink( CurTime() )
	return true
end