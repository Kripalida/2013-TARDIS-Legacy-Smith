local checkbox_options={
	{"Flight sounds", "smith_flightsound"},
	{"Teleport sounds", "smith_matsound"},
	{"Door sounds", "smith_doorsound"},
	{"Lock sounds", "smith_locksound"},
	{"Phase sounds", "smith_phasesound"},
	{"Repair sounds", "smithint_repairsound"},
	{"Power sounds", "smithint_powersound"},
	{"Cloisterbell sound", "smithint_cloisterbell"},
	{"Interior Crack sound", "smithint_crack"},
	{"Interior Creaks sound", "smithint_creaks"},
	{"Flightmode music", "smithint_musicext"},
	{"Interior idle sounds", "smithint_idlesound"},
	{"Interior control sounds", "smithint_controlsound"},
	{"Interior music", "smithint_music"},
	{"Interior scanner", "smithint_scanner"},
	{"Interior dynamic light", "smithint_dynamiclight"},
	{"Exterior dynamic light", "smith_dynamiclight"},
}

for k,v in pairs(checkbox_options) do
	CreateClientConVar(v[2], "1", true)
end

local special_checkbox_options={
}

for k,v in pairs(special_checkbox_options) do
	CreateClientConVar(v[2], v[3], true, v[4])
end

CreateClientConVar("smithint_musicvol", "1", true)
CreateClientConVar("smith_flightvol", "1", true)

CreateClientConVar("smithint_mainlight_r", "0", true, true)
CreateClientConVar("smithint_mainlight_g", "0", true, true)
CreateClientConVar("smithint_mainlight_b", "0", true, true)

CreateClientConVar("smithint_seclight_r", "0", true, true)
CreateClientConVar("smithint_seclight_g", "255", true, true)
CreateClientConVar("smithint_seclight_b", "255", true, true)

CreateClientConVar("smithint_warnlight_r", "200", true, true)
CreateClientConVar("smithint_warnlight_g", "0", true, true)
CreateClientConVar("smithint_warnlight_b", "0", true, true)

CreateClientConVar("smith_extcol_r", "255", true, true)
CreateClientConVar("smith_extcol_g", "228", true, true)
CreateClientConVar("smith_extcol_b", "91", true, true)

