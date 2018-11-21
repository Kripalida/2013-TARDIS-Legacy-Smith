include('shared.lua')
 
--[[---------------------------------------------------------
   Name: Draw
   Purpose: Draw the model in-game.
   Remember, the things you render first will be underneath!
---------------------------------------------------------]]
function ENT:Draw()
	if LocalPlayer().smith_viewmode and self:GetNWEntity("smith",NULL)==LocalPlayer().smith and not LocalPlayer().smith_render then
		self:DrawModel()
		if WireLib then
			Wire_Render(self)
		end
	end
end

function ENT:OnRemove()
	if self.cloisterbell then
		self.cloisterbell:Stop()
		self.cloisterbell=nil
	end
	if self.creaks then
		self.creaks:Stop()
		self.creaks=nil
	end
	if self.idlesound then
		self.idlesound:Stop()
		self.idlesound=nil
	end
end

function ENT:Initialize()
	self.timerotor={}
	self.timerotor.pos=0
	self.timerotor.mode=1
	self.parts={}
end

net.Receive("smithInt-SetParts", function()
	local t={}
	local interior=net.ReadEntity()
	local count=net.ReadFloat()
	for i=1,count do
		local ent=net.ReadEntity()
		ent.smith_part=true
		if IsValid(interior) then
			table.insert(interior.parts,ent)
		end
	end
end)

net.Receive("smithInt-UpdateAdv", function()
	local success=tobool(net.ReadBit())
	if success then
	else
		surface.PlaySound("hoxii/smith/cloisterbell.wav")
	end
end)

net.Receive("smithInt-SetAdv", function()
	local interior=net.ReadEntity()
	local ply=net.ReadEntity()
	local mode=net.ReadFloat()
	if IsValid(interior) and IsValid(ply) and mode then
		if ply==LocalPlayer() then
		end
		interior.flightmode=mode
	end
end)

net.Receive("smithInt-ControlSound", function()
	local smith=net.ReadEntity()
	local control=net.ReadEntity()
	local snd=net.ReadString()
	if IsValid(smith) and IsValid(control) and snd and tobool(GetConVarNumber("smithint_controlsound"))==true and LocalPlayer().smith==smith and LocalPlayer().smith_viewmode then
		sound.Play(snd,control:GetPos())
	end
end)

function ENT:Think()
	local smith=self:GetNWEntity("smith",NULL)
	if IsValid(smith) and LocalPlayer().smith_viewmode and LocalPlayer().smith==smith then
		if tobool(GetConVarNumber("smithint_cloisterbell"))==true and not IsValid(LocalPlayer().smith_skycamera) then
			if smith.health and smith.health < 251 then
				if self.cloisterbell and !self.cloisterbell:IsPlaying() then
					self.cloisterbell:Play()
				elseif not self.cloisterbell then
					self.cloisterbell = CreateSound(self, "hoxii/smith/cloisterbell_loop.wav")
					self.cloisterbell:Play()
				end
			else
				if self.cloisterbell and self.cloisterbell:IsPlaying() then
					self.cloisterbell:Stop()
					self.cloisterbell=nil
				end
			end
		else
			if self.cloisterbell and self.cloisterbell:IsPlaying() then
				self.cloisterbell:Stop()
				self.cloisterbell=nil
			end
		end

		if tobool(GetConVarNumber("smithint_creaks"))==true and not IsValid(LocalPlayer().smith_skycamera) then
			if not smith.power or smith.repairing then
				if self.creaks and !self.creaks:IsPlaying() then
					self.creaks:Play()
				elseif not self.creaks then
					self.creaks = CreateSound(self, "hoxii/smith/creaks_loop.wav")
					self.creaks:Play()
				        self.creaks:ChangeVolume(0.4,0)
				end
			else
				if self.creaks and self.creaks:IsPlaying() then
					self.creaks:Stop()
					self.creaks=nil
				end
			end
		else
			if self.creaks and self.creaks:IsPlaying() then
				self.creaks:Stop()
				self.creaks=nil
			end
		end
		
				if tobool(GetConVarNumber("smithint_crack"))==true and not IsValid(LocalPlayer().smith_skycamera) then
			if smith.health and smith.health < 76 then
				if self.crack and !self.crack:IsPlaying() then
					self.crack:Play()
				elseif not self.crack then
					self.crack = CreateSound(self, "doctorwho1200/capaldi/crack.wav")
					self.crack:Play()
				        self.crack:ChangeVolume(1,0)
				end
			else
				if self.crack and self.crack:IsPlaying() then
					self.crack:Stop()
					self.crack=nil
				end
			end
		else
			if self.crack and self.crack:IsPlaying() then
				self.crack:Stop()
				self.crack=nil
			end
		end	
		
		if tobool(GetConVarNumber("smithint_idlesound"))==true and smith.health and smith.health >= 1 and not IsValid(LocalPlayer().smith_skycamera) and not smith.repairing and smith.power then
			if self.idlesound and !self.idlesound:IsPlaying() then
				self.idlesound:Play()
			elseif not self.idlesound then
				self.idlesound = CreateSound(self, "hoxii/smith/interior_idle_loop.wav")
				self.idlesound:Play()
				self.idlesound:ChangeVolume(0.7,0)
			end
		else
			if self.idlesound and self.idlesound:IsPlaying() then
				self.idlesound:Stop()
				self.idlesound=nil
			end
		end
		
		if not IsValid(LocalPlayer().smith_skycamera) and tobool(GetConVarNumber("smithint_dynamiclight"))==true then
			if smith.health and smith.health > 0 and not smith.repairing and smith.power then
				local dlight = DynamicLight( self:EntIndex() )
				if ( dlight ) then
					local size=1024
					local v=self:GetNWVector("mainlight",Vector(0,0,0))
					dlight.Pos = self:LocalToWorld(Vector(0,0,300))
					dlight.r = v.x
					dlight.g = v.y
					dlight.b = v.z
					dlight.Brightness = 3
					dlight.Decay = size * 5
					dlight.Size = size
					dlight.DieTime = CurTime() + 1
				end
			end

			if smith.health and smith.health > 0 and not smith.repairing and smith.power then
			   local dlight2 = DynamicLight( self:EntIndex()+10000 )
			   if ( dlight2 ) then
				   local size=1024
				   local v=self:GetNWVector("seclight",Vector(0,0,0))
					if smith.health < 251 then
						v=self:GetNWVector("warnlight",Vector(0,0,0))
					end
				   dlight2.Pos = self:LocalToWorld(Vector(0,0,-50))
				   dlight2.r = v.x
				   dlight2.g = v.y
				   dlight2.b = v.z
				   dlight2.Brightness = 5
				   dlight2.Decay = size * 10
				   dlight2.Size = size
				   dlight2.DieTime = CurTime() + 1
			   end
                        end
			
			if (smith.moving or smith.flightmode) then
				if self.timerotor.pos==1 then
					self.timerotor.pos=0
				end
				
				self.timerotor.pos=math.Approach( self.timerotor.pos, self.timerotor.mode, FrameTime()*0.07 )
				self:SetPoseParameter( "rotor", self.timerotor.pos )
			end
              end
	else
		if self.cloisterbell then
			self.cloisterbell:Stop()
			self.cloisterbell=nil
		end
		if self.creaks then
			self.creaks:Stop()
			self.creaks=nil
		end
		if self.idlesound then
			self.idlesound:Stop()
			self.idlesound=nil
		end
		if self.crack then
			self.crack:Stop()
			self.crack=nil
		end
	end
end