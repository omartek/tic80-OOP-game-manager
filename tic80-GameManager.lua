-- title:   Game state manager using OOP class.lua
-- author:  oltek
-- desc:    OOP in Lua using M.Ritcher class module
-- site:    https://github.com/vrld/hump
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

--[[  CLASS MODULE imported using Amalg tool
Copyright (c) 2010-2013 Matthias Richter

taken from https://github.com/vrld/hump
see https://youtu.be/GfwpRU0cT10?t=2794 for usage
see https://youtu.be/3IdOCxHGMIo?t=6239 for usage like game manager (state machine)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

do
local _ENV = _ENV
package.preload[ "class" ] = function( ... ) local arg = _G.arg;

local function include_helper(to, from, seen)
	if from == nil then
		return to
	elseif type(from) ~= 'table' then
		return from
	elseif seen[from] then
		return seen[from]
	end

	seen[from] = to
	for k,v in pairs(from) do
		k = include_helper({}, k, seen) -- keys might also be tables
		if to[k] == nil then
			to[k] = include_helper({}, v, seen)
		end
	end
	return to
end

-- deeply copies `other' into `class'. keys in `other' that are already
-- defined in `class' are omitted
local function include(class, other)
	return include_helper(class, other, {})
end

-- returns a deep copy of `other'
local function clone(other)
	return setmetatable(include({}, other), getmetatable(other))
end

local function new(class)
	-- mixins
	class = class or {}  -- class can be nil
	local inc = class.__includes or {}
	if getmetatable(inc) then inc = {inc} end

	for _, other in ipairs(inc) do
		if type(other) == "string" then
			other = _G[other]
		end
		include(class, other)
	end

	-- class implementation
	class.__index = class
	class.init    = class.init    or class[1] or function() end
	class.include = class.include or include
	class.clone   = class.clone   or clone

	-- constructor call
	return setmetatable(class, {__call = function(c, ...)
		local o = setmetatable({}, c)
		o:init(...)
		return o
	end})
end

-- interface for cross class-system compatibility (see https://github.com/bartbes/Class-Commons).
if class_commons ~= false and not common then
	common = {}
	function common.class(name, prototype, parent)
		return new{__includes = {prototype, parent}}
	end
	function common.instance(class, ...)
		return class(...)
	end
end


-- the module
return setmetatable({new = new, include = include, clone = clone},
	{__call = function(_,...) return new(...) end})
end
end
-- END class.lua MODULE

Class = require 'class' -- import module above for usage

-- state machine object definition

StateMachine = Class{}

function StateMachine:init(states)
	self.empty = { -- initialitation with empty funcions
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {} -- [name] -> [function that returns states created in function init()]
	self.current = self.empty
end

function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit() -- if exists executed before passing to next game state
	self.current = self.states[stateName]() -- this command copies functions from class created for the chosen game state
	self.current:enter(enterParams) -- if exists executed like first
end

function StateMachine:update()
	self.current:update() -- when called executes update function of the selected game state
end

function StateMachine:render()
	self.current:render()  -- when called executes update function of the selected game state
end

-- game state functions definition

BaseState = Class{} -- base empty class

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update() end
function BaseState:render() end

TitleScreenState = Class{__includes = BaseState} -- TitleScreenState() function definition, same name as in function init()

function TitleScreenState:update() -- update code for this game state
	if btnp(0) then gStateMachine:change('play') end  -- use :change() to change game state
end

function TitleScreenState:render() -- render code for this game state
	cls(13)
	print("Ciao",100,60,12)
	print("Ciao",101,61,15)
	print("premi Up",100,70,12)
	print("premi Up",101,71,15)
end

PlayState = Class{__includes = BaseState} -- PlayState() class include BaseState class, same name as in function init()

function PlayState:init() -- class constructor
	self.t=0
	self.x=0
	self.y=0
end

function PlayState:update()  -- update code for this game state
	if btnp(0) then gStateMachine:change('title') end  -- use :change() to change game state
    if btnp(4) then updateSprites() end
	self.t = self.t + 1

end

function PlayState:render()  -- render code for this game state
	if self.t%6==0 then
	cls(13)
	for k, sprite in pairs(sprites) do
		spr(sprite.sprite+self.t%60//30*2,sprite.x+math.random(0,10),sprite.y+math.random(0,10),14,3,0,0,2,2)
	end
	print("premi Z",20,20,12)
	print("premi Z",21,21,15)
	print("premi Up",20,30,12)
	print("premi Up",21,31,15)
	print("HELLO WORLD!",84,84)
	end
end


-- init

Ball = Class{} -- create the Ball class (the tic80 logo image)

function Ball:init(a,b) -- class constructor
    self.sprite=1
    self.x=a
    self.y=b
end

sprite0 = Ball(50,50) -- create a single object

sprites = {}  -- or use empty array for the objects

function updateSprites() -- function to add sprites to the previous list, two every time the function is called
	for i=0,1 do -- iteration to create 10 objects inside spites list
		table.insert(sprites,Ball(math.random(0,240), math.random(0,136)))
	end
end

function init()
    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end, -- choose a name for your first game state
        ['play'] = function() return PlayState() end, -- choose a name for your secondo game state
    }
    gStateMachine:change('title')

end

-- main program

init()
updateSprites()

function TIC()

	gStateMachine:update() -- same as calling gStateMachine.current:update()
	gStateMachine:render()

end
