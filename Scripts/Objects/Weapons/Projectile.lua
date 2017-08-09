Script.movespeed=50.0
Script.pickradius=0
Script.damage=5
Script.lifetime=1000
Script.enabled=false--bool "Enabled"

function Script:Start()
	self.sound={}	
	self.sound.ricochet={}
	self.sound.ricochet[1]=Sound:Load("Sound/Ricochet/bullet_impact_dirt_01.wav")
	self.sound.ricochet[2]=Sound:Load("Sound/Ricochet/bullet_impact_dirt_02.wav")
	self.sound.ricochet[3]=Sound:Load("Sound/Ricochet/bullet_impact_dirt_03.wav")
	self.starttime=Time:GetCurrent()
end

function Script:Enable()--in
	if self.enabled==false then
		self.enabled=true
	end
end

function Script:FindScriptedParent(entity,func)
	while entity~=nil do
		if entity.script then
			if type(entity.script[func])=="function" then
				return entity
			end
		end
		entity = entity:GetParent()
	end
	return nil
end

function Script:UpdateWorld()
	if self.enabled==false then return end
	if self.entity:Hidden() then return end
	local pickinfo=PickInfo()	
	local pos = self.entity:GetPosition(true)
	local targetpos = Transform:Point(0,0,self.movespeed/60.0 * Time:GetSpeed(),self.entity,nil)
	local result = self.entity.world:Pick(pos,targetpos,pickinfo,self.pickradius,true,Collision.Projectile)
	if result then
		local enemy = self:FindScriptedParent(pickinfo.entity,"Hurt")
		if enemy then
			if self.owner then
				--if self.owner.teamid==enemy.script.teamid then
				--	result=false
				--end
			end
			if result then
				if enemy.script.health>0 then
					enemy.script:Hurt(self.damage,self.owner)
				end
			end	
		end
		if result then
			
			--Bullet mark decal
			local mtl
			local scale = 0.1
			if enemy~=nil then
				mtl = Material:Load("Materials/Decals/wound.mat")
				scale = 0.1
			else
				if pickinfo.surface~=nil then
					local pickedmaterial = pickinfo.surface:GetMaterial()
					if pickedmaterial~=nil then
						rendermode = pickedmaterial:GetDecalMode()
					end
				end
				mtl = Material:Load("Materials/Decals/bulletmark.mat")
			end
			local decal = Decal:Create(mtl)
			decal:AlignToVector(pickinfo.normal,2)
			decal:Turn(0,0,Math:Random(0,360))
			decal:SetScript("Scripts/Objects/Effects/BulletMark.lua")
			if mtl~=nil then mtl:Release() end
			decal:SetPosition(pickinfo.position)
			decal:SetParent(pickinfo.entity)
			
			--Apply global scaling
			local mat = decal:GetMatrix()
			mat[0] = mat[0]:Normalize() * scale
			mat[1] = mat[1]:Normalize() * scale
			mat[2] = mat[2]:Normalize() * scale	
			decal:SetMatrix(mat)

			--Play sound
			decal:EmitSound(self.sound.ricochet[math.random(#self.sound.ricochet)],30)

			self.entity:Release()
		else
			self.entity:SetPosition(targetpos)
		end
	else
		self.entity:SetPosition(targetpos)
	end
	if Time:GetCurrent()-self.starttime>self.lifetime then
		self.entity:Release()
	end
end
