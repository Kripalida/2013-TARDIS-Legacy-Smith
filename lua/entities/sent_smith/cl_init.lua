include('shared.lua')
 
--[[---------------------------------------------------------
   Name: Draw
   Purpose: Draw the model in-game.
   Remember, the things you render first will be underneath!
---------------------------------------------------------]]
function ENT:Draw() 
	if not self.phasing and self.visible and not self.invortex then
		self:DrawModel()
		if WireLib then
			Wire_Render(self)
		end
	elseif self.phasing then
		if self.percent then
			if not self.phasemode and self.highPer <= 0 then
				self.phasing=false
			elseif self.phasemode and self.percent >= 1 then
				self.phasing=false
			end
		end
		
		self.percent = (self.phaselifetime - CurTime())
		self.highPer = self.percent + 0.5
		if self.phasemode then
			self.percent = (1-self.percent)-0.5
			self.highPer = self.percent+0.5
		end
		self.percent = math.Clamp( self.percent, 0, 1 )
		self.highPer = math.Clamp( self.highPer, 0, 1 )

		--Drawing original model
		local normal = self:GetUp()
		local origin = self:GetPos() + self:GetUp() * (self.maxs.z - ( self.height * self.highPer ))
		local distance = normal:Dot( origin )
		
		render.EnableClipping( true )
		render.PushCustomClipPlane( normal, distance )
			self:DrawModel()
		render.PopCustomClipPlane()
		
		local restoreT = self:GetMaterial()
		
		--Drawing phase texture
		render.MaterialOverride( self.wiremat )

		normal = self:GetUp()
		distance = normal:Dot( origin )
		render.PushCustomClipPlane( normal, distance )
		
		local normal2 = self:GetUp() * -1
		local origin2 = self:GetPos() + self:GetUp() * (self.maxs.z - ( self.height * self.percent ))
		local distance2 = normal2:Dot( origin2 )
		render.PushCustomClipPlane( normal2, distance2 )
			self:DrawModel()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		
		render.MaterialOverride( restoreT )
		render.EnableClipping( false )
	end
end

function ENT:Phase(mode)
	self.phasing=true
	self.phaseactive=true
	self.phaselifetime=CurTime()+1
	self.phasemode=mode
end

function ENT:Initialize()
	self.health=1000
	self.phasemode=false
	self.visible=true
	self.flightmode=false
	self.visible=true
	self.power=false
	self.z=0
	self.phasedraw=0
	self.mins = self:OBBMins()
	self.maxs = self:OBBMaxs()
	self.wiremat = Material( "models/hoxii/smith/phase" )
	self.height = self.maxs.z - self.mins.z
end

function ENT:OnRemove()
	if self.flightloop then
		self.flightloop:Stop()
		self.flightloop=nil
	end
	if self.flightloop2 then
		self.flightloop2:Stop()
		self.flightloop2=nil
	end
end

