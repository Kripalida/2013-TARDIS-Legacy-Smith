ENT.Type = "anim"
if WireLib then
	ENT.Base 			= "base_wire_entity"
else
	ENT.Base			= "base_gmodentity"
end 
ENT.PrintName		= "2013 TARDIS Handbrake"
ENT.Author			= "Dr. Matt"
ENT.Contact			= "mattjeanes23@gmail.com"
ENT.Instructions	= "Don't spawn this!"
ENT.Purpose			= "Time and Relative Dimension in Space's Handbrake"
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Doctor Who"
ENT.smith_part		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Bool",	0,	"On" );
	self:NetworkVar( "Bool",	1,	"IsToggle" );

	self:SetOn( false )
	self:SetIsToggle( true );
end