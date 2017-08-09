Script.Speed=1.0--float
Script.Sequence="0"--string

function Script:Start()
	self.entity:PlayAnimation(self.Sequence,self.Speed/100.0,1)
end
