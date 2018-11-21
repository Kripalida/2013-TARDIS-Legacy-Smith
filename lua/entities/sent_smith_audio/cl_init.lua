include('shared.lua')

function ENT:Draw()
	if LocalPlayer().smith==self:GetNWEntity("smith", NULL) and LocalPlayer().smith_viewmode and not LocalPlayer().smith_render then
		self:DrawModel()
	end
end

function ENT:StopTheme()
	if self.sound then
		self.sound:Stop()
		self.sound=nil
	end
end

function ENT:OnRemove()
	self:StopTheme()
end

local sounds={
	{"Main Theme (1963-1966)", "1963"},
	{"Main Theme (1966-1980)", "1966"},
	{"Main Theme (1980-1986)", "1980"},
	{"Main Theme (1986-1987)", "1986"},
	{"Main Theme (1996)", "1996"},
	{"Main Theme (2005-2008)", "2005"},
	{"Main Theme (2008-2009)", "2008"},
	{"Main Theme (2010-2012)", "2010"},
	{"Main Theme (2013)", "2013"},
	{"Main Theme (2014-present)", "2014"},
    {"Main Theme (2014-rock)", "2014rock"},
	{"The Doctor's Theme", "TheDoctorsTheme"},
	{"Siege Mode", "SiegeMode"},
	{"Father's Day", "fathersday"},
	{"Rose In Peril", "RoseInPeril"},
	{"I'm Coming To Get You", "ImComingToGetYou"},
	{"Hologram", "Hologram"},
	{"Clockwork TARDIS", "ClockworkTardis"},
	{"Rose's Theme", "RosesTheme"},
	{"The Face Of Boe", "TheFaceOfBoe"},
	{"The Lone Dalek", "TheLoneDalek"},
	{"New Adventures", "NewAdventures"},
	{"The Daleks", "TheDaleks"},
	{"The Cybermen", "TheCybermen"},
	{"Doomsday", "doomsday"},
	{"All The Strange, Strange Creatures", "AllTheStrangeStrangeCreatures"},
	{"Martha's Theme", "marthastheme"},
	{"Boe", "Boe"},
	{"The Futurekind", "TheFuturekind"},
	{"YANA", "YANA"},
	{"This Is Gallifrey, Our Childhood, Our Home", "ThisIsGallifreyOurChildhoodOurHome"},
	{"Donna's Theme", "donnastheme"},
	{"The Source", "TheSource"},
	{"The Doctor's Theme Series 4", "TheDoctorsThemeSeriesFour"},
	{"The Greatest Story Never Told", "TheGreatestStoryNeverTold"},
	{"Davros", "davros"},
	{"The Clouds Pass", "TheCloudsPass"},
	{"Vale Decem", "ValeDecem"},
	{"The New Doctor", "TheNewDoctor"},
	{"Down to Earth", "downtoearth"},
	{"Can I Come With You?", "CanIComeWithYou"},
	{"The Sun's Gone Wibbly", "TheSunsGoneWibbly"},
	{"I Am the Doctor", "iamthedoctor"},
	{"The Mad Man With a Box", "TheMadManWithaBox"},
	{"Amy In the TARDIS", "AmyInthetardis"},
	{"Amy's Theme", "AmysTheme"},
	{"A Lonely Decision", "Alonelydecision"},
	{"The Vampires Of Venice", "TheVampiresOfVenice"},
	{"The Dream", "TheDream"},
	{"Paint", "Paint"},
	{"Hidden Treasures", "HiddenTreasures"},
	{"A Troubled Man", "atroubledman"},
	{"With Love, Vincent", "WithLoveVincent"},
	{"Adrift In the TARDIS", "AdriftInthetardis"},
	{"Doctor Gastronomy", "doctorgastronomy"},
	{"A Useful Striker", "AUsefulStriker"},
	{"Beneath Stonehenge", "BeneathStonehenge"},
	{"Who Else Is Coming", "WhoElseIsComing"},
	{"The Pandorica", "ThePandorica"},
	{"Words Win Wars", "WordsWinWars"},
	{"The Life And Death Of Amy Pond", "TheLifeAndDeathOfAmyPond"},
	{"The Perfect Prison", "ThePerfectPrison"},
	{"The Sad Man With a Box", "TheSadManWithaBox"},
	{"My Angel Put The Devil in Me", "MyAngelPutTheDevilinMe"},
	{"I Remember You", "irememberyou"},
	{"Come Along Pond", "comealongpond"},
	{"My Husband's Home", "MyHusbandsHome"},
	{"He Comes Every Christmas", "ComesEveryChristmas"},
	{"Abigail's Song", "Abigailsong"},
	{"I Am The Doctor In Utah", "iamthedoctorinutah"},
	{"The Impossible Astronaut", "TheImpossibleAstronaut"},
	{"Brigadier Lethbridge - Stewart", "BrigadierLethbridgeStewart"},
	{"The Wedding Of River Song", "TheWeddingOfRiverSong"},
	{"Together Or Not At All", "TogetherOrNotAtAll"},
	{"Goodbye Pond", "goodbyepond"},
	{"Clara In the TARDIS", "ClaraInthetardis"},
	{"One Word", "OneWord"},
	{"Psychotic Potato Dwarf", "PsychoticPotatoDwarf"},
	{"Monking About", "MonkingAbout"},
	{"Clara?", "Clara"},
	{"Bah Bah Biker", "BahBahBiker"},
	{"Up The Shard", "UpTheShard"},
	{"The Leaf", "TheLeaf"},
	{"Something Awesome", "SomethingAwesome"},
	{"Merry Gejelh", "MerryGejelh"},
	{"Infinite Potential", "infinitepotential"},
	{"Thomas Thomas", "ThomasThomas"},
	{"To Save The Doctor", "ToSaveTheDoctor"},
	{"Trenzalore/The Long Song/I Am Information", "Trenzalore"},
	{"Hello Twelve", "HelloTwelve"},
	{"A Drink First", "ADrinkFirst"},
	{"A Good Man Last Variation", "AGoodManLastVariation"},
	{"A Good Man An Incredible Liar", "AGoodManAnIncredibleLiar"},
	{"A Good Man", "AGoodMan"},
	{"An Idiot With A Box", "AnIdiotWithABox"},
	{"Bill Enters the TARDIS", "BillEnterstheTARDIS"},
	{"Doctor, I Let You Go", "DoctorILetYouGo"},
	{"Every Single Time, You Lose", "EverySingleTimeYouLose"},
	{"Hello Hello", "HelloHello"},
	{"I'm Afraid", "ImAfraid"},
	{"Missy's Theme", "MissysTheme"},
	{"One's Regeneration", "OnesRegeneration"},
	{"Pudding Brains", "PuddingBrains"},
	{"The Doctor Falls The New Doctor", "TheDoctorFallsTheNewDoctor"},
	{"The Lie of the Land", "TheLieoftheLand"},
	{"The Oath", "TheOath"},
	{"Timelord's Death Sentence", "TimelordsDeathSentence"},
	{"Twelfth Doctor's Regeneration", "TwelfthDoctorsRegeneration"},
	{"Twice Upon a Time", "TwiceUponaTime"},
	{"Vale Une", "ValeUne"},
	{"You Will Become", "YouWillBecome"},
		
}

