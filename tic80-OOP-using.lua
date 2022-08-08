-- title:   OOP using class.lua module
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
-- end class module

-- inizio prg

Class = require 'class' -- import module above

Ball = Class{} -- create the class

function Ball:init(a,b) -- constructor
    self.sprite=1
    self.x=a
    self.y=b
end

sprite0 = Ball(50,50) -- create a single object

local sprites = {}  -- or use empty array for the objects

for i=0,9 do -- iteration to create 10 objects inside spites list
    table.insert(sprites,Ball(math.random(0,240), math.random(0,136)))
end

t=0
x=0
y=0

function TIC()

	if btn(0) then y=-1 end -- not used
	if btn(1) then y=1 end
	if btn(2) then x=-1 end
	if btn(3) then x=1 end

	if t%6==0 then
	cls(13)
		for k, sprite in pairs(sprites) do
			spr(sprite.sprite+t%60//30*2,sprite.x+math.random(0,10),sprite.y+math.random(0,10),14,3,0,0,2,2)
		end
	end
	print("HELLO WORLD!",84,84)
	t=t+1
	x=0
    y=0
end
