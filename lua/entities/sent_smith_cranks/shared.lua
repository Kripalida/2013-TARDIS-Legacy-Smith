ENT.Type = "anim"
if WireLib then
	ENT.Base 			= "base_wire_entity"
else
	ENT.Base			= "base_gmodentity"
end 
ENT.PrintName		= "2013 TARDIS Cranks"
ENT.Author			= "Dr. Matt"
ENT.Contact			= "mattjeanes23@gmail.com"
ENT.Instructions	= "Don't spawn this!"
ENT.Purpose			= "Time and Relative Dimension in Space's Cranks"
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Doctor Who"
ENT.smith_part		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Bool",	0,	"Dir" );
	self:NetworkVar( "Bool",	1,	"IsToggle" );

	self:SetDir( false )
	self:SetIsToggle( true );
end