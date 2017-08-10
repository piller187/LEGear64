Script.maxHealth = 100		--int	"Max Health"

function Script:Start()
	InitComponent(self, "HealthComponent")

	self.health = self.maxHealth

	self.onDead = EventManager:create()
end

function Script:GetHealth()
	return self.health
end

function Script:Hurt(args)
	self.health = self.health - args.value
end

function Script:Heal(args)
	self.health = self.health + args.value
end