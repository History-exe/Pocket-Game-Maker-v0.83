
--========================================
-- define sav file scene class
--========================================

SaveFilePreview=class(PGBase)

function SaveFilePreview:ctor( num )
	-- data.sfo, pic.png
	local sfo = GetFullGameDataFolderPath(num) .. "/DATA.SFO"
	local view = GetFullGameDataFolderPath(num) .. "/PIC.TGA"

	if FileIsExist(view) then
		self.icon = ImageLoad(view,IMG_4444)
	else
		self.icon = ImageLoad(am_pack.res,SAVE_UI_DEFAULT,IMG_4444)
	end
	self.icondx = 90
	self.icondy = 20
	self.iconscale = 0.56
	self.scalecount = 0.004

	self.isexist = false

	if FileIsExist(sfo) then
		local buffer,size = PGBufferCreate(sfo)
		-- init
		local temp = LoadGameDataInfo( buffer )
		FontSetColor(am_font.pf,MAKE_RGBA_4444(0,0,0,255))

		self.title = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.title,temp.gamename,2,2)

		local time = temp.time.year .. "/" .. temp.time.month .. "/" .. temp.time.day .. "  " .. temp.time.hour .. ":" .. temp.time.minutes .. ":" .. temp.time.seconds
		self.data = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.data,time,2,2)

		self.details = ImageCreate(480,40,IMG_4444)
		FontDraw(am_font.pf,self.details,temp.msg,2,2)

		FontSetColor(am_font.pf,FONT_COLOR)
		-- fini
		PGBufferDelete(bufer)

		self.isexist = true
	else
		FontSetColor(am_font.pf,MAKE_RGBA_4444(0,0,0,255))
		self.title = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.title,"NO DATA",2,2)
		self.data = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.data,"AAAA/AA/AA  AA:AA:AA",2,2)
		self.details = ImageCreate(480,40,IMG_4444)
		FontDraw(am_font.pf,self.details,"NO DETAILS",2,2)
		FontSetColor(am_font.pf,FONT_COLOR)
	end

	self.titledx = 0
	self.titledy = 0

	self.datadx = 165
	self.datady = PGM_ORI_SCREEN_HEIGHT * 0.78
	self.clipx = self.datadx
	self.clipy = self.datady

	self.detailsdx = 0
	self.detailsdy = PGM_ORI_SCREEN_HEIGHT * 0.92

	self.alpha = 0
	self.count = 0

	local mask = MAKE_RGBA_4444(255,255,255,0)
	--ImageSetMask(self.icon,mask)
	ImageSetMask(self.data,mask)
	ImageSetMask(self.details,mask)
end

function SaveFilePreview:init( num )
	local sfo = GetFullGameDataFolderPath(num) .. "/DATA.SFO"
	local view = GetFullGameDataFolderPath(num) .. "/PIC.TGA"

	if FileIsExist(view) then
		self.icon = ImageLoad(view,IMG_4444)
	else
		self.icon = ImageLoad(am_pack.res,SAVE_UI_DEFAULT,IMG_4444)
	end

	self.isexist = false

	if FileIsExist(sfo) then
		local buffer,size = PGBufferCreate(sfo)
		-- init
		local temp = LoadGameDataInfo( buffer )
		FontSetColor(am_font.pf,MAKE_RGBA_4444(0,0,0,255))

		self.title = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.title,temp.gamename,2,2)

		local time = temp.time.year .. "/" .. temp.time.month .. "/" .. temp.time.day .. "  " .. temp.time.hour .. ":" .. temp.time.minutes .. ":" .. temp.time.seconds
		self.data = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.data,time,2,2)

		self.details = ImageCreate(480,40,IMG_4444)
		FontDraw(am_font.pf,self.details,temp.msg,2,2)

		FontSetColor(am_font.pf,FONT_COLOR)
		-- fini
		PGBufferDelete(bufer)

		self.isexist = true
	else
		FontSetColor(am_font.pf,MAKE_RGBA_4444(0,0,0,255))
		self.title = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.title,"NO DATA",2,2)
		self.data = ImageCreate(240,40,IMG_4444)
		FontDraw(am_font.pf,self.data,"AAAA/AA/AA  AA:AA:AA",2,2)
		self.details = ImageCreate(480,40,IMG_4444)
		FontDraw(am_font.pf,self.details,"NO DETAILS",2,2)
		FontSetColor(am_font.pf,FONT_COLOR)
	end

	self.alpha = 0
	self.count = 0

	local mask = MAKE_RGBA_4444(255,255,255,0)
	--ImageSetMask(self.icon,mask)
	ImageSetMask(self.data,mask)
	ImageSetMask(self.details,mask)
end

