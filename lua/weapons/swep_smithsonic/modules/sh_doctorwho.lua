-- Doctor Who

if SERVER then
	util.AddNetworkString("smithsonic-SetLinkedsmith")

	function SWEP:Movesmith(ent)
		ent:Go(self.Owner.smith_vec, self.Owner.smith_ang)
		self.Owner.smith_vec=nil
		self.Owner.smith_ang=nil
	end
	
	SWEP:AddHook("Initialize", "doctorwho", function(self)
		self.reloadcur=0
	end)

	SWEP:AddHook("Reload", "doctorwho", function(self)
		if CurTime()>self.reloadcur then
			self.reloadcur=CurTime()+1
			local smith = self.Owner.linked_smith
			if IsValid(self.Owner.linked_smith) then
				if not smith.moving and self.Owner.smith_vec and self.Owner.smith_ang then
					self:Movesmith(self.Owner.linked_smith)
					self.Owner:ChatPrint("TARDIS moving to set destination.")
				elseif not smith.moving and not self.Owner.smith_vec and not self.Owner.smith_ang then
					local trace=util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector() * 99999, { self.Owner } )
					self.Owner.smith_vec=trace.HitPos
					local ang=trace.HitNormal:Angle()
					ang:RotateAroundAxis( ang:Right(), -90 )
					self.Owner.smith_ang=ang
					self:Movesmith(smith)
					self.Owner:ChatPrint("TARDIS moving to AimPos.")
				elseif smith.moving and smith.longflight and smith.invortex then
					self.Owner.linked_smith:LongReappear()
					self.Owner:ChatPrint("TARDIS materialising.")
				end
			end
		end
	end)
	
	SWEP:AddFunction(function(self,data)
		if data.ent.smithExterior then
			data.ent:ToggleDoor()
		end
	end)
	
	SWEP:AddFunction(function(self,data)
		if data.ent.smithPart then
			data.ent:Use(self.Owner, self.Owner, USE_ON, 1)
		end
	end)

	SWEP:AddFunction(function(self,data)
		if self.Owner:KeyDown(IN_WALK) and self.Owner.linked_smith and IsValid(self.Owner.linked_smith) and data.keydown2 and not data.keydown1 and data.hooks.cantool then
			self.Owner.linked_smith:SetTrackingEnt(data.ent)
			if IsValid(self.Owner.linked_smith.trackingent) then
				self.Owner:ChatPrint("Tracking entity set.")
			else
				self.Owner:ChatPrint("Tracking disabled.")
			end
		end
	end)

	SWEP:AddFunction(function(self,data)
		if (data.class=="weepingangel" or data.class=="cube" or data.class=="cube2") and data.hooks.cantool then
			if data.ent.Victim == nil then
				local newvictim=self.Owner
				if data.ent.OldVictim and IsValid(data.ent.OldVictim) and data.ent.OldVictim:IsPlayer() then
					newvictim=data.ent.OldVictim
				end
				data.ent.Victim=newvictim
				data.ent.OldVictim=nil
				local name="Weeping Angel"
				if data.class=="cube" or data.class=="cube2" then name="Cube" end
				self.Owner:ChatPrint("The "..name.." has been un-frozen in time and is now chasing "..newvictim:Nick())
			else
				data.ent.OldVictim=data.ent.Victim
				data.ent.Victim=nil
				local name="Weeping Angel"
				if data.class=="cube" or data.class=="cube2" then name="Cube" end
				self.Owner:ChatPrint("The "..name.." has been frozen in time.")
			end
		end
	end)

	SWEP:AddFunction(function(self,data)
		if (data.class=="sent_smith" or data.class=="sent_smith_interior") and data.hooks.cantool then
			local e
			if data.class=="sent_smith_interior" then
				e=data.ent.smith
			else
				e=data.ent
			end
			if self.Owner:KeyDown(IN_WALK) then
				if data.keydown1 and (not data.keydown2) then
					if self.Owner.linked_smith==e then
						self.Owner.linked_smith=NULL
						net.Start("smithsonic-SetLinkedsmith")
							net.WriteEntity(NULL)
						net.Send(self.Owner)
						self.Owner:ChatPrint("TARDIS unlinked.")
					elseif e.owner==self.Owner or (self.Owner:IsAdmin() or self.Owner:IsSuperAdmin()) then
						self.Owner.linked_smith=e
						net.Start("smithsonic-SetLinkedsmith")
							net.WriteEntity(e)
						net.Send(self.Owner)
						self.Owner:ChatPrint("TARDIS linked.")
					else
						self.Owner:ChatPrint("You may only link a TARDIS you spawned.")
					end
				end
			else
				if data.keydown1 and not data.keydown2 then
					local success=e:ToggleLocked()
					if success then
						if e.locked then
							self.Owner:ChatPrint("TARDIS locked.")
						else
							self.Owner:ChatPrint("TARDIS unlocked.")
						end
					end
				elseif data.keydown2 and not data.keydown1 then
					local success=e:TogglePhase()
					if success then
						if e.visible then
							self.Owner:ChatPrint("TARDIS now visible.")
						else
							self.Owner:ChatPrint("TARDIS no longer visible.")
						end
					end
				end
			end
		end
	end)

	SWEP:AddFunction(function(self,data)
		if data.ent.smith_part then
			data.ent:Use(self.Owner, self.Owner, USE_ON, 1)
		end
	end)

	SWEP:AddFunction(function(self,data)
		if data.class=="worldspawn" and data.ent:IsWorld() and self.Owner.linked_smith then
			if self.Owner:KeyDown(IN_WALK) then
				self.Owner.smith_vec=nil
				self.Owner.smith_ang=nil
				local smith=self.Owner.linked_smith
				if IsValid(smith) and smith.invortex then
					smith:SetDestination(smith:GetPos(),smith:GetAngles())
				end
				self.Owner:ChatPrint("TARDIS destination unset.")
			else
				self.Owner.smith_vec=data.trace.HitPos
				local ang=data.trace.HitNormal:Angle()
				ang:RotateAroundAxis( ang:Right( ), -90 )
				self.Owner.smith_ang=ang
				local smith=self.Owner.linked_smith
				if IsValid(smith) and smith.invortex then
					smith:SetDestination(data.trace.HitPos,ang)
				end
				self.Owner:ChatPrint("TARDIS destination set.")
			end
		end
	end)
