include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end

net.Receive("smithInt-SetSkyCamera", function()
	LocalPlayer().smith_skycamera=net.ReadEntity()
end)

hook.Add("HUDPaint", "smithInt-SkyCamera", function()
	local skycamera=LocalPlayer().smith_skycamera
	if skycamera and IsValid(skycamera) then
		local x = ScrW() / 2
		local y = ScrH() / 2
		 
		--set the drawcolor
		surface.SetDrawColor( 255, 255, 255, 255 )
		 
		local gap = 10
		if LocalPlayer():KeyDown(IN_ATTACK2) then
			gap = 5
		end
		local length = gap + 15
		 
		--draw the crosshair
		surface.DrawLine( x - length, y, x - gap, y )
		surface.DrawLine( x + length, y, x + gap, y )
		surface.DrawLine( x, y - length, x, y - gap )
		surface.DrawLine( x, y + length, x, y + gap )
	end
end)