hook.Add("PopulateToolMenu", "smith-PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Doctor Who", "smith_Options", "2013 TARDIS", "", "", function(panel)
		panel:ClearControls()
		//Do menu things here
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Double spawn trace (Admin Only)" )
		checkBox:SetToolTip( "This should fix some maps where the interior/skycamera doesn't spawn properly" )
		checkBox:SetValue( GetConVarNumber( "smith_doubletrace" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("smith-DoubleTrace")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Take damage (Admin Only)" )
		checkBox:SetValue( GetConVarNumber( "smith_takedamage" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("smith-TakeDamage")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end			
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Allow phasing in flightmode (Admin Only)" )
		checkBox:SetValue( GetConVarNumber( "smith_flightphase" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("smith-FlightPhase")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Physical Damage (Admin Only)" )
		checkBox:SetToolTip( "This enables/disables physical damage from hitting stuff at high speeds." )
		checkBox:SetValue( GetConVarNumber( "smith_physdamage" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("smith-PhysDamage")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "No-collide during teleport (Admin Only)" )
		checkBox:SetToolTip( "This enables no-collide on the TARDIS when it is teleporting and disables it after again." )
		checkBox:SetValue( GetConVarNumber( "smith_nocollideteleport" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("smith-NoCollideTeleport")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Advanced Mode (Admin Only)" )
		checkBox:SetToolTip( "This sets interior navigation to advanced, turn off for easy." )
		checkBox:SetValue( GetConVarNumber( "smith_advanced" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("smith-AdvancedMode")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Lock doors during teleport (Admin Only)" )
		checkBox:SetToolTip( "This stops players from entering/leaving while it is teleporting." )
		checkBox:SetValue( GetConVarNumber( "smith_teleportlock" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("smith-TeleportLock")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		/* -- i feel people arnt going to know what this does and end up breaking everything, the above checkbox should help in most cases.
		local slider = vgui.Create( "DNumSlider" )
			slider:SetText( "Spawn Offset (Admin Only)" )
			slider:SetToolTip("Try the above checkbox first, this is a last resort for advanced users only.")
			slider:SetValue(0)
			slider:SetDecimals(0)
			slider:SetMin(-10000)
			slider:SetMax(5000)
			slider.val=0
			slider.OnValueChanged = function(self,val)
				if not (slider.val==val) then
					slider.val=val
					if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
						net.Start("smith-SpawnOffset")
							net.WriteFloat(val)
						net.SendToServer()
					else
						chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
						chat.PlaySound()
					end
				end
			end
			panel:AddItem(slider)
			
		local button = vgui.Create( "DButton" )
		button:SetText( "Reset Spawn Offset" )
		button.DoClick = function(self)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				if slider then
					slider:SetValue(0)
				end
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to use this button.")
				chat.PlaySound()
			end
		end
		panel:AddItem(button)
		*/
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Colors:")
		panel:AddItem(DLabel)
		
		local CategoryList = vgui.Create( "DPanelList" )
		//CategoryList:SetAutoSize( true )
		CategoryList:SetTall( 260 )
		CategoryList:SetSpacing( 10 )
		CategoryList:EnableHorizontal( false )
		CategoryList:EnableVerticalScrollbar( true )
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Exterior Lamp:")
		CategoryList:AddItem(DLabel)
		
		local Mixer = vgui.Create( "DColorMixer" )
		Mixer:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer:SetColor( Color(GetConVarNumber("smith_extcol_r"), GetConVarNumber("smith_extcol_g"), GetConVarNumber("smith_extcol_b")) )	--Set the default color
		Mixer.ValueChanged = function(self,col)
			RunConsoleCommand("smith_extcol_r", col.r)
			RunConsoleCommand("smith_extcol_g", col.g)
			RunConsoleCommand("smith_extcol_b", col.b)
		end
		CategoryList:AddItem(Mixer)
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Interior Main:")
		CategoryList:AddItem(DLabel)
		
		local Mixer1 = vgui.Create( "DColorMixer" )
		Mixer1:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer1:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer1:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer1:SetColor( Color(GetConVarNumber("smithint_mainlight_r"), GetConVarNumber("smithint_mainlight_g"), GetConVarNumber("smithint_mainlight_b")) )	--Set the default color
		Mixer1.ValueChanged = function(self,col)
			RunConsoleCommand("smithint_mainlight_r", col.r)
			RunConsoleCommand("smithint_mainlight_g", col.g)
			RunConsoleCommand("smithint_mainlight_b", col.b)
		end
		CategoryList:AddItem(Mixer1)

		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Interior Secondary:")
		CategoryList:AddItem(DLabel)
		
		local Mixer2 = vgui.Create( "DColorMixer" )
		Mixer2:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer2:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer2:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer2:SetColor( Color(GetConVarNumber("smithint_seclight_r"), GetConVarNumber("smithint_seclight_g"), GetConVarNumber("smithint_seclight_b")) )	--Set the default color
		Mixer2.ValueChanged = function(self,col)
			RunConsoleCommand("smithint_seclight_r", col.r)
			RunConsoleCommand("smithint_seclight_g", col.g)
			RunConsoleCommand("smithint_seclight_b", col.b)
		end
		CategoryList:AddItem(Mixer2)
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Interior Warning:")
		CategoryList:AddItem(DLabel)
		
		local Mixer3 = vgui.Create( "DColorMixer" )
		Mixer3:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer3:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer3:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer3:SetColor( Color(GetConVarNumber("smithint_warnlight_r"), GetConVarNumber("smithint_warnlight_g"), GetConVarNumber("smithint_warnlight_b")) )	--Set the default color
		Mixer3.ValueChanged = function(self,col)
			RunConsoleCommand("smithint_warnlight_r", col.r)
			RunConsoleCommand("smithint_warnlight_g", col.g)
			RunConsoleCommand("smithint_warnlight_b", col.b)
		end
		CategoryList:AddItem(Mixer3)
		
		panel:AddItem(CategoryList)
		
		local button = vgui.Create("DButton")
		button:SetText("Reset Colors")
		button.DoClick = function(self)
			Mixer:SetColor(Color(255,228,91))
			Mixer1:SetColor(Color(0,0,0))
			Mixer2:SetColor(Color(0,255,255))
			Mixer3:SetColor(Color(200,0,0))
		end
		panel:AddItem(button)
		
		panel:AddControl("Slider", {
			Label="Music Volume",
			Type="float",
			Min=0.1,
			Max=1,
			Command="smithint_musicvol",
		})
		
		panel:AddControl("Slider", {
			Label="Exterior Flight Volume",
			Type="float",
			Min=0.1,
			Max=1,
			Command="smith_flightvol",
		})
		
		local checkboxes={}
		for k,v in pairs(special_checkbox_options) do
			local checkBox = vgui.Create( "DCheckBoxLabel" ) 
			checkBox:SetText( v[1] ) 
			checkBox:SetValue( GetConVarNumber( v[2] ) )
			checkBox:SetConVar( v[2] )
			panel:AddItem(checkBox)
			table.insert(checkboxes, checkBox)
		end
		
		for k,v in pairs(checkbox_options) do
			local checkBox = vgui.Create( "DCheckBoxLabel" ) 
			checkBox:SetText( v[1] ) 
			checkBox:SetValue( GetConVarNumber( v[2] ) )
			checkBox:SetConVar( v[2] )
			panel:AddItem(checkBox)
			table.insert(checkboxes, checkBox)
		end
	end)
end)