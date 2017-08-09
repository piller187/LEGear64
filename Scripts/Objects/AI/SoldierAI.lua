import "Scripts/Functions/GetEntityNeighbors.lua"

--Public values
Script.health=100--int "Health"
Script.enabled=true--bool "Enabled"
Script.target=nil--entity "Target"
Script.sightradius=30--float "Sight Range"
Script.senseradius=2--float "Hearing Range"
Script.teamid=2--choice "Team" "Neutral,Good,Bad"
Script.attackdelay=300--int "Attack delay"
Script.animspeedrun=0.04--float "Run anim speed"
Script.projectileprefabpath="Prefabs/Projectiles/tracer.pfb"--path "Projectile" "Prefab (*.pfb):pfb
Script.burstdelay=1000
Script.optimumshootingdistance=10
Script.burstcount=5
Script.firetime=50
Script.allyrange=5

--Private values
Script.damage=5
Script.attackrange=1.5
Script.meleechaserange=3
Script.updatefrequency=500
Script.lastupdatetime=0
Script.prevtarget=nil
Script.followingtarget=false
Script.maxaccel=15
Script.speed=6
Script.lastupdatetargettime=0
Script.attackmode=0
Script.attackbegan=0
Script.attack1sound=""--path "Attack 1 sound" "Wav file (*.wav):wav|Sound"
Script.attack2sound=""--path "Attack 2 sound" "Wav file (*.wav):wav|Sound"
Script.alertsound=""--path "Alert sound" "Wav file (*.wav):wav|Sound"
Script.deathsound=""--path "Death sound" "Wav file (*.wav):wav|Sound"
Script.idlesound=""--path "Idle sound" "Wav file (*.wav):wav|Sound"
Script.shoot1sound=""--path "Fire 1 sound" "Wav file (*.wav):wav|Sound"
Script.shoot2sound=""--path "Fire 2 sound" "Wav file (*.wav):wav|Sound"
Script.shoot3sound=""--path "Fire 3 sound" "Wav file (*.wav):wav|Sound"

function Script:Start()
	self.projectileprefab = Prefab:Load(self.projectileprefabpath)
	if self.projectileprefab~=nil then
		self.projectileprefab:Hide()
	end
	self.lastshoottime = math.random(0,self.burstdelay*1.25)
	if self.entity:GetMass()==0 then
		self.entity:SetMass(10)
	end
	self.entity:SetPickMode(Entity.BoxPick,true)
	self.entity:SetPickMode(0,false)
	self.entity:SetPhysicsMode(Entity.CharacterPhysics)
	self.entity:SetCollisionType(Collision.Prop,true)
	self.entity:SetCollisionType(Collision.Character,false)
	if self.enabled then
		if self.target~=nil then
			self:SetMode("roam")
		else
			self:SetMode("idle")
		end
	end
	self.sound={}
	if self.alertsound then self.sound.alert = Sound:Load(self.alertsound) end
	self.sound.attack={}
	if self.attack1sound then self.sound.attack[1] = Sound:Load(self.attack1sound) end
	if self.attack2sound then self.sound.attack[2] = Sound:Load(self.attack2sound) end
	if self.idlesound then self.sound.idle = Sound:Load(self.idlesound) end
	self.lastidlesoundtime=Time:GetCurrent()+math.random(1,20000)
	self.sound.shoot={}
	if self.shoot1sound~="" then self.sound.shoot[1] = Sound:Load(self.shoot1sound) end
	if self.shoot2sound~="" then self.sound.shoot[2] = Sound:Load(self.shoot2sound) end
	if self.shoot3sound~="" then self.sound.shoot[3] = Sound:Load(self.shoot3sound) end
	
	--Add muzzleflash to gun
	local limb=self.entity:FindChild("muzzle")
	if limb~=nil then
		local mtl=Material:Create()
		mtl:SetBlendMode(5)
		limb:SetMaterial(mtl)
		mtl:Release()
		self.muzzleflash = Sprite:Create()
		self.muzzleflash:SetSize(0.35,0.35)
		local pos=limb:GetPosition(true)
		self.muzzleflash:SetPosition(pos,true)
		self.muzzleflash:SetParent(limb,true)
		mtl = Material:Load("Materials/Effects/muzzleflash.mat")
		if mtl then
			self.muzzleflash:SetMaterial(mtl)
			mtl:Release()
			mtl=nil
		end
		local light = PointLight:Create()
		light:SetRange(5)
		light:SetColor(1,0.75,0)
		light:SetParent(self.muzzleflash,flash)
		if light.world:GetLightQuality()<2 then
			light:SetShadowMode(0)	
		end
		self.muzzleflash:Hide()
	end
