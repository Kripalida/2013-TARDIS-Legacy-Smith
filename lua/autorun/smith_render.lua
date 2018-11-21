if SERVER then
	hook.Add( "SetupPlayerVisibility", "smith-Render", function(ply,viewent)
		if IsValid(ply.smith) then
			AddOriginToPVS(ply.smith:GetPos())
		end
	end)
elseif CLIENT then
	local rt,mat
	local size=1024
	local CamData = {}
	CamData.x = 0
	CamData.y = 0
	CamData.fov = 90
	CamData.drawviewmodel = false
	CamData.w = size
	CamData.h = size
	
	hook.Add("InitPostEntity", "smith-Render", function()
		rt=GetRenderTarget("smith_rt",size,size,false)
		mat=Material("models/hoxii/smith/scannersmith")
		mat:SetTexture("$basetexture",rt)
	end)
	
	hook.Add("RenderScene", "smith-Render", function()
		if tobool(GetConVarNumber("smithint_scanner"))==false then return end
		local smith=LocalPlayer().smith
		if IsValid(smith) and LocalPlayer().smith_viewmode then
			CamData.origin = smith:LocalToWorld(Vector(26, 0, 80))
			CamData.angles = smith:GetAngles()
			LocalPlayer().smith_render=true
			local old = render.GetRenderTarget()
			render.SetRenderTarget( rt )
			render.Clear(0,0,0,255)
			cam.Start2D()
				render.RenderView(CamData)
			cam.End2D()
			render.CopyRenderTargetToTexture(rt)
			render.SetRenderTarget(old)
			LocalPlayer().smith_render=false
		end
	end)
	
	hook.Add( "PreDrawHalos", "smith-Render", function() // not ideal, but the new scanner sorta forced me to do this
		if tobool(GetConVarNumber("smithint_halos"))==false then return end
		local smith=LocalPlayer().smith
		if IsValid(smith) and not LocalPlayer().smith_render then
			local interior=smith:GetNWEntity("interior",NULL)
			if IsValid(interior) and interior.parts then
				for k,v in pairs(interior.parts) do
					if v.shouldglow then
						halo.Add( {v}, Color( 255, 255, 255, 255 ), 1, 1, 1, true, true )
					end
				end
			end
		end
	end )
end