function SaveFilePreview:fini()
	if self.icon then ImageFree(self.icon) self.icon = nil end
	if self.title then ImageFree(self.title) self.title = nil end
	if self.data then ImageFree(self.data) self.data = nil end
	if self.details then ImageFree(self.details) self.details = nil end
end

function SaveFilePreview:update()
	self.count = self.count + 1
	if self.count > 5 then
		self.count = 0
		self.alpha = self.alpha + 20
		if self.alpha >= 255 then self.alpha = 255 end
		local mask = MAKE_RGBA_4444(255,255,255,self.alpha)
		--ImageSetMask(self.icon,mask)
		ImageSetMask(self.data,mask)
		ImageSetMask(self.details,mask)
	end

	self.detailsdx = self.detailsdx - 1.6
	if self.detailsdx < -480 then
		self.detailsdx = self.detailsdx + 480
	end

	self.datadx = self.datadx - 0.4
	if self.datadx < 165-200 then
		self.datadx = self.datadx + 200
	end

	self.iconscale = self.iconscale + self.scalecount
	if self.iconscale > 0.625 or self.iconscale < 0.56 then
		self.scalecount = -self.scalecount
	end
end

function SaveFilePreview:render()
	ImageToScreen(self.title,self.titledx,self.titledy)

	SetClip(self.clipx,self.clipy,150,40)
	ImageToScreen(self.data,self.datadx,self.datady)
	ImageToScreen(self.data,self.datadx+200,self.datady)
	ResetClip()

	ImageToScreen(self.details,self.detailsdx,self.detailsdy)
	ImageToScreen(self.details,self.detailsdx+480,self.detailsdy)
	
	local w=PGM_ORI_SCREEN_WIDTH*self.iconscale
	local h=PGM_ORI_SCREEN_HEIGHT*self.iconscale

	if PGMARD then
		DrawImage(self.icon,0,0,0,0,(PGM_ORI_SCREEN_WIDTH/2)-w/2,(PGM_ORI_SCREEN_HEIGHT*0.4)-h/2+h,w,-h)
	else
		DrawImage(self.icon,0,0,0,0,(PGM_ORI_SCREEN_WIDTH/2)-w/2,(PGM_ORI_SCREEN_HEIGHT*0.4)-h/2,w,h)
	end
end

function SaveFilePreview:isfadefinish()
	return (self.alpha >= 255)
end

function SaveFilePreview:FileIsExist()
	return self.isexist
end

--========================================

SAVE_MODE_LOAD = 0
SAVE_MODE_SAVE = 1
SAVE_MODE_DELETE = 2

SaveUIScene=class(PGSceneBase)

function SaveUIScene:ctor(mode)
	self.macro = {
		fadein=0,
		fadeout=1,
		preview=2,	-- skip preview and control
		select=3,
		makesure=4,
	}

	FontResize(am_font.pf,26)
	FontSetColor(am_font.pf,MAKE_RGBA_4444(127,0,127,255))
	self.quad = {}
	for i=1,10 do
		self.quad[i] = ImageCreate(32,32,IMG_4444)
		FontDraw(am_font.pf,self.quad[i],""..(i-1),2,2)
	end
	FontResize(am_font.pf,FONT_SIZE)
	FontSetColor(am_font.pf,FONT_COLOR)

	self.screen = false
	self.ui = ImageLoad(am_pack.res,SAVE_UI_FILE,IMG_8888)

	self.loading = ImageLoad(am_pack.res,SAVE_UI_LOADING,IMG_4444)
	self.angle = 0
	self.lasttick = 0

	self.view = false
	self.mode = mode
	self.test = false

	self.alpha = 0
	self.count = 0

	self.flag={load=false,save=false}

	ImageSetMask(self.ui,MAKE_RGBA_8888(255,255,255,0))

	if mode==SAVE_MODE_SAVE then
		for i=1,GAME_SAVELISTSIZE do
			local sfo = GetFullGameDataFolderPath(i-1) .. "/DATA.SFO"
			if not FileIsExist(sfo) then
				self.number = i - 1
				break
			end
		end
	elseif mode==SAVE_MODE_LOAD then
		for i=1,GAME_SAVELISTSIZE do
			local sfo = GetFullGameDataFolderPath(i-1) .. "/DATA.SFO"
			if not FileIsExist(sfo) then
				self.number = i - 2
				break
			end
		end
	else
		self.number = 0
	end

	if not self.number or self.number < 0 then self.number = 0 end

	self.colorV = 6
	self.coloralpha = 0
end

function SaveUIScene:init()
	
end

function SaveUIScene:fini()
	self.macro = nil
	for i=1,10 do
		if self.quad[i] then
			ImageFree(self.quad[i])
			self.quad[i] = nil
		end
	end
	self.quad = nil
	if self.screen then
		ImageFree(self.screen)
		self.screen = nil
	end
	if self.ui then
		ImageFree(self.ui)
		self.ui = nil
	end
	if self.loading then
		ImageFree(self.loading)
		self.loading = nil
	end
	if self.view then
		self.view:fini()
		self.view = nil
	end