function ENT:Think()
	if tobool(GetConVarNumber("smith_flightsound"))==true then
		if not self.flightloop then
			self.flightloop=CreateSound(self, "hoxii/smith/flight_loopext.wav")
			self.flightloop:SetSoundLevel(90)
			self.flightloop:Stop()
		end
		if self.flightmode and self.visible and not self.moving then
			if !self.flightloop:IsPlaying() then
				self.flightloop:Play()
			end
			local e = LocalPlayer():GetViewEntity()
			if !IsValid(e) then e = LocalPlayer() end
			local smith=LocalPlayer().smith
			if not (smith and IsValid(smith) and smith==self and e==LocalPlayer()) then
				local pos = e:GetPos()
				local spos = self:GetPos()
				local doppler = (pos:Distance(spos+e:GetVelocity())-pos:Distance(spos+self:GetVelocity()))/200
				if self.exploded then
					local r=math.random(90,130)
					self.flightloop:ChangePitch(math.Clamp(r+doppler,80,120),0.1)
				else
					self.flightloop:ChangePitch(math.Clamp((self:GetVelocity():Length()/250)+95+doppler,80,120),0.1)
				end
				self.flightloop:ChangeVolume(GetConVarNumber("smith_flightvol"),0)
			else
				if self.exploded then
					local r=math.random(90,130)
					self.flightloop:ChangePitch(r,0.1)
				else
					local p=math.Clamp(self:GetVelocity():Length()/250,0,15)
					self.flightloop:ChangePitch(95+p,0.1)
				end
				self.flightloop:ChangeVolume(0.75*GetConVarNumber("smith_flightvol"),0)
			end
		else
			if self.flightloop:IsPlaying() then
				self.flightloop:Stop()
			end
		end
		
		local interior=self:GetNWEntity("interior",NULL)
		if not self.flightloop2 and interior and IsValid(interior) then
			self.flightloop2=CreateSound(interior, "hoxii/smith/flight_loop.wav")
			self.flightloop2:Stop()
		end
		if self.flightloop2 and (self.flightmode or self.invortex) and LocalPlayer().smith_viewmode and not IsValid(LocalPlayer().smith_skycamera) and interior and IsValid(interior) and ((self.invortex and self.moving) or not self.moving) then
			if !self.flightloop2:IsPlaying() then
				self.flightloop2:Play()
				self.flightloop2:ChangeVolume(0.4,0)
			end
			if self.exploded then
				local r=math.random(90,130)
				self.flightloop2:ChangePitch(r,0.1)
			else
				local p=math.Clamp(self:GetVelocity():Length()/250,0,15)
				self.flightloop2:ChangePitch(95+p,0.1)
			end
		elseif self.flightloop2 then
			if self.flightloop2:IsPlaying() then
				self.flightloop2:Stop()
			end
		end
	else
		if self.flightloop then
			self.flightloop:Stop()
			self.flightloop=nil
		end
		if self.flightloop2 then
			self.flightloop2:Stop()
			self.flightloop2=nil
		end
	end
	
	if self.light_on and tobool(GetConVarNumber("smith_dynamiclight"))==true then
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			local size=400
			local v=self:GetNWVector("extcol",Vector(255,255,255))
			local c=Color(v.x,v.y,v.z)
			dlight.Pos = self:GetPos() + self:GetUp() * 123
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			dlight.Brightness = 1
			dlight.Decay = size * 5
			dlight.Size = size
			dlight.DieTime = CurTime() + 1
		end
	end
	if self.health and self.health > 20 and self.visible and self.power and not self.moving and tobool(GetConVarNumber("smith_dynamiclight"))==true then
		local dlight2 = DynamicLight( self:EntIndex() )
		if ( dlight2 ) then
			local size=400
			local v=self:GetNWVector("extcol",Vector(255,255,255))
			local c=Color(v.x,v.y,v.z)
			dlight2.Pos = self:GetPos() + self:GetUp() * 123
			dlight2.r = c.r
			dlight2.g = c.g
			dlight2.b = c.b
			dlight2.Brightness = 1
			dlight2.Decay = size * 5
			dlight2.Size = size
			dlight2.DieTime = CurTime() + 1
		end
	end
end

net.Receive("smith-UpdateVis", function()
	local ent=net.ReadEntity()
	ent.visible=tobool(net.ReadBit())
end)

net.Receive("smith-Phase", function()
	local smith=net.ReadEntity()
	local interior=net.ReadEntity()
	if IsValid(smith) then
		smith.visible=tobool(net.ReadBit())
		smith:Phase(smith.visible)
		if not smith.visible and tobool(GetConVarNumber("smith_phasesound"))==true then
			smith:EmitSound("hoxii/smith/cloak.wav", 100, 100)
			if IsValid(interior) then
				interior:EmitSound("hoxii/smith/cloak.wav", 100, 100)
			end
		end
	end
end)

net.Receive("smith-UpdateUnVis", function()
	local ent=net.ReadEntity()
	ent.unvisible=tobool(net.ReadBit())
end)

net.Receive("smith-UnPhase", function()
	local smith=net.ReadEntity()
	local interior=net.ReadEntity()
	if IsValid(smith) then
		smith.unvisible=tobool(net.ReadBit())
		smith:UnPhase(smith.unvisible)
		if not smith.unvisible and tobool(GetConVarNumber("smith_unphasesound"))==true then
			smith:EmitSound("hoxii/smith/uncloak.wav", 100, 100)
			if IsValid(interior) then
				interior:EmitSound("hoxii/smith/uncloak.wav", 100, 100)
			end
		end
	end
end)

net.Receive("smith-Explode", function()
	local ent=net.ReadEntity()
	ent.exploded=true
end)

net.Receive("smith-UnExplode", function()
	local ent=net.ReadEntity()
	ent.exploded=false
end)

net.Receive("smith-Flightmode", function()
	local ent=net.ReadEntity()
	ent.flightmode=tobool(net.ReadBit())
end)

net.Receive("smith-SetInterior", function()
	local ent=net.ReadEntity()
	ent.interior=net.ReadEntity()
end)

