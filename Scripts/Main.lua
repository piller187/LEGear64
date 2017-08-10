import "Scripts/LCS.lua"
import("Scripts/Menu.lua")

--Initialize Steamworks (optional)
--Steamworks:Initialize()

--Initialize analytics (optional).  Create an account at www.gameamalytics.com to get your game keys
--[[if DEBUG==false then
	Analytics:SetKeys("GAME_KEY_xxxxxxxxx", "SECRET_KEY_xxxxxxxxx")
	Analytics:Enable()
end]]

--Set the application title
title="LEGear64"

--Create a window
local windowstyle = 0
local winwidth
local winheight
local gfxmode = System:GetGraphicsMode(System:CountGraphicsModes()-1)
if System:GetProperty("devmode")=="1" then
	gfxmode.x = math.min(1280,gfxmode.x)
	gfxmode.y = Math:Round(gfxmode.x * 9 / 16)
	windowstyle = Window.Titlebar
else
	gfxmode.x = System:GetProperty("screenwidth",gfxmode.x)
	gfxmode.y = System:GetProperty("screenheight",gfxmode.y)
	windowstyle = Window.Fullscreen
end
window=Window:Create(title,0,0,gfxmode.x,gfxmode.y,windowstyle)

--Create the graphics context
context=Context:Create(window,0)
if context==nil then return end

--Create a world
world=World:Create()

local gamemenu = BuildMenu(context)

--Load a map
local mapfile = System:GetProperty("map")
if mapfile~="" then
	if Map:Load(mapfile)==false then return end
	prevmapname = FileSystem:StripAll(changemapname)

	CallPostStart(world)
	
	--Send analytics event
	Analytics:SendProgressEvent("Start",prevmapname)
	
	gamemenu.newbutton:SetText("RESUME GAME")
	--window:HideMouse()
else
	gamemenu:Show()
end

while window:Closed()==false do
	
	if gamemenu:Update()==false then return end
	
	--Handle map change
	if changemapname~=nil then
		
		--Pause the clock
		Time:Pause()
		
		--Pause garbage collection
		System:GCSuspend()		
		
		--Clear all entities
		world:Clear()
		
		--Send analytics event
		Analytics:SendProgressEvent("Complete",prevmapname)
		
		--Load the next map
		if Map:Load("Maps/"..changemapname..".map")==false then return end
		prevmapname = changemapname
		
		CallPostStart(world)
		
		--Send analytics event
		Analytics:SendProgressEvent("Start",prevmapname)
		
		--Resume garbage collection
		System:GCResume()
		
		--Resume the clock
		Time:Resume()
		
		changemapname = nil
	end	
	
	if gamemenu:Hidden() then
		
		--Update the app timing
		Time:Update()
		
		--Update the world
		world:Update()
		
	end

	--Render the world
	world:Render()
		
	--Render statistics
	context:SetBlendMode(Blend.Alpha)
	if DEBUG then
		context:SetColor(1,0,0,1)
		context:DrawText("Debug Mode",2,2)
		context:SetColor(1,1,1,1)
		context:DrawStats(2,22)
		context:SetBlendMode(Blend.Solid)
	else
		--Toggle statistics on and off
		if (window:KeyHit(Key.F11)) then showstats = not showstats end
		if showstats then
			context:SetColor(1,1,1,1)
			context:DrawText("FPS: "..Math:Round(Time:UPS()),2,2)
		end
	end
	
	--Refresh the screen
	if VSyncMode==nil then VSyncMode=true end
	context:Sync(VSyncMode)
	
end