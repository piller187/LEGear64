--Styles
if Style==nil then Style={} end
if Style.Button==nil then Style.Button={} end
Style.Button.Push=8
Style.Button.Checkbox=2
Style.Button.Radio=3
Style.Button.OK=4
Style.Button.Cancel=5
Style.Button.Link=6
--Style.Button.Label=16

--Default values
Script.pushed=false
Script.hovered=false
Script.textindent=4
Script.checkboxsize=14
Script.checkboxindent=5
Script.radius=3

function Script:GetState()
	return self.widget:GetState()
end

function Script:OK()
	--EventQueue:Emit(Event.WidgetAction,self.widget)
end

function Script:Cancel()
	--EventQueue:Emit(Event.WidgetAction,self.widget)
end

function Script:Draws(x,y,width,height)
	local gui = self.widget:GetGUI()	
	local scale = gui:GetScale()	
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	gui:SetColor(1,0,0.1)
	gui:DrawRect(pos.x,pos.y+(sz.height-self.checkboxsize*scale)/2,self.checkboxsize*scale,self.checkboxsize*scale,0)
end

function Script:Draw(x,y,width,height)
	--System:Print("Paint Button")
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	local style = self.style--self.widget:GetStyle()
	local text = self.widget:GetText()
	
	--Background
	--gui:SetColor(0.2)
	--gui:DrawRect(pos.x,pos.y,sz.width,sz.height)
	
	if self.style=="Link" then
		--Draw text
		if text~="" then
			--if self.widget:GetParent()==gui:GetBase() then
			--	gui:SetColor(0,0,0,0)		
			--	gui:Clear()-- clear the alpha channel
			--end
			gui:SetColor(1,1,1,0.9)
			if self.hovered then
				gui:SetColor(1,1,1,1)
			end
			gui:DrawText(text,pos.x,pos.y,sz.width,sz.height)--,Text.Center + Text.VCenter)
		end
	
	elseif self.style=="Link" then
		--Draw text
		if text~="" then
			--gui:SetColor(0,0,0,0)		
			--gui:Clear()-- clear the alpha channel
			--gui:SetColor(1,1,1,0.7)
			gui:SetColor(51/255/1,151/255/1,1/1,1)
			gui:DrawText(text,pos.x,pos.y,sz.width,sz.height)--,Text.Center + Text.VCenter)
			if self.hovered then
				gui:DrawLine(pos.x,pos.y+gui:GetFontHeight()+1*scale,pos.x+gui:GetTextWidth(text),pos.y+gui:GetFontHeight()+1*scale)
			end
		end

	elseif self.style=="Checkbox" then--self:And(style,Style.Button.Checkbox)==true and self:And(style,Style.Button.Push)==false then
		
		--Checkbox style
		if self.pushed then
			gui:SetColor(0.1,0.1,0.1)
		else
			gui:SetColor(0.15,0.15,0.15)
		end
		gui:DrawRect(pos.x,pos.y+(sz.height-self.checkboxsize*scale)/2,self.checkboxsize*scale,self.checkboxsize*scale,0)
		--if self.hovered then
		--	gui:SetColor(51/255,151/255,1)
		--else
			gui:SetColor(0,0,0)
		--end
		gui:DrawRect(pos.x,pos.y+(sz.height-self.checkboxsize*scale)/2,self.checkboxsize*scale,self.checkboxsize*scale,1)

		--Draw text
		if text~="" then
			gui:SetColor(0,0,0,1)
			gui:DrawText(text,pos.x+self.checkboxsize*scale+self.textindent*scale+1,pos.y,sz.width-(self.checkboxsize*scale+1+self.textindent*scale),sz.height,Text.VCenter)
			gui:SetColor(0.7,0.7,0.7,1)
			gui:DrawText(text,pos.x+self.checkboxsize*scale+self.textindent*scale,pos.y,sz.width-(self.checkboxsize*scale+self.textindent*scale),sz.height,Text.VCenter)
		end				

		if self.widget:GetState() then
			if self.hovered then
				gui:SetColor(1,1,1)
			else
				gui:SetColor(0.7,0.7,0.7)
			end
			gui:DrawRect(pos.x+self.checkboxindent*scale,pos.y+(sz.height-self.checkboxsize*scale)/2+self.checkboxindent*scale,(self.checkboxsize-2*self.checkboxindent)*scale,(self.checkboxsize-2*self.checkboxindent)*scale,0)
		end

	elseif style=="Radio" then--self:And(style,Style.Button.Radio)==true and self:And(style,Style.Button.Push)==false then
		
		--Radio button style
		
	
	else

		--Push button style
		if self.pushed==true or self.widget:GetState() then
			gui:SetColor(0.15,0.15,0.15)
		else
			--if self.hovered then
			--	gui:SetColor(0.27,0.27,0.27)
			--else
				gui:SetColor(0.2,0.2,0.2)				
			--end
		end
		gui:SetColor(0.2,0.2,0.2,1.0,1)
		
		--[[if self:And(style,Style.Button.OK) then
			if self.pushed==true or self.widget:GetState()==Widget.SelectedState then
				gui:SetColor(51/255*0.6, 151/255*0.6, 1*0.6, 1, 0)
				gui:SetColor(51/255*0.6*0.75, 151/255*0.6*0.75, 1*0.6*0.75, 1, 1)
			else
				if self.hovered then
					gui:SetColor(51/255*0.6*1.1, 151/255*0.6*1.1, 1*0.6*1.1, 1, 0)
					gui:SetColor(51/255*0.6*0.75*1.1, 151/255*0.6*0.75*1.1, 1*0.6*0.75*1.1, 1, 1)
				else
					gui:SetColor(51/255*0.6, 151/255*0.6, 1*0.6, 1, 0)
					gui:SetColor(51/255*0.6*0.75, 151/255*0.6*0.75, 1*0.6*0.75, 1, 1)
				end
			end
		end]]
		
		gui:SetGradientMode(true)	
		gui:DrawRect(pos.x,pos.y,sz.width,sz.height,0,scale*self.radius)
		gui:SetGradientMode(false)
		
		if self.pushed==true or self.widget:GetState() then
			gui:SetColor(0.0,0.0,0.0)
		else
			gui:SetColor(0.75,0.75,0.75)
		end
		
		if self.pushed==true or self.widget:GetState() then
			gui:SetColor(0.75,0.75,0.75)
		else
			gui:SetColor(0.0,0.0,0.0)		
		end
		
		if self.hovered then
			gui:SetColor(51/255,151/255,1)
		else
			gui:SetColor(0,0,0)
		end
		gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1,scale*self.radius)
		
		--Draw image if present
		local image = self.widget:GetImage()
		if image~=nil then
			local imgsz = image:GetSize()
			gui:SetColor(0.7)
			gui:DrawImage(image,pos.x+(sz.x-imgsz.x)/2,pos.y+(sz.y-imgsz.y)/2)
		end		
		
		if text~="" then
			gui:SetColor(0.0,0.0,0.0)
			if self.pushed then
				--gui:DrawText(text,pos.x+scale+scale,pos.y+scale+scale,sz.width,sz.height,Text.Center+Text.VCenter)	
			else
				--gui:DrawText(text,pos.x+scale,pos.y+scale,sz.width,sz.height,Text.Center+Text.VCenter)	
			end

			--gui:SetColor(0,0,0)
			--gui:DrawText(text,1+pos.x,1+pos.y,sz.width,sz.height,Text.Center+Text.VCenter)	
			gui:SetColor(0.7,0.7,0.7)

