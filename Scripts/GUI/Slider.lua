--Styles
--[[if Style==nil then Style={} end
if Style.Slider==nil then Style.Slider={} end
Style.Slider.Horizontal=1
Style.Slider.Vertical=2
Style.Slider.Scrollbar=4
Style.Slider.Trackbar=8
Style.Slider.Stepper=16]]

--Initial values
Script.hovered=false
Script.itemheight=20
Script.sliderwidth=19
Script.sliderincrements = 1
Script.arrowsize=10
Script.stepperarrowsize=7
Script.trackbarknobsize=8
Script.knobwidth=12
Script.style = "Scrollbar"--Style.Slider.Horizontal
Script.layout = "Horizontal"
Script.offset=0

--function Script:DoubleCLick(button,x,y)
--end

function Script:UpdateSlider()
	local gui = self.widget:GetGUI()
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	if self.itemheight*scale * self.widget:CountItems()>sz.height then
		self.slidervisible=true
		--self.sliderrange.x = sz.height
		--self.sliderrange.y = self.itemheight*scale * self.widget:CountItems()
		self.widget:SetRange(sz.height,self.itemheight*scale * self.widget:CountItems())
	else
		self.slidervisible=nil
	end
	self.itemcount=self.widget:CountItems()
	self.guiscale = scale
end

