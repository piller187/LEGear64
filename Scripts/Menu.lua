function BuildMenu(context)
	
	if VSyncMode==nil then VSyncMode=true end

	local GameMenu={}
	local scale = 1

	--GUI
	local gui = GUI:Create(context)
	gui:Hide()
	gui:SetScale(scale)
	local widget
	
	gui:GetBase():SetScript("Scripts/GUI/Panel.lua")
	gui:GetBase():SetObject("backgroundcolor",Vec4(0,0,0,0.5))
	
	GameMenu.gui=gui
	GameMenu.context = context
	
	--Create a link button
	GameMenu.newbutton = Widget:Button("NEW GAME",100,gui:GetBase():GetSize().y/2-60,300,20,gui:GetBase())
	GameMenu.newbutton:SetString("style","Link")
	GameMenu.newbutton:SetAlignment(1,0,0,0)

	GameMenu.options = Widget:Button("OPTIONS",100,gui:GetBase():GetSize().y/2-10,300,20,gui:GetBase())
	GameMenu.options:SetString("style","Link")
	GameMenu.options:SetAlignment(1,0,0,0)

	GameMenu.quit = Widget:Button("QUIT",100,gui:GetBase():GetSize().y/2+40,300,20,gui:GetBase())
	GameMenu.quit:SetString("style","Link")
	GameMenu.quit:SetAlignment(1,0,0,0)

	optionspanel = Widget:Panel(gui:GetBase():GetClientSize().x/2-250,gui:GetBase():GetClientSize().y/2-300,500,600,gui:GetBase())
	optionspanel:SetAlignment(0,0,0,0)
	GameMenu.optionspanel=optionspanel
	
	indent=8
	
	--Create a panel
	widget = Widget:Tabber(indent,indent,optionspanel:GetClientSize().x-indent*2,optionspanel:GetClientSize().y-indent*2,optionspanel)
	widget:AddItem("Options",true)
	optionspanel:SetObject("backgroundcolor",Vec4(0.15,0.15,0.15,1))
	
	GameMenu.tabber = widget

	local indent = 12
	panel = Widget:Panel(indent,indent,widget:GetClientSize().x-indent*2,widget:GetClientSize().y-indent*2-30,widget)
	panel:SetBool("border",true)
	
	GameMenu.panel={}
	GameMenu.panel.general=panel

	GameMenu.closeoptions = Widget:Button("Close",widget:GetClientSize().x-72-indent,widget:GetClientSize().y-28-5,72,28,widget)
	GameMenu.applyoptions = Widget:Button("Apply",widget:GetClientSize().x-72*2-4-indent,widget:GetClientSize().y-28-5,72,28,widget)
	
	local y=20
	local sep=40
	
	--Graphics resolution
	Widget:Label("Screen Resolution",20,y,200,16,panel)
	y=y+16
	GameMenu.screenres = Widget:ChoiceBox(20,y,200,30,panel)
	local count = System:CountGraphicsModes()
	local window = context:GetWindow()
	for n=0,count-1 do
		local gfx = System:GetGraphicsMode(n)
		local selected=false
		if window:GetWidth()==gfx.x and window:GetHeight()==gfx.y then selected=true end
		GameMenu.screenres:AddItem( gfx.x.."x"..gfx.y,selected)
	end
	y=y+sep
	
	--Antialias
	Widget:Label("Antialias",20,y,200,16,panel)
	y=y+16
	GameMenu.antialias = Widget:ChoiceBox(20,y,200,30,panel)
	GameMenu.antialias:AddItem("None")
	GameMenu.antialias:AddItem("2x")
	GameMenu.antialias:AddItem("4x")
	y=y+sep
	
	--Texture quality
	Widget:Label("Texture Detail",20,y,200,16,panel)
	y=y+16
	GameMenu.texturequality = Widget:ChoiceBox(20,y,200,30,panel)
	GameMenu.texturequality:AddItem("Low")
	GameMenu.texturequality:AddItem("Medium")
	GameMenu.texturequality:AddItem("High")
	GameMenu.texturequality:AddItem("Very High")
	y=y+sep
	
	--Lighting quality
	Widget:Label("Lighting Quality",20,y,200,16,panel)
	y=y+16
	GameMenu.lightquality = Widget:ChoiceBox(20,y,200,30,panel)
	GameMenu.lightquality:AddItem("Low")
	GameMenu.lightquality:AddItem("Medium")
	GameMenu.lightquality:AddItem("High")
	y=y+sep
	
	--Terrain quality
	Widget:Label("Terrain Quality",20,y,200,16,panel)
	y=y+16
	GameMenu.terrainquality = Widget:ChoiceBox(20,y,200,30,panel)
	GameMenu.terrainquality:AddItem("Low")
	GameMenu.terrainquality:AddItem("Medium")
	GameMenu.terrainquality:AddItem("High")
	y=y+sep
	
	--Water quality
	Widget:Label("Water Quality",20,y,200,16,panel)
	y=y+16
	GameMenu.waterquality = Widget:ChoiceBox(20,y,200,30,panel)
	GameMenu.waterquality:AddItem("Low")
	GameMenu.waterquality:AddItem("Medium")
	GameMenu.waterquality:AddItem("High")
	y=y+sep
	
	--Anisotropy
	Widget:Label("Anisotropic Filter",20,y,200,16,panel)
	y=y+16
	GameMenu.afilter = Widget:ChoiceBox(20,y,200,30,panel)
	GameMenu.afilter:AddItem("None")
	GameMenu.afilter:AddItem("2x")
	GameMenu.afilter:AddItem("4x")
	GameMenu.afilter:AddItem("8x")
	GameMenu.afilter:AddItem("16x")
	GameMenu.afilter:AddItem("32x")
	y=y+sep
	
	--Create a checkbox
	GameMenu.tfilter = Widget:Button("Trilinear Filter",20,y,200,30,panel)
	GameMenu.tfilter:SetString("style","Checkbox")
	y=y+sep
	
	--Create a checkbox
	GameMenu.vsync = Widget:Button("Vertical Sync",20,y,200,30,panel)
	GameMenu.vsync:SetString("style","Checkbox")
	y=y+sep
	
	GameMenu.confirmquitpanel = Widget:Panel(gui:GetBase():GetClientSize().x/2-150,gui:GetBase():GetClientSize().y/2-50,300,100,gui:GetBase())
	GameMenu.confirmquitpanel:SetAlignment(0,0,0,0)
	GameMenu.confirmquitpanel:SetFloat("radius",3)
	GameMenu.confirmquitpanel:SetBool("border",true)
	Widget:Label("Are you sure you want to quit?",20,20,300,20,GameMenu.confirmquitpanel)
	GameMenu.confirmquit = Widget:Button("OK",GameMenu.confirmquitpanel:GetClientSize().x/2-2-72,GameMenu.confirmquitpanel:GetClientSize().y-26-4,72,26,GameMenu.confirmquitpanel)
	GameMenu.cancelquit = Widget:Button("Cancel",GameMenu.confirmquitpanel:GetClientSize().x/2+2,GameMenu.confirmquitpanel:GetClientSize().y-26-4,72,26,GameMenu.confirmquitpanel)
	GameMenu.confirmquitpanel:Hide()
	
	optionspanel:Hide()
	
	--Load settings
	local world = World:GetCurrent()
	local quality
	if world~=nil then
		
		quality = tonumber((System:GetProperty("lightquality")))
		if quality~=nil then world:SetLightQuality(quality) end
		
		quality = tonumber((System:GetProperty("waterquality")))
		if quality~=nil then world:SetWaterQuality(quality) end
		
		quality = tonumber((System:GetProperty("terrainquality")))
		if quality~=nil then world:SetTerrainQuality(quality) end
		
	end
	
	--Texture detail
	quality = tonumber((System:GetProperty("texturedetail")))
	if quality~=nil then Texture:SetDetail(quality) end
	
	--Anisotropic filter
	quality = tonumber((System:GetProperty("anisotropicfilter")))
	if quality~=nil then Texture:SetAnisotropy(quality) end
	
	--TriLinear Filter
	quality = tonumber((System:GetProperty("trilinearfilter")))
	if quality~=nil then
		if quality>0 then
			quality=true
		else
			quality=false
		end
		Texture:SetTrilinearFilterMode(quality)
	end

	--Vertical sync
	quality = tonumber((System:GetProperty("verticalsync")))
	if quality~=nil then
		if quality>0 then
			VSyncMode=true
		else
			VSyncMode=false
		end
	end
	
	function GameMenu:Show()
		self.gui:Show()
		self.context:GetWindow():ShowMouse()
	end
	
	function GameMenu:Hidden()
		return self.gui:Hidden()
	end
	
	function GameMenu:Hide()
		self.gui:Hide()
		self.context:GetWindow():HideMouse()
		self.context:GetWindow():FlushMouse()
		self.context:GetWindow():FlushKeys()
		self.context:GetWindow():SetMousePosition(self.context:GetWidth()/2,self.context:GetHeight()/2)
	end
	
	function GameMenu:GetSettings()
		
		local world = World:GetCurrent()
		local n,i
		
		if VSyncMode==nil then VSyncMode=true end
		self.vsync:SetState(VSyncMode)
		
		--Antialias
		local aa = (System:GetProperty("antialias","1")).."x"
		if aa=="0x" or aa=="1x" then aa="None" end
		for i=0,self.antialias:CountItems()-1 do
			if self.antialias:GetItemText(i)==aa then
				self.antialias:SelectItem(i)
				break
			end
		end
		
		--[[local count = world:CountEntities()
		for n=0,count-1 do
			local entity=world:GetEntity(n)
			if entity:GetClass()==Object.CameraClass then
				local camera = tolua.cast(entity,"Camera")
				aa = tostring(camera:GetMultisampleMode()).."x"
				if aa=="0x" or aa=="1x" then aa="None" end
				for i=0,self.antialias:CountItems()-1 do
					if self.antialias:GetItemText(i)==aa then
						self.antialias:SelectItem(i)
						break
					end
				end			
				break
			end
		end]]
		
		--Screen resolution
		local w = self.context:GetWindow():GetWidth()
		local h = self.context:GetWindow():GetHeight()	
		local gfxmode = tostring(w).."x"..tostring(h)
		self.screenres:SelectItem(-1)
		for n=0,self.screenres:CountItems()-1 do
			if self.screenres:GetItemText(n)==gfxmode then
				self.screenres:SelectItem(n)
				break
			end
		end
		
		local anisotropy = tostring(Texture:GetAnisotropy()).."x"
		if anisotropy=="0x" then anisotropy="None" end
		for n=0,self.afilter:CountItems()-1 do
			if anisotropy==self.afilter:GetItemText(n) then
				self.afilter:SelectItem(n)
				break
			end
		end
		self.tfilter:SetState(Texture:GetTrilinearFilterMode())
		self.lightquality:SelectItem(world:GetLightQuality())
		self.terrainquality:SelectItem(world:GetTerrainQuality())
		self.waterquality:SelectItem(world:GetWaterQuality())
		self.texturequality:SelectItem(self.texturequality:CountItems()-1-Texture:GetDetail())
	end
	
	function GameMenu:splitstring(str,sep)
		local array = {}
		local reg = string.format("([^%s]+)",sep)
		for mem in string.gmatch(str,reg) do
			table.insert(array, mem)
		end
		return array
	end

	function GameMenu:ApplySettings()
		local world = World:GetCurrent()
		local item=nil
		
		--Antialias
		item = self.antialias:GetSelectedItem()
		if item>-1 then
			local aa = self.antialias:GetItemText(item)
			aa = string.gsub(aa,"x","")
			if aa=="None" then aa="1" end
			aa = tonumber(aa)
			local count = world:CountEntities()
			for n=0,count-1 do
				local entity=world:GetEntity(n)
				if entity:GetClass()==Object.CameraClass then
					local camera = tolua.cast(entity,"Camera")
					camera:SetMultisampleMode(aa)
				end
			end
			System:SetProperty("antialias",aa)
		end
		
		--Graphics mode
		item=self.screenres:GetSelectedItem()
		if item>-1 then
			local gfxmode = self.screenres:GetItemText(item)
			gfxmode = self:splitstring(gfxmode,"x")
			local window = self.context:GetWindow()
			window:SetLayout(0,0,gfxmode[1],gfxmode[2])
			System:SetProperty("screenwidth",gfxmode[1])
			System:SetProperty("screenheight",gfxmode[2])
		end
		
		--Light quality
		world:SetLightQuality(self.lightquality:GetSelectedItem())
		System:SetProperty("lightquality",self.lightquality:GetSelectedItem())
		
		--Water quality
		local quality = self.waterquality:GetSelectedItem()
		world:SetWaterQuality(quality)
		System:SetProperty("waterquality",quality)
		
		--Texture detail
		quality = self.texturequality:CountItems()-1-self.texturequality:GetSelectedItem()
		Texture:SetDetail(quality)
		System:SetProperty("texturedetail",quality)
		
		--Anisotropy
		item = self.afilter:GetSelectedItem()
		if item>-1 then
			quality = self.afilter:GetItemText(item)
			quality = string.gsub(quality,"x","")
			if quality=="None" then quality = "0" end
			Texture:SetAnisotropy(tonumber(quality))
			System:SetProperty("anisotropicfilter",quality)
		end
		
		--Trilinear filter
		quality = self.tfilter:GetState()
		Texture:SetTrilinearFilterMode(quality)
		if quality then
			System:SetProperty("trilinearfilter","1")
		else
			System:SetProperty("trilinearfilter","0")
		end		
		
		--Terriain quality
		quality = self.terrainquality:GetSelectedItem()
		world:SetTerrainQuality(quality)
		System:SetProperty("terrainquality",quality)
		
		--Vertical synv
		if (self.vsync:GetState()) then
			VSyncMode=true
			System:SetProperty("verticalsync","1")
		else
			VSyncMode=false
			System:SetProperty("verticalsync","0")
		end
	end

	function GameMenu:ProcessEvent(event)
		
		if event.id == Event.WindowSize then
				
			--if event.source == self.context:GetWindow() then
			--	local sz = self.gui:GetBase():GetSize()
			--	local wsz = self.optionspanel:GetSize()
				--self.optionspanel:SetLayout((sz.x-wsz.x)/2,(sz.y-wsz.y)/2,wsz.x,wsz.y)
			--end
		
		elseif event.id == Event.WidgetSelect then
			

			
		elseif event.id == Event.WidgetAction then
			
			if event.source == self.tabber then
				
				if event.data==0 then
					self.panel.general:Show()
				else
					self.panel.general:Hide()
				end
				
			end
			
			if event.source == self.options then
				self:GetSettings()
				self.tabber:SelectItem(0)
				self:ProcessEvent(Event(Event.WidgetAction,self.tabber,0))
				self.newbutton:Disable()
				self.options:Disable()
				self.quit:Disable()
				self.optionspanel:Show()
				
			elseif event.source == self.newbutton then
				if self.newbutton:GetText()=="NEW GAME" then
					if Map:Load("Maps/start.map") then
						prevmapname = "start"
						
						--Send analytics event
						Analytics:SendProgressEvent("Start",prevmapname)
						
						self.newbutton:SetText("RESUME GAME")
					end
				end
				self.gui:Hide()
				self.context:GetWindow():HideMouse()
				self.context:GetWindow():FlushMouse()
				self.context:GetWindow():FlushKeys()
				self.context:GetWindow():SetMousePosition(self.context:GetWidth()/2,self.context:GetHeight()/2)
				Time:Resume()
				
			elseif event.source == self.applyoptions then
				self:ApplySettings()
				self:ProcessEvent(Event(Event.WidgetAction,self.closeoptions))
				
			elseif event.source == self.closeoptions then
				self.newbutton:Enable()
				self.options:Enable()
				self.quit:Enable()
				self.optionspanel:Hide()
				
			elseif event.source == self.cancelquit then
				self.newbutton:Enable()
				self.options:Enable()
				self.quit:Enable()
				self.confirmquitpanel:Hide()
				
			elseif event.source == self.quit then
				self.newbutton:Disable()
				self.options:Disable()
				self.quit:Disable()
				self.confirmquitpanel:Show()
			
			elseif event.source == self.confirmquit then
				return false
				
			end
		end
		return true
	end

	function GameMenu:Update()
		
		if context:GetWindow():KeyHit(Key.Escape) then
			if self.optionspanel:Hidden() then
				if self.newbutton:GetText()=="NEW GAME" then
					self:ProcessEvent(Event(Event.WidgetAction,self.quit))
				else
					if self.gui:Hidden() then
						Time:Pause()
						self.gui:Show()
						self.context:GetWindow():ShowMouse()
					else
						self.gui:Hide()
						self.context:GetWindow():FlushMouse()
						self.context:GetWindow():FlushKeys()
						self.context:GetWindow():HideMouse()
						self.context:GetWindow():SetMousePosition(self.context:GetWidth()/2,self.context:GetHeight()/2)
						Time:Resume()
					end
				end
			else
				self:ProcessEvent(Event(Event.WidgetAction,self.closeoptions))
			end
		end
		
		while EventQueue:Peek() do
			local event = EventQueue:Wait()
			if self:ProcessEvent(event)==false then return false end
		end
		return true
	end
	
	return GameMenu
end