local tpsounds={}
tpsounds[0]={ // normal
	"hoxii/smith/dematext.wav",
	"hoxii/smith/matext.wav",
	"hoxii/smith/fullext.wav"
}
tpsounds[1]={ // fast demat
	"hoxii/smith/fast_demat.wav",
	"hoxii/smith/matext.wav",
	"hoxii/smith/fullext.wav"
}
tpsounds[2]={ // fast return
	"hoxii/smith/fastreturn_demat.wav",
	"hoxii/smith/fastreturn_mat.wav",
	"hoxii/smith/fastreturn_full.wav"
}
net.Receive("smith-Go", function()
	local smith=net.ReadEntity()
	if IsValid(smith) then
		smith.moving=true
	end
	local interior=net.ReadEntity()
	local exploded=tobool(net.ReadBit())
	local pitch=(exploded and 110 or 100)
	local long=tobool(net.ReadBit())
	local snd=net.ReadFloat()
	local snds=tpsounds[snd]
	if tobool(GetConVarNumber("smith_matsound"))==true then
		if IsValid(smith) and LocalPlayer().smith==smith then
			if smith.visible then
				if long then
					smith:EmitSound(snds[1], 100, pitch)
				else
					smith:EmitSound(snds[3], 100, pitch)
				end
			end
			if interior and IsValid(interior) and LocalPlayer().smith_viewmode and not IsValid(LocalPlayer().smith_skycamera) then
				if long then
					sound.Play("hoxii/smith/demat.wav", interior:LocalToWorld(Vector(0,0,0)))
				else
					sound.Play("hoxii/smith/full.wav", interior:LocalToWorld(Vector(0,0,0)))
				end
			end
		elseif IsValid(smith) and smith.visible then
			local pos=net.ReadVector()
			local pos2=net.ReadVector()
			if pos then
				sound.Play(snds[1], pos, 75, pitch)
			end
			if pos2 and not long then
				sound.Play(snds[2], pos2, 75, pitch)
			end
		end
	end
end)

net.Receive("smith-Stop", function()
	smith=net.ReadEntity()
	if IsValid(smith) then
		smith.moving=nil
	end
end)

net.Receive("smith-Reappear", function()
	local smith=net.ReadEntity()
	local interior=net.ReadEntity()
	local exploded=tobool(net.ReadBit())
	local pitch=(exploded and 110 or 100)
	local snd=net.ReadFloat()
	local snds=tpsounds[snd]
	if tobool(GetConVarNumber("smith_matsound"))==true then
		if IsValid(smith) and LocalPlayer().smith==smith then
			if smith.visible then
				smith:EmitSound(snds[2], 100, pitch)
			end
			if interior and IsValid(interior) and LocalPlayer().smith_viewmode and not IsValid(LocalPlayer().smith_skycamera) then
				sound.Play("hoxii/smith/mat.wav", interior:LocalToWorld(Vector(0,0,0)))
			end
		elseif IsValid(smith) and smith.visible then
			sound.Play(snds[2], net.ReadVector(), 75, pitch)
		end
	end
end)

net.Receive("Player-Setsmith", function()
	local ply=net.ReadEntity()
	ply.smith=net.ReadEntity()
end)

net.Receive("smith-SetHealth", function()
	local smith=net.ReadEntity()
	smith.health=net.ReadFloat()
end)

net.Receive("smith-SetLocked", function()
	local smith=net.ReadEntity()
	local interior=net.ReadEntity()
	local locked=tobool(net.ReadBit())
	local makesound=tobool(net.ReadBit())
	if IsValid(smith) then
		smith.locked=locked
		if tobool(GetConVarNumber("smith_locksound"))==true and makesound then
			sound.Play("hoxii/smith/lock.wav", smith:GetPos())
		end
	end
	if IsValid(interior) then
		if tobool(GetConVarNumber("smith_locksound"))==true and not IsValid(LocalPlayer().smith_skycamera) and makesound then
			sound.Play("hoxii/smith/lock.wav", interior:LocalToWorld(Vector(-308,0,0)))
		end
	end
end)

net.Receive("smith-SetViewmode", function()
	LocalPlayer().smith_viewmode=tobool(net.ReadBit())
	LocalPlayer().ShouldDisableLegs=(not LocalPlayer().smith_viewmode)
	
	if LocalPlayer().smith_viewmode and GetConVarNumber("r_rootlod")>0 then
		Derma_Query("The TARDIS Interior requires model detail on high, set now?", "2013 TARDIS Interior", "Yes", function() RunConsoleCommand("r_rootlod", 0) end, "No", function() end)
	end
		
end)

hook.Add( "ShouldDrawLocalPlayer", "smith-ShouldDrawLocalPlayer", function(ply)
	if IsValid(ply.smith) and not ply.smith_viewmode then
		return false
	end
end)

net.Receive("smith-PlayerEnter", function()
	if tobool(GetConVarNumber("smith_doorsound"))==true then
		local ent1=net.ReadEntity()
		local ent2=net.ReadEntity()
		if IsValid(ent1) and ent1.visible then
			sound.Play("hoxii/smith/door.wav", ent1:GetPos())
		end
		if IsValid(ent2) and not IsValid(LocalPlayer().smith_skycamera) then
			sound.Play("hoxii/smith/door.wav", ent2:LocalToWorld(Vector(-308,0,0)))
		end
	end
end)

