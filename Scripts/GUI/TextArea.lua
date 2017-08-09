Script.caretposition=0
Script.sellen=0
Script.doubleclickrange = 1
Script.doubleclicktime = 500
Script.textindent = 4
Script.text=""
Script.currentline = 1
Script.linespacing = 1.0
Script.sellines=1
Script.sliderwidth = 22
Script.maxlinewidth=0

function Script:Start()
	self.lines={}
	self.slider={}
	self.linewidth={}
	
	local sz = self.widget:GetSize(true)
	local scale = self.widget:GetGUI():GetScale()
	
	self.size = self.widget:GetSize(true)
	
	--Vertical slider
	self.slider[0] = Widget:Slider(sz.width-self.sliderwidth*scale,0,self.sliderwidth,sz.height--[[-self.sliderwidth]],self.widget)
	--self.slider[0]:SetScript("Scripts/GUI/Slider.lua")
	--self.slider[0]:SetStyle(Style.Slider.Vertical + Style.Slider.Scrollbar)
	self.slider[0]:SetString("layout","Vertical")
	self.slider[0]:SetAlignment(0,1,1,1)
	self.slider[0]:Hide()
	self.slider[0].script.owner = self
	
	--Horizontal slider
	self.slider[1] = Widget:Slider(0,sz.height-self.sliderwidth*scale,sz.width-self.sliderwidth,self.sliderwidth,self.widget)
	--self.slider[1]:SetScript("Scripts/GUI/Slider.lua")
	--self.slider[1]:SetStyle(Style.Slider.Horizontal + Style.Slider.Scrollbar)
	self.slider[1]:SetAlignment(1,1,0,1)
	self.slider[1]:Hide()
	self.slider[1].script.owner = self
end

function Script:UpdateSlider(widget)
	self.widget:Redraw()
end