--gui:SetColor(Math:Random(),Math:Random(),Math:Random())

			if self.pushed then
				gui:DrawText(text,pos.x+scale,pos.y+scale,sz.width,sz.height,Text.Center+Text.VCenter)	
			else
				gui:DrawText(text,pos.x,pos.y,sz.width,sz.height,Text.Center+Text.VCenter)	
			end
		end
		
	end
end

function Script:MouseEnter(x,y)
	self.hovered = true
	self.widget:Redraw()
end

function Script:MouseLeave(x,y)
	self.hovered = false
	self.widget:Redraw()
end

function Script:MouseDown(button,x,y)
	if button==Mouse.Left then
		self.pushed=true
		--local style = self.widget:GetStyle()
		self.widget:Redraw()
	end
end

function Script:And(set, flag)
	return set % (2*flag) >= flag
end

function Script:MouseUp(button,x,y)
	if button==Mouse.Left then
		local gui = self.widget:GetGUI()
		self.pushed=false
		if self.hovered then
			if self.style=="Checkbox" then
				self.widget:SetState(not self.widget:GetState())
			end
			EventQueue:Emit(Event.WidgetAction,self.widget)
		end
		self.widget:Redraw()
	end
end

function Script:KeyDown(keycode)
	if keycode==Key.Enter then
		if self.style=="Checkbox" then
			self.widget:SetState(not self.widget:GetState())
		end
		EventQueue:Emit(Event.WidgetAction,self.widget)
		self.widget:Redraw()
	end
end