net.Receive("smithInt-Gramophone-Send", function(l,ply)
	local gramophone=net.ReadEntity()
	local smith=net.ReadEntity()
	local interior=net.ReadEntity()
	local play=tobool(net.ReadBit())
	local choice=net.ReadFloat()
	local custom=tobool(net.ReadBit())
	local customstr
	if custom then
		customstr=net.ReadString()
	end
	if IsValid(gramophone) and IsValid(smith) and IsValid(interior) then
		gramophone:StopTheme()
		if play and tobool(GetConVarNumber("smithint_music"))==true then
			local addr
			if custom and not (customstr=="") then
				addr=customstr
			elseif choice and sounds[choice] then
				addr="https://tardissound.000webhostapp.com/"..sounds[choice][2]..".mp3"
			else
				return
			end
			sound.PlayURL(addr, "", function(station)
				if station then
					station:SetPos(gramophone:GetPos())
					station:SetVolume(1)
					station:Play()
					gramophone.sound=station
				else
					LocalPlayer():ChatPrint("ERROR: Failed to load theme (check console for BASS error!)")
				end
			end)
		end
	end
end)

net.Receive("smithInt-Gramophone-GUI", function()	
	local gramophone=net.ReadEntity()
	local smith=net.ReadEntity()
	local interior=net.ReadEntity()
	local choice=0
	
	local function SendSelection(play,customstr)
		if IsValid(gramophone) and IsValid(smith) and IsValid(interior) then
			net.Start("smithInt-Gramophone-Bounce")
				net.WriteEntity(gramophone)
				net.WriteEntity(smith)
				net.WriteEntity(interior)
				net.WriteBit(play)
				net.WriteFloat(choice)
				if customstr then
					net.WriteBit(true)
					net.WriteString(customstr)
				else
					net.WriteBit(false)
				end
			net.SendToServer()
			return true
		else
			return false
		end
	end
	
	local window = vgui.Create( "DFrame" )
	window:SetSize( 200, 155+221 )
	window:Center()
	window:SetTitle( "Gramophone" )
	window:MakePopup()
	
	local label = vgui.Create( "DLabel", window )
	label:SetPos(10,30) // Position
	label:SetColor(Color(255,255,255,255)) // Color
	label:SetFont("Trebuchet24")
	label:SetText("Select theme tune") // Text
	label:SizeToContents() // make the control the same size as the text.
	
	local listview = vgui.Create( "DListView", window )
	listview:SetPos(10,60)
	listview:SetSize(180,16+221)
	listview:SetMultiSelect( false )
	listview:AddColumn( "Themes" )
	listview.OnClickLine = function(self,line)
		local name=line:GetValue(1)
		self:ClearSelection()
		self:SelectItem(line)
		for k,v in pairs(sounds) do
			if v[1]==name then
				choice=k
			end
		end
	end
	
	for k,v in pairs(sounds) do
		listview:AddLine( v[1] )
	end
	
	local button = vgui.Create( "DButton", window )
	button:SetSize( 180, 30 )
	button:SetPos( 10, window:GetTall()-74 )
	button:SetText( "Enter Custom Theme" )
	button.DoClick = function( button )
		Derma_StringRequest(
			"Enter Custom Theme",
			"Input a web link of a sound (MP3, MP2, MP1, OGG, WAV, AIFF)",
			"",
			function(text) SendSelection(true,text) end,
			function(text) end
		)
	end
	
	local button = vgui.Create( "DButton", window )
	button:SetSize( 87.5, 30 )
	button:SetPos( 10, window:GetTall()-38 )
	button:SetText( "Play" )
	button.DoClick = function( button )
		local success=SendSelection(true)
		if success then
			window:Close()
		end
	end
	
	local button = vgui.Create( "DButton", window )
	button:SetSize( 87.5, 30 )
	button:SetPos( 102.5, window:GetTall()-38 )
	button:SetText( "Stop" )
	button.DoClick = function( button )
		local success=SendSelection(false)
		if success then
			window:Close()
		end
	end
end)

function ENT:Think()
	if self.sound then
		if tobool(GetConVarNumber("smithint_music"))==true then
			local smith=self:GetNWEntity("smith",NULL)
			if IsValid(smith) then
				local interior=smith:GetNWEntity("interior",NULL)
				if LocalPlayer().smith==smith and IsValid(interior) then
					if LocalPlayer().smith_viewmode and not (LocalPlayer().smith_skycamera and IsValid(LocalPlayer().smith_skycamera)) then
						local distance=LocalPlayer():GetPos():Distance(interior:GetPos())
						local volume=math.Clamp(((distance*-1)/1700+1.1)*GetConVarNumber("smithint_musicvol"),0,1)
						self.sound:SetVolume(volume)
					elseif (not LocalPlayer().smith_viewmode or (LocalPlayer().smith_skycamera and IsValid(LocalPlayer().smith_skycamera))) and tobool(GetConVarNumber("smithint_musicext"))==true then
						local volume=math.Clamp(GetConVarNumber("smithint_musicvol"),0,1)
						self.sound:SetVolume(volume)
					else
						self.sound:SetVolume(0)
					end
				else
					self:StopTheme()
				end
			end
		else
			self:StopTheme()
		end
	end

end