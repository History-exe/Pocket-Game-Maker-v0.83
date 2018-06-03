
WaitKeyScene=class(PGSceneBase)

function WaitKeyScene:ctor(key)
	self.key = key
	if not key then
		self.key = PSP_BUTTON_CIRCLE
	end
	self.ispress = false
	am_scene_update()
end

function WaitKeyScene:render()
	am_scene_render()
end

function WaitKeyScene:idle()
	if self.ispress then
		drawevent()
	end
end

function WaitKeyScene:KeyDown(key)
	if key==self.key then
		self.ispress = true
		playfile(DEFAULT_SOUND,4)
	end
end

function WaitKeyScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	self.ispress = true
end

-- ================================================

function waitforkey(key)
	if scene then scene:fini() end
	scene = WaitKeyScene.new(key)
	scene:init()
	collectgarbage("collect")
end