function Script:Draw(x,y,width,height)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	local style = self.style--self.widget:GetStyle()
	
	--System:Print(self.widget:GetPosition().x)
	
	if self.layout=="Vertical" then--self:bitand(style,Style.Slider.Horizontal)==false then
		
		-----------------------------------------------
		--Draw vertical slider
		-----------------------------------------------
		
		if self.style=="Trackbar" then--self:bitand(style,Style.Slider.Trackbar)==true then
			
			-----------------------------------------------
			--Trackbar style
			-----------------------------------------------			
			gui:SetColor(0.15)
			gui:DrawRect(pos.x+sz.width/2-scale*2,pos.y+self.trackbarknobsize*scale/2,scale*4,sz.height-self.trackbarknobsize*scale+1,0)
			--if self.hovered then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x+sz.width/2-scale*2,pos.y+self.trackbarknobsize*scale/2,scale*4,sz.height-self.trackbarknobsize*scale+1,1)
			
			--Draw ticks
			--[[for n=0,self.sliderrange.y-1 do
				local y = n / (self.sliderrange.y-1) * (sz.height - self.trackbarknobsize*scale)
				if n==0 or n==self.sliderrange.y-1 then
					gui:SetColor(0)
					gui:DrawLine(pos.x + sz.width/2 - 2.5*2*scale,self.trackbarknobsize*scale/2 + pos.y + y,pos.x + sz.width/2 + 2*2.5*scale,self.trackbarknobsize*scale/2 + pos.y + y)
				else
					gui:SetColor(0)
					gui:DrawLine(pos.x + sz.width/2 + 2*scale,self.trackbarknobsize*scale/2 + pos.y + y,pos.x + sz.width/2 + 3*scale + 2*scale,self.trackbarknobsize*scale/2 + pos.y + y)
				end
			end]]
			
			--Draw knob
			local y = self.widget:GetSliderValue() / (self.widget:GetRange().y-1) * (sz.height - self.trackbarknobsize*scale) - self.trackbarknobsize*scale/2
			local rx = pos.x + sz.width/2 - self.knobwidth/2*scale
			local ry = pos.y + self.trackbarknobsize*scale/2 + y
			local rw = self.knobwidth*scale
			local rh = self.trackbarknobsize*scale
			--if self.knobhoveredstate then
			--	gui:SetColor(1)
			--else
				gui:SetColor(0.7)
			--end
			gui:DrawPolygon(rx,ry, rx+rw,ry, rx+rw+rh/2, ry+rh/2, rx+rw, ry+rh, rx, ry+rh, 0)
			--if self.hovered then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawPolygon(rx,ry, rx+rw,ry, rx+rw+rh/2, ry+rh/2, rx+rw, ry+rh, rx, ry+rh, 1)
			
		elseif self.style=="Stepper" then--self:bitand(style,Style.Slider.Stepper)==true then
			
			-----------------------------------------------
			--Stepper style
			-----------------------------------------------				
			
			local arrowsz = self.stepperarrowsize*scale
			
			--Top button
			if self.arrowpressed==-1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x,pos.y,sz.width,math.floor(sz.height/2),0)
			end
			--if self.sliderhoverstate==-1 then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x,pos.y,sz.width,math.floor(sz.height/2),1)
			if self.sliderhoverstate==-1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			gui:DrawPolygon(pos.x + (sz.width - arrowsz)/2, pos.y + (sz.height/2+arrowsz/2)/2,pos.x + sz.width/2, pos.y + (sz.height/2-arrowsz/2)/2,pos.x + (sz.width + arrowsz)/2, pos.y + (sz.height/2+arrowsz/2)/2,0)
			
			--Bottom button
			if self.arrowpressed==1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x,pos.y + math.floor(sz.height/2),sz.width,math.floor(sz.height/2),0)
			end
			--if self.sliderhoverstate==1 then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x,pos.y + math.floor(sz.height/2),sz.width,math.floor(sz.height/2),1)
			if self.sliderhoverstate==1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			gui:DrawPolygon(pos.x + (sz.width - arrowsz)/2, sz.height - sz.height/2 + pos.y + (sz.height/2-arrowsz/2)/2, pos.x + sz.width/2, sz.height - sz.height/2 + pos.y + (sz.height/2+arrowsz/2)/2, pos.x + (sz.width + arrowsz)/2, sz.height - sz.height/2 + pos.y + (sz.height/2-arrowsz/2)/2,0)
			
		else
			
			-----------------------------------------------
			--Scrollbar style
			-----------------------------------------------		
			
			--Top button
			if self.arrowpressed==-1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x,pos.y,sz.width,self.sliderwidth*scale,0)				
			end
			gui:SetColor(0,0,0)
			gui:DrawRect(pos.x,pos.y,sz.width,self.sliderwidth*scale,1)
			if self.sliderhoverstate==-1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			gui:DrawPolygon(pos.x + (sz.width - self.arrowsize*scale)/2, pos.y + (self.sliderwidth*scale+self.arrowsize*scale/2)/2, pos.x + sz.width/2, pos.y + (self.sliderwidth*scale-self.arrowsize*scale/2)/2, pos.x + (sz.width + self.arrowsize*scale)/2, pos.y + (self.sliderwidth*scale+self.arrowsize*scale/2)/2,0)
			
			--Track
			gui:SetColor(0.15,0.15,0.15)
			gui:DrawRect(pos.x,pos.y+self.sliderwidth*scale,sz.x,sz.height-self.sliderwidth*scale*2,0)
			
			--Bottom button
			if self.arrowpressed==1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x,pos.y+sz.height-self.sliderwidth*scale,sz.width,self.sliderwidth*scale,0)				
			end
			gui:SetColor(0,0,0)
			gui:DrawRect(pos.x,pos.y+sz.height-self.sliderwidth*scale,sz.width,self.sliderwidth*scale,1)
			if self.sliderhoverstate==1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			gui:DrawPolygon(pos.x + (sz.width - self.arrowsize*scale)/2, sz.height - self.sliderwidth*scale + pos.y + (self.sliderwidth*scale-self.arrowsize*scale/2)/2, pos.x + sz.width/2, sz.height - self.sliderwidth*scale + pos.y + (self.sliderwidth*scale+self.arrowsize*scale/2)/2,pos.x + (sz.width + self.arrowsize*scale)/2, sz.height - self.sliderwidth*scale + pos.y + (self.sliderwidth*scale-self.arrowsize*scale/2)/2,0)
			
			--Slider knob
			local knob = self:GetKnobArea()
			gui:SetColor(0.2,0.2,0.2)
			gui:DrawRect(pos.x,pos.y+scale*self.sliderwidth+knob.position,sz.width,knob.size,0)
			gui:SetColor(0,0,0)		
			gui:DrawRect(pos.x,pos.y+scale*self.sliderwidth+knob.position-1,sz.width,knob.size+2,1)
			
			--Outline
			--if self.hovered then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x,pos.y,sz.x,sz.y,1)
			
		end
		
	else
		
		-----------------------------------------------
		--Draw horizontal slider
		-----------------------------------------------
		
		if self.style=="Trackbar" then--self:bitand(style,Style.Slider.Trackbar)==true then
			
			-----------------------------------------------
			--Trackbar style
			-----------------------------------------------					
			gui:SetColor(0.15)
			gui:DrawRect(pos.x+self.trackbarknobsize*scale/2,pos.y+sz.height/2-scale*2,sz.width-self.trackbarknobsize*scale+1,scale*4,0)			
			--if self.hovered then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x+self.trackbarknobsize*scale/2,pos.y+sz.height/2-scale*2,sz.width-self.trackbarknobsize*scale+1,scale*4,1)			
			
			--Draw ticks
			--[[for n=0,self.sliderrange.y-1 do
				local x = n / (self.sliderrange.y-1) * (sz.width - self.trackbarknobsize*scale)
				if n==0 or n==self.sliderrange.y-1 then
					gui:SetColor(0)
					--gui:DrawLine(pos.x + sz.width/2 - 2.5*2*scale,self.trackbarknobsize*scale/2 + pos.y + y,pos.x + sz.width/2 + 2*2.5*scale,self.trackbarknobsize*scale/2 + pos.y + y)
					gui:DrawLine(self.trackbarknobsize*scale/2 + pos.x + x,pos.y + sz.height/2 - 2.5*2*scale,self.trackbarknobsize*scale/2 + pos.x + x,pos.y + sz.height/2 + 2*2.5*scale)
				else
					gui:SetColor(0)
					--gui:DrawLine(pos.x + sz.width/2 + 2*scale,self.trackbarknobsize*scale/2 + pos.y + y,pos.x + sz.width/2 + 3*scale + 2*scale,self.trackbarknobsize*scale/2 + pos.y + y)
					gui:DrawLine(self.trackbarknobsize*scale/2 + pos.x + x,pos.y + sz.height/2 + 2*scale,self.trackbarknobsize*scale/2 + pos.x + x,pos.y + sz.height/2 + 3*scale + 2*scale)
				end
			end]]
			
			--Draw knob
			local x = self.widget:GetSliderValue() / (self.widget:GetRange().y-1) * (sz.width - self.trackbarknobsize*scale) - self.trackbarknobsize*scale/2
			local rx = pos.x + self.trackbarknobsize*scale/2 + x
			local ry = pos.y + sz.height/2 - self.knobwidth/2*scale
			local rw = self.trackbarknobsize*scale
			local rh = self.knobwidth*scale
			if self.knobhoveredstate then
				gui:SetColor(1)
			else
				gui:SetColor(0.7)
			end
			gui:DrawPolygon(rx,ry, rx,ry+rh, rx+rw/2, ry+rh+rw/2, rx+rw, ry+rh, rx+rw, ry, 0)
			--if self.hovered then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawPolygon(rx,ry, rx,ry+rh, rx+rw/2, ry+rh+rw/2, rx+rw, ry+rh, rx+rw, ry, 1)			
			
		elseif self.style=="Stepper" then--self:bitand(style,Style.Slider.Stepper)==true then
			
			-----------------------------------------------
			--Stepper style
			-----------------------------------------------				
			local arrowsz = self.stepperarrowsize*scale
			
			--Left button
			if self.arrowpressed==-1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x,pos.y,math.floor(sz.width/2),sz.height,0)
			end
			--if self.sliderhoverstate==-1 then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x,pos.y,math.floor(sz.width/2),sz.height,1)
			if self.sliderhoverstate==-1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			local v0 = Vec2(pos.x + (sz.width/2+arrowsz/2)/2, pos.y + (sz.height - arrowsz)/2)
			local v1 = Vec2(pos.x + (sz.width/2-arrowsz/2)/2, pos.y + sz.height/2)
			local v2 = Vec2(pos.x + (sz.width/2+arrowsz/2)/2, pos.y + (sz.height + arrowsz)/2)
			gui:DrawPolygon(v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, 0)
			
			--Right button
			if self.arrowpressed==1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x + math.floor(sz.width/2),pos.y,math.floor(sz.width/2),sz.height,0)
			end
			--if self.sliderhoverstate==1 then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x + math.floor(sz.width/2),pos.y,math.floor(sz.width/2),sz.height,1)
			if self.sliderhoverstate==1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			local v0 = Vec2(sz.width - sz.width/2 + pos.x + (sz.width/2-arrowsz/2)/2, pos.y + (sz.height - arrowsz)/2)
			local v1 = Vec2(sz.width - sz.width/2 + pos.x + (sz.width/2+arrowsz/2)/2, pos.y + sz.height/2)
			local v2 = Vec2(sz.width - sz.width/2 + pos.x + (sz.width/2-arrowsz/2)/2, pos.y + (sz.height + arrowsz)/2)
			gui:DrawPolygon(v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, 0)
			
		else
			
			-----------------------------------------------
			--Scrollbar style
			-----------------------------------------------		
			
			--Left button
			if self.arrowpressed==-1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x,pos.y,self.sliderwidth*scale,sz.height,0)				
			end
			gui:SetColor(0,0,0)
			gui:DrawRect(pos.x,pos.y,self.sliderwidth*scale,sz.height,1)
			if self.sliderhoverstate==-1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			local v0 = Vec2(pos.x + (self.sliderwidth*scale+self.arrowsize*scale/2)/2, pos.y + (sz.height - self.arrowsize*scale)/2)
			local v1 = Vec2(pos.x + (self.sliderwidth*scale-self.arrowsize*scale/2)/2, pos.y + sz.height/2)
			local v2 = Vec2(pos.x + (self.sliderwidth*scale+self.arrowsize*scale/2)/2, pos.y + (sz.height + self.arrowsize*scale)/2)
			gui:DrawPolygon(v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, 0)
			
			--Track
			gui:SetColor(0.15,0.15,0.15)
			gui:DrawRect(pos.x+self.sliderwidth*scale,pos.y,sz.width-self.sliderwidth*scale*2,sz.y,0)
			
			--Right button
			if self.arrowpressed==1 then
				gui:SetColor(0.2,0.2,0.2)
				gui:DrawRect(pos.x+sz.width-self.sliderwidth*scale,pos.y,self.sliderwidth*scale,sz.height,0)				
			end
			gui:SetColor(0,0,0)
			gui:DrawRect(pos.x+sz.width-self.sliderwidth*scale,pos.y,self.sliderwidth*scale,sz.height,1)
			if self.sliderhoverstate==1 then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.75,0.75,0.75)
			end
			local v0 = Vec2(pos.x + sz.width - self.sliderwidth*scale + (self.sliderwidth*scale-self.arrowsize*scale/2)/2, pos.y + (sz.height - self.arrowsize*scale)/2)
			local v1 = Vec2(pos.x + sz.width - self.sliderwidth*scale + (self.sliderwidth*scale+self.arrowsize*scale/2)/2, pos.y + sz.height/2)
			local v2 = Vec2(pos.x + sz.width - self.sliderwidth*scale + (self.sliderwidth*scale-self.arrowsize*scale/2)/2, pos.y + (sz.height + self.arrowsize*scale)/2)
			gui:DrawPolygon(v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, 0)
			
			--Slider knob
			local knob = self:GetKnobArea()
			gui:SetColor(0.2,0.2,0.2)
			gui:DrawRect(pos.x+scale*self.sliderwidth+knob.position,pos.y,knob.size,sz.height,0)
			gui:SetColor(0,0,0)		
			gui:DrawRect(pos.x+scale*self.sliderwidth+knob.position-1,pos.y,knob.size+2,sz.height,1)
			
			--Outline
			--if self.hovered then
			--	gui:SetColor(51/255,151/255,1)
			--else
				gui:SetColor(0,0,0)
			--end
			gui:DrawRect(pos.x,pos.y,sz.x,sz.y,1)		
			
		end
	end
	
	--[[
	local item = self.widget:GetSelectedItem()
	local y=0
	
	local firstitem = math.floor(self.offset / (self.itemheight*scale))
	local lastitem = math.ceil((self.offset + sz.height) / (self.itemheight*scale))
	firstitem = math.max(0,firstitem)
	lastitem = math.min(lastitem,self.widget:CountItems()-1)	
	
	for item=firstitem,lastitem do
		y=item*scale*self.itemheight
		if item==self.widget:GetSelectedItem() then
			--if self.focused==true then
				gui:SetColor(51/255/2,151/255/2,1/2)
			--else
			--	gui:SetColor(0.4,0.4,0.4)
			--end
			gui:DrawRect(pos.x,pos.y+y-self.offset,sz.width,scale*self.itemheight)
		end
		gui:SetColor(0.75,0.75,0.75)
		gui:DrawText(self.widget:GetItemText(item), scale * 8 + pos.x, pos.y + y - self.offset, sz.width, scale * self.itemheight, Text.Left + Text.VCenter)		
	end
	
	if self.hovered then
		gui:SetColor(51/255/4,151/255/4,1/4)
	else
		gui:SetColor(0,0,0)
	end
	gui:DrawRect(pos.x,pos.y,sz.width-1,sz.height-1,1)		
]]
end