net.Receive("smith-PlayerExit", function()
	if tobool(GetConVarNumber("smith_doorsound"))==true then
		local ent1=net.ReadEntity()
		local ent2=net.ReadEntity()
		if IsValid(ent1) and ent1.visible then
			sound.Play("hoxii/smith/door.wav", ent1:GetPos())
		end
		if IsValid(ent2) and not IsValid(LocalPlayer().smith_skycamera) then
			sound.Play("hoxii/smith/door.wav", ent2:LocalToWorld(Vector(-308,0,0)))
		end
	end
end)

net.Receive("smith-SetRepairing", function()
	local smith=net.ReadEntity()
	local repairing=tobool(net.ReadBit())
	local interior=net.ReadEntity()
	if IsValid(smith) then
		smith.repairing=repairing
	end
	if IsValid(interior) and LocalPlayer().smith==smith and LocalPlayer().smith_viewmode and tobool(GetConVarNumber("smithint_powersound"))==true then
		if repairing then
			sound.Play("hoxii/smith/powerdown.wav", interior:GetPos())
		else
			sound.Play("hoxii/smith/powerup.wav", interior:GetPos())
		end
	end
end)

net.Receive("smith-BeginRepair", function()
	local smith=net.ReadEntity()
	if IsValid(smith) then
		/*
		local mat=Material("models/drmatt/smith/smith_df")
		if not mat:IsError() then
			mat:SetTexture("$basetexture", "models/props_combine/metal_combinebridge001")
		end
		*/
	end
end)

net.Receive("smith-FinishRepair", function()
	local smith=net.ReadEntity()
	if IsValid(smith) then
		if tobool(GetConVarNumber("smithint_repairsound"))==true and smith.visible then
			sound.Play("hoxii/smith/repairfinish.wav", smith:GetPos())
		end
		/*
		local mat=Material("models/drmatt/smith/smith_df")
		if not mat:IsError() then
			mat:SetTexture("$basetexture", "models/drmatt/smith/smith_df")
		end
		*/
	end
end)

net.Receive("smith-SetLight", function()
	local smith=net.ReadEntity()
	local on=tobool(net.ReadBit())
	if IsValid(smith) then
		smith.light_on=on
	end
end)

net.Receive("smith-SetPower", function()
	local smith=net.ReadEntity()
	local on=tobool(net.ReadBit())
	local interior=net.ReadEntity()
	if IsValid(smith) then
		smith.power=on
	end
	if IsValid(interior) and LocalPlayer().smith==smith and LocalPlayer().smith_viewmode and tobool(GetConVarNumber("smithint_powersound"))==true then
		if on then
			sound.Play("hoxii/smith/powerup.wav", interior:GetPos())
		else
			sound.Play("hoxii/smith/powerdown.wav", interior:GetPos())
		end
	end
end)

net.Receive("smith-SetVortex", function()
	local smith=net.ReadEntity()
	local on=tobool(net.ReadBit())
	if IsValid(smith) then
		smith.invortex=on
	end
end)

surface.CreateFont( "HUDNumber", {font="Trebuchet MS", size=40, weight=900} )

hook.Add("HUDPaint", "smith-DrawHUD", function()
	local p = LocalPlayer()
	local smith = p.smith
	if smith and IsValid(smith) and smith.health and (tobool(GetConVarNumber("smith_takedamage"))==true or smith.exploded) then
		local health = math.floor(smith.health)
		local n=0
		if health <= 99 then
			n=20
		end
		if health <= 9 then
			n=40
		end
		local col=Color(255,255,255)
		if health <= 251 then
			col=Color(255,0,0)
		end
		draw.RoundedBox( 20, 820, ScrH()-1070, 280-n, 50, Color(0, 0, 0, 180) )
		draw.DrawText("Integrity: "..health.."%","HUDNumber", 835, ScrH()-1067, col)
	end
end)

hook.Add("CalcView", "smith_CLView", function( ply, origin, angles, fov )
	local smith=LocalPlayer().smith
	local viewent = LocalPlayer():GetViewEntity()
	if !IsValid(viewent) then viewent = LocalPlayer() end
	local dist= -250
	
	if smith and IsValid(smith) and viewent==LocalPlayer() and not LocalPlayer().smith_viewmode then
		local pos=smith:GetPos()+(smith:GetUp()*50)
		local tracedata={}
		tracedata.start=pos
		tracedata.endpos=pos+ply:GetAimVector():GetNormal()*dist
		tracedata.mask=MASK_NPCWORLDSTATIC
		local trace=util.TraceLine(tracedata)
		local view = {}
		view.origin = trace.HitPos
		view.angles = angles
		return view
	end
end)

hook.Add( "HUDShouldDraw", "smith-HideHUD", function(name)
	local viewmode=LocalPlayer().smith_viewmode
	if ((name == "CHudHealth") or (name == "CHudBattery")) and viewmode then
		return false
	end
end)