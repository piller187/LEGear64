Script.caretposition=0
Script.sellen=0
Script.doubleclickrange = 1
Script.doubleclicktime = 500
Script.offsetx = 0
Script.textindent = 4
Script.text=""

function Script:SetText()
	self.text = self.widget:GetText()
end

function Script:Draw(x,y,width,height)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	local item = self.widget:GetSelectedItem()
	local text = self.widget:GetText()
	
	self:UpdateOffset()
	
	--Draw the widget background
	gui:SetColor(0.15,0.15,0.15)
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,0)
	
	--Draw text selection background
	if self.sellen~=0 then
		local n
		local x = gui:GetScale()*self.textindent
		local px = x
		local fragment = self:GetSelectedText()
		local w = gui:GetTextWidth(fragment)
		local c1 = math.min(self.caretposition,self.caretposition+self.sellen)
		local c2 = math.max(self.caretposition,self.caretposition+self.sellen)
		local prefix = String:Left(text,c1)
		px = px + gui:GetTextWidth(prefix)
		--if self.focused==true then
		--	gui:SetColor(51/255/2,151/255/2,1/2)
		--else
			gui:SetColor(0.4,0.4,0.4)
		--end
		gui:DrawRect(pos.x + px + self.offsetx, pos.y+2*scale,w,sz.height-4*scale,0)
	end
	
	--Draw text
	gui:SetColor(0.75,0.75,0.75)
	if text~="" then
		gui:DrawText(text,scale * self.textindent + pos.x+self.offsetx,pos.y,math.max(sz.width,sz.width-self.offsetx),sz.height,Text.Left+Text.VCenter)
	end
	
	--Draw the caret
	if self.cursorblinkmode then
		if self.focused then
			local x = self:GetCaretCoord()
			gui:DrawLine(pos.x + x + self.offsetx,pos.y+2*scale,pos.x + x + self.offsetx,pos.y + sz.height-4*scale)
		end
	end
	
	--Draw the widget outline
	--if self.hovered==true then
	--	gui:SetColor(51/255,151/255,1)
	--else
		gui:SetColor(0,0,0)
	--end
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)
	
end

--Find the character position for the given x coordinate
function Script:GetCharAtPosition(pos,clickonchar)
	local text = self.widget:GetText()
	local gui = self.widget:GetGUI()
	local n
	local c
	local scale = gui:GetScale()
	local x = scale*self.textindent
	local count = String:Length(text)
	local lastcharwidth=0
	for n=0,count-1 do
		c = String:Mid(text,n,1)
		lastcharwidth = gui:GetTextWidth(c)
		if clickonchar then
			if x >= pos then return n end
		else
			if x >= pos - lastcharwidth/2 then return n end
		end
		x = x + lastcharwidth
	end
	return count
end

--Get the x coordinate of the current caret position
function Script:GetCaretCoord(caret)
	if caret==nil then caret = self.caretposition end
	local text = self.widget:GetText()
	local gui = self.widget:GetGUI()
	local n
	local c
	local x = gui:GetScale() * self.textindent
	local count = math.min(caret-1,(String:Length(text)-1))
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
		local text = self.widget:GetText()
		local l = String:Length(text)
		self.caretposition = l
		self.sellen = -l
		self.widget:Redraw()
	end
end

