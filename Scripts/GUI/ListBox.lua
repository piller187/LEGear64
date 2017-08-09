Script.hovered=false
Script.offset=0
Script.itemheight=20
Script.sliderwidth=19
Script.sliderrange={}
Script.sliderincrements = Script.itemheight

function Script:UpdateSlider()
	local gui = self.widget:GetGUI()
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	if self.itemheight*scale * self.widget:CountItems()>sz.height then
		self.slidervisible=true
		self.sliderrange.x = sz.height
		self.sliderrange.y = self.itemheight*scale * self.widget:CountItems()
		self.offset = math.max(0,self.offset)
		self.offset = math.min(self.offset,self.sliderrange.y-self.sliderrange.x)
	else
		self.slidervisible=nil
		self.offset=0
	end
	self.itemcount=self.widget:CountItems()
	self.guiscale = scale
end

function Script:Resize(width,height)
	self:UpdateSlider()
end

function Script:Draw(x,y,width,height)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	
	if self.itemcount~=self.widget:CountItems() or self.guiscale~=scale then
		self:UpdateSlider()
	end
	
	if self.slidervisible==true then
		sz.width = sz.width - scale*self.sliderwidth
		local indent = 6*scale
		
		--Top button
		gui:SetColor(0,0,0)
		gui:DrawRect(pos.x+sz.width,pos.y,scale*self.sliderwidth,scale*self.sliderwidth,1)
		if self.sliderhoverstate==-1 then
			gui:SetColor(1,1,1)
		else
			gui:SetColor(0.75,0.75,0.75)
		end
		gui:DrawPolygon(pos.x+indent+sz.width,pos.y+scale*self.sliderwidth-indent, pos.x+sz.width+self.sliderwidth*scale/2,pos.y - scale*self.sliderwidth+self.sliderwidth*scale + indent, pos.x+sz.width+self.sliderwidth*scale-indent,pos.y + scale*self.sliderwidth-indent,0)
		
		--Track
		gui:SetColor(0.15,0.15,0.15)
		gui:DrawRect(pos.x+sz.width,pos.y+scale*self.sliderwidth,scale*self.sliderwidth,sz.height-scale*self.sliderwidth*2,0)
		gui:SetColor(0,0,0)
		gui:DrawRect(pos.x+sz.width,pos.y,scale*self.sliderwidth,sz.height,1)
		
		--Bottom button
		gui:SetColor(0,0,0)
		gui:DrawRect(pos.x+sz.width,pos.y+sz.height-scale*self.sliderwidth,scale*self.sliderwidth,scale*self.sliderwidth,1)
		if self.sliderhoverstate==1 then
			gui:SetColor(1,1,1)
		else
			gui:SetColor(0.75,0.75,0.75)
		end
		gui:DrawPolygon(pos.x+indent+sz.width,pos.y+sz.height-scale*self.sliderwidth+indent, pos.x+sz.width+self.sliderwidth*scale/2,pos.y + sz.height - scale*self.sliderwidth+self.sliderwidth*scale - indent, pos.x+sz.width+self.sliderwidth*scale - indent,pos.y + sz.height - scale*self.sliderwidth+indent,0)
		
		--Slider knob
		local knob = self:GetKnobArea()
		gui:SetColor(0.2,0.2,0.2)
		gui:DrawRect(pos.x+sz.width,pos.y+scale*self.sliderwidth+knob.position,scale*self.sliderwidth,knob.size,0)
		gui:SetColor(0,0,0)		
		gui:DrawRect(pos.x+sz.width,pos.y+scale*self.sliderwidth+knob.position,scale*self.sliderwidth,knob.size,1)
		
	end
	
	gui:SetColor(0.15,0.15,0.15)
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,0)
	
	local item = self.widget:GetSelectedItem()
	local y=0
	
	local firstitem = math.floor(self.offset / (self.itemheight*scale))
	local lastitem = math.floor((self.offset + sz.height) / (self.itemheight*scale))
	firstitem = math.max(0,firstitem)
	lastitem = math.min(lastitem,self.widget:CountItems()-1)	
	
	for item=firstitem,lastitem do
		y=item*scale*self.itemheight
		if item==self.widget:GetSelectedItem() then
			--if self.focused==true then
				gui:SetColor(51/255,151/255,1)
			--else
			--	gui:SetColor(0.4,0.4,0.4)
			--end
			--gui:SetColor(51/255/2*0.75,151/255/2*0.75,1/2*0.75,1,1)
			--gui:SetGradientMode(true)
			gui:DrawRect(pos.x,pos.y+y-self.offset,sz.width,scale*self.itemheight)
			--gui:SetGradientMode(false)
			gui:SetColor(1,1,1,1)
		else
			gui:SetColor(0.75,0.75,0.75,1)
		end
		
		gui:DrawText(self.widget:GetItemText(item), scale * 8 + pos.x, pos.y + y - self.offset, sz.width, scale * self.itemheight, Text.Left + Text.VCenter)		
	end
	
	--Draw outline
	--if self.hovered then
	--	gui:SetColor(51/255,151/255,1)
	--else
		gui:SetColor(0,0,0)
	--end
	if self.slidervisible then
		gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)		
	else
		gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)
	end