end

function Script:Detach()
	if self.projectileprefab~=nil then
		self.projectileprefab:Release()
		self.projectileprefab=nil
	end
	if self.muzzleflash~=nil then
		self.muzzleflash:Release()
		self.muzzleflash=nil
	end
end

function Script:Enable()--in
	if self.enabled==false then
		if self.health>0 then
			self.enabled=true
			if self.target~=nil then
				self:SetMode("roam")
			else
				self:SetMode("idle")
			end
		end
	end
end

function Script:ChooseTarget()
	local entities = GetEntityNeighbors(self.entity,self.sightradius,true)
	local k,entity
	for k,entity in pairs(entities) do
		if entity.script.teamid~=nil and entity.script.teamid~=0 and entity.script.teamid~=self.teamid then
			if entity.script.health>0 then
				local pos = Transform:Point(entity:GetPosition(true),nil,self.entity)
				if pos.z<0 or entity:GetDistance(self.entity)<6 then
					local d = self.entity:GetDistance(entity)
					local pickinfo=PickInfo()
					if self.entity.world:Pick(self.entity:GetPosition()+Vec3(0,1.6,0),entity:GetPosition()+Vec3(0,1.6,0),pickinfo,0,false,Collision.LineOfSight)==false then
						return entity.script
					end
				end
			end
		end
	end
end

function Script:AlertNeighbors()
	if self.target~=nil then
		local entities = GetEntityNeighbors(self.entity,self.allyrange,true)
		local k,entity
		for k,entity in pairs(entities) do
			if entity.script.teamid==self.teamid then
				if entity.script.health>0 then
					if entity.script.target==nil then
						if type(entity.script["SetTarget"])=="function" then
							entity.script:SetTarget(self.target)
						end
					end
				end
			end
		end
	end
end

function Script:DistanceToTarget()
	local pos = self.entity:GetPosition()
	local targetpos = self.target.entity:GetPosition()
	if math.abs(targetpos.y-pos.y)<1.5 then
		return pos:xz():DistanceToPoint(targetpos:xz())
	else
		return 100000--if they are on different vertical levels, assume they can't be reached
	end
end

function Script:TargetInRange()
	local pos = self.entity:GetPosition()
	local targetpos = self.target.entity:GetPosition()
	if math.abs(targetpos.y-pos.y)<1.5 then
		if pos:xz():DistanceToPoint(targetpos:xz())<self.attackrange then
			return true
		end
	end
	return false
end

function Script:Hurt(damage,distributorOfPain)
	if self.health>0 then
		if distributorOfPain then
			if self.target~=distributorOfPain then
				if self.teamid~=distributorOfPain.teamid then
					self:SetTarget(distributorOfPain)
					self:SetMode("attack")
					self:AlertNeighbors()
				end
			end
		end
		self.health = self.health - damage
		if self.health<=0 then
			self.entity:SetMass(0)
			self.entity:SetCollisionType(0)
			self.entity:SetPhysicsMode(Entity.RigidBodyPhysics)
			self:SetMode("dying")
		end
	end
end

function Script:EndDeath()
	self:SetMode("dead")
end

function Script:DirectMoveToTarget()
	self.entity:Stop()
	local targetpos = self.target.entity:GetPosition()
	local pos = self.entity:GetPosition()
	local dir = Vec2(targetpos.z-pos.z,targetpos.x-pos.x):Normalize()
	local angle = -Math:ATan2(dir.y,-dir.x) + self.entity:GetCharacterControllerAngle() + 180.0
	self.entity:SetInput(angle,self.speed)
end

