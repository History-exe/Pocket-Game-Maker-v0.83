
--========================================
-- define menu scene base class
--========================================

PGMenuScene=class(PGSceneBase)

function PGMenuScene:ctor()
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
	self.box = false

	self.colorV = 6
	self.coloralpha = 0
end

function PGMenuScene:init()
	self.dx = MENU_ICON_DX
	self.dy = MENU_ICON_DY
	self.shakedx = self.dx
	self.shakedy = self.dy

	if not PGMIOS then
		self.icon = CacheImageLoad(am_pack.res,MENU_ICON,IMG_4444)
	end
	self.mode = 1
	self.index = 1

	--self.box = CacheImageLoad(am_pack.res,MENU_BOX,IMG_8888)

	for i=1,MENU_BUTTON_COUNT,1 do
		self.menu[i] = PGColorButton.new(am_pack.res,MENU_BUTTON[i])
		self.menu[i].dx = MENU_BUTTON_DX + MENU_BUTTON_STEP_DX * (i-1)
		self.menu[i].dy = MENU_BUTTON_DY + MENU_BUTTON_STEP_DY * (i-1)
		self.menu[i].alpha = 0
	end

	if PGMIOS or PGMARD then
		self.index = 0
	end
end

function PGMenuScene:fini()
	if self.icon then ImageFree(self.icon) self.icon = nil end
	if self.box then ImageFree(self.box) self.box = nil end
	for i=1,MENU_BUTTON_COUNT do
		if self.menu and self.menu[i] then
			self.menu[i]:fini()
			self.menu[i] = nil
		end
	end
	self.menu = nil
end

function PGMenuScene:update()

	self.coloralpha = self.coloralpha + self.colorV
	if self.coloralpha <= 50 then
		self.coloralpha = 50
		self.colorV = -self.colorV
	elseif self.coloralpha >= 180 then
		self.coloralpha = 180
		self.colorV = -self.colorV
	end

	if am_dialog then am_dialog:update() end

	self.shakecount = self.shakecount + 1
	if self.shakecount >= 10 then
		self.shakecount = 0
		self.shakedx = self.dx
		self.shakedy = self.dy + self.shakestepdy
		self.shakestepdy = - self.shakestepdy
	end

	for i=1,MENU_BUTTON_COUNT do
		self.menu[i].ispress = false
	end
	if self.index>0 then
		self.menu[self.index].ispress = true
	end

	if self.mode==1 then
		self.alpha = self.alpha + 10
		if self.alpha >= 255 then self.alpha = 255 self.mode = 2 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
		if self.box then ImageSetMask(self.box,MAKE_RGBA_8888(255,255,255,self.alpha)) end
		for i=1,MENU_BUTTON_COUNT do
			self.menu[i].alpha = self.alpha
			self.menu[i]:update()
		end
	elseif self.mode==2 then
		-- control
	elseif self.mode==3 then
		self.alpha = self.alpha - 20
		if self.alpha <= 0 then self.alpha = 0 self.mode = 4 end
		if self.icon then ImageSetMask(self.icon,MAKE_RGBA_4444(255,255,255,self.alpha)) end
		if self.box then ImageSetMask(self.box,MAKE_RGBA_8888(255,255,255,self.alpha)) end
		for i=1,MENU_BUTTON_COUNT do
			self.menu[i].alpha = self.alpha
			self.menu[i]:update()
		end
	end

	am_scene_update()
end

function PGMenuScene:render()
	am_scene_render()
	if self.box then ImageToScreen(self.box,MENU_BOX_DX,MENU_BOX_DY) end
	for i=1,MENU_BUTTON_COUNT do
		-- render menu
		if self.menu and self.menu[i] then self.menu[i]:render() end
	end
	if self.icon then ImageToScreen(self.icon,self.shakedx,self.shakedy) end

	if self.touchindex==1111 then
		filluprect(self.coloralpha)
	end
end

function PGMenuScene:idle()
	if self.mode==4 then
		--drawevent()
		if MENU_ICON_INDEX==0 then
			drawevent()
			return
		end
		if menu_callback then
			menu_callback()
		else
			print("title callback function is nil. system exit ...")
			drawscenebase()
			PGSetState(PGM_QUIT)
		end
	end
end

-- control