else
	function SWEP:PointingAt(ent)
		if not IsValid(ent) then return end
		
		local ViewEnt = self.Owner:GetViewEntity()
		local fov = 20
		local Disp = ent:GetPos() - ViewEnt:GetPos()
		local Dist = Disp:Length()
		local Width = 100
		
		local MaxCos = math.abs( math.cos( math.acos( Dist / math.sqrt( Dist * Dist + Width * Width ) ) + fov * ( math.pi / 180 ) ) )
		Disp:Normalize()
		local dot=Disp:Dot( ViewEnt:EyeAngles():Forward() )
		local tr=self.Owner:GetEyeTraceNoCursor()
		
		if IsValid(tr.Entity) and tr.Entity==ent then
			return 0.25
		elseif dot>MaxCos then
			return math.Clamp((1-dot)*2+0.3,0.1,1)
		else
			return 1
		end
	end
	
	SWEP:AddHook("Think", "doctorwho", function(self, keydown1, keydown2)	
		if (keydown1 and keydown2) and self.Owner.linked_smith and IsValid(self.Owner.linked_smith) and CurTime()>self.curbeep then
			local smith=self.Owner.linked_smith
			local n=self:PointingAt(smith)
			self.curbeep=CurTime()+n
			self:EmitSound("smithsonic/beep.wav")
		end
	end)
	
	net.Receive("smithsonic-SetLinkedsmith", function(len)
		LocalPlayer().linked_smith=net.ReadEntity()
	end)
end