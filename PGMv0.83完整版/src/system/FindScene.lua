
--========================================
-- define find scene base class
--========================================

PGFindScene=class(PGSceneBase)

function PGFindScene:ctor()
	self.dx = 0
	self.dy = 0
	self.icon = false
	self.alpha = 0
	self.mode = 0
	self.dxV = 0
	self.dyV = 0
	self.analogdx = 127
	self.analogdy = 127
end

function PGFindScene:init(scr)
	self.dx = FIND_ICON_DX
	self.dy = FIND_ICON_DY
	if not PGMIOS then
		self.icon = CacheImageLoad(am_pack.res,FIND_ICON,IMG_4444)
	end
	self.mode = 1
	if scr then
		am_rect_allreset()
		include(scr)
	end
end

function PGFindScene:fini()
	if self.icon then ImageFree(self.icon) self.icon = nil end
end

function PGFindScene:update()

	if self.analogdx < 64 then
		self.dxV = self.dxV - FIND_ANALOG_SPEED
	elseif self.analogdx > 192 then
		self.dxV = self.dxV + FIND_ANALOG_SPEED
	end
	if self.analogdy < 64 then
		self.dyV = self.dyV - FIND_ANALOG_SPEED
	elseif self.analogdy > 192 then
		self.dyV = self.dyV + FIND_ANALOG_SPEED
	end

	self.dx = self.dx + self.dxV
	self.dy = self.dy + self.dyV

	if self.dxV < 0 then
		if self.dxV~=-FIND_ICON_SPEED then
			self.dxV = self.dxV * 0.98
		end
	else
		if self.dxV~=FIND_ICON_SPEED then
			self.dxV = self.dxV * 0.98
		end
	end
	if self.dyV < 0 then
		if self.dyV~=-FIND_ICON_SPEED then
			self.dyV = self.dyV * 0.98
		end
	else
		if self.dyV~=FIND_ICON_SPEED then
			self.dyV = self.dyV * 0.98
		end
	end

	if self.dx < 0 then
		self.dx = 0
		if self.dxV~=-FIND_ICON_SPEED then self.dxV = -self.dxV end
	elseif self.dx > PGM_SCREEN_WIDTH - 15 then
		self.dx = PGM_SCREEN_WIDTH - 15
		if self.dxV~=FIND_ICON_SPEED then self.dxV = -self.dxV end
	end

	if self.dy < 0 then
		self.dy = 0
		if self.dyV~=-FIND_ICON_SPEED then self.dyV = -self.dyV end
	elseif self.dy > PGM_SCREEN_HEIGHT - 15 then
		self.dy = PGM_SCREEN_HEIGHT - 15
		if self.dyV~=FIND_ICON_SPEED then self.dyV = -self.dyV end
	end

	if self.mode==1 then
		self.alpha = self.alpha + 10
		if self.alpha >= 255 then self.alpha = 255 self.mode = 2 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
	elseif self.mode==2 then
		-- control
		am_rect.dx = self.dx + 2
		am_rect.dy = self.dy + 2
	elseif self.mode==3 then
		self.alpha = self.alpha - 20
		if self.alpha <= 0 then self.alpha = 0 self.mode = 4 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
	end

	am_scene_update()
end

function PGFindScene:render()
	am_scene_render()
	if self.icon then
		ImageToScreen(self.icon,self.dx,self.dy)
	end
end

function PGFindScene:idle()
	if self.mode==4 then
		--drawevent()
		if find_callback then
			find_callback()
		else
			print("find callback function is nil. system exit ...")
			drawscenebase()
			PGSetState(PGM_QUIT)
		end
	end
end

-- control

function PGFindScene:KeyDown(key)
	if self.mode~=2 then return end
	if key==PSP_BUTTON_UP then
		self.dyV = -FIND_ICON_SPEED
	elseif key==PSP_BUTTON_DOWN then
		self.dyV = FIND_ICON_SPEED
	elseif key==PSP_BUTTON_LEFT then
		self.dxV = -FIND_ICON_SPEED
	elseif key==PSP_BUTTON_RIGHT then
		self.dxV = FIND_ICON_SPEED
	elseif key==PSP_BUTTON_CIRCLE then
		local index = testrect(self.dx+2,self.dy+2)
		if index > 0 then
			self.mode = 3
			am_rect.dx = self.dx + 2
			am_rect.dy = self.dy + 2
			playfile(FIND_SOUND,4)
		end
	end
end

function PGFindScene:KeyUp(key)
	if self.mode~=2 then return end
	if key==PSP_BUTTON_UP then
		if self.dyV~=FIND_ICON_SPEED then self.dyV = 0 end
	elseif key==PSP_BUTTON_DOWN then
		if self.dyV~=-FIND_ICON_SPEED then self.dyV = 0 end
	elseif key==PSP_BUTTON_LEFT then
		if self.dxV~=FIND_ICON_SPEED then self.dxV = 0 end
	elseif key==PSP_BUTTON_RIGHT then
		if self.dxV~=-FIND_ICON_SPEED then self.dxV = 0 end
	end
end

function PGFindScene:AnalogProc(x,y)
	if self.mode~=2 then return end
	self.analogdx = x
	self.analogdy = y
end

function PGFindScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	self.dx = dx
	self.dy = dy
end

function PGFindScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	self.dx = dx
	self.dy = dy
end

function PGFindScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end
	self.dx = dx
	self.dy = dy
	local index = testrect(self.dx+2,self.dy+2)
	if index > 0 then
		self.mode = 3
		am_rect.dx = self.dx + 2
		am_rect.dy = self.dy + 2
		playfile(FIND_SOUND,4)
	end
end

-- ================================================

function drawfind(scr)
	if scene then scene:fini() end
	scene = PGFindScene.new()
	scene:init(scr)
	collectgarbage("collect")
end
