function Script:Start()
	InitComponent(self, "InputComponent")

	self.window = Window:GetCurrent()
	self.keys = {}

	for i = 0, 9 do
		table.insert(self.keys, { key = Key["D"..i], down = false })
	end

	for i = 65, 90 do
		table.insert(self.keys, { key = i, down = false })
	end	
	
	self.onKeyPressed = EventManager:create()
end

function Script:KeyCodeToNumber(key)
	if key == Key.D0 then return 0 end
	if key == Key.D1 then return 1 end
	if key == Key.D2 then return 2 end
	if key == Key.D3 then return 3 end
	if key == Key.D4 then return 4 end
	if key == Key.D5 then return 5 end
	if key == Key.D6 then return 6 end
	if key == Key.D7 then return 7 end
	if key == Key.D8 then return 8 end
	if key == Key.D9 then return 9 end
end

function Script:IsKeyNumeric(key)
	if 	key == Key.D0 or key == Key.D1 or key == Key.D2 or key == Key.D3 or key == Key.D4 or 
		key == Key.D5 or key == Key.D6 or key == Key.D7 or key == Key.D8 or key == Key.D9 then
		return true
	end

	return false
end

function Script:UpdateWorld()
	--for i = 0, 9 do
	for k, v in pairs(self.keys) do
		--System:Print("Key = "..v.key.." down = "..tostring(v.down))
		if self.window:KeyDown(v.key) == true and v.down == false then
			v.down = true
		elseif self.window:KeyDown(v.key) == false and v.down == true then
			self.onKeyPressed:raise({ key = v.key })
			v.down = false
		end
	end
end