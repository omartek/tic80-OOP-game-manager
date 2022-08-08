-- title:  simple scene manager
-- author: digitsensitive
-- desc:   a simple scene manager
-- script: lua

-- global game table
G={
	runtime=0,
	SM={}
}

-- simple scene manager
local scene={}
function scene:new(o)
	o=o or {}
	self.__index=self
	setmetatable(o,self)
	o.timePassed=0
	return o
end

function scene:onExit()
end

function scene:onEnter()
end

local sceneManager={}
function sceneManager:create()
	self.__index=self
	o=setmetatable({},self)
	o.currentScene={}
	o.scenes={}
	return o
end

function sceneManager:addScene(s)
	table.insert(self.scenes,s)
end

function sceneManager:setCurrentScene(s)
	self.currentScene=s
end

function sceneManager:switchScene(s)
	if self.currentScene~=s then
		self.currentScene:onExit()
		self.currentScene=s
		self.currentScene:onEnter()
	end
end

local bootScene=scene:new({})
local mainMenuScene=scene:new({})

function init()
 G.SM=sceneManager:create()
	G.SM:addScene(bootScene)
	G.SM:addScene(mainMenuScene)
	G.SM:setCurrentScene(bootScene)
end

init()

function TIC()
 if btnp(6) then
		if G.SM.currentScene==bootScene then
				G.SM:switchScene(mainMenuScene)
		else
			G.SM:switchScene(bootScene)
		end
	end
	G.SM.currentScene:update()
 G.SM.currentScene:draw()
	G.runtime=G.runtime+1
	printhc("Press A to change the scene",100,4)
	rectb(0,0,240,130,4)
end

-- Boot Scene
bootScene.update=function()
	bootScene.timePassed=
		bootScene.timePassed+1
end

bootScene.draw=function()
 cls()
	printhc("Boot Scene",40,5)
	printhc("Scene time: " .. bootScene.timePassed,50,13)
	printhc("Global time: " .. G.runtime,60,14)
end

-- MainMenu Scene
mainMenuScene.update=function()
	mainMenuScene.timePassed=
		mainMenuScene.timePassed+1
end

mainMenuScene.draw=function()
 cls()
	printhc("Main Menu Scene",40,10)
	printhc("Scene time: " .. mainMenuScene.timePassed,50,13)
	printhc("Global time: " .. G.runtime,60,14)
end

-- short general helper functions
function max(n1,n2) return math.max(n1,n2) end
function printhc(t,y,c)
	local w=print(t,-8,-8)
	local x=(240-w)/2
	print(t,x,y,c)
end
