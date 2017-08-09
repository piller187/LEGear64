--Styles
if Style==nil then Style={} end
if Style.Label==nil then Style.Label={} end
Style.Label.Left=0
Style.Label.Center=16
Style.Label.Right=8
Style.Label.VCenter=32

--[[
Const LABEL_LEFT=0
Const LABEL_FRAME=1
Const LABEL_SUNKENFRAME=2
Const LABEL_SEPARATOR=3
Const LABEL_RIGHT=8
Const LABEL_CENTER=16
]]

function Script:Draw(x,y,width,height)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = gui:GetScale()
	local text = self.widget:GetText()
	local indent=4
	
	gui:SetColor(0.7,0.7,0.7)

	if self.border==true then
		gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)
	end

	if text~="" then
		local style=0
		if self.align=="Left" then style = Text.Left end
		if self.align=="Center" then style = Text.Center end
		if self.align=="Right" then style = Text.Right end
		if self.valign=="Center" then style = style + Text.VCenter end
		
		if self.wordwrap==true then style = style + Text.WordWrap end
		
		if self.border==true then
			gui:DrawText(text,pos.x+scale*indent,pos.y+scale*indent,sz.width-scale*indent*2,sz.height-scale*indent*2,style)	
		else
			gui:DrawText(text,pos.x,pos.y,sz.width,sz.height,style)	
		end
	end
end

function Script:bitand(set, flag)
	return set % (2*flag) >= flag
end