function Script:GetKnobArea()
	local knob = {}
	local scale = self.widget:GetGUI():GetScale()
	local sz = self.widget:GetSize(true)
	local style = self.style--self.widget:GetStyle()
	if self.layout=="Vertical" then--self:bitand(style,Style.Slider.Horizontal)==false then
		knob.position = Math:Round(self.widget:GetSliderValue() / self.widget:GetRange().y * (sz.height-scale*self.sliderwidth*2))
		knob.size = Math:Round(self.widget:GetRange().x / self.widget:GetRange().y * (sz.height-scale*self.sliderwidth*2))
	else
		knob.position = Math:Round(self.widget:GetSliderValue() / self.widget:GetRange().y * (sz.width-scale*self.sliderwidth*2))
		knob.size = Math:Round(self.widget:GetRange().x / self.widget:GetRange().y * (sz.width-scale*self.sliderwidth*2))		
	end
	return knob
end

function Script:SetValue(value)
	if value~=self.widget:GetSliderValue() then
		self.widget:SetSliderValue(value)
		if self.owner then
			self.owner:UpdateSlider(self.widget)
		end
	end
end

function Script:MouseWheel(delta)
	local prevoffset = self.widget:GetSliderValue()
	local scale = self.widget:GetGUI():GetScale()
	local style = self.style--self.widget:GetStyle()
	--if self.style=="Trackbar" or self.style=="Stepper" then--self:bitand(style,Style.Slider.Trackbar) or self:bitand(style,Style.Slider.Stepper) then
	--	self:SetValue(self.offset + delta)
	--else
		self:SetValue(self.widget:GetSliderValue() + delta * self.sliderincrements)
	--end
	self:SetValue(math.min( math.max(0,self.widget:GetSliderValue()) ,self.widget:GetRange().y-self.widget:GetRange().x))
	if prevoffset~=self.widget:GetSliderValue() then
		self.widget:Redraw()
		EventQueue:Emit(Event.WidgetAction,self.widget,self.widget:GetSliderValue())
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
	self.arrowpressed=nil
	self.widget:Redraw()