end

function SaveUIScene:update()
	self.coloralpha = self.coloralpha + self.colorV
	if self.coloralpha <= 50 then
		self.coloralpha = 50
		self.colorV = -self.colorV
	elseif self.coloralpha >= 180 then
		self.coloralpha = 180
		self.colorV = -self.colorV
	end

	am_scene_update()

	if self.state==self.macro.fadein then
		self.count = self.count + 1
		if self.count > 2 then
			self.count = 0
			self.alpha = self.alpha + 22
			if self.alpha >= 200 then
				self.alpha = 200
				self.state = self.macro.previw
				self.lasttick = TimerGetTicks(am_timer)
			end
			ImageSetMask(self.ui,MAKE_RGBA_8888(255,255,255,self.alpha))
		end
	elseif self.state==self.macro.previw then
		if TimerGetTicks(am_timer) - self.lasttick > 20 then
			self.lasttick = TimerGetTicks(am_timer)
			self.angle = self.angle + 16
			if self.angle > 360 then
				self.angle = self.angle - 360
				self.state = self.macro.select
				self:viewinit( self.number )
			end
		end
	elseif self.state==self.macro.select then
		if self.view then self.view:update() end
	elseif self.state==self.macro.fadeout then
		self.count = self.count + 1
		if self.count > 2 then
			self.count = 0
			self.alpha = self.alpha - 25
			if self.alpha <= 0 then
				self.alpha = 0
			end
			ImageSetMask(self.ui,MAKE_RGBA_8888(255,255,255,self.alpha))
		end
	end
end

function SaveUIScene:render()
	if self.screen then
		if self.state==self.macro.fadeout then
			am_scene_render()
		else
			--ImageToScreen(self.screen,0,0)
			DrawImage(self.screen,0,0,0,0,0,0,PGM_ORI_SCREEN_WIDTH,PGM_ORI_SCREEN_HEIGHT)
		end

		ImageToScreen(self.ui,0,0)

		if self.state==self.macro.previw then
			RenderQuad(self.loading,0,0,64,64,208,104,1,1,self.angle,MAKE_RGBA_4444(255,255,255,255))
			local ten = math.floor( (self.number+1)/10 ) + 1
			local one = (self.number+1) % 10 + 1
			ImageToScreen(self.quad[ ten ],480-48,272-34)
			ImageToScreen(self.quad[ one ],480-28,272-34)
			--print(ten,one)
		elseif self.state==self.macro.select then
			if self.view then self.view:render() end
		end
	else
		am_scene_render()
	end

	if self.touchindex==1111 then
		filluprect(self.coloralpha)
	elseif self.touchindex==2222 then
		filldownrect(self.coloralpha)
	elseif self.touchindex==3333 then
		fillleftrect(self.coloralpha)
	elseif self.touchindex==4444 then
		fillrightrect(self.coloralpha)
	end
end

function SaveUIScene:idle()
	if not self.screen then
		self.screen = ScreenToImage()
		self.state = self.macro.fadein
	end
	if self.state==self.macro.fadeout and self.alpha<=0 then
		--drawevent()
		if speak_attribute().msg and self.flag.load then
			speakmode(speak_mode_sample)
			if am_ramus then
				speak_load_text(speak_attribute().msg)
				drawskip()
			else
				say(speak_attribute().msg)
			end
		else
			drawevent()
		end
	end
end

function SaveUIScene:viewinit( num )
	if self.view then
		self.view:fini()
		self.view:init( num )
	else
		self.view = SaveFilePreview.new( num )
	end
	collectgarbage("collect")
end

-- control

function SaveUIScene:KeyDown(key)
	if self.state==self.macro.select then
		if key==PSP_BUTTON_LEFT then
			self.number = self.number - 1
			if self.number < 0 then
				self.number = GAME_SAVELISTSIZE - 1
			end
			self.state=self.macro.previw
			self.angle=0
			playfile(SAVE_SOUND,4)
		elseif key==PSP_BUTTON_RIGHT then
			self.number = self.number + 1
			if self.number >= GAME_SAVELISTSIZE then
				self.number = 0
			end
			self.state=self.macro.previw
			self.angle=0
			playfile(SAVE_SOUND,4)
		elseif key==PSP_BUTTON_CROSS then
			self.state=self.macro.fadeout
		elseif key==PSP_BUTTON_CIRCLE then
			if self.mode==SAVE_MODE_SAVE then
				amp_save( self.number,self.screen )
				self.state=self.macro.fadeout
				self.flag.save=true
			elseif self.mode==SAVE_MODE_LOAD then
				if self.view and self.view:FileIsExist() then
					amp_load( self.number )
					self.state=self.macro.fadeout
				else
					playfile(SAVE_SOUND,4)
				end
				self.flag.load=true
			end
		end
	elseif self.state==self.macro.previw then
		if key==PSP_BUTTON_LEFT then
			self.number = self.number - 1
			if self.number < 0 then
				self.number = GAME_SAVELISTSIZE - 1
			end
			self.lasttick = TimerGetTicks(am_timer)
			self.angle=12
			playfile(SAVE_SOUND,4)
		elseif key==PSP_BUTTON_RIGHT then
			self.number = self.number + 1
			if self.number >= GAME_SAVELISTSIZE then
				self.number = 0
			end
			self.lasttick = TimerGetTicks(am_timer)
			self.angle=12
			playfile(SAVE_SOUND,4)
		end
	end
