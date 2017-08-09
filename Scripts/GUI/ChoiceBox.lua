--Styles
if Style==nil then Style={} end
if Style.Combobox==nil then Style.Combobox={} end
Style.Combobox.Compact=1

function Script:Draw(x,y,width,height)
	--System:Print("Paint Button")
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	
	gui:SetColor(1,1,1,1)
	
	--if self.pushed then
		gui:SetColor(0.15)
	--else
	--	if self.hovered then
	--		gui:SetColor(0.3,0.3,0.3)
	--	else
	--		gui:SetColor(0.25,0.25,0.25)
	--		gui:SetColor(0.15,0.15,0.15,1.0,1)
	--	end
	--end
	
	--gui:SetGradientMode(true)	
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,0)
	--gui:SetGradientMode(false)
	
	gui:SetColor(0.75,0.75,0.75)

	--gui:DrawLine(pos.x,pos.y,pos.x+sz.width,pos.y)
	--gui:DrawLine(pos.x,pos.y,pos.x,pos.y+sz.height)
	
	gui:SetColor(0.0,0.0,0.0)		

	--gui:DrawLine(pos.x+1,pos.y+sz.height-1,pos.x+sz.width-1,pos.y+sz.height-1)
	--gui:DrawLine(pos.x+sz.width-1,pos.y+1,pos.x+sz.width-1,pos.y+sz.height)
	
	--if self.hovered then
	--	gui:SetColor(51/255,151/255,1)
	--else
		gui:SetColor(0,0,0)
	--end
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)
	
	local item = self.widget:GetSelectedItem()
	if item>-1 then	
		gui:SetColor(0.75,0.75,0.75)
		gui:DrawText(self.widget:GetItemText(item),scale*8+pos.x,pos.y,sz.width-scale*8*2,sz.height,Text.Center+Text.VCenter)	
	end
	
	local w = scale * 9
	local x = pos.x + sz.width - w/2 - scale * 8
	local y = pos.y
	y = y + sz.height/2 - w/2

	if self.buttonhover==1 then
		gui:SetColor(1,1,1)
	else
		gui:SetColor(0.75,0.75,0.75)
	end
	gui:DrawPolygon(x,y,x,y+w,x+w/2,y+w/2,0)
	
	x = pos.x + scale * 8
	if self.buttonhover==-1 then
		gui:SetColor(1,1,1)
	else
		gui:SetColor(0.75,0.75,0.75)
	end
	gui:DrawPolygon(x+w/2,y,x+w/2,y+w,x,y+w/2,0)
	
end

function Script:MouseEnter(x,y)
	self.hovered = true
	self.widget:Redraw()
end

function Script:MouseWheel(delta)
	local item = self.widget:GetSelectedItem() + delta
	item = math.max(item,0)
	item = math.min(item,self.widget:CountItems()-1)
	if item~=self.widget:GetSelectedItem() then
		self.widget.selection = item
		self.widget:Redraw()
		EventQueue:Emit(Event.WidgetSelect,self.widget,item)
	end
end

function Script:MouseDown(button,x,y)
	if button==Mouse.Left then
		if self.buttonhover~=nil then
			self:MouseWheel(self.buttonhover)
		end
	end
end

function Script:MouseLeave(x,y)
	self.buttonhover = nil
	self.hovered = false
	self.widget:Redraw()
end

function Script:MouseMove(x,y)
	local sz = self.widget:GetSize(true)
	local scale = self.widget:GetGUI():GetScale()
	local prevbuttonhover = self.buttonhover
	self.buttonhover = nil
	if x>0 and y>0 and x<sz.width and y<sz.height then
		if x<sz.width/2 then
			self.buttonhover = -1
		else
			self.buttonhover = 1
		end
	end
	if prevbuttonhover~=self.buttonhover then
		self.widget:Redraw()
	end
end

function Script:KeyDown(button)
	if button==Key.Right or button==Key.Down then
		local item = self.widget:GetSelectedItem()
		item = item + 1
		if item<self.widget:CountItems() then
			if item~=self.widget:GetSelectedItem() then
				self.widget.selection = item
				self.widget:Redraw()
				EventQueue:Emit(Event.WidgetSelect,self.widget,item)
			end
		end
	end
	if button==Key.Left or button==Key.Up then
		local item = self.widget:GetSelectedItem()
		item = item - 1
		if item>-1 then
			if item~=self.widget:GetSelectedItem() then
				self.widget.selection = item
				self.widget:Redraw()
				EventQueue:Emit(Event.WidgetSelect,self.widget,item)
			end
		end
	end	
end

function Script:KeyUp(button,x,y)
	--System:Print("KeyUp")	
end
