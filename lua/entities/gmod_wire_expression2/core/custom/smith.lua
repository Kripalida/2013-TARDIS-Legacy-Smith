/******************************************************************************\
	smith custom E2 functions by Dr. Matt
\******************************************************************************/

E2Lib.RegisterExtension("smith", true)

local function CheckPP(ply, ent) // Prop Protection
	return hook.Call("PhysgunPickup", GAMEMODE, ply, ent)
end

local function smith_Get(ent)
	if ent and IsValid(ent) then
		if ent:GetClass()=="sent_smith_interior" and IsValid(ent.smith) then
			return ent.smith
		elseif ent:GetClass()=="sent_smith" then
			return ent
		elseif ent:IsPlayer() then
			if IsValid(ent.smith) then
				return ent.smith
			else
				return NULL
			end
		else
			return NULL
		end
	end
	return NULL
end

local function smith_Teleport(data,ent,pos,ang)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local pos=Vector(pos[1], pos[2], pos[3])
		if ang then ang=Angle(ang[1], ang[2], ang[3]) end
		local success=ent:Go(pos,ang)
		if success then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

local function smith_Phase(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:TogglePhase()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Flightmode(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:ToggleFlight()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Lock(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:ToggleLocked()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Physlock(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:TogglePhysLock()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Power(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:TogglePower()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Isomorph(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") or not IsValid(data.player) then return 0 end
		local success=ent:IsomorphicToggle(data.player)
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Longflight(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:ToggleLongFlight()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Materialise(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:LongReappear()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Selfrepair(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:ToggleRepair()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Track(data,ent,trackent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:SetTrackingEnt(trackent)
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Spinmode(data,ent,spinmode)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		ent:SetSpinMode(spinmode)
		return ent.spinmode
	end
	return 0
end

local function smith_SetDestination(data,ent,pos,ang)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local pos=Vector(pos[1], pos[2], pos[3])
		if ang then ang=Angle(ang[1], ang[2], ang[3]) end
		if ent.invortex then
			ent:SetDestination(pos,ang)
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

local function smith_FastReturn(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:FastReturn()
		if success then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

local function smith_HADS(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:ToggleHADS()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_FastDemat(data,ent)
	if ent and IsValid(ent) and CheckPP(data.player,ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		local success=ent:DematFast()
		if success then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

// get details

local function smith_Moving(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.moving then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Visible(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.visible then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Flying(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.flightmode then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Locked(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.locked then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Physlocked(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.physlocked then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Powered(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.power then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Isomorphic(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.isomorphic then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Longflighted(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.longflight then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Selfrepairing(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.repairing then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_LastPos(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.lastpos then
			return ent.lastpos
		else
			return Vector()
		end
	end
	return Vector()
end

local function smith_LastAng(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.lastang then
			return {ent.lastang.p, ent.lastang.y, ent.lastang.r}
		else
			return {0,0,0}
		end
	end
	return {0,0,0}
end

local function smith_Health(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.health then
			return math.floor(ent.health)
		else
			return 0
		end
	end
	return 0
end

local function smith_Tracking(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if IsValid(ent.trackingent) then
			return ent.trackingent
		else
			return NULL
		end
	end
	return NULL
end

local function smith_InVortex(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.invortex then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_IsHADS(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return 0 end
		if ent.hads then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function smith_Pilot(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_smith") then return NULL end
		if not ent.pilot then return NULL end
		return ent.pilot
	end
	return NULL
end

--------------------------------------------------------------------------------

//set details
e2function entity entity:smithGet()
	return smith_Get(this)
end

e2function number entity:smithDemat(vector pos)
	return smith_Teleport(self, this, pos)
end

e2function number entity:smithDemat(vector pos, angle rot)
	return smith_Teleport(self, this, pos, rot)
end

e2function number entity:smithPhase()
	return smith_Phase(self, this)
end

e2function number entity:smithFlightmode()
	return smith_Flightmode(self, this)
end

e2function number entity:smithLock()
	return smith_Lock(self, this)
end

e2function number entity:smithPhyslock()
	return smith_Physlock(self, this)
end

e2function number entity:smithPower()
	return smith_Power(self, this)
end

e2function number entity:smithIsomorph()
	return smith_Isomorph(self,this)
end

e2function number entity:smithLongflight()
	return smith_Longflight(self, this)
end

e2function number entity:smithMaterialise()
	return smith_Materialise(self, this)
end

e2function number entity:smithSelfrepair()
	return smith_Selfrepair(self, this)
end

e2function number entity:smithTrack(entity ent)
	return smith_Track(self, this, ent)
end

e2function number entity:smithSpinmode(number spinmode)
	return smith_Spinmode(self, this, spinmode)
end

e2function number entity:smithSetDestination(vector pos)
	return smith_SetDestination(self, this, pos)
end

e2function number entity:smithSetDestination(vector pos, angle rot)
	return smith_SetDestination(self, this, pos, rot)
end

e2function number entity:smithFastReturn()
	return smith_FastReturn(self, this)
end

e2function number entity:smithHADS()
	return smith_HADS(self, this)
end

e2function number entity:smithFastDemat()
	return smith_FastDemat(self, this)
end

// get details
e2function number entity:smithMoving()
	return smith_Moving(this)
end

e2function number entity:smithVisible()
	return smith_Visible(this)
end

e2function number entity:smithFlying()
	return smith_Flying(this)
end

e2function number entity:smithHealth()
	return smith_Health(this)
end

e2function number entity:smithLocked()
	return smith_Locked(this)
end

e2function number entity:smithPhyslocked()
	return smith_Physlocked(this)
end

e2function number entity:smithPowered()
	return smith_Powered(this)
end

e2function number entity:smithIsomorphic()
	return smith_Isomorphic(this)
end

e2function number entity:smithLongflighted()
	return smith_Longflighted(this)
end

e2function number entity:smithSelfrepairing()
	return smith_Selfrepairing(this)
end

e2function vector entity:smithLastPos()
	return smith_LastPos(this)
end

e2function angle entity:smithLastAng()
	return smith_LastAng(this)
end

e2function entity entity:smithTracking()
	return smith_Tracking(this)
end

e2function number entity:smithInVortex()
	return smith_InVortex(this)
end

e2function number entity:smithIsHADS()
	return smith_IsHADS(this)
end

e2function entity entity:smithPilot()
	return smith_Pilot(this)
end