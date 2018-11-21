include('shared.lua')
 
SWEP.PrintName          = "2013 Sonic Screwdriver"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = true
SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/swep_hud_smithicon")

function SWEP:Initialize()
	surface.CreateFont( "HUD_Sonic", {
		font = "Default",
		size = 16,
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = true,
	} )
	self:SetWeaponHoldType( self.HoldType )
	self:CallHook("Initialize")
end

function SWEP:OnRemove()
	self:CallHook("OnRemove")
end

function SWEP:Holster(wep)
	self:CallHook("Holster",wep)
end

function SWEP:PreDrawViewModel(vm,ply,wep)
	local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
	local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)
	self:CallHook("PreDrawViewModel", vm,ply,wep,keydown1,keydown2)
end

function SWEP:Think()
	local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
	local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)	
	self:CallHook("Think", keydown1, keydown2)
end