function PGMenuScene:IconBack()
	self.index = self.index - 1
	if self.index < 1 then
		self.index = MENU_BUTTON_COUNT
		self.dx = MENU_ICON_DX + (self.index-1) * MENU_ICON_STEP_DX
		self.dy = MENU_ICON_DY + (self.index-1) * MENU_ICON_STEP_DY
	else
		self.dx = self.dx - MENU_ICON_STEP_DX
		self.dy = self.dy - MENU_ICON_STEP_DY
	end
	self.shakedx = self.dx
	self.shakedy = self.dy
end

function PGMenuScene:IconNext()
	self.index = self.index + 1
	if self.index > MENU_BUTTON_COUNT then
		self.index = 1
		self.dx = MENU_ICON_DX
		self.dy = MENU_ICON_DY
	elseif self.index==1 then
		self.dx = MENU_ICON_DX
		self.dy = MENU_ICON_DY
	else
		self.dx = self.dx + MENU_ICON_STEP_DX
		self.dy = self.dy + MENU_ICON_STEP_DY
	end
	self.shakedx = self.dx
	self.shakedy = self.dy
end

function PGMenuScene:KeyDown(key)
	if self.mode~=2 then return end
	if MENU_CONTROL_MODE==1 then
		if key==PSP_BUTTON_LEFT then
			self:IconBack()
			playfile(MENU_SOUND,4)
		elseif key==PSP_BUTTON_RIGHT then
			self:IconNext()
			playfile(MENU_SOUND,4)
		end
	elseif MENU_CONTROL_MODE==2 then
		if key==PSP_BUTTON_UP then
			self:IconBack()
			playfile(MENU_SOUND,4)
		elseif key==PSP_BUTTON_DOWN then
			self:IconNext()
			playfile(MENU_SOUND,4)
		end
	end

	if key==PSP_BUTTON_CIRCLE then
		if self.index > 0 then
			self.mode = 3
			MENU_ICON_INDEX = self.index
		end
		playfile(MENU_SOUND,4)
	elseif key==PSP_BUTTON_CROSS then
		self.mode = 3
		MENU_ICON_INDEX = 0
		playfile(MENU_SOUND,4)
	end
end

function PGMenuScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end
	for i=1,MENU_BUTTON_COUNT do
		if dx > self.menu[i].dx and dx < self.menu[i].dx + self.menu[i].w
		and dy > self.menu[i].dy and dy < self.menu[i].dy + self.menu[i].h then
			self.index = i
			self.touchindex = i
			self.dx = MENU_ICON_DX + (i-1) * MENU_ICON_STEP_DX
			self.dy = MENU_ICON_DY + (i-1) * MENU_ICON_STEP_DY
			self.shakedx = self.dx
			self.shakedy = self.dy
			--playfile(MENU_SOUND,4)
			return
		end
	end
	self.index = 0
	self.dx = -100
	self.dy = 0
	self.shakedx = self.dx
	self.shakedy = self.dy

	if testuprect(dx,dy) then
		self.touchindex = 1111
		self.coloralpha = 0
	else
		self.touchindex = false
	end
end

function PGMenuScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end
	if self.index > 0 then
		for i=1,MENU_BUTTON_COUNT do
			if dx > self.menu[i].dx and dx < self.menu[i].dx + self.menu[i].w
			and dy > self.menu[i].dy and dy < self.menu[i].dy + self.menu[i].h then
				self.index = i
				self.dx = MENU_ICON_DX + (i-1) * MENU_ICON_STEP_DX
				self.dy = MENU_ICON_DY + (i-1) * MENU_ICON_STEP_DY
				self.shakedx = self.dx
				self.shakedy = self.dy
				if self.touchindex~=i then
					self.touchindex = i
					--playfile(MENU_SOUND,4)
				end
				return
			end
		end
		self.index = 0
		self.dx = -100
		self.dy = 0
		self.shakedx = self.dx
		self.shakedy = self.dy
	end

	if self.touchindex==1111 then
		if not testuprect(dx,dy) then
			self.touchindex = false
		end
	end
end

function PGMenuScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.mode~=2 then return end
	if self.index > 0 then
		self.mode = 3
		MENU_ICON_INDEX = self.index
		playfile(MENU_SOUND,4)
	end
	if self.touchindex==1111 then
		self.mode = 3
		MENU_ICON_INDEX = 0
		playfile(MENU_SOUND,4)
	end
	self.touchindex=false
end

function menutest()
	return MENU_ICON_INDEX
end

-- ================================================

function drawmenu()
	if scene then scene:fini() end
	scene = PGMenuScene.new()
	scene:init()
	collectgarbage("collect")
end
