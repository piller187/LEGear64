Script.movespeed=5.0--float "Move speed"
Script.movementsmoothing = 0.3--float "Move smoothness"
Script.radius = 0.5--float "Radius"
Script.lookspeed = 0.1--float "Look speed"
Script.looksmoothing = 0.5--float "Look smoothness"

function Script:Start()
	local window = Window:GetCurrent()
	self.mousepos = window:GetMousePosition()
	self.camerarotation = self.entity:GetRotation()
	if (self.entity:GetMass()==0) then
		self.entity:SetMass(10)
	end
	self.entity:SetGravityMode(false)
	if type(self.entity.SetElasticity)=="SetBuoyancyMode" then
		self.entity:SetBuoyancyMode(false)
	end
	self.entity:SetCollisionType(Collision.Projectile)
	if self.entity:GetShape()==nil then
		local shape = Shape:Sphere(0,0,0, 0,0,0, self.radius*2,self.radius*2,self.radius*2)
		self.entity:SetShape(shape)
		shape:Release()
	end
	self.entity:SetFriction(0,0)
	if type(self.entity.SetElasticity)=="function" then
		self.entity:SetElasticity(0)
	end
	self.entity:SetSweptCollisionMode(true)
	self.listener = Listener:Create(self.entity)
	self.entity:SetBuoyancyMode(false)
end

--Collision filter so the spectator doesn't knock things over
function Script:Overlap(entity)
	if entity:GetMass()==0 then
		return Collision.Collide
	else
		return Collision.None
	end
end

function Script:UpdateWorld()
	local window = Window:GetCurrent()
	local cx = Math:Round(context:GetWidth()/2)
	local cy = Math:Round(context:GetHeight()/2)
	local mpos = window:GetMousePosition()
	window:SetMousePosition(cx,cy)
	local centerpos = window:GetMousePosition()
	if self.started then
		mpos = mpos * self.looksmoothing + self.mousepos * (1-self.looksmoothing)
		local dx = (mpos.x - centerpos.x) * self.lookspeed
		local dy = (mpos.y - centerpos.y) * self.lookspeed		
		self.camerarotation.x = self.camerarotation.x + dy
		self.camerarotation.y = self.camerarotation.y + dx
		self.mousepos = mpos
	else
		self.mousepos = Vec3(centerpos.x,centerpos.y,0)
		self.started=true
	end
end

function Script:UpdatePhysics()
	local move=0
	local strafe=0
	local ascension=0
	local window = Window:GetCurrent()
	if window:KeyDown(Key.W) or window:KeyDown(Key.Up) then move = move + self.movespeed end
	if window:KeyDown(Key.S) or window:KeyDown(Key.Down) then move = move - self.movespeed end
	if window:KeyDown(Key.D) or window:KeyDown(Key.Right) then strafe = strafe + self.movespeed end
	if window:KeyDown(Key.A) or window:KeyDown(Key.Left) then strafe = strafe - self.movespeed end
	if window:KeyDown(Key.Q) or window:KeyDown(Key.PageDown) then ascension = ascension - self.movespeed end
	if window:KeyDown(Key.E) or window:KeyDown(Key.PageUp) then ascension = ascension + self.movespeed end
	local currentvelocity = self.entity:GetVelocity(false)
	local desiredvelocity = Vec3(strafe,0,move) + Transform:Vector(0,ascension,0,nil,self.entity)
	local velocity = currentvelocity * self.movementsmoothing + desiredvelocity * (1.0-self.movementsmoothing)
	self.entity:AddForce((desiredvelocity - currentvelocity) * self.entity:GetMass() / self.movementsmoothing,false)
	self.entity:PhysicsSetRotation(self.camerarotation.x,self.camerarotation.y,self.camerarotation.z)
end
