
--========================================
-- define ramus button class
--========================================

PGRamusButton=class(PGBase)

function PGRamusButton:ctor(...)
	-- drawramus("one",*one,"two",*two,"three",*three)
	local index=0
	self.test = {}
	self.label = {}
	self.sel={}
	for i=1,32,2 do
		if not arg[i] or not arg[i+1] then break end
		index = index + 1
		self.label[index] = arg[i+1]
		self.test[index] = DialogLayer.new()
		self.test[index]:init(
			RAMUS_BUTTON_DX + RAMUS_BUTTON_STEP_DX * (index-1),
			RAMUS_BUTTON_DY + RAMUS_BUTTON_STEP_DY * (index-1),
			480,40,IMG_4444)
		string_to_quad(am_font.pf,FONT_COLOR,
			arg[i],self.test[index].quad,
			0,2,DIALOG_FONT_WIDTH,DIALOG_FONT_HEIGHT,200,100)
		self.sel[index]=arg[i]
	end
	self.test.count = index

	if not PGMIOS then
		self.icon = CacheImageLoad(am_pack.res,RAMUS_ICON,IMG_4444)
	end
	self.icon_dx = RAMUS_ICON_DX
	self.icon_dy = RAMUS_ICON_DY
	self.shakedx = self.icon_dx
	self.shakedy = self.icon_dy
	self.shakestepdx = 0
	self.shakestepdy = 2
	self.shakecount = 0

	self.bg = CacheImageLoad(am_pack.res,RAMUS_BUTTON_BG,IMG_4444)
	self.bg_w = ImageGetW(self.bg)
	self.bg_h = ImageGetH(self.bg) / 2

	self.index = 1

	if PGMIOS then
		self.index = 0
	end
end

function PGRamusButton:fini()
	if self.test then
		for i=1,self.test.count do
			self.test[i]:fini()
			self.test[i] = nil
		end
		self.test = nil
	end
	self.label = nil
	if self.icon then ImageFree(self.icon) self.icon = false end
	if self.bg then ImageFree(self.bg) self.bg = false end
end

function PGRamusButton:update()
	self.shakecount = self.shakecount + 1
	if self.shakecount >= 18 then
		self.shakecount = 0
		self.shakedx = self.icon_dx
		self.shakedy = self.icon_dy + self.shakestepdy
		self.shakestepdy = - self.shakestepdy
	end
end

function PGRamusButton:render()
	if RAMUS_BUTTON_ICON_MODE==2 then
		if self.test then
			for i=1,self.test.count do
				local dx = RAMUS_BUTTON_BG_DX + RAMUS_BUTTON_STEP_DX * (i-1)
				local dy = RAMUS_BUTTON_BG_DY + RAMUS_BUTTON_STEP_DY * (i-1)
				if self.index~=i then
					DrawImage(self.bg,0,0,self.bg_w,self.bg_h,dx,dy,self.bg_w,self.bg_h)
				else
					DrawImage(self.bg,0,self.bg_h,self.bg_w,self.bg_h,dx,dy,self.bg_w,self.bg_h)
				end
				self.test[i]:render(1)
			end
		end
		if self.icon then
			ImageToScreen(self.icon,self.shakedx,self.shakedy)
		end
	elseif RAMUS_BUTTON_ICON_MODE==1 then
		ImageToScreen(self.bg,RAMUS_BUTTON_BG_DX,RAMUS_BUTTON_BG_DY)
		if self.test then
			for i=1,self.test.count do self.test[i]:render(1) end
		end
		if self.icon then
			ImageToScreen(self.icon,self.shakedx,self.shakedy)
		end
	end
end

-- control

function PGRamusButton:KeyDown(key)
	if key==PSP_BUTTON_UP then
		self.index = self.index - 1
		if self.index < 1 then
			self.icon_dx = RAMUS_ICON_DX + RAMUS_ICON_STEP_DX * (self.test.count-1)
			self.icon_dy = RAMUS_ICON_DY + RAMUS_ICON_STEP_DY * (self.test.count-1)
			self.index = self.test.count
		else
			self.icon_dx = self.icon_dx - RAMUS_ICON_STEP_DX
			self.icon_dy = self.icon_dy - RAMUS_ICON_STEP_DY
		end
		self.shakedx = self.icon_dx
		self.shakedy = self.icon_dy
		playfile(RAMUS_SOUND,4)
	elseif key==PSP_BUTTON_DOWN then
		if self.index==0 then
			self.index = self.test.count
		end
		self.index = self.index + 1
		if self.index > self.test.count then
			self.icon_dx = RAMUS_ICON_DX
			self.icon_dy = RAMUS_ICON_DY
			self.index = 1
		else
			self.icon_dx = self.icon_dx + RAMUS_ICON_STEP_DX
			self.icon_dy = self.icon_dy + RAMUS_ICON_STEP_DY
		end
		self.shakedx = self.icon_dx
		self.shakedy = self.icon_dy
		playfile(RAMUS_SOUND,4)
	elseif key==PSP_BUTTON_LEFT then

	elseif key==PSP_BUTTON_RIGHT then

	elseif key==PSP_BUTTON_CIRCLE then
		-- +1 作跳转修正
		if self.index > 0 then
			goto(self.label[ self.index ] + 1)
			am_ramus_fini()
		end
		playfile(RAMUS_SOUND,4)
	end
