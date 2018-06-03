
--========================================
-- define special find scene base class
--========================================

SFindScene=class(PGSceneBase)

function SFindScene:ctor()
	self.dx = 0
	self.dy = 0
	self.icon = false
	self.alpha = 0
	self.mode = 0
	self.dxV = 0
	self.dyV = 0
	self.analogdx = 127
	self.analogdy = 127

	self.thum = {size=0,index=0}
	self.thumscr = {}

	-- default ini
	self.FIND_ANALOG_SPEED = FIND_ANALOG_SPEED
	self.FIND_ICON_SPEED = FIND_ICON_SPEED
	self.FIND_SOUND = FIND_SOUND
	self.TEST_SOUND = nil
	self.FIND_ICON_DX = FIND_ICON_DX
	self.FIND_ICON_DY = FIND_ICON_DY
end

function SFindScene:init(scr)
	self.dx = self.FIND_ICON_DX
	self.dy = self.FIND_ICON_DY
	if not PGMIOS then
		self.icon = CacheImageLoad(am_pack.res,FIND_ICON,IMG_4444)
	end
	self.mode = 1
	if scr then include(scr) end
end

function SFindScene:fini()
	if self.icon then ImageFree(self.icon) self.icon = nil end
	if self.thum then
		for i=1,self.thum.size do
			self.thum[i]:fini()
			self.thum[i] = nil
		end
		self.thum = nil
	end
	self.thumscr = nil
end

function SFindScene:sethand(file,dx,dy)
	if self.icon then ImageFree(self.icon) self.icon = nil end
	if file then
		self.icon = CacheImageLoad(am_pack.res,file,IMG_4444)
	else
		self.icon = CacheImageLoad(am_pack.res,FIND_ICON,IMG_4444)
	end
	if dx>0 and dx<480-15 and dy>0 and dy<272-15 then
		self.dx = dx
		self.dy = dy
	end
end

function SFindScene:addicon(...)
	if self.thum.size >= 20 then return end
	if arg[2]==nil then
		-- {file,dx,dy,scr}
		self.thum.size = self.thum.size + 1
		self.thum[ self.thum.size ] = PGColorButton.new(am_pack.res,arg[1].file)
		self.thum[ self.thum.size ].dx = arg[1].dx
		self.thum[ self.thum.size ].dy = arg[1].dy
		self.thumscr[ self.thum.size ] = arg[1].scr
	else
		-- file,dx,dy,scr
		self.thum.size = self.thum.size + 1
		self.thum[ self.thum.size ] = PGColorButton.new(am_pack.res,arg[1])
		self.thum[ self.thum.size ].dx = arg[2]
		self.thum[ self.thum.size ].dy = arg[3]
		self.thumscr[ self.thum.size ] = arg[4]
	end
end

function SFindScene:analogspeed(...)
	-- analog_speed,icon_speed
	self.FIND_ANALOG_SPEED = FIND_ANALOG_SPEED
	self.FIND_ICON_SPEED = FIND_ICON_SPEED
	if arg[1] then self.FIND_ANALOG_SPEED=arg[1] end
	if arg[2] then self.FIND_ICON_SPEED=arg[2] end
end

function SFindScene:sounds(...)
	-- press_sound,test_sound
	self.FIND_SOUND=arg[1]
	self.TEST_SOUND=arg[2]
end

function SFindScene:update()

	if self.analogdx < 64 then
		self.dxV = self.dxV - self.FIND_ANALOG_SPEED
	elseif self.analogdx > 192 then
		self.dxV = self.dxV + self.FIND_ANALOG_SPEED
	end
	if self.analogdy < 64 then
		self.dyV = self.dyV - self.FIND_ANALOG_SPEED
	elseif self.analogdy > 192 then
		self.dyV = self.dyV + self.FIND_ANALOG_SPEED
	end

	self.dx = self.dx + self.dxV
	self.dy = self.dy + self.dyV

	if self.dxV < 0 then
		if self.dxV~=-self.FIND_ICON_SPEED then
			self.dxV = self.dxV * 0.98
		end
	else
		if self.dxV~=self.FIND_ICON_SPEED then
			self.dxV = self.dxV * 0.98
		end
	end
	if self.dyV < 0 then
		if self.dyV~=-self.FIND_ICON_SPEED then
			self.dyV = self.dyV * 0.98
		end
	else
		if self.dyV~=self.FIND_ICON_SPEED then
			self.dyV = self.dyV * 0.98
		end
	end

	if self.dx < 0 then
		self.dx = 0
		if self.dxV~=-self.FIND_ICON_SPEED then self.dxV = -self.dxV end
	elseif self.dx > PGM_SCREEN_WIDTH - 15 then
		self.dx = PGM_SCREEN_WIDTH - 15
		if self.dxV~=self.FIND_ICON_SPEED then self.dxV = -self.dxV end
	end

	if self.dy < 0 then
		self.dy = 0
		if self.dyV~=-self.FIND_ICON_SPEED then self.dyV = -self.dyV end
	elseif self.dy > PGM_SCREEN_HEIGHT - 15 then
		self.dy = PGM_SCREEN_HEIGHT - 15
		if self.dyV~=self.FIND_ICON_SPEED then self.dyV = -self.dyV end
	end

	if self.mode==1 then
		self.alpha = self.alpha + 10
		if self.alpha >= 255 then self.alpha = 255 self.mode = 2 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
		for i=1,self.thum.size do
			self.thum[i].alpha = self.alpha
		end
	elseif self.mode==2 then
		-- control

		self.thum.index = 0

		for i=1,self.thum.size do
			local thum = self.thum[i]
			thum.ispress = false
			if self.dx > thum.dx and self.dx < thum.dx + thum.w and self.dy > thum.dy and self.dy < thum.dy + thum.h then
				--thum.ispress = true
				self.thum.index = i
			end
			--thum:update()
		end

		if self.thum.index~=0 then
			self.thum[ self.thum.index ].ispress = true
			if SFIND_CHOSE_INDEX ~= self.thum.index then
				SFIND_CHOSE_INDEX = self.thum.index
				if self.TEST_SOUND then playfile(self.TEST_SOUND,3) end
			end
		else
			SFIND_CHOSE_INDEX = 0
		end

	elseif self.mode==3 then
		self.alpha = self.alpha - 20
		if self.alpha <= 0 then self.alpha = 0 self.mode = 4 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
		for i=1,self.thum.size do
			self.thum[i].alpha = self.alpha
		end
	end

	for i=1,self.thum.size do
		self.thum[i]:update()
	end

	am_scene_update()

