function Script:PostStart()
	InitGameObject(self, "Croc")

	self.Health = FindComponent(self, "HealthComponent")
	self.Input = FindComponent(self, "InputComponent")

	--self.Input.onKeyPressed:subscribe(self.Health, self.Health.Hurt)

	--self.Input.onKeyPressed:subscribe(self.Health, self.Health.Hurt, function(args) 
	--	args.value = self.Input:KeyCodeToNumber(args.key) 
	--end)

	self.Input.onKeyPressed:subscribe(self.Health, self.Health.Hurt, function(args) 
		args.value = self.Input:KeyCodeToNumber(args.key) 
	end,
	function(args)
		return self.Input:IsKeyNumeric(args.key)
	end)
end

--This function will be called after the world is rendered, before the screen is refreshed.
--Use this to perform any 2D drawing you want the entity to display.
function Script:PostRender(context)
	context:SetBlendMode(Blend.Alpha)

	context:DrawText(self.Health:GetHealth(), 0, 0)

	context:SetBlendMode(Blend.Solid)
end