end

function Script:GetKnobArea()
	local knob = {}
	local scale = self.widget:GetGUI():GetScale()
	local sz = self.widget:GetSize(true)
	knob.position = Math:Round(self.offset / self.sliderrange.y * (sz.height-scale*self.sliderwidth*2))
	knob.size = Math:Round(self.sliderrange.x / self.sliderrange.y * (sz.height-scale*self.sliderwidth*2))
	return knob
end

function Script:MouseWheel(delta)
	if self.slidervisible then
		local prevoffset = self.offset
		local scale = self.widget:GetGUI():GetScale()
		self.offset = self.offset + delta * self.sliderincrements * scale
		self.offset = math.max(0,self.offset)
		self.offset = math.min(self.offset,self.sliderrange.y-self.sliderrange.x)
		if prevoffset~=self.offset then
			self.widget:Redraw()
		end
	end
	--[[local item = self.widget:GetSelectedItem() + delta
	item = math.max(item,0)
	item = math.min(item,self.widget:CountItems()-1)
	if item~=self.widget:GetSelectedItem() then
		self.widget:SelectItem(item)
		EventQueue:Emit(Event.WidgetSelect,self.widget,item)
	end]]
end

function Script:MouseEnter(x,y)
	self.hovered = true
	self.widget:Redraw()
end

function Script:MouseLeave(x,y)
	self.hovered = false
	self.sliderhoverstate = nil
	self.widget:Redraw()
end

function Script:MouseUp(button,x,y)
	if button==Mouse.Left then
		self.knobgrabbed = false
	end
end

function Script:MouseMove(x,y)
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local prevhoverstate = self.sliderhoverstate
	self.sliderhoverstate = nil
	if self.knobgrabbed==true then
		local knob = self:GetKnobArea()
		local scale = self.widget:GetGUI():GetScale()
		local knobposition = y - self.knobgrabposition
		local sz = self.widget:GetSize(true)
		self.offset = Math:Round(knobposition / ((sz.y-self.sliderwidth*scale*2) - knob.size) * (self.sliderrange.y-self.sliderrange.x))
		self.offset = math.max(self.offset,0)
		self.offset = math.min(self.offset,self.sliderrange.y-self.sliderrange.x)
		self.widget:Redraw()
	else
		if self.slidervisible==true then
			if x>=0 and y>=0 and x<sz.x and y<sz.y then
				local scale = self.widget:GetGUI():GetScale()
				local sz = self.widget:GetSize(true)
				local knob = self:GetKnobArea()
				if x>self.widget:GetSize(true).x-self.sliderwidth*scale then
					if y<self.sliderwidth*scale then
						self.sliderhoverstate=-1
					elseif y>sz.height-self.sliderwidth*scale then
						self.sliderhoverstate=1
					end
				end
			end
		end
	end
	if prevhoverstate~=self.sliderhoverstate then
		self.widget:Redraw()
	end