end

function SFindScene:render()
	am_scene_render()
	for i=1,self.thum.size do
		self.thum[i]:render()
	end
	if self.icon then
		ImageToScreen(self.icon,self.dx,self.dy)
	end
end

function SFindScene:idle()
	if self.mode==4 then
		--drawevent()
		if self.thumscr[ self.thum.index ] then
			SFIND_CHOSE_INDEX = self.thum.index
			jump(self.thumscr[ self.thum.index ])
			drawevent()
		else
			drawscenebase()
			PGSetState(PGM_QUIT)
		end
	end
end

-- control

function SFindScene:KeyDown(key)
	if self.mode~=2 then return end
	if key==PSP_BUTTON_UP then
		self.dyV = -self.FIND_ICON_SPEED
	elseif key==PSP_BUTTON_DOWN then
		self.dyV = self.FIND_ICON_SPEED
	elseif key==PSP_BUTTON_LEFT then
		self.dxV = -self.FIND_ICON_SPEED
	elseif key==PSP_BUTTON_RIGHT then
		self.dxV = self.FIND_ICON_SPEED
	elseif key==PSP_BUTTON_CIRCLE then
		if self.thum.index > 0 then
			self.mode = 3
			if self.FIND_SOUND then playfile(self.FIND_SOUND,4) end
		end
	end
end

function SFindScene:KeyUp(key)
	if self.mode~=2 then return end
	if key==PSP_BUTTON_UP then
		if self.dyV~=self.FIND_ICON_SPEED then self.dyV = 0 end
	elseif key==PSP_BUTTON_DOWN then
		if self.dyV~=-self.FIND_ICON_SPEED then self.dyV = 0 end
	elseif key==PSP_BUTTON_LEFT then
		if self.dxV~=self.FIND_ICON_SPEED then self.dxV = 0 end
	elseif key==PSP_BUTTON_RIGHT then
		if self.dxV~=-self.FIND_ICON_SPEED then self.dxV = 0 end
	end
end

function SFindScene:AnalogProc(x,y)
	if self.mode~=2 then return end
	self.analogdx = x
	self.analogdy = y
end

function SFindScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	self.dx = dx
	self.dy = dy

	for i=1,self.thum.size do
		local thum = self.thum[i]
		thum.ispress = false
		if self.dx > thum.dx and self.dx < thum.dx + thum.w and self.dy > thum.dy and self.dy < thum.dy + thum.h then
			--thum.ispress = true
			self.thum.index = i
		end
		--thum:update()
	end
	SFIND_CHOSE_INDEX = self.thum.index
end

function SFindScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	self.dx = dx
	self.dy = dy
end

function SFindScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end
	self.dx = dx
	self.dy = dy
	if self.thum.index > 0 then
		self.mode = 3
		if self.FIND_SOUND then playfile(self.FIND_SOUND,4) end
	end
end

--========================================
-- define special find scene functions
--========================================

SFIND_CHOSE_INDEX = 0

function sf_sethand(filename,dx,dy)
	scene:sethand(filename,dx,dy)
end

function sf_addicon(...)
	-- {file,dx,dy,scr}
	-- file,dx,dy,scr
	scene:addicon(...)
end

function sf_analogspeed(...)
	-- analog_speed,icon_speed
	scene:analogspeed(...)
end

function sf_setsounds(...)
	-- press_sound,test_sound
	scene:sounds(...)
end

function sfindtest()
	return SFIND_CHOSE_INDEX
end

-- ================================================

function drawsfind(scr)
	if scene then scene:fini() end
	scene = SFindScene.new()
	scene:init(scr)
	collectgarbage("collect")
end
