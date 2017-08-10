--coroutine function
function Wait(ms)
	local tm = Time:GetCurrent()
	while true do
		if Time:GetCurrent() > tm + ms then
			break
		end
		coroutine.yield()
	end
end

function CreateMessageEvent(self, msg, event)
	self[event] = EventManager:create()

	if self.Messages == nil then self.Messages = {} end
	if self.Messages[msg] == nil then
		self.Messages[msg] = self[event]
	end
end

function FindComponent(self, name)
	for i = 0, self.entity:CountChildren() - 1 do
		local ent = self.entity:GetChild(i)
		if ent.script ~= nil then
			if ent.script.name ~= nil then
				if ent.script.name == name then
					return ent.script
				end
			end
		end
	end
end

function PrintComponent(self, name)
	for i = 0, self.entity:CountChildren() - 1 do
		local ent = self.entity:GetChild(i)
		if ent.script ~= nil then
			if ent.script.name ~= nil then
				System:Print(ent.script.name)
			end
		end
	end
end

function InitComponent(self, name)
	self.name = name

	self.gameObject = self.entity:GetParent()
end

function InitGameObject(self, name)
    self.name = name
	self.onReceiveMessage = EventManager:create()
	self.ReceiveMessage = function(self, args)
        System:Print("Message: "..args.Message.." To: "..self.name)
		if self.Messages ~= nil then
			if self.Messages[args.Message] ~= nil then
				self.Messages[args.Message]:raise(args)
			else
				self.onReceiveMessage:raise(args)
			end
		else
			self.onReceiveMessage:raise(args)
		end
	end

	self.SendMessage = function(self, args)
		args.Source = self.entity	-- when sending messages out we automatically create the Source of the sender variable
		if type(args.Dest) ~= "table" then	-- we can send to 1 entity or a table of entities
			args.Dest.script:ReceiveMessage(args)
		else
			for k,v in ipairs(args.Dest) do
				v.script:ReceiveMessage(args)
			end
		end
	end

	-- handle collisions
	self.entered = true
	self.exited = false
	self.hadCollision = false
	self.onCollisionEnter = EventManager:create()
	self.onCollisionLeave = EventManager:create()
	self.onCollision = EventManager:create()
	self.Collision = function(self, entity, position, normal, speed)
		System:Print("Calling Collision")
		self.hadCollision = true
		self.onCollision:raise({ entity = entity, position = position, normal = normal, speed = speed })
		if self.entered == false then
			self.onCollisionEnter:raise({ entity = entity, position = position, normal = normal, speed = speed })
			self.entered = true
			self.exited = false
		end
	end

	self.UpdatePhysics = function(self)
		if self.entered then
			if self.hadCollision == false then
				if self.exited == false then
					self.onCollisionLeave:raise({})
					self.exited = true
					self.entered = false
				end
			end
		end
		self.hadCollision = false
	end
end

function CallPostStart(world)
	for i = world:CountEntities() - 1, 0, -1 do
		local ent = world:GetEntity(i)
		
		if ent.script ~= nil then
			if ent.script.PostStart ~= nil then
				ent.script:PostStart()
			end
		end
	end
end


----------------------------------------------
-- Leadwerks Component System
-- http://leadwerks.com      	
-- - - - - - - - - - - - - - - - - - - - - - -
-- Free to use for all Leadwerks owners
-- and as always we take no responsibility
-- for anything that the usage of this can 
-- cause directly or indirectly. 
-- - - - - - - - - - - - - - - - - - - - - - -
-- Rick & Roland                       	
-----------------------------------------------

--[[
Class: EventManager


]]

local EventManagerID = 0

if EventManager ~= nil then return end
EventManager = {}
EventManager.coroutines = {}

function EventManager:create()
	obj = {}
    setmetatable(obj, self)
    self.__index = self
	self.handlers = {}
	for k, v in pairs(EventManager) do
		obj[k] = v
	end

    return obj