function Script:DoubleClick(button,x,y)
	if button==Mouse.Left then
		x = x - self.offsetx
		--if math.abs(self.lastmouseposition.x-x)<=self.doubleclickrange and math.abs(self.lastmouseposition.y-y)<=self.doubleclickrange then
			
			local badchars = "<>,./\\?[]{}!@#$%^&*()-_=+| 	"

			--Select the word at the mouse position
			local text = self.widget:GetText()
			local l = String:Length(text)
			local c = self:GetCharAtPosition(x,true)
			self.caretposition = c
			self.sellen = -1
			local chr=String:Mid(text,c-1,1)
			
			if chr==" " or chr=="	" then
				
				--Select spaces in this word before the clicked character
				for n = c-2, 0, -1 do
					if String:Mid(text,n,1)~=" " and String:Mid(text,n,1)~="	" then
						break
					else
						self.sellen = self.sellen - 1
					end
				end
				
				--Select spaces in this word after the clicked character
				for n = c, l-1 do
					if String:Mid(text,n,1)~=" " and String:Mid(text,n,1)~="	" then
						break
					else
						self.caretposition = self.caretposition + 1
						self.sellen = self.sellen - 1
					end	
				end						
				
			elseif String:Find(badchars,chr)>-1 then
				
				--Stop here
				
			else
				--Select characters in this word before the clicked character				
				for n = c-2, 0, -1 do
					chr = String:Mid(text,n,1)
					if String:Find(badchars,chr)>-1 then
					--if chr==" " or chr=="." or chr=="/" then
						break
					else
						self.sellen = self.sellen - 1
					end
				end
				
				--Select characters in this word after the clicked character
				for n = c, l-1 do
					chr = String:Mid(text,n,1)
					if String:Find(badchars,chr)>-1 then
					--if String:Mid(text,n,1)==" " then
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
			
		--end		
	end
end

