--Styles
if Style==nil then Style={} end
if Style.Panel==nil then Style.Panel={} end
Style.Panel.Border=1
Style.Panel.Raised=2
Style.Panel.Group=3
Script.radius=0
Script.backgroundcolor = Vec4(0.2,0.2,0.2,1)

--[[
Const PANEL_SUNKEN=1
Const PANEL_RAISED=2
Const PANEL_GROUP=3
Const PANEL_BORDER=PANEL_SUNKEN	'For backwards compatibility
]]

function Script:bitand(set, flag)
	return set % (2*flag) >= flag
end

function Script:Start()
	self.color = {}
	self.color.background = Vec4(0.2,0.2,0.2,1)
	self.color.foreground = Vec4(0.7,0.7,0.7,1)
	self.color.border = Vec4(0,0,0,1)
end

function Script:SetColor(r,g,b,a,index)
	self.color.background.r=r
	self.color.background.g=g
	self.color.background.b=b
	self.color.background.a=a
end

function Script:SetStyle(style)
	if self:bitand(style,Style.Panel.Group) then
		self.widget:SetPadding(8,8,8,8)	
	elseif self:bitand(style,Style.Panel.Raised) or self:bitand(style,Style.Panel.Border) then
		self.widget:SetPadding(1,1,1,1)
	else
		self.widget:SetPadding(0,0,0,0)		
	end
end

function Script:MouseDown()
	self.widget:Redraw()
end

function Script:Adjust()
	if self.border then
		self.widget:SetPadding(1,1,1,1)
	end
end

function Script:Draw(x,y,width,height)	
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = self.widget:GetGUI():GetScale()
	
	if self.widget:GetParent()==nil then
		gui:SetColor(0,0,0,0)
		gui:Clear()
	end

	gui:SetColor(self.backgroundcolor.r,self.backgroundcolor.g,self.backgroundcolor.b,self.backgroundcolor.a)
	--gui:SetColor(self.color.background.r,self.color.background.g,self.color.background.b,self.color.background.a)
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,0,self.radius)
	
	--Draw image if present
	local image = self.widget:GetImage()
	if image~=nil then
		local imgsz = image:GetSize()
		imgsz.x = imgsz.x * scale
		imgsz.y = imgsz.y * scale
		gui:SetColor(self.color.foreground.r,self.color.foreground.g,self.color.foreground.b,self.color.foreground.a)
		--gui:DrawImage(image,pos.x+(sz.x-imgsz.x)/2,pos.y+(sz.y-imgsz.y)/2,imgsz.x,imgsz.y)
		gui:DrawImage(image,pos.x,pos.y,sz.x,sz.y)
	end
	
	--Draw border
	--if self.border then
		gui:SetColor(self.color.border.r,self.color.border.g,self.color.border.b,self.color.border.a)
		--gui:SetColor(0,1,0,1)
		gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1,self.radius)
	--end
	
	--gui:SetColor(1,0,0)
	--gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)
	--gui:DrawRect(pos.x+self.indent/2*scale,pos.y+self.indent/2*scale,sz.width-self.indent*scale,sz.height-self.indent*scale,1)
	--gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)	
end