end

function Script:MouseUp(button,x,y)
	if button==Mouse.Left then
		self.knobgrabbed = false
		if self.arrowpressed~=nil then
			self.arrowpressed=nil
			self.widget:Redraw()
		end
	end
end

function Script:MouseMove(x,y)
	local prevhoverstate = self.sliderhoverstate
	local prevknobhoveredstate = self.knobhoveredstate
	self.knobhoveredstate = nil
	self.sliderhoverstate = nil
	if self.knobgrabbed==true then
		local state=self.widget:GetSliderValue()
		local style = self.style--self.widget:GetStyle()
		local knob = self:GetKnobArea()
		local scale = self.widget:GetGUI():GetScale()
		if self.layout=="Vertical" then--self:bitand(style,Style.Slider.Horizontal)==false then
			if self.style=="Trackbar" then
			--if self:bitand(style,Style.Slider.Trackbar) then
				local sz = self.widget:GetSize(true)
				self:SetValue(Math:Round(((y - self.knobgrabposition)+self.trackbarknobsize*scale/2) / (sz.height - self.trackbarknobsize*scale) * (self.widget:GetRange().y-1)))
			else
				local knobposition = y - self.knobgrabposition
				local sz = self.widget:GetSize(true)
				self:SetValue(Math:Round(knobposition / ((sz.y-self.sliderwidth*scale*2) - knob.size) * (self.widget:GetRange().y-self.widget:GetRange().x)))
			end
		else
			if self.style=="Trackbar" then
			--if self:bitand(style,Style.Slider.Trackbar) then
				local sz = self.widget:GetSize(true)
				self:SetValue(Math:Round(((x - self.knobgrabposition)+self.trackbarknobsize*scale/2) / (sz.width - self.trackbarknobsize*scale) * (self.widget:GetRange().y-1)))
			else
				local knobposition = x - self.knobgrabposition
				local sz = self.widget:GetSize(true)
				self:SetValue(Math:Round(knobposition / ((sz.x-self.sliderwidth*scale*2) - knob.size) * (self.widget:GetRange().y-self.widget:GetRange().x)))
			end
		end
		self:SetValue(math.max(self.widget:GetSliderValue(),0))
		self:SetValue(math.min(self.widget:GetSliderValue(),self.widget:GetRange().y-self.widget:GetRange().x))
		if self.widget:GetSliderValue()~=state then
			self.widget:Redraw()
			EventQueue:Emit(Event.WidgetAction,self.widget,self.widget:GetSliderValue())
		end
	else
		local scale = self.widget:GetGUI():GetScale()
		local sz = self.widget:GetSize(true)
		local knob = self:GetKnobArea()
		if x>=0 and x<sz.width and y>=0 and y<sz.height then
			local style = self.style--self.widget:GetStyle()
			if self.layout=="Vertical" then--self:bitand(style,Style.Slider.Horizontal)==false then
				--if self:bitand(style,Style.Slider.Stepper) then
				if self.layout=="Horizontal" then
					if y<sz.height/2 then
						self.sliderhoverstate=-1						
					else
						self.sliderhoverstate=1
					end
				elseif self.style=="Trackbar" then--self:bitand(style,Style.Slider.Trackbar) then
					if x>(sz.width-self.knobwidth*scale)/2 and x<(sz.width+self.knobwidth*scale)/2 then
						local kh = self.trackbarknobsize*scale
						local ky = self.widget:GetSliderValue() / (self.widget:GetRange().y-1) * (sz.height - self.trackbarknobsize*scale) - self.trackbarknobsize*scale/2 + kh/2									
						if y>=ky and y<ky+kh then
							self.knobhoveredstate=true
						end
					end
				else
					if y<self.sliderwidth*scale then
						self.sliderhoverstate=-1
					elseif y>sz.height-self.sliderwidth*scale then
						self.sliderhoverstate=1
					end
				end
			else
				if self.style=="Stepper" then--self:bitand(style,Style.Slider.Stepper) then
					if x<sz.width/2 then
						self.sliderhoverstate=-1						
					else
						self.sliderhoverstate=1
					end					
				else
					if x<self.sliderwidth*scale then
						self.sliderhoverstate=-1
					elseif x>sz.width-self.sliderwidth*scale then
						self.sliderhoverstate=1
					end
				end
			end			
		end
	end
	if prevhoverstate~=self.sliderhoverstate or prevknobhoveredstate~=self.knobhoveredstate then
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
	local state = self.widget:GetSliderValue()
	self.focused=true
	if button==Mouse.Left then
		local style = self.style--self.widget:GetStyle()
		local scale = self.widget:GetGUI():GetScale()
		local sz = self.widget:GetSize(true)
		if x>0 and y>0 and x<sz.width and y<sz.height then
			if self.layout=="Vertical" then--self:bitand(style,Style.Slider.Horizontal)==false then
				if self.style=="Stepper" then--self:bitand(style,Style.Slider.Stepper)==true then					
					if y<sz.height/2 then
						self.arrowpressed=-1
						self:MouseWheel(-1)
						self.widget:Redraw()
					else
						self.arrowpressed=1
						self:MouseWheel(1)
						self.widget:Redraw()
					end
					return
				elseif self.style=="Trackbar" then--self:bitand(style,Style.Slider.Trackbar)==true then
					if x>(sz.width-self.knobwidth*scale)/2 and x<(sz.width+self.knobwidth*scale)/2 then
						local kh = self.trackbarknobsize*scale
						local ky = self.widget:GetSliderValue() / (self.widget:GetRange().y-1) * (sz.height - self.trackbarknobsize*scale) - self.trackbarknobsize*scale/2 + kh/2									
						if y<ky then
							--Step up
							self:MouseWheel(-1)
						elseif y>ky+kh then
							--Step down
							self:MouseWheel(1)
						else
							--Grab thew slider knob
							self.knobgrabbed=true
							self.knobgrabposition = y - ky + kh/2
						end
					end
				else
					if y<self.sliderwidth*scale then
						self.arrowpressed=-1
						self:MouseWheel(-1)
						self.widget:Redraw()
					elseif y>sz.height - self.sliderwidth*scale then
						self.arrowpressed=1
						self:MouseWheel(1)
						self.widget:Redraw()
					else
						local knob = self:GetKnobArea()			
						if y-self.sliderwidth*scale<knob.position then
							--Move the knob up
							--self:SetValue(self.widget:GetSliderValue() - knob.size / (sz.height - self.sliderwidth*scale*2) * self.widget:GetRange().y)
							--self:SetValue(math.max(self.widget:GetSliderValue(),0))
							--self.widget:Redraw()
							self:MouseWheel(-3)
						elseif y-self.sliderwidth*scale>knob.position + knob.size then
							--Move the knob down
							--self:SetValue(self.widget:GetSliderValue() + knob.size / (sz.height - self.sliderwidth*scale*2) * self.widget:GetRange().y)
							--self:SetValue(math.min(self.widget:GetSliderValue(),self.widget:GetRange().y-self.widget:GetRange().x))
							--self.widget:Redraw()
							self:MouseWheel(3)
						else
							--Grab thew slider knob							
							self.knobgrabbed=true
							self.knobgrabposition = y - knob.position				
						end
					end
				end
			else
				if self.style=="Stepper" then--self:bitand(style,Style.Slider.Stepper)==true then
					if x<sz.width/2 then
						self.arrowpressed=-1
						self:MouseWheel(-1)
						self.widget:Redraw()
					else
						self.arrowpressed=1
						self:MouseWheel(1)
						self.widget:Redraw()
					end
					return
				elseif self.style=="Trackbar" then--self:bitand(style,Style.Slider.Trackbar)==true then
					if y>(sz.height-self.knobwidth*scale)/2 and y<(sz.height+self.knobwidth*scale)/2 then
						local kw = self.trackbarknobsize*scale
						local kx = self.widget:GetSliderValue() / (self.widget:GetRange().y-1) * (sz.width - self.trackbarknobsize*scale) - self.trackbarknobsize*scale/2 + kw/2									
						if x<kx then
							--Step up
							self:MouseWheel(-1)
						elseif x>kx+kw then
							--Step down
							self:MouseWheel(1)
						else
							--Grab thew slider knob
							self.knobgrabbed=true
							self.knobgrabposition = x - kx + kw/2
						end
					end
				else
					if x<self.sliderwidth*scale then
						self.arrowpressed=-1
						self:MouseWheel(-1)
						self.widget:Redraw()
						return
					elseif x>sz.width - self.sliderwidth*scale then
						self.arrowpressed=1
						self:MouseWheel(1)
						self.widget:Redraw()
						return
					else
						local knob = self:GetKnobArea()	
						if x-self.sliderwidth*scale<knob.position then
							--Move the knob left
							self:MouseWheel(-3)							
							--self:SetValue(self.widget:GetSliderValue() - knob.size / (sz.width - self.sliderwidth*scale*2) * self.widget:GetRange().y)
							--self:SetValue(math.max(self.widget:GetSliderValue(),0))
							self.widget:Redraw()
						elseif x-self.sliderwidth*scale>knob.position + knob.size then
							--Move the knob right
							self:MouseWheel(3)	
							--self:SetValue(self.widget:GetSliderValue() + knob.size / (sz.width - self.sliderwidth*scale*2) * self.widget:GetRange().y)
							--self:SetValue(math.min(self.widget:GetSliderValue(),self.widget:GetRange().y-self.widget:GetRange().x))
							self.widget:Redraw()						
						else
							--Grab thew slider knob
							self.knobgrabbed=true
							self.knobgrabposition = x - knob.position			
						end
					end
				end
			end
		end
	end
	if self.widget:GetSliderValue()~=state then
		EventQueue:Emit(Event.WidgetAction,self.widget,self.widget:GetSliderValue())
	end
end

function Script:bitand(set, flag)
	return set % (2*flag) >= flag
end

function Script:KeyDown(button)
	local state = self.widget:GetSliderValue()
	--local style = self.style--self.widget:GetStyle()
	if button==Key.Right or button==Key.Down then--(button==Key.Right and self:bitand(style,Style.Slider.Horizontal)==true) or (button==Key.Down and self:bitand(style,Style.Slider.Horizontal)==false) then
		self:SetValue(self.widget:GetSliderValue() + self.sliderincrements)
		self:SetValue(math.min(self.widget:GetSliderValue(),self.widget:GetRange().y-self.widget:GetRange().x))
	end
	if button==Key.Left or button==Key.Up then--(button==Key.Left and self:bitand(style,Style.Slider.Horizontal)==true) or (button==Key.Up and self:bitand(style,Style.Slider.Horizontal)==false) then
		self:SetValue(self.widget:GetSliderValue() - self.sliderincrements)
		self:SetValue(math.max(self.widget:GetSliderValue(),0))
	end
	if self.widget:GetSliderValue()~=state then
		self.widget:Redraw()
		EventQueue:Emit(Event.WidgetAction,self.widget,self.widget:GetSliderValue())
	end
end