function Script:AddText(text)
	self.updateslidersneeded=true
	local morelines = text:split("\n")
	local gui=self.widget:GetGUI()
	local n
	for n=1,#morelines do
		self.lines[#self.lines+1] = morelines[n]
		self.linewidth[#self.lines] = gui:GetTextWidth(morelines[n])
		self.maxlinewidth = math.max(self.maxlinewidth,self.linewidth[#self.lines])
	end
end

function Script:SetText(text)
	self.updateslidersneeded=true
	self.maxlinewidth = 0
	local n
	local lines = {}
	if text~="" then
		lines = text:split("\n")
		for n=1,#lines do
			self:AddText(lines[n])
			--self.linewidth[n] = self.widget:GetGUI():GetTextWidth(self.lines[n])
			--self.maxlinewidth = math.max(self.maxlinewidth,self.linewidth[n])
		end
	end
end

function Script:GetGlobalCharPos(chr,line)
	local n	
	for n=1,line-1 do
		chr = chr + string.len(self.lines[n])+1
	end
	return chr
end

function Script:GetLocalCharPos(chr)
	local n
	local line = self:GetCharLine(chr)
	for n=1,line-1 do
		chr = chr - (string.len(self.lines[n])+1)
	end
	return chr
end

function string:split( inSplitPattern )
  local outResults = { }
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end

function Script:GetLineChars(l)
	if l==nil then l=self.currentline end
	if l<1 then return 0 end
	if l>#self.lines then return 0 end
	return string.len(self.lines[l])
end

function Script:GetCaretPosition(global)
	if global then
		return self:GetGlobalCharPos(self.caretposition,self.currentline)	
	else
		return self.caretposition
	end
end

function Script:SetCaretPosition(pos,global)
	pos = math.max(pos,0)
	if global then
		self.caretposition = self:GetLocalCharPos(pos)
		self.currentline = self:GetCharLine(pos)		
	else
		self.caretposition = pos
	end
	self.caretposition = math.min(self.caretposition,string.len(self.lines[self.currentline]))
	self:UpdateSliders()
end

function Script:GetCharLine(chr)
	local n
	local count=0
	for n=1,#self.lines do
		count = count + string.len(self.lines[n])+1
		if count>chr then
			return n
		end
	end
	return #self.lines
end

function Script:Draw(x,y,width,height)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local line
	
	if sz~=self.size or self.updateslidersneeded==true then
		self:UpdateSliders(false)
	end
	
	local scale = gui:GetScale()
	
	if self.slider[0]==nil or self.slider[1]==nil then return end

	if not self.slider[0]:Hidden() then
		sz.width = sz.width - scale * self.sliderwidth-1
	end
	if not self.slider[1]:Hidden() then
		sz.height = sz.height - scale * self.sliderwidth-1
	end
	
	--local cliprect = gui:GetClipRegion()
	gui:SetClipRegion(pos.x,pos.y,sz.width,sz.height)

	local item = self.widget:GetSelectedItem()
	local text-- = self.widget:GetText()
	local n,s
	local lineheight = gui:GetLineHeight()*self.linespacing
	local lh = gui:GetLineHeight()
	local caretheight = lineheight--gui:GetFontHeight()--+2*scale
	local gcaret = self:GetGlobalCharPos(self.caretposition,self.currentline)
	local selend = gcaret + self.sellen
	local selstartline,firstline,lastline
	if selend~=gcaret then
		selstartline = self:GetCharLine(selend)
		firstline = math.min(selstartline,self.currentline)
		lastline = math.max(selstartline,self.currentline)
	end
	local firstvisibleline = math.floor(self.slider[0]:GetSliderValue() / lineheight)
	local firstvisibleline = math.min(firstvisibleline,#self.lines)
	local firstvisibleline = math.max(firstvisibleline,1)
	local lastvisibleline = math.ceil((self.slider[0]:GetSliderValue() + sz.height) / lineheight)
	local lastvisibleline = math.min(lastvisibleline,#self.lines)
	local lastvisibleline = math.max(lastvisibleline,1)

	--self:UpdateOffset()
	
	--Draw the widget background
	gui:SetColor(0.1,0.1,0.1)
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,0)
	
	gui:GetFontHeight()
	
	text = self.lines[self.currentline]
	
	--Draw text selection background
	if self.sellen~=0 then		
		local c1 = math.min(gcaret,gcaret+self.sellen)
		local c2 = math.max(gcaret,gcaret+self.sellen)
		c1 = self:GetLocalCharPos(c1)
		c2 = self:GetLocalCharPos(c2)
		for line=math.max(firstline,firstvisibleline),math.min(lastvisibleline,lastline) do
			local x = gui:GetScale()*self.textindent
			local y = (line-1) * lineheight + self.textindent * scale
			local px = x
			local fragment		
			local linetext = self.lines[line]
			local linelen = string.len(linetext)
			if firstline==lastline then
				local prefix = String:Left(linetext,c1)			
				px = px + gui:GetTextWidth(prefix)
				fragment = String:Mid(linetext,c1,c2-c1)
			else
				if line==firstline then
					fragment = String:Right(linetext,linelen-c1)
					local prefix = String:Left(linetext,c1)
					px = px + gui:GetTextWidth(prefix)
				elseif line==lastline then
					fragment = String:Left(linetext,c2)
				else
					fragment = self.lines[line]
				end
			end			
			local w = gui:GetTextWidth(fragment)
			--if self.focused then
			--	gui:SetColor(51/255/2,151/255/2,1/2)
			--else
				gui:SetColor(0.4,0.4,0.4)
			--end
			gui:DrawRect(pos.x + px + self.slider[1]:GetSliderValue()*-1*scale, -1*scale+ self.slider[0]:GetSliderValue()*-1+pos.y + y+(lh-caretheight)/2,w,caretheight,0)
		end
	end
	
	--System:Print("")
	--Draw text
	gui:SetColor(0.75,0.75,0.75)
	local ty = 0
	--for n,s in ipairs(self.lines) do
	for line=firstvisibleline,lastvisibleline do
		s = self.lines[line]
		ty = (line-1) * lineheight + self.textindent * scale
		gui:DrawText(s,scale * self.textindent + pos.x+self.slider[1]:GetSliderValue()*-1,self.slider[0]:GetSliderValue()*-1+pos.y+ty,math.max(sz.width,sz.width-self.slider[1]:GetSliderValue()*-1),sz.height,Text.Left)
		--ty = ty + lineheight
	end
	
	--Draw the caret
	if self.cursorblinkmode then
		if self.focused then
			local x = self:GetCaretCoord()
			local y = (self.currentline-1) * lineheight + self.textindent * scale *0.5
			gui:DrawLine(pos.x + x + self.slider[1]:GetSliderValue()*-1,1*scale+self.slider[0]:GetSliderValue()*-1+pos.y+y + (lh-caretheight)/2,pos.x + x + self.slider[1]:GetSliderValue()*-1,self.slider[0]:GetSliderValue()*-1+pos.y+y + (lh+caretheight)/2 + 1*scale)
		end
	end
	
	--Draw the widget outline
	--if self.hovered==true then
	--	gui:SetColor(51/255/4,151/255/4,1/4)
	--else
		gui:SetColor(0,0,0)
	--end
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)

end

function Script:GetLineAtPosition(y)
	local gui = self.widget:GetGUI()
	local lineheight = gui:GetLineHeight()*self.linespacing
	local l = 1 + math.floor(y / lineheight)
	l = math.max(1,l)
	l = math.min(l,#self.lines)
	return l
end

--Find the character position for the given x coordinate
function Script:GetCharAtPosition(px,py,clickonchar)	
	local gui = self.widget:GetGUI()
	local n
	local c
	local x = gui:GetScale()*self.textindent
	local l
	if py==nil then
		l = self.currentline
	else
		l = self:GetLineAtPosition(py)
	end
	local text = self.lines[l]
	local count = string.len(text)
	local lastcharwidth=0
	for n=0,count-1 do
		c = String:Mid(text,n,1)
		lastcharwidth = gui:GetTextWidth(c)
		if clickonchar then
			if x >= px then return n,l end
		else
			if x >= px - lastcharwidth/2 then return n,l end
		end
		x = x + lastcharwidth
	end
	return count,l
end

--Get the x coordinate of the current caret position
function Script:GetCaretCoord(caret)
	if caret==nil then caret = self.caretposition end
	local text = self.lines[self.currentline]--self.widget:GetText()
	local gui = self.widget:GetGUI()
	local n
	local c
	local x = gui:GetScale() * self.textindent
	local count = math.min(caret-1,(string.len(text)-1))
	for n=0,count do
		c = String:Mid(text,n,1)
		x = x + gui:GetTextWidth(c)
	end
	return x
end

--Blink the caret cursor on and off
function Script:CursorBlink()
	if self.cursorblinkmode == nil then
		self.cursorblinkmode = false
	end
	self.cursorblinkmode = not self.cursorblinkmode
	self.widget:Redraw()
end

function Script:TripleClick(button,x,y)
	if button==Mouse.Left then
	
		if #self.lines==0 then return end
		y = y - self.textindent * self.widget:GetGUI():GetScale()
		y = y - self.slider[0]:GetSliderValue()*-1
		self.currentline = self:GetLineAtPosition(y)
		self.caretposition = string.len(self.lines[self.currentline])
		self:UpdateSliders()
		self.sellen = -self.caretposition
		self.widget:Redraw()
	end
end

function Script:MouseWheel(delta)
	if self.slider[0]~=nil then
		self.slider[0].script:MouseWheel(delta)
	end
end

function Script:DoubleClick(button,x,y)
	if button==Mouse.Left then
	
		if #self.lines==0 then return end
	
		x = x - self.slider[1]:GetSliderValue()*-1
		y = y - self.slider[0]:GetSliderValue()*-1
		y = y - self.textindent * self.widget:GetGUI():GetScale()

		--if math.abs(self.lastmouseposition.x-x)<=self.doubleclickrange and math.abs(self.lastmouseposition.y-y)<=self.doubleclickrange then
			
			--Select the word at the mouse position
			local text = self.lines[self.currentline]--self.widget:GetText()
			local l = string.len(text)
			local c = self:GetCharAtPosition(x,y,true)
			self.caretposition = c
			self.sellen = -1
			
			if String:Mid(text,c-1,1)==" " then
				
				--Select spaces in this word before the clicked character
				for n = c-2, 0, -1 do
					if String:Mid(text,n,1)~=" " then
						break
					else
						self.sellen = self.sellen - 1
					end
				end
				
				--Select spaces in this word after the clicked character
				for n = c, l-1 do
					if String:Mid(text,n,1)~=" " then
						break
					else
						self.caretposition = self.caretposition + 1
						self.sellen = self.sellen - 1
					end	
				end						
				
			else
				
				--Select characters in this word before the clicked character
				for n = c-2, 0, -1 do
					if String:Mid(text,n,1)==" " then
						break
					else
						self.sellen = self.sellen - 1
					end
				end
				
				--Select characters in this word after the clicked character
				for n = c, l-1 do
					if String:Mid(text,n,1)==" " then
						break
					else
						self.caretposition = self.caretposition + 1
						self.sellen = self.sellen - 1
					end	
				end
				
			end
			
			self.widget:GetGUI():ResetCursorBlink()
			self.cursorblinkmode=true
			self.pressed=false
			self:UpdateSliders()
			self.widget:Redraw()
			
		--end		
	end
end

function Script:MouseDown(button,x,y)
	self.focused=true
	self.preferredxcaretposition=nil
	local scale = self.widget:GetGUI():GetScale()

	if button==Mouse.Left then	
	
		if #self.lines==0 then return end
	
		x = x - self.slider[1]:GetSliderValue()*-1
		y = y - self.slider[0]:GetSliderValue()*-1
		y = y - self.textindent*scale		

		--Detect double-click
		--[[local currenttime = Time:Millisecs()
		if self.lastmousehittime~=nil then
			if math.abs(self.lastmouseposition.x-x)<=self.doubleclickrange and math.abs(self.lastmouseposition.y-y)<=self.doubleclickrange then
				if currenttime - self.lastmousehittime < self.doubleclicktime then
					self.lastmousehittime = currenttime
					
					--Select the word at the mouse position
					local text = self.widget:GetText()
					local l = string.len(text)
					local c = self:GetCharAtPosition(x,true)
					self.caretposition = c
					self.sellen = -1
					
					if String:Mid(text,c-1,1)==" " then
						
						--Select spaces in this word before the clicked character
						for n = c-2, 0, -1 do
							if String:Mid(text,n,1)~=" " then
								break
							else
								self.sellen = self.sellen - 1
							end
						end
						
						--Select spaces in this word after the clicked character
						for n = c, l-1 do
							if String:Mid(text,n,1)~=" " then
								break
							else
								self.caretposition = self.caretposition + 1
								self.sellen = self.sellen - 1
							end	
						end						
						
					else
						
						--Select characters in this word before the clicked character
						for n = c-2, 0, -1 do
							if String:Mid(text,n,1)==" " then
								break
							else
								self.sellen = self.sellen - 1
							end
						end
						
						--Select characters in this word after the clicked character
						for n = c, l-1 do
							if String:Mid(text,n,1)==" " then
								break
							else
								self.caretposition = self.caretposition + 1
								self.sellen = self.sellen - 1
							end	
						end
						
					end
					
					self.widget:GetGUI():ResetCursorBlink()
					self.cursorblinkmode=true
					self.pressed=false
					self.widget:Redraw()
					return
					
				end
			end
		end]]
		
		self.lastmouseposition = {}
		self.lastmouseposition.x = x
		self.lastmouseposition.y = y
		self.lastmousehittime = currenttime
		--self.currentline = self:GetLineAtPosition(y)
		
		--Position caret under mouse click
		local prevcaret = self:GetCaretPosition(true)
		if self.shiftpressed then
			if self.preferredcaret~=nil then
				prevcaret = self.preferredcaret
			end
		end
		local c0 = math.min(prevcaret + self.sellen)
		local c1 = math.max(prevcaret + self.sellen)
		self.cursorblinkmode=true
		self.caretposition, self.currentline = self:GetCharAtPosition(x,y)
		gcaret = self:GetCaretPosition(true)		
		self.widget:GetGUI():ResetCursorBlink()
		self.cursorblinkmode=true
		self.pressed=true
		if self.shiftpressed then
			self.sellen = prevcaret - gcaret
		else
			self.sellen=0
			self.preferredcaret = gcaret
		end
		self:UpdateSliders()
		self.widget:Redraw()
	elseif button==Mouse.Right then	
		EventQueue:Emit(Event.WidgetMenu,self.widget,0,x,y)
	end
end

function Script:MouseUp(button,x,y)
	if button==Mouse.Left then
		self.pressed=false
	end
end

function Script:GetSelectedText(line)
	if lin==nil then
		line = self.currentline
	end
	if self.sellen==0 then return "" end
	local c1 = math.min(self.caretposition,self.caretposition+self.sellen)
	local c2 = math.max(self.caretposition,self.caretposition+self.sellen)
	local linelength = self:GetLineChars(line)
	c1 = math.max(0,c1)
	c2 = math.min(c2,linelength)
	return String:Mid(self.lines[line],c1,c2-c1)
	--return String:Mid(self.widget:GetText(),c1,c2-c1)
end

function Script:UpdateSliders(framecaret)
	self.updateslidersneeded=false
	if framecaret==nil then framecaret=true end
	local sz = self.widget:GetSize(true)
	local width = sz.width
	local height = sz.height
	local text = self.lines[self.currentline]--self.widget:GetText()
	local gui = self.widget:GetGUI()
	local scale = gui:GetScale()
	local c = String:Right(text,1)
	local cw = gui:GetTextWidth(c)
	local tw = gui:GetTextWidth(text)
	local lh = gui:GetLineHeight()*self.linespacing
	local showscrollbar0 = false
	local showscrollbar1 = false
	lsz = self.widget:GetSize(false)
	
	if #self.lines * lh > height then
		width = width - scale * self.sliderwidth
		lsz.width = lsz.width - self.sliderwidth
		showscrollbar0 = true
	end
	if self.maxlinewidth>width then	
		height = height - scale * self.sliderwidth
		lsz.height = lsz.height - self.sliderwidth
		showscrollbar1 = true
	end
	if not showscrollbar0 then
		if #self.lines * lh > height then
			width = width - scale * self.sliderwidth
			lsz.width = lsz.width - self.sliderwidth
			showscrollbar0 = true
		end
	end
	
	self.slider[0].script.sliderincrements=lh
	
	--[[if tw + scale * self.textindent * 2 > width then
		local fragment = self:GetSelectedText()
		local fw = gui:GetTextWidth(fragment)
		if fw + scale * self.textindent * 2 > width then
			local coord = self:GetCaretCoord()
			if self.slider[1]:GetSliderValue()*-1 + coord - scale * self.textindent < 0 then
				self.slider[1]:SetSliderValue((-coord + scale * self.textindent)*-1)
			elseif self.slider[1]:GetSliderValue()*-1 + coord > width - scale * self.textindent then
				self.slider[1]:SetSliderValue((-(coord - (width - scale * self.textindent)))*-1)
			end
		else
			local c1 = math.min(self.caretposition,self.caretposition+self.sellen)
			local c2 = math.max(self.caretposition,self.caretposition+self.sellen)
			coord1 = self:GetCaretCoord(c1)
			coord2 = self:GetCaretCoord(c2)
			if self.slider[1]:GetSliderValue()*-1 + coord1 - scale * self.textindent < 0 then
				self.slider[1]:SetSliderValue((-coord1 + scale * self.textindent)*-1)
			elseif self.slider[1]:GetSliderValue()*-1 + coord2 > width - scale * self.textindent then
				self.slider[1]:SetSliderValue((-(coord2 - (width - scale * self.textindent)))*-1)
			end
		end
		if self.slider[1]:GetSliderValue()*-1 + tw < width - scale * self.textindent * 2 then
			self.slider[1]:SetSliderValue( (width - tw - scale * self.textindent * 2)*-1 )
		end
	else
		self.slider[1]:SetSliderValue(0)
	end]]
	
	local textheight = #self.lines * lh+self.textindent*scale
	
	--Vertical scrolling	
	local visiblelines = math.floor(height / lh)
	if showscrollbar0 then--#self.lines * lh > sz.height then
		self.slider[0]:SetRange(height,#self.lines*lh+self.textindent*scale*2)
		if framecaret then
			if self.currentline * lh+self.textindent*scale - self.slider[0]:GetSliderValue()>height then
				self.slider[0]:SetSliderValue(-height + self.currentline * lh+self.textindent*scale)
			elseif (self.currentline-1) * lh --[[+self.textindent*scale]] - self.slider[0]:GetSliderValue() < 0 then
				self.slider[0]:SetSliderValue((self.currentline-1) * lh )--+self.textindent*scale
			end
		end
		if textheight - self.slider[0]:GetSliderValue() < height then
			self.slider[0]:SetSliderValue(textheight - height)
		end
		self.slider[0]:SetLayout(lsz.width,0,self.sliderwidth,lsz.height)			
		self.slider[0]:Show()
	else
		self.slider[0]:SetSliderValue(0)
		--self.slider[0]:Disable()
		self.slider[0]:Hide()
	end
	
	--Horizontal scrolling
	local lh = gui:GetLineHeight()*self.linespacing
	if showscrollbar1 then--self.maxlinewidth>sz.width then
		if framecaret then
			if self:GetCaretCoord()-self.slider[1]:GetSliderValue()>width then
				self.slider[1]:SetSliderValue( self:GetCaretCoord() - width)
			elseif self:GetCaretCoord()-self.slider[1]:GetSliderValue() < 0 then
				self.slider[1]:SetSliderValue(self:GetCaretCoord())
			end
		end
		if self.maxlinewidth + gui:GetScale()*self.textindent*2 - self.slider[1]:GetSliderValue() < width then
			self.slider[1]:SetSliderValue(self.maxlinewidth + gui:GetScale()*self.textindent*2 - width)
		end
		self.slider[1]:SetRange(width,self.maxlinewidth+gui:GetScale()*self.textindent*2)
		self.slider[1]:SetLayout(0,lsz.height,lsz.width,self.sliderwidth)
		self.slider[1]:Show()
		--self.slider[1]:Enable()
	else
		self.slider[1]:SetSliderValue(0)
		--self.slider[1]:Disable()
		self.slider[1]:Hide()
	end
end

function Script:MouseMove(x,y)
	if self.pressed then
		local scale = self.widget:GetGUI():GetScale()
		
		--Select range of characters
		x = x - self.slider[1]:GetSliderValue()*-1
		y = y - self.slider[0]:GetSliderValue()*-1
		y = y - self.textindent*scale

		local currentcaretpos = self.caretposition
		local prevcaretpos = self.caretposition
		local prevgcaret = self:GetGlobalCharPos(prevcaretpos,self.currentline) + self.sellen
		local prevcaretline = self:GetCharLine(prevgcaret)
		self.cursorblinkmode=true
		self.caretposition, self.currentline = self:GetCharAtPosition(x,y)
		--if self.caretposition ~= prevcaretpos or self.currentline~=prevcaretline then
			local gcaret = self:GetGlobalCharPos(self.caretposition,self.currentline)
			self.sellen = prevgcaret - gcaret
			self.widget:GetGUI():ResetCursorBlink()
			self.cursorblinkmode=true
			self:UpdateSliders()
			self.widget:Redraw()
		--end
	end
end

function Script:GainFocus()
	self.focused = true
end

function Script:LoseFocus()
	self.focused=false
	--self.sellen=0
	self.widget:Redraw()
	local s = self.lines[self.currentline]--self.widget:GetText()
	if self.text~=s then
		EventQueue:Emit(Event.WidgetAction,self.widget)
		self.text=s
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

function Script:KeyUp(keycode)
	if keycode==Key.Shift then
		self.shiftpressed=false
	end
end

function Script:KeyDown(keycode)
	if keycode==Key.Shift then
		self.shiftpressed=true
	end
	if keycode==Key.Up or keycode==Key.Down then
		local prevgcaret = self:GetCaretPosition(true)
		local prevline = self.currentline
		
		if self.preferredxcaretposition==nil then
			self.preferredxcaretposition = self:GetCaretCoord()
			--self.preferredcaret = self:GetCaretPosition(true)
		end
		
		if keycode==Key.Up then
			if self.currentline<2 then
				--Move caret all the way to the left
				self.caretposition = 0
			else
				--Move caret to previous line
				self.currentline = self.currentline - 1
				self.caretposition = self:GetCharAtPosition(self.preferredxcaretposition-self.slider[1]:GetSliderValue()*-1,nil)
			end
		else
			if self.currentline>#self.lines-1 then
				--Move caret all the way to the right
				self.caretposition = self:GetLineChars()
			else
				--Move caret to next line
				self.currentline = self.currentline + 1
				self.caretposition = self:GetCharAtPosition(self.preferredxcaretposition-self.slider[1]:GetSliderValue()*-1,nil)
			end
		end
		
		if self.shiftpressed then
			local gcaret = self:GetCaretPosition(true)
			if gcaret==prevgcaret then
				return
			end
			local otherend
			if keycode==Key.Up then
				if self:GetCharLine(math.max(prevgcaret,prevgcaret+self.sellen))==self.currentline+1 and prevline>1 then
					otherend = math.min(prevgcaret,prevgcaret+self.sellen)
				else
					otherend = math.max(prevgcaret,prevgcaret+self.sellen)
				end
			else
				otherend = prevgcaret + self.sellen
			end
			self.sellen = -(gcaret - otherend)
		else
			self.preferredcaret = nil
			self.sellen=0
		end
		
		self:UpdateSliders()
		self.widget:GetGUI():ResetCursorBlink()
		self.cursorblinkmode=true
		self.widget:Redraw()
		
	elseif keycode==Key.Right or keycode==Key.Left then
		
		self.preferredxcaretposition = nil
		
		self.widget:GetGUI():ResetCursorBlink()
		self.cursorblinkmode=true

		if self.shiftpressed~=true and self.sellen~=0 then
			
			--Move the caret to the right side of the selection
			local gcaret = self:GetCaretPosition(true)
			if keycode==Key.Right then
				self:SetCaretPosition(math.max(gcaret,gcaret + self.sellen),true)
			else
				self:SetCaretPosition(math.min(gcaret,gcaret + self.sellen),true)
			end
			
			--if gcaret==self:GetCaretPosition(true) then
			--	return
			--end

			self.sellen = 0
			self.widget:GetGUI():ResetCursorBlink()
			self.cursorblinkmode=true
			self.widget:Redraw()
			self.preferredcaret = nil
			
		else
			--Move the caret one character right
			local gcaret = self:GetCaretPosition(true)
			local text = self.lines[self.currentline]
			local prevpos = self:GetCaretPosition(true)
			local newpos = prevpos
			if keycode==Key.Right then
				if newpos<string.len(self.widget.text) then
					newpos = newpos + 1
				end
			else
				if gcaret>0 then
					newpos = newpos - 1
				end
			end
			local c0 = prevpos + self.sellen,prevpos
			local c1 = prevpos + self.sellen,prevpos
			self:SetCaretPosition(newpos,true)

			if gcaret==self:GetCaretPosition(true) then
			--	return
			end
			
			if self.shiftpressed then
				if self.sellen<0 then
					self.sellen = -(newpos - c0)
				else
					self.sellen = c1 - newpos
				end
			else
				self.sellen = 0
				self.preferredcaret = nil
			end
			self:UpdateSliders()
			self.widget:Redraw()
			
		end
		
	end
end