end

function Script:GainFocus()
	self.focused = true
end

function Script:LoseFocus()
	self.focused = false
	self.widget:Redraw()
end

function Script:MouseDown(button,x,y)
	self.focused=true
	if button==Mouse.Left then
		if self.slidervisible==true then
			local scale = self.widget:GetGUI():GetScale()
			local sz = self.widget:GetSize(true)
			if x>self.widget:GetSize(true).x-self.sliderwidth*scale then
				if y<self.sliderwidth*scale then
					self:MouseWheel(-1)
				elseif y>sz.height - self.sliderwidth*scale then
					self:MouseWheel(1)
				else
					local knob = self:GetKnobArea()
					if y-self.sliderwidth*scale<knob.position then
						self.offset = self.offset - knob.size / (sz.height - self.sliderwidth*scale*2) * self.sliderrange.y
						self.offset = math.max(self.offset,0)
						self.widget:Redraw()
					elseif y-self.sliderwidth*scale>knob.position + knob.size then
						self.offset = self.offset + knob.size / (sz.height - self.sliderwidth*scale*2) * self.sliderrange.y
						self.offset = math.min(self.offset,self.sliderrange.y-self.sliderrange.x)
						self.widget:Redraw()						
					else
						--Grab thew slider knob
						self.knobgrabbed=true
						self.knobgrabposition = y - knob.position
						self.knobgraboffset = self.offset					
					end
				end
				return
			end
		end
		y = y + self.offset
		local item = math.floor(y / self.itemheight / self.widget:GetGUI():GetScale())
		if item>-1 and item<self.widget:CountItems() and item~=self.widget:GetSelectedItem() then
			self.widget:SelectItem(item)
			EventQueue:Emit(Event.WidgetSelect,self.widget,item)
		end
	end
	if button==Mouse.Right then
		y = y + self.offset
		local item = math.floor(y / self.itemheight / self.widget:GetGUI():GetScale())
		if item>-1 and item<self.widget:CountItems() then
			EventQueue:Emit(Event.WidgetMenu,self.widget,item,x,y)
		end
	end
end

function Script:DoubleClick(button,x,y)
	if button==Mouse.Left then
		y = y + self.offset
		local item = math.floor(y / self.itemheight / self.widget:GetGUI():GetScale())
		if item>-1 and item<self.widget:CountItems() then
			EventQueue:Emit(Event.WidgetAction,self.widget,item)
		end
	end
end

function Script:SelectItem(index)
	local scale = self.widget:GetGUI():GetScale()
	local sz = self.widget:GetSize(true)
	if (index + 1) * self.itemheight*scale - self.offset > sz.y then
		self.offset = (index + 1) * self.itemheight*scale - sz.y
	elseif index * self.itemheight*scale - self.offset < 0 then
		self.offset = index * self.itemheight*scale
	end
end

function Script:KeyDown(button)
	if button==Key.Right or button==Key.Down then
		local item = self.widget:GetSelectedItem()
		item = item + 1
		if item<self.widget:CountItems() then
			if item~=self.widget:GetSelectedItem() then
				self.widget:SelectItem(item)
				EventQueue:Emit(Event.WidgetSelect,self.widget,item)
			end		
		end
	end
	if button==Key.Left or button==Key.Up then
		local item = self.widget:GetSelectedItem()
		item = item - 1
		if item>-1 then
			if item~=self.widget:GetSelectedItem() then
				self.widget:SelectItem(item)
				EventQueue:Emit(Event.WidgetSelect,self.widget,item)
			end
		end
	end	
end