function Script:SetMode(mode)
	if mode~=self.mode then
		local prevmode=self.mode
		self.mode=mode
		if mode=="idle" then
			self.target=nil			
			self.entity:PlayAnimation("Idle",0.02)
			self.entity:Stop()--stop following anything
		elseif mode=="shoot" then
			self.entity:Stop()
			self.entity:PlayAnimation("fire",0.05)
		elseif mode=="roam" then
			if self.target~=nil then
				self.entity:PlayAnimation("Run",self.animspeedrun)
				self.entity:GoToPoint(self.target:GetPosition(true),5,5)
			else
				self:SetMode("idle")
			end
		elseif mode=="attack" then
			self:EndAttack()
		elseif mode=="chase" then
			if self.entity:Follow(self.target.entity,self.speed,self.maxaccel) then
				if prevmode~="chase" then
					if self.sound.alert then self.entity:EmitSound(self.sound.alert) end
				end
				self.followingtarget=true
				self.entity:PlayAnimation("Run",self.animspeedrun,300)
				if self:DistanceToTarget()<self.attackrange*2 then
					self.followingtarget=false
					self.entity:Stop()
					self:DirectMoveToTarget()
				end
			else
				self.target=nil
				self:SetMode("idle")
				return
			end
		elseif mode=="dying" then
			self.entity:Stop()
			self.entity:PlayAnimation("Death",0.04,300,1,"EndDeath")							
		elseif mode=="dead" then
			self.entity:SetCollisionType(0)
			self.entity:SetMass(0)
			self.entity:SetShape(nil)
			self.entity:SetPhysicsMode(Entity.RigidBodyPhysics)
			self.enabled=false
		end
	end
end

function Script:EndAttack()
	if self.mode=="attack" then	
		if self.target.health<=0 then
			self:SetMode("idle")
			return
		end
		local d = self:DistanceToTarget()
		if d>self.attackrange and d<self.meleechaserange+1.0 then
			self:SetMode("chase")
			return
		end
		if d>self.meleechaserange+1.0 then
			self:SetMode("shoot")
			return			
		end
		self.entity:Stop()
		self.attackmode = 1-self.attackmode--switch between right and left attack modes	
		
		local sequencename = "Attack"..tostring(1+self.attackmode)
		
		--Search for another sequence if the model doesn't contain two attack animations
		if sequencename=="Attack2" then
			if self.entity:FindAnimationSequence("Attack2")==-1 then
				sequencename="Attack1"
			end
		end
		if sequencename=="Attack1" then
			if self.entity:FindAnimationSequence("Attack1")==-1 then
				sequencename="Attack"
			end
		end
		
		self.entity:PlayAnimation(sequencename,0.05,300,1,"EndAttack")
		self.attackbegan = Time:GetCurrent()
		if self.sound.attack[self.attackmode+1] then
			if math.random()>0.75 then
				self.entity:EmitSound(self.sound.attack[self.attackmode+1])
			end
		end
	end
end

function Script:TargetVisible()
	
	--Return false if no target is set
	if self.target==nil then
		self.lastresult=nil
		return false
	end
	
	--Only check visibility once in a while
	if self.lastresult~=nil then
		if Time:GetCurrent()-self.lastresulttime<500 then
			return self.lastresult
		end
	end
	
	--Check visibility
	self.lastresulttime=Time:GetCurrent()
	local pos = self.entity:GetPosition()
	local targetpos = self.target.entity:GetPosition()
	pos.y=pos.y+1.6
	targetpos.y=targetpos.y+1.6
	self.entity:Hide()
	self.target.entity:Hide()
	local world=self.entity.world
	local pickinfo = PickInfo()
	local result=world:Pick(pos,targetpos,pickinfo,0,false)--,Collision.LineOfSight)
	self.lastresult=not result
	self.entity:Show()
	self.target.entity:Show()
	return self.lastresult
end

function Script:SetTarget(target)
	if target~=self.target then
		self.lastshoottime = Time:GetCurrent()+math.random(0,self.burstdelay*1.25)
		self.target=target
		local d = self:DistanceToTarget()
		if d>self.attackrange and d<self.meleechaserange then
			self:SetMode("chase")
		else
			self:SetMode("shoot")
		end
	end
end