end

--[[
Function: subscribe(owner, method, arguments, filterFunction)

Subscribe to an event

Parameters: 

	owner - owner of the method
	method - function/method to call on raise
	arguments - table or string of arguments
	filterFunction - function called for enable/disable the event
	
Returns:

	A number the identifies the event. Can be used to remove a subscribtion
]]
function EventManager:subscribe(owner, method, arguments, filterFunction, postFunction)
	if method == nil then 
		System:Print( debug.traceback() ) 
	end
	
	Debug:Assert( owner ~= nil, "Calling EventManager:subscribe with Null-Owner" )
	Debug:Assert( method ~= nil, "Calling EventManager:subscribe with Null-Method")
	
	EventManagerID = EventManagerID+1
	
	local func = nil 
	if filterFunction ~= nil then 
		func = filterFunction
	end
	
	table.insert(self.handlers, { 
			Id = EventManagerID, 
			Owner = owner, 
			Method = method, 
			Arguments = arguments,
			FilterFunction = func,
			PostFunction = postFunction })

	return EventManagerID
end

--[[
Function: unsubscribe(id)

Unsubscribe an event

Parameters: 

	id - identification on the event
	
See Also:
	<subscribe(owner, method, arguments, filterFunction)>
]]
function EventManager:unsubscribe(id) -- the id returned when subscribing
	for i = 1, #self.handlers do
		if  self.handlers[i].Id == id then
			table.remove(self.handlers, i)
			return
		end
	end
end

function EventManager:raise(args)
	for i = 1, #self.handlers do
		local handler = self.handlers[i]
		if handler ~= nil then
      --local arguments = self:_doArguments(handler, args)
			if	handler.FilterFunction ~= nil and handler.FilterFunction ~= "" then 
				if handler.FilterFunction(args) then
					local arguments = self:_doArguments(handler, args)
					
					local co = coroutine.create(handler.Method)
					local status, err = coroutine.resume(co, handler.Owner, arguments)
                    if status == false then
                        System:Print("ERROR: "..err)
                        error("Check log for error.")
                    end
					if coroutine.status(co) ~= "dead" then
						table.insert( EventManager.coroutines, co)
					end
          
					-- we only call the post function if we have a filter so we don't have to filter again
					if handler.PostFunction ~= nil then
						handler.PostFunction(arguments)
					end
				end
			else
				local arguments = self:_doArguments(handler, args)
				local co = coroutine.create(handler.Method)
				local status, err = coroutine.resume(co, handler.Owner, arguments)
                if status == false then
                    System:Print("ERROR: "..err)
					error("Check log for error.")
                end
				if coroutine.status(co) ~= "dead" then
					table.insert(EventManager.coroutines, co)
				end
        
        if handler.PostFunction ~= nil then
						handler.PostFunction(arguments)
					end
			end
		end
	end
end

--[[
Function: update()

Updates the EventManager

]]
function EventManager:update()
	for i = #EventManager.coroutines, 1, -1 do
		local co = EventManager.coroutines[i]
		local status, err = coroutine.resume(co)
        if status == false then
            System:Print("ERROR: "..err)
			error("Check log for error.")
        end
		if coroutine.status(co) == "dead" then
			table.remove(EventManager.coroutines, i)
		end
	end
end

function EventManager:_doArguments(handler, args)
	local arguments = args
	if 	handler.Arguments ~= nil and handler.Arguments ~= "" then
		local handlerArgs = handler.Arguments(args)	-- call the arguments callback function passing these args
		local handlertype = type(handlerArgs)
		local argstype = type(args)
		if 	type(handlerArgs) == "table" and type(args) == "table" then
			for k,v in pairs(handlerArgs) do
				arguments[k]=v
			end
		elseif 	type(handlerArgs) == "string" and type(args) == "string" then
			arguments = arguments .. "," .. handlerArgs
		end
	end

	return arguments
end