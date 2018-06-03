
--========================================
-- define title scene base class
--========================================

PGTitleScene=class(PGSceneBase)

function PGTitleScene:ctor(...)
	self.dx = 0
	self.dy = 0
	self.icon = false
	self.alpha = 0
	self.mode = 0
	self.index = 0
	self.shakedx = 0
	self.shakedy = 0
	self.shakecount = 0
	self.shakestepdy = 2
	self.menu = {}
	self.label = {}
	self.label.count = TITLE_BUTTON_COUNT
	for i=1,TITLE_BUTTON_COUNT do
		self.label[i] = arg[i]
	end
end

function PGTitleScene:init()
	self.dx = TITLE_ICON_DX
	self.dy = TITLE_ICON_DY
	self.shakedx = self.dx
	self.shakedy = self.dy
	if not PGMIOS then
		self.icon = CacheImageLoad(am_pack.res,TITLE_ICON,IMG_4444)
	end
	self.mode = 1
	self.index = 1

	for i=1,TITLE_BUTTON_COUNT do
		self.menu[i] = PGColorButton.new(am_pack.res,TITLE_BUTTON[i])
		self.menu[i].dx = TITLE_BUTTON_DX + TITLE_BUTTON_STEP_DX * (i-1)
		self.menu[i].dy = TITLE_BUTTON_DY + TITLE_BUTTON_STEP_DY * (i-1)
		self.menu[i].alpha = 0
	end

	if PGMIOS then
		self.index = 0
	end
end

function PGTitleScene:fini()
	if self.icon then ImageFree(self.icon) self.icon = nil end
	for i=1,TITLE_BUTTON_COUNT do
		if self.menu and self.menu[i] then
			self.menu[i]:fini()
			self.menu[i] = nil
		end
	end
	self.menu = nil
	self.label = nil
end

function PGTitleScene:update()

	self.shakecount = self.shakecount + 1
	if self.shakecount >= 10 then
		self.shakecount = 0
		self.shakedx = self.dx
		self.shakedy = self.dy + self.shakestepdy
		self.shakestepdy = - self.shakestepdy
	end

	for i=1,TITLE_BUTTON_COUNT do
		self.menu[i].ispress = false
	end
	if self.index~=0 then
		self.menu[self.index].ispress = true
	end

	if self.mode==1 then
		self.alpha = self.alpha + 10
		if self.alpha >= 255 then self.alpha = 255 self.mode = 2 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
		for i=1,TITLE_BUTTON_COUNT do
			self.menu[i].alpha = self.alpha
			self.menu[i]:update()
		end
	elseif self.mode==2 then
		-- control
	elseif self.mode==3 then
		self.alpha = self.alpha - 20
		if self.alpha <= 0 then self.alpha = 0 self.mode = 4 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
		for i=1,TITLE_BUTTON_COUNT do
			self.menu[i].alpha = self.alpha
			self.menu[i]:update()
		end
	end

	am_scene_update()
end

function PGTitleScene:render()
	am_scene_render()
	for i=1,TITLE_BUTTON_COUNT do
		-- render menu
		if self.menu and self.menu[i] then self.menu[i]:render() end
	end
	if self.icon then ImageToScreen(self.icon,self.shakedx,self.shakedy) end
end

function PGTitleScene:idle()
	if self.mode==4 then
		--drawevent()
		if title_callback then
			title_callback()
		else
			print("title callback function is nil. system exit ...")
			drawscenebase()
			PGSetState(PGM_QUIT)
		end
	end
end

-- control

function PGTitleScene:IconBack()
	self.index = self.index - 1
	if self.index < 1 then
		self.index = TITLE_BUTTON_COUNT
		self.dx = TITLE_ICON_DX + (self.index-1) * TITLE_ICON_STEP_DX
		self.dy = TITLE_ICON_DY + (self.index-1) * TITLE_ICON_STEP_DY
	else
		self.dx = self.dx - TITLE_ICON_STEP_DX
		self.dy = self.dy - TITLE_ICON_STEP_DY
	end
	self.shakedx = self.dx
	self.shakedy = self.dy
end

function PGTitleScene:IconNext()
	self.index = self.index + 1
	if self.index > TITLE_BUTTON_COUNT then
		self.index = 1
		self.dx = TITLE_ICON_DX
		self.dy = TITLE_ICON_DY
	elseif self.index==1 then
		self.dx = TITLE_ICON_DX
		self.dy = TITLE_ICON_DY
	else
		self.dx = self.dx + TITLE_ICON_STEP_DX
		self.dy = self.dy + TITLE_ICON_STEP_DY
	end
	self.shakedx = self.dx
	self.shakedy = self.dy
end

function PGTitleScene:KeyDown(key)
	if self.mode~=2 then return end

	if TITLE_CONTROL_MODE==1 then
		if key==PSP_BUTTON_LEFT then
			self:IconBack()
			playfile(TITLE_SOUND,4)
		elseif key==PSP_BUTTON_RIGHT then
			self:IconNext()
			playfile(TITLE_SOUND,4)
		end
	elseif TITLE_CONTROL_MODE==2 then
		if key==PSP_BUTTON_UP then
			self:IconBack()
			playfile(TITLE_SOUND,4)
		elseif key==PSP_BUTTON_DOWN then
			self:IconNext()
			playfile(TITLE_SOUND,4)
		end
	end

	if key==PSP_BUTTON_CIRCLE then
		if self.index > 0 then
			self.mode = 3
			TITLE_ICON_INDEX = self.index
			goto( self.label[ self.index ] + 1 )
		end
		playfile(TITLE_SOUND,4)
	end
end

function PGTitleScene:TestTitleRect(dx,dy)
	for i=1,TITLE_BUTTON_COUNT do
		if dx > self.menu[i].dx and dx < self.menu[i].dx + self.menu[i].w and dy > self.menu[i].dy and dy < self.menu[i].dy + self.menu[i].h then
			return i
		end
	end
	return 0
end

function PGTitleScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end
	self.index = self:TestTitleRect(dx,dy)
	self.temp_index = self.index
	if self.index==0 then
		self.dx = -100
		self.dy = -100
		self.shakedx = self.dx
		self.shakedy = self.dy
	else
		self.dx = TITLE_ICON_DX + (self.index-1) * TITLE_ICON_STEP_DX
		self.dy = TITLE_ICON_DY + (self.index-1) * TITLE_ICON_STEP_DY
		self.shakedx = self.dx
		self.shakedy = self.dy
		--playfile(TITLE_SOUND,4)
	end
end

function PGTitleScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end

	if self.index==0 then
		return
	end

	self.index = self:TestTitleRect(dx,dy)
	if self.index==0 then
		self.dx = -100
		self.dy = -100
		self.shakedx = self.dx
		self.shakedy = self.dy
	else
		self.dx = TITLE_ICON_DX + (self.index-1) * TITLE_ICON_STEP_DX
		self.dy = TITLE_ICON_DY + (self.index-1) * TITLE_ICON_STEP_DY
		self.shakedx = self.dx
		self.shakedy = self.dy
		if self.temp_index~=self.index then
			self.temp_index = self.index
			--playfile(TITLE_SOUND,4)
		end
	end
end

function PGTitleScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end
	if self.index ~= 0 then
		self.mode = 3
		TITLE_ICON_INDEX = self.index
		goto( self.label[ self.index ] + 1 )
		playfile(TITLE_SOUND,4)
	end
end

function titletest()
	return TITLE_ICON_INDEX
end

-- ================================================

function drawtitle(...)
	if scene then scene:fini() end
	scene = PGTitleScene.new(...)
	scene:init()
	collectgarbage("collect")
end