end

function PGRamusButton:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	for i=1,self.test.count do
		local dx2 = RAMUS_BUTTON_BG_DX + RAMUS_BUTTON_STEP_DX * (i-1)
		local dy2 = RAMUS_BUTTON_BG_DY + RAMUS_BUTTON_STEP_DY * (i-1)
		if dx > dx2 and dx < dx2 + self.bg_w
		and dy > dy2 and dy < dy2 + self.bg_h then
			self.touchindex = i
			self.index = i
			self.icon_dx = RAMUS_ICON_DX + RAMUS_ICON_STEP_DX * (i-1)
			self.icon_dy = RAMUS_ICON_DY + RAMUS_ICON_STEP_DY * (i-1)
			self.shakedx = self.icon_dx
			self.shakedy = self.icon_dy
			--playfile(RAMUS_SOUND,4)
			return
		end
	end
	self.index = 0
	self.icon_dx = -100
	self.icon_dy = 0
	self.shakedx = self.icon_dx
	self.shakedy = self.icon_dy
end

function PGRamusButton:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.index <= 0 then return end

	for i=1,self.test.count do
		local dx2 = RAMUS_BUTTON_BG_DX + RAMUS_BUTTON_STEP_DX * (i-1)
		local dy2 = RAMUS_BUTTON_BG_DY + RAMUS_BUTTON_STEP_DY * (i-1)
		if dx > dx2 and dx < dx2 + self.bg_w
		and dy > dy2 and dy < dy2 + self.bg_h then
			self.index = i
			self.icon_dx = RAMUS_ICON_DX + RAMUS_ICON_STEP_DX * (i-1)
			self.icon_dy = RAMUS_ICON_DY + RAMUS_ICON_STEP_DY * (i-1)
			self.shakedx = self.icon_dx
			self.shakedy = self.icon_dy
			if self.touchindex~=i then
				self.touchindex = i
				--playfile(RAMUS_SOUND,4)
			end
			return
		end
	end
	self.index = 0
	self.icon_dx = -100
	self.icon_dy = 0
	self.shakedx = self.icon_dx
	self.shakedy = self.icon_dy
end

function PGRamusButton:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.index > 0 and self.index <= self.test.count then
		goto(self.label[ self.index ] + 1)
		am_ramus_fini()
		playfile(RAMUS_SOUND,4)
	end
end

function PGRamusButton:ispress()
	return self.index > 0
end


--========================================
-- define ramus scene class
--========================================

PGRamusScene=class(PGSceneBase)

function PGRamusScene:ctor(...)
	if not am_ramus then
		am_ramus = PGRamusButton.new(...)
		am_ramus:init()
		--print("创建分支显示场景")
	end
	self.colorV = 6
	self.coloralpha = 0
end

function PGRamusScene:update()
	self.coloralpha = self.coloralpha + self.colorV
	if self.coloralpha <= 50 then
		self.coloralpha = 50
		self.colorV = -self.colorV
	elseif self.coloralpha >= 180 then
		self.coloralpha = 180
		self.colorV = -self.colorV
	end
	am_ramus_update()
	am_scene_update()
end

function PGRamusScene:render()
	am_scene_render()
	if self.touchindex==1111 then
		filluprect(self.coloralpha)
	end
end

function PGRamusScene:KeyDown(key)
	if am_ramus then am_ramus:KeyDown(key) end
	if key==PSP_BUTTON_START then
		if not call_menu_flag then
			return
		end
		drawmenu()
		playfile(DEFAULT_SOUND,4)
	elseif key==PSP_BUTTON_SELECT then
		--show_helper("help.png")		-- 呼出帮助文件
	elseif key==PSP_BUTTON_LEFT_TRIGGER then
		--show_strategy(strategy_img)	-- 呼出攻略
	end
end

function PGRamusScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	if am_ramus then
		am_ramus:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
		if am_ramus:ispress() then return end
	end
	if testuprect(dx,dy) then
		if not call_menu_flag then
			return
		end
		self.touchindex = 1111
		self.coloralpha = 0
		return
	end
end

function PGRamusScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if am_ramus then
		am_ramus:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
		if am_ramus:ispress() then return end
	end
	if self.touchindex==1111 then
		if not testuprect(dx,dy) then
			self.touchindex = false
			return
		end
	end
end

function PGRamusScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if am_ramus and am_ramus:ispress() then
		am_ramus:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
		return
	end
	if self.touchindex==1111 then
		playfile(DEFAULT_SOUND,4)
		self.touchindex = false
		return drawmenu()
	end
	self.touchindex = false
end

function PGRamusScene:idle()
	if am_ramus==false then drawevent() end
end

-- ================================================

function drawramus(...)
	if scene then scene:fini() end
	scene = PGRamusScene.new(...)
	scene:init()
	collectgarbage("collect")
end