end

function SaveUIScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	self.coloralpha = 0
	if self.state==self.macro.select then
		if testuprect(dx,dy) then
			self.touchindex = 1111
		elseif testdownrect(dx,dy) then
			self.touchindex = 2222
		elseif testleftrect(dx,dy) then
			self.touchindex = 3333
		elseif testrightrect(dx,dy) then
			self.touchindex = 4444
		end
	elseif self.state==self.macro.previw then
		if testleftrect(dx,dy) then
			self.touchindex = 3333
		elseif testrightrect(dx,dy) then
			self.touchindex = 4444
		end
	end
end

function SaveUIScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.state==self.macro.select then
		if self.touchindex==1111 then
			if not testuprect(dx,dy) then
				self.touchindex = false
			end
		elseif self.touchindex==2222 then
			if not testdownrect(dx,dy) then
				self.touchindex = false
			end
		elseif self.touchindex==3333 then
			if not testleftrect(dx,dy) then
				self.touchindex = false
			end
		elseif self.touchindex==4444 then
			if not testrightrect(dx,dy) then
				self.touchindex = false
			end
		end
	elseif self.state==self.macro.previw then
		if self.touchindex==3333 then
			if not testleftrect(dx,dy) then
				self.touchindex = false
			end
		elseif self.touchindex==4444 then
			if not testrightrect(dx,dy) then
				self.touchindex = false
			end
		end
	end
end

function SaveUIScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.state==self.macro.select then
		if self.touchindex==1111 then
			self.state=self.macro.fadeout
		elseif self.touchindex==2222 then
			if self.mode==SAVE_MODE_SAVE then
				amp_save( self.number,self.screen )
				self.state=self.macro.fadeout
				self.flag.save=true
			elseif self.mode==SAVE_MODE_LOAD then
				if self.view and self.view:FileIsExist() then
					amp_load( self.number )
					self.state=self.macro.fadeout
				else
					playfile(SAVE_SOUND,4)
				end
				self.flag.load=true
			end
		elseif self.touchindex==3333 then
			self.number = self.number - 1
			if self.number < 0 then
				self.number = GAME_SAVELISTSIZE - 1
			end
			self.state=self.macro.previw
			self.angle=0
			playfile(SAVE_SOUND,4)
		elseif self.touchindex==4444 then
			self.number = self.number + 1
			if self.number >= GAME_SAVELISTSIZE then
				self.number = 0
			end
			self.state=self.macro.previw
			self.angle=0
			playfile(SAVE_SOUND,4)
		end
	elseif self.state==self.macro.previw then
		if self.touchindex==3333 then
			self.number = self.number - 1
			if self.number < 0 then
				self.number = GAME_SAVELISTSIZE - 1
			end
			self.lasttick = TimerGetTicks(am_timer)
			self.angle=12
			playfile(SAVE_SOUND,4)
		elseif self.touchindex==4444 then
			self.number = self.number + 1
			if self.number >= GAME_SAVELISTSIZE then
				self.number = 0
			end
			self.lasttick = TimerGetTicks(am_timer)
			self.angle=12
			playfile(SAVE_SOUND,4)
		end
	end
	self.touchindex = false
end

-- ================================================

function drawsave()
	if PGMPSP and GAME_SAVEMODE==PGMPSP then
		local screen = ScreenToImage()
		psp_save( screen )
		ImageFree(screen)
		drawevent()
	else
		if scene then scene:fini() end
		scene = SaveUIScene.new(SAVE_MODE_SAVE)
		scene:init()
	end
	collectgarbage("collect")
end

function drawload()
	if PGMPSP and GAME_SAVEMODE==PGMPSP then
		local screen = ScreenToImage()
		psp_load( screen )
		ImageFree(screen)
		drawevent()
	else
		if scene then scene:fini() end
		scene = SaveUIScene.new(SAVE_MODE_LOAD)
		scene:init()
	end
	collectgarbage("collect")
end