function Script:MouseDown(button,x,y)
	self.focused=true
	if button==Mouse.Left then	
		
		x = x - self.offsetx
		
		--Detect double-click
		--[[local currenttime = Time:Millisecs()
		if self.lastmousehittime~=nil then
			if math.abs(self.lastmouseposition.x-x)<=self.doubleclickrange and math.abs(self.lastmouseposition.y-y)<=self.doubleclickrange then
				if currenttime - self.lastmousehittime < self.doubleclicktime then
					self.lastmousehittime = currenttime
					
					--Select the word at the mouse position
					local text = self.widget:GetText()
					local l = String:Length(text)
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
		
		--Position caret under mouse click
		local prevcaretposition = self.caretposition + self.sellen
		self.cursorblinkmode=true
		self.caretposition = self:GetCharAtPosition(x)
		self.widget:GetGUI():ResetCursorBlink()
		self.cursorblinkmode=true
		self.pressed=true
		if self.shiftpressed then
			self.sellen = prevcaretposition - self.caretposition
		else
			self.sellen=0
		end
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

function Script:GetSelectedText()
	if self.sellen==0 then return "" end
	local c1 = math.min(self.caretposition,self.caretposition+self.sellen)
	local c2 = math.max(self.caretposition,self.caretposition+self.sellen)
	return String:Mid(self.widget:GetText(),c1,c2-c1)
end

function Script:UpdateOffset()
	local width = self.widget:GetSize(true).x
	local text = self.widget:GetText()
	local gui = self.widget:GetGUI()
	local scale = gui:GetScale()
	local c = String:Right(text,1)
	local cw = gui:GetTextWidth(c)
	local tw = gui:GetTextWidth(text)
	if tw + scale * self.textindent * 2 > width then
		local fragment = self:GetSelectedText()
		local fw = gui:GetTextWidth(fragment)
		if fw + scale * self.textindent * 2 > width then
			local coord = self:GetCaretCoord()
			if self.offsetx + coord - scale * self.textindent < 0 then
				self.offsetx = -coord + scale * self.textindent
			elseif self.offsetx + coord > width - scale * self.textindent then
				self.offsetx = -(coord - (width - scale * self.textindent))
			end
		else
			local c1 = math.min(self.caretposition,self.caretposition+self.sellen)
			local c2 = math.max(self.caretposition,self.caretposition+self.sellen)
			coord1 = self:GetCaretCoord(c1)
			coord2 = self:GetCaretCoord(c2)
			if self.offsetx + coord1 - scale * self.textindent < 0 then
				self.offsetx = -coord1 + scale * self.textindent
			elseif self.offsetx + coord2 > width - scale * self.textindent then
				self.offsetx = -(coord2 - (width - scale * self.textindent))
			end
		end
		if self.offsetx + tw < width - scale * self.textindent * 2 then
			self.offsetx = (width - tw - scale * self.textindent * 2)
		end
	else
		self.offsetx = 0
	end
end

function Script:MouseMove(x,y)
	if self.pressed then
		
		--Select range of characters
		x = x - self.offsetx
		local currentcaretpos = self.caretposition
		local prevcaretpos = self.caretposition + self.sellen
		self.cursorblinkmode=true
		self.caretposition = self:GetCharAtPosition(x)
		if self.caretposition ~= currentcaretpos then
			self.widget:GetGUI():ResetCursorBlink()
			self.cursorblinkmode=true
			self.sellen = prevcaretpos - self.caretposition	
			self.widget:Redraw()
		end
		
	end
end

function Script:GainFocus()
	self.focused = true
end

function Script:LoseFocus()
	self.focused=false
	self.sellen=0
	self.widget:Redraw()
	local s = self.widget:GetText()
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
	if keycode==Key.Up or keycode==Key.Left then
		
		if self.shiftpressed~=true and self.sellen~=0 then
			
			--Move the caret to the left side of the selection
			self.caretposition = math.min(self.caretposition,self.caretposition + self.sellen)
			self.sellen = 0
			self.widget:GetGUI():ResetCursorBlink()
			self.cursorblinkmode=true
			self.widget:Redraw()
			
		else
			
			--Move the caret one character left
			local text = self.widget:GetText()
			if self.caretposition>0 then
				self.caretposition = self.caretposition - 1
				self.widget:GetGUI():ResetCursorBlink()
				self.cursorblinkmode=true
				if self.shiftpressed then
					self.sellen = self.sellen + 1
				else
					self.sellen = 0
				end
				self.widget:Redraw()
			end
			
		end
		
	elseif keycode==Key.Down or keycode==Key.Right then
		
		if self.shiftpressed~=true and self.sellen~=0 then
			
			--Move the caret to the right side of the selection
			self.caretposition = math.max(self.caretposition,self.caretposition + self.sellen)
			self.sellen = 0
			self.widget:GetGUI():ResetCursorBlink()
			self.cursorblinkmode=true
			self.widget:Redraw()
			
		else
			
			--Move the caret one character right
			local text = self.widget:GetText()
			if self.caretposition<String:Length(text) then		
				self.caretposition = self.caretposition + 1
				self.widget:GetGUI():ResetCursorBlink()
				self.cursorblinkmode=true
				if self.shiftpressed then
					self.sellen = self.sellen - 1
				else
					self.sellen = 0
				end
				self.widget:Redraw()
			end
			
		end
		
	elseif keycode==Key.Enter then
		
		self.widget:GetGUI():SetFocus(nil)
		
	end
end

function Script:KeyChar(charcode)
	local s = self.widget:GetText()
	local c = String:Chr(charcode)
	if c=="\b" then
		
		--Backspace
		if String:Length(s)>0 then
			if self.sellen==0 then
				if self.caretposition==String:Length(s) then
					s = String:Left(s,String:Length(s)-1)
				elseif self.caretposition>0 then
					s = String:Left(s,self.caretposition-1)..String:Right(s,String:Length(s)-self.caretposition)
				end
				self.caretposition = self.caretposition - 1
				self.caretposition = math.max(0,self.caretposition)
			else
				local c1 = math.min(self.caretposition,self.caretposition+self.sellen)
				local c2 = math.max(self.caretposition,self.caretposition+self.sellen)
				s = String:Left(s,c1)..String:Right(s,String:Length(s) - c2)
				self.caretposition = c1
				self.sellen = 0
			end
			self.widget:GetGUI():ResetCursorBlink()
			self.cursorblinkmode=true
			self.widget.text = s
			self.widget:Redraw()
			--EventQueue:Emit(Event.WidgetAction,self.widget)
			
		end
	elseif c~="\r" and c~="" then
		
		--Insert a new character
		local c1 = math.min(self.caretposition,self.caretposition+self.sellen)
		local c2 = math.max(self.caretposition,self.caretposition+self.sellen)
		s = String:Left(s,c1)..c..String:Right(s,String:Length(s) - c2)
		self.caretposition = self.caretposition + 1
		if self.sellen<0 then self.caretposition = self.caretposition + self.sellen end
		self.sellen=0
		self.widget:GetGUI():ResetCursorBlink()
		self.cursorblinkmode=true		
		self.widget.text = s
		self.widget:Redraw()
		--EventQueue:Emit(Event.WidgetAction,self.widget)
		
	end
end
