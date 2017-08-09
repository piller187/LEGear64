Script.progress = 0
Script.radius=3

function Script:Draw(x,y,width,height)
	local gui = self.widget:GetGUI()
	local pos = self.widget:GetPosition(true)
	local sz = self.widget:GetSize(true)
	local scale = self.widget:GetGUI():GetScale()
	
	--Track
	gui:SetColor(0.15)
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height)	
	
	--Progress indicator
	gui:SetColor(51/255,151/255,1)
	gui:DrawRect(pos.x+scale*1,pos.y+scale*1,sz.width*self.progress-scale*2,sz.height-scale*2)
	
	--Outline
	gui:SetColor(0)
	gui:DrawRect(pos.x,pos.y,sz.width,sz.height,1)
	
end
