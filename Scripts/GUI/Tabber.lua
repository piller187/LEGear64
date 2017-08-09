--Styles
if Style==nil then Style={} end
if Style.Panel==nil then Style.Panel={} end
Style.Panel.Border=1
Style.Panel.Group=2

--Initial values
Script.indent=1
Script.tabsize = iVec2(72,28)
Script.textindent=6
Script.tabradius=5

function Script:Start()	
	self.widget:SetPadding(self.indent,self.indent,self.tabsize.y+self.indent,self.indent)
end

function Script:MouseLeave()
	if self.hovereditem~=nil then
		self.hovereditem = nil
		local scale = self.widget:GetGUI():GetScale()
		local pos = self.widget:GetPosition(true)
		local sz = self.widget:GetSize(true)
		self.widget:GetGUI():Redraw(pos.x,pos.y,sz.width,self.tabsize.y*scale+1)
		--self.widget:Redraw()
	end
end

function Script:Draw(x,y,width,height)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = self.widget:GetGUI():GetScale()
	local n
	local sel =  self.widget:GetSelectedItem()
	
	--Draw border
	gui:SetColor(0)
	gui:DrawRect(pos.x,pos.y+self.tabsize.y*scale,sz.width,sz.height-self.tabsize.y*scale,1)
	
	--Draw unselected tabs
	for n=0,self.widget:CountItems()-1 do
		if n~=sel then
			self:DrawTab(n)
		end
	end
	
	--Draw selected tab
	if sel>-1 then
		self:DrawTab(sel)
	end
	
	---Panel background
	gui:SetColor(0.2)
	gui:DrawRect(pos.x+1,pos.y+self.tabsize.y*scale+1,sz.width-2,sz.height-self.tabsize.y*scale-2)
end

function Script:DrawTab(n)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = self.widget:GetGUI():GetScale()
	local s = self.widget:GetItemText(n)
	
	local textoffset=2*scale
	if self.widget:GetSelectedItem()==n then
		textoffset=0
	end
	
	local leftpadding=0
	local rightpadding=0
	if self.widget:GetSelectedItem()==n then
		gui:SetColor(0.2)
		if n>0 then
			leftpadding = scale*1
		end
		rightpadding = scale*1
	else
		gui:SetColor(0.1)
	end
	gui:DrawRect(-leftpadding+pos.x+n*(self.tabsize.x)*scale,textoffset+pos.y,rightpadding+leftpadding+self.tabsize.x*scale+1,self.tabsize.y*scale+self.tabradius*scale+1,0,self.tabradius*scale)
	gui:SetColor(0)
	gui:DrawRect(-leftpadding+pos.x+n*(self.tabsize.x)*scale,textoffset+pos.y,rightpadding+leftpadding+self.tabsize.x*scale+1,self.tabsize.y*scale+self.tabradius*scale+1,1,self.tabradius*scale)
	
	if self.widget:GetSelectedItem()~=n then
		gui:SetColor(0)
		gui:DrawLine(pos.x+n*self.tabsize.x*scale,pos.y+self.tabsize.y*scale,pos.x+n*self.tabsize.x*scale+self.tabsize.x*scale,pos.y+self.tabsize.y*scale)
	end
	if self.hovereditem==n and self.widget:GetSelectedItem()~=n then
		gui:SetColor(1)
	else
		gui:SetColor(0.7)
	end
	gui:DrawText(s,pos.x+(n*self.tabsize.x+self.textindent)*scale,textoffset+pos.y+self.textindent*scale,(self.tabsize.x-self.textindent*2)*scale-2,(self.tabsize.y-self.textindent*2)*scale-1,Text.VCenter+Text.Center)

end

function Script:MouseDown(button,x,y)
	if button==Mouse.Left then
		if self.hovereditem~=self.widget:GetSelectedItem() and self.hovereditem~=nil then
			self.widget.selection=self.hovereditem
			local scale = self.widget:GetGUI():GetScale()
			local pos = self.widget:GetPosition(true)
			local sz = self.widget:GetSize(true)
			self.widget:GetGUI():Redraw(pos.x,pos.y,sz.width,self.tabsize.y*scale+1)
			EventQueue:Emit(Event.WidgetAction,self.widget,self.hovereditem)
		end
	elseif button==Mouse.Right then
		if self.hovereditem~=self.widget:GetSelectedItem() and self.hovereditem~=nil then
			EventQueue:Emit(Event.WidgetMenu,self.widget,self.hovereditem,x,y)		
		end
	end
end

function Script:KeyDown(keycode)
	if keycode==Key.Right or keycode==Key.Down then
		local item = self.widget:GetSelectedItem() + 1
		if item<self.widget:CountItems() then
			self.widget.selection=item
			local scale = self.widget:GetGUI():GetScale()
			local pos = self.widget:GetPosition(true)
			local sz = self.widget:GetSize(true)
			self.widget:GetGUI():Redraw(pos.x,pos.y,sz.width,self.tabsize.y*scale+1)
			EventQueue:Emit(Event.WidgetAction,self.widget,item)
		end
	elseif keycode==Key.Left or keycode==Key.Up then
		local item = self.widget:GetSelectedItem() - 1
		if item>-1 and self.widget:CountItems()>0 then
			self.widget.selection=item
			local scale = self.widget:GetGUI():GetScale()
			local pos = self.widget:GetPosition(true)
			local sz = self.widget:GetSize(true)
			self.widget:GetGUI():Redraw(pos.x,pos.y,sz.width,self.tabsize.y*scale+1)
			EventQueue:Emit(Event.WidgetAction,self.widget,item)
		end
	elseif keycode==Key.Tab then
		local item = self.widget:GetSelectedItem() + 1
		if item>self.widget:CountItems()-1 then
			item=0
		end
		if self.widget:CountItems()>1 then
			self.widget.selection=item
			local scale = self.widget:GetGUI():GetScale()
			local pos = self.widget:GetPosition(true)
			local sz = self.widget:GetSize(true)
			self.widget:GetGUI():Redraw(pos.x,pos.y,sz.width,self.tabsize.y*scale+1)
			EventQueue:Emit(Event.WidgetAction,self.widget,item)
		end		
	end
end

function Script:MouseMove(x,y)
	local prevhovereditem = self.hovereditem
	self.hovereditem = nil
	local scale = self.widget:GetGUI():GetScale()
	local sz = self.widget:GetSize(true)
	if x>=0 and y>=0 and x<sz.width and y<self.tabsize.y*scale then
		local item = math.floor(x / (self.tabsize.x*scale))
		if item>=0 and item<self.widget:CountItems() then
			self.hovereditem=item
		end
	end
	if self.hovereditem==self.widget:GetSelectedItem() and prevhovereditem==nil then
		return
	end
	if self.hovereditem==nil and prevhovereditem==self.widget:GetSelectedItem() then
		return
	end
	if prevhovereditem~=self.hovereditem then
		local pos = self.widget:GetPosition(true)
		local sz = self.widget:GetSize(true)
		self.widget:GetGUI():Redraw(pos.x,pos.y,sz.width,self.tabsize.y*scale+1)
	end
end