function Script:UpdatePhysics()
	if self.enabled==false then return end

	local t = Time:GetCurrent()
	self.entity:SetInput(self.entity:GetRotation().y,0)
	
	if self.sound.idle then
		if t-self.lastidlesoundtime>0 then
			self.lastidlesoundtime=t+20000*Math:Random(0.75,1.25)
			self.entity:EmitSound(self.sound.idle,20)
		end
	end
	
	if self.mode=="idle" then
		if t-self.lastupdatetargettime>250 then
			self.lastupdatetargettime=t
			local target = self:ChooseTarget()
			if target then
				self:SetTarget(target)				
				self:AlertNeighbors()
			end
		end
	elseif self.mode=="roam" then
		if self.entity:GetDistance(self.target)<1 then
			self:SetMode("idle")
		end
	elseif self.mode=="chase" then
		if self.target.health<=0 then	
			self.target=nil
			self:SetMode("idle")
			return
		end
		local d=self:DistanceToTarget()
		if self:TargetInRange() then
			self:SetMode("attack")
		elseif d<self.attackrange*2 then
			self.followingtarget=false
			self.entity:Stop()
			self:DirectMoveToTarget()
		elseif d>self.meleechaserange+1.0 and Time:GetCurrent()>self.lastshoottime then
			if self:TargetVisible() then
				self.entity:Stop()
				self:SetMode("shoot")
			end
		else
			if self.followingtarget==false then
				if self.entity:Follow(self.target.entity,self.speed,self.maxaccel) then
					self:SetMode("idle")
				end
			end
		end
	elseif self.mode=="shoot" then
		if self.target.health<=0 then
			self.target=nil
			self:SetMode("idle")
			return
		end
		if self:TargetVisible()==false or self:DistanceToTarget()<self.meleechaserange then
			self:SetMode("chase")
		else
			local pos = self.entity:GetPosition()
			local targetpos = self.target.entity:GetPosition()
			local dx=targetpos.x-pos.x
			local dz=targetpos.z-pos.z
			local angle=Math:ATan2(dx,dz)
			if self.entity:GetCharacterControllerAngle()>90.0 then
				angle=angle+180
			end
			self.entity:SetInput(angle,0)
			if self.lastshoottime==nil then self.lastshoottime=0 end
			if self.consecutiveshots==nil then
				self.consecutiveshots=0
			end
			if Time:GetCurrent()-self.lastshoottime>self.firetime then
				self.lastshoottime=Time:GetCurrent()
				if self.projectileprefab~=nil then
					if self.muzzleflash then
						local projectile = self.projectileprefab:Instance()
						projectile:Show()
						self.entity:PlayAnimation("fire",0.05,100,1)
						self.muzzleflash:EmitSound(self.sound.shoot[#self.sound.shoot])
						self.muzzleflash:SetAngle(math.random(0,360))
						self.muzzleflashtime=Time:GetCurrent()
						projectile = projectile.script
						projectile.owner = self
						projectile.entity:SetPosition(self.muzzleflash:GetPosition(true))
						if type(projectile.Enable)=="function" then projectile:Enable() end
						local diff = ((self.target.entity:GetPosition(true)+Vec3(0,1.5,0))-self.muzzleflash:GetPosition(true)):Normalize()
						projectile.entity:AlignToVector(diff)				
						projectile.entity:Turn(Math:Random(-3,3),Math:Random(-3,3),0)
						self.consecutiveshots=self.consecutiveshots+1
						if self.consecutiveshots==self.burstcount then
							self.consecutiveshots=0
							self.lastshoottime=self.lastshoottime+self.burstdelay+math.random(0,self.burstdelay*0.25)
							if self:DistanceToTarget()>self.optimumshootingdistance then
								self:SetMode("chase")
							end
						end
					end
				end
			end
		end
	elseif self.mode=="attack" then
		if self.attackbegan~=nil then
			if t-self.attackbegan>self.attackdelay then
				if self.target.entity:GetDistance(self.entity)<1.5 then
					self.attackbegan=nil
					self.target:Hurt(self.damage)
				end
			end
		end
		local pos = self.entity:GetPosition()
		local targetpos = self.target.entity:GetPosition()
		local dx=targetpos.x-pos.x
		local dz=targetpos.z-pos.z
		if self.entity:GetCharacterControllerAngle()>90.0 then
			self.entity:AlignToVector(-dx,0,-dz)
		else
			self.entity:AlignToVector(dx,0,dz) 
		end
	end
end

function Script:UpdateMuzzleFlash()
	if self.muzzleflashtime then
		if Time:GetCurrent()-self.muzzleflashtime<30 then
			self.muzzleflash:Show()
		else
			self.muzzleflash:Hide()
		end
	end
end

function Script:Draw()
	if self.enabled==false then return end
	self:UpdateMuzzleFlash()
end
