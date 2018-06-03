
local speak_attr = {
	quad_i=1,
	word_table=false,
	code_table={count=0},
	dx=0,dy=0,
	len_count=0,line_count=0,
	msg=false,

	index=0,
	state=0,
}

speak_mode_sample,
speak_mode_skip,
speak_mode_auto=1,2,3

local speak_state_default,
	speak_state_delay,
	speak_state_wiatkey,
	speak_state_newpage,
	speak_state_end=1,2,3,4,5

local half=PGM_ORI_SCREEN_HEIGHT/2
local speak_mode=speak_mode_sample
local text_layer=false

function text_layer_render()
	if text_layer then
		if DIALOG_MODE == DIALOG_HALFSCREEN then
			--SetClip(0,half,PGM_ORI_SCREEN_WIDTH,half)
		end
		text_layer:render(speak_attr.quad_i)
		ResetClip()
	end
end

local function text_layer_create()
	if not text_layer then
		text_layer=DialogLayer.new()
		text_layer:init(0,0,PGM_ORI_SCREEN_WIDTH,PGM_ORI_SCREEN_HEIGHT,IMG_4444)
		speak_attr.dx=DIALOG_DX
		speak_attr.dy=DIALOG_DY
	end
end

function speaking()
	return speak_attr.state~=0
end

function speakmode(mode)
	if not mode then
		return speak_mode
	end
	speak_mode=mode
end

function speak_load_text(tx)
	if tx then
		speak_attr.msg=tx
		speak_attr.word_table=DialogCreate(tx)
		speak_attr.code_table={count=0}
		speak_attr.index=1
		speak_attr.state=speak_state_default
	end
end

function speak_attribute()
	return speak_attr
end

function speak_attribute_reset()
	speak_attr.quad_i=1
	speak_attr.word_table=false
	speak_attr.code_table={count=0}
	speak_attr.dx=0
	speak_attr.dy=0
	speak_attr.len_count=0
	speak_attr.line_count=0
	speak_attr.msg=false

	speak_attr.index=0
	speak_attr.state=0
end


--[[
====================== 普通模式 ======================
]]--

SpeakScene=class(PGSceneBase)

function SpeakScene:ctor()
	self.lasttick=TimerGetTicks(am_timer)
	self.state=speak_attr.state
	self.delay=0

	text_layer_create()

	self.icon = CacheImageLoad(am_pack.res,DIALOG_ICON,IMG_4444)
	self.frame_index=1
	self.frame_tick=TimerGetTicks(am_timer)
	self.frame = {size=ImageGetH(self.icon)}
	for i=1,16 do
		self.frame[i]=(i-1)*ImageGetH(self.icon)
	end
	
	self.colorV = 6
	self.coloralpha = 0
end

function SpeakScene:fini()
	speak_attr.state=self.state

	if self.icon then
		ImageFree(self.icon)
		self.icon=nil
	end
end

function SpeakScene:update()
	
	self.coloralpha = self.coloralpha + self.colorV
	if self.coloralpha <= 50 then
		self.coloralpha = 50
		self.colorV = -self.colorV
	elseif self.coloralpha >= 180 then
		self.coloralpha = 180
		self.colorV = -self.colorV
	end

	if TimerGetTicks(am_timer)-self.frame_tick >= DIALOG_ICON_SPEED then
		self.frame_index = self.frame_index + 1
		self.frame_tick=TimerGetTicks(am_timer)
		if self.frame_index > 16 then
			self.frame_index=1
		end
	end

	am_scene_update()

	if self.state==speak_state_default then
		if TimerGetTicks(am_timer)-self.lasttick > DIALOG_SPEED then
			local unit=speak_attr.word_table[ speak_attr.index ]
			
			--nge_print("type=" .. unit.type)
			--nge_print("value=" .. unit.value)

			if not unit then
				self.state=speak_state_end
				return
			end

			if unit.type==PGD_SINT8 then
				FontDraw(am_font.pf,text_layer.quad[ speak_attr.quad_i ],unit.value,speak_attr.dx,speak_attr.dy)
				speak_attr.dx=speak_attr.dx+FontTextSize(am_font.pf,unit.value)
				speak_attr.len_count=speak_attr.len_count+1
			elseif unit.type==PGD_UINT8 then
				FontDraw(am_font.pf,text_layer.quad[ speak_attr.quad_i ],unit.value,speak_attr.dx,speak_attr.dy)
				speak_attr.dx=speak_attr.dx+DIALOG_FONT_WIDTH
				speak_attr.len_count=speak_attr.len_count+2
			elseif unit.type==PGD_NEWLINE then
				if unit.value==0 then
					unit.value=1
				end
				speak_attr.len_count=0
				speak_attr.line_count=speak_attr.line_count+unit.value
				speak_attr.dy=speak_attr.dy+DIALOG_FONT_HEIGHT*unit.value
				speak_attr.dx=DIALOG_DX
			elseif unit.type==PGD_TABLE then
				if unit.value==0 then
					unit.value=1
				end
				speak_attr.len_count=speak_attr.len_count+unit.value*2
				speak_attr.dx=speak_attr.dx+DIALOG_FONT_WIDTH*unit.value
			elseif unit.type==PGD_COLOR then
				local count=speak_attr.code_table.count+1
				speak_attr.code_table.count=count
				speak_attr.code_table[ count ] = {type=unit.type,value=unit.value}
				FontSetColor(am_font.pf,unit.value)
			elseif unit.type==PGD_DCOLOR then
				speak_attr.code_table.count=speak_attr.code_table.count-1
				if speak_attr.code_table.count<=0 then
					speak_attr.code_table.count=0
					FontSetColor(am_font.pf,FONT_COLOR)
				else
					FontSetColor(am_font.pf,speak_attr.code_table[ speak_attr.code_table.count ].value)
				end
			elseif unit.type==PGD_DELAY then
				self.delay=unit.value
				self.state=speak_state_delay
			elseif unit.type==PGD_WAITKEY then
				self.state=speak_state_waitkey
			end

			self.lasttick=TimerGetTicks(am_timer)
			speak_attr.index=speak_attr.index+1

			if self.state~=speak_state_delay then

				if speak_attr.index>speak_attr.word_table.count then
					self.state=speak_state_end
				end

				if speak_attr.len_count >= DIALOG_LINELEN-1 then
					speak_attr.len_count=0
					speak_attr.line_count=speak_attr.line_count+1
					speak_attr.dy=speak_attr.dy+DIALOG_FONT_HEIGHT
					speak_attr.dx=DIALOG_DX
				end

				if speak_attr.line_count >= DIALOG_LINEMAX then
					self.state=speak_state_newpage
				end

			end

		end

	elseif self.state==speak_state_delay then
		if TimerGetTicks(am_timer)-self.lasttick >= self.delay then
			self.delay=0
			if speak_attr.index>speak_attr.word_table.count then
				self.state=speak_state_end
			else
				self.state=speak_state_default
			end
		end
	end
end

function SpeakScene:render()
	am_scene_render()
	if (self.state==speak_state_newpage or
		self.state==speak_state_waitkey or
		self.state==speak_state_end) and self.icon then
		if (speak_attr.dx+DIALOG_FONT_WIDTH) >= (PGM_SCREEN_WIDTH * 0.88) or 
			speak_attr.dy > (DIALOG_DY + (DIALOG_LINEMAX-1)*DIALOG_FONT_HEIGHT) then
			DrawImage(self.icon,self.frame[ self.frame_index ],0,
				self.frame.size,self.frame.size,
				DIALOG_ICON_DX,DIALOG_ICON_DY,
				DIALOG_ICON_SIZE,DIALOG_ICON_SIZE)
		else
			DrawImage(self.icon,self.frame[ self.frame_index ],0,
				self.frame.size,self.frame.size,
				speak_attr.dx+(DIALOG_FONT_WIDTH*0.5),speak_attr.dy-DIALOG_ICON_SIZE*0.32,
				DIALOG_ICON_SIZE,DIALOG_ICON_SIZE)
		end
	end
	
	if self.touchindex==1111 then
		filluprect(self.coloralpha)
	end
end

function SpeakScene:idle()
	if DIALOG_MODE == DIALOG_FULLSCREEN and
		self.state==speak_state_end then
		self.state=0
		drawevent()
	end
end

function SpeakScene:KeyDown(key)

	if key==PSP_BUTTON_CIRCLE then
		if self.state==speak_state_end then
			self.state=0
			drawevent()
		elseif self.state==speak_state_newpage then
			self.state=speak_state_default
			textclear(true)
		elseif self.state==speak_state_waitkey then
			self.state=speak_state_default
		end
		playfile(DIALOG_SOUND,4)
	elseif key==PSP_BUTTON_START then
		if (self.state==speak_state_newpage or
			self.state==speak_state_waitkey or
			self.state==speak_state_end) and
			call_menu_flag then
			drawmenu()
			playfile(DIALOG_SOUND,4)
		end
	elseif key==PSP_BUTTON_SELECT then
		--show_helper("help.png")		-- 呼出帮助文件
	elseif key==PSP_BUTTON_LEFT_TRIGGER then
		--show_strategy(strategy_img)	-- 呼出攻略
	end

end

function SpeakScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	if testuprect(dx,dy) then
		if (self.state==speak_state_newpage or
			self.state==speak_state_waitkey or
			self.state==speak_state_end) and
			call_menu_flag then
			self.touchindex = 1111
			self.coloralpha = 0
			return
		end
	else
		self.touchindex = false
	end
	
	self.touchText=true
end

function SpeakScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.touchindex==1111 then
		if not testuprect(dx,dy) then
			self.touchindex = false
		end
		return
	end
end

function SpeakScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.touchindex==1111 then
		playfile(DIALOG_SOUND,4)
		self.touchindex = false
		return drawmenu()
	end
	
	if not self.touchText then
		return	
	end
	
	self.touchText=false
	
	if self.state==speak_state_end then
		self.state=0
		drawevent()
		playfile(DIALOG_SOUND,4)
	elseif self.state==speak_state_newpage then
		self.state=speak_state_default
		textclear(true)
		playfile(DIALOG_SOUND,4)
	elseif self.state==speak_state_waitkey then
		self.state=speak_state_default
		playfile(DIALOG_SOUND,4)
	end
end


--[[
====================== 快进模式 ======================
]]--

SkipScene=class(PGSceneBase)

function SkipScene:ctor()
	self.lasttick=TimerGetTicks(am_timer)
	self.state=speak_attr.state
	self.delay=0

	text_layer_create()

	if self.state==speak_state_newpage then
		self.delay=200
	elseif speak_attr.index > speak_attr.word_table.count then
		self.delay=205
		self.lasttick=TimerGetTicks(am_timer)-205
		self.state=speak_state_end
	end
	
	self.colorV = 6
	self.coloralpha = 0
end

function SkipScene:fini()
	speak_attr.state=self.state
end

function SkipScene:update()
	
	self.coloralpha = self.coloralpha + self.colorV
	if self.coloralpha <= 50 then
		self.coloralpha = 50
		self.colorV = -self.colorV
	elseif self.coloralpha >= 180 then
		self.coloralpha = 180
		self.colorV = -self.colorV
	end

	am_scene_update()

	if self.delay~=0 then
		if TimerGetTicks(am_timer)-self.lasttick > self.delay then
			self.delay=0
			self.lasttick=TimerGetTicks(am_timer)
			if speak_attr.index > speak_attr.word_table.count then
				self.skipover=true
				if self.state==speak_state_newpage then
					textclear(true)
				end
			else
				textclear(true)
			end
		end
		return
	end

	for i=speak_attr.index,speak_attr.word_table.count do
		local unit=speak_attr.word_table[ speak_attr.index ]

		if unit.type==PGD_SINT8 then
			FontDraw(am_font.pf,text_layer.quad[ speak_attr.quad_i ],unit.value,speak_attr.dx,speak_attr.dy)
			speak_attr.dx=speak_attr.dx+FontTextSize(am_font.pf,unit.value)
			speak_attr.len_count=speak_attr.len_count+1
		elseif unit.type==PGD_UINT8 then
			FontDraw(am_font.pf,text_layer.quad[ speak_attr.quad_i ],unit.value,speak_attr.dx,speak_attr.dy)
			speak_attr.dx=speak_attr.dx+DIALOG_FONT_WIDTH
			speak_attr.len_count=speak_attr.len_count+2
		elseif unit.type==PGD_NEWLINE then
			if unit.value==0 then
				unit.value=1
			end
			speak_attr.len_count=0
			speak_attr.line_count=speak_attr.line_count+unit.value
			speak_attr.dy=speak_attr.dy+DIALOG_FONT_HEIGHT*unit.value
			speak_attr.dx=DIALOG_DX
		elseif unit.type==PGD_TABLE then
			if unit.value==0 then
				unit.value=1
			end
			speak_attr.len_count=speak_attr.len_count+unit.value*2
			speak_attr.dx=speak_attr.dx+DIALOG_FONT_WIDTH*unit.value
		elseif unit.type==PGD_COLOR then
			local count=speak_attr.code_table.count+1
			speak_attr.code_table.count=count
			speak_attr.code_table[ count ] = {type=unit.type,value=unit.value}
			FontSetColor(am_font.pf,unit.value)
		elseif unit.type==PGD_DCOLOR then
			speak_attr.code_table.count=speak_attr.code_table.count-1
			if speak_attr.code_table.count<=0 then
				speak_attr.code_table.count=0
				FontSetColor(am_font.pf,FONT_COLOR)
			else
				FontSetColor(am_font.pf,speak_attr.code_table[ speak_attr.code_table.count ].value)
			end
		end

		speak_attr.index=speak_attr.index+1

		if speak_attr.len_count >= DIALOG_LINELEN-1 then
			speak_attr.len_count=0
			speak_attr.line_count=speak_attr.line_count+1
			speak_attr.dy=speak_attr.dy+DIALOG_FONT_HEIGHT
			speak_attr.dx=DIALOG_DX
		end

		if speak_attr.line_count >= DIALOG_LINEMAX then
			self.delay=200
			self.lasttick=TimerGetTicks(am_timer)
			self.state=speak_state_newpage
			break
		end

	end

	if speak_attr.index > speak_attr.word_table.count then
		self.delay=205
		self.lasttick=TimerGetTicks(am_timer)
		self.state=speak_state_end
	end
	
	if self.touchindex==1111 then
		filluprect(self.coloralpha)
	end

end

function SkipScene:render()
	am_scene_render()
	
	if self.touchindex==1111 then
		filluprect(self.coloralpha)
	end
end

function SkipScene:idle()
	if self.skipover then
		self.state=0
		drawevent()
	end
end

function SkipScene:KeyDown(key)

	if key==PSP_BUTTON_CROSS then
		speakmode(speak_mode_sample)
		drawevent()
		playfile(DIALOG_SOUND,4)
	end

end

function SkipScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	if testuprect(dx,dy) then
		self.touchindex = 1111
		self.coloralpha = 0
	else
		self.touchindex = false
	end
end

function SkipScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.touchindex==1111 then
		if not testuprect(dx,dy) then
			self.touchindex = false
		end
		return
	end
end

function SkipScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.touchindex==1111 then
		speakmode(speak_mode_sample)
		drawevent()
		playfile(DIALOG_SOUND,4)
	end
end


--[[
====================== 自动模式 ======================
]]--

AutoScene=class(PGSceneBase)

function AutoScene:ctor()
	self.lasttick=TimerGetTicks(am_timer)
	self.state=speak_attr.state
	self.delay=0

	text_layer_create()

	if speak_attr.index>speak_attr.word_table.count then
		self.state=speak_state_end
		self.autotick=self.lasttick-DIALOG_AUTO_TICK
	end

	self.icon = CacheImageLoad(am_pack.res,DIALOG_ICON,IMG_4444)
	self.frame_index=1
	self.frame_tick=TimerGetTicks(am_timer)
	self.frame = {size=ImageGetH(self.icon)}
	for i=1,16 do
		self.frame[i]=(i-1)*ImageGetH(self.icon)
	end

	self.auto_icon = CacheImageLoad(am_pack.res,DIALOG_AUTO_ICON,IMG_4444)
	self.auto_tick=TimerGetTicks(am_timer)
	self.auto_display=true

	self.colorV = 6
	self.coloralpha = 0
end

function AutoScene:init()
	if not self:voicefinish() then
		self.autotick=false
	end
end

function AutoScene:fini()
	speak_attr.state=self.state

	if self.icon then
		ImageFree(self.icon)
		self.icon=nil
	end

	if self.auto_icon then
		ImageFree(self.auto_icon)
		self.auto_icon=nil
	end
end

function AutoScene:update()

	self.coloralpha = self.coloralpha + self.colorV
	if self.coloralpha <= 50 then
		self.coloralpha = 50
		self.colorV = -self.colorV
	elseif self.coloralpha >= 180 then
		self.coloralpha = 180
		self.colorV = -self.colorV
	end

	if TimerGetTicks(am_timer)-self.frame_tick >= DIALOG_ICON_SPEED then
		self.frame_index = self.frame_index + 1
		self.frame_tick=TimerGetTicks(am_timer)
		if self.frame_index > 16 then
			self.frame_index=1
		end
	end

	if TimerGetTicks(am_timer)-self.auto_tick >= DIALOG_AUTO_ICON_TICK then
		self.auto_display=not self.auto_display
		self.auto_tick=TimerGetTicks(am_timer)
	end

	am_scene_update()

	if self.state==speak_state_default then
		if TimerGetTicks(am_timer)-self.lasttick > DIALOG_SPEED then
			local unit=speak_attr.word_table[ speak_attr.index ]

			if not unit then
				self.state=speak_state_end
				return
			end

			if unit.type==PGD_SINT8 then
				FontDraw(am_font.pf,text_layer.quad[ speak_attr.quad_i ],unit.value,speak_attr.dx,speak_attr.dy)
				speak_attr.dx=speak_attr.dx+FontTextSize(am_font.pf,unit.value)
				speak_attr.len_count=speak_attr.len_count+1
			elseif unit.type==PGD_UINT8 then
				FontDraw(am_font.pf,text_layer.quad[ speak_attr.quad_i ],unit.value,speak_attr.dx,speak_attr.dy)
				speak_attr.dx=speak_attr.dx+DIALOG_FONT_WIDTH
				speak_attr.len_count=speak_attr.len_count+2
			elseif unit.type==PGD_NEWLINE then
				if unit.value==0 then
					unit.value=1
				end
				speak_attr.len_count=0
				speak_attr.line_count=speak_attr.line_count+unit.value
				speak_attr.dy=speak_attr.dy+DIALOG_FONT_HEIGHT*unit.value
				speak_attr.dx=DIALOG_DX
			elseif unit.type==PGD_TABLE then
				if unit.value==0 then
					unit.value=1
				end
				speak_attr.len_count=speak_attr.len_count+unit.value*2
				speak_attr.dx=speak_attr.dx+DIALOG_FONT_WIDTH*unit.value
			elseif unit.type==PGD_COLOR then
				local count=speak_attr.code_table.count+1
				speak_attr.code_table.count=count
				speak_attr.code_table[ count ] = {type=unit.type,value=unit.value}
				FontSetColor(am_font.pf,unit.value)
			elseif unit.type==PGD_DCOLOR then
				speak_attr.code_table.count=speak_attr.code_table.count-1
				if speak_attr.code_table.count<=0 then
					speak_attr.code_table.count=0
					FontSetColor(am_font.pf,FONT_COLOR)
				else
					FontSetColor(am_font.pf,speak_attr.code_table[ speak_attr.code_table.count ].value)
				end
			elseif unit.type==PGD_DELAY then
				self.delay=unit.value
				self.state=speak_state_delay
			elseif unit.type==PGD_WAITKEY then
				self.delay=DIALOG_AUTO_TICK*0.5
				self.state=speak_state_delay
			end

			self.lasttick=TimerGetTicks(am_timer)
			speak_attr.index=speak_attr.index+1

			if speak_attr.index>speak_attr.word_table.count then
				if self.state~=speak_state_delay then
					self.state=speak_state_end
				end
			end

			if speak_attr.len_count >= DIALOG_LINELEN-1 then
				speak_attr.len_count=0
				speak_attr.line_count=speak_attr.line_count+1
				speak_attr.dy=speak_attr.dy+DIALOG_FONT_HEIGHT
				speak_attr.dx=DIALOG_DX
			end

			if speak_attr.line_count >= DIALOG_LINEMAX then
				self.delay=DIALOG_AUTO_TICK*0.5
				self.state=speak_state_newpage
			end

		end

	elseif self.state==speak_state_delay then
		if TimerGetTicks(am_timer)-self.lasttick >= self.delay then
			self.delay=0
			if speak_attr.index>speak_attr.word_table.count then
				self.state=speak_state_end
			else
				self.state=speak_state_default
			end
		end
	elseif self.state==speak_state_newpage then
		if TimerGetTicks(am_timer)-self.lasttick >= self.delay then
			textclear(true)
			self.state=speak_state_default
		end
	else
		if speak_attr.index>speak_attr.word_table.count then
			self.state=speak_state_end
		else
			self.state=speak_state_default
		end
	end
end

function AutoScene:render()
	am_scene_render()
	if (self.state==speak_state_newpage or
		self.state==speak_state_waitkey or
		self.state==speak_state_end) and self.icon then
		if (speak_attr.dx+DIALOG_FONT_WIDTH) >= (PGM_SCREEN_WIDTH * 0.88) or 
			speak_attr.dy > (DIALOG_DY + (DIALOG_LINEMAX-1)*DIALOG_FONT_HEIGHT) then
			DrawImage(self.icon,self.frame[ self.frame_index ],0,
				self.frame.size,self.frame.size,
				DIALOG_ICON_DX,DIALOG_ICON_DY,
				DIALOG_ICON_SIZE,DIALOG_ICON_SIZE)
		else
			DrawImage(self.icon,self.frame[ self.frame_index ],0,
				self.frame.size,self.frame.size,
				speak_attr.dx+(DIALOG_FONT_WIDTH*0.5),speak_attr.dy-DIALOG_ICON_SIZE*0.32,
				DIALOG_ICON_SIZE,DIALOG_ICON_SIZE)
		end
	end

	if self.auto_display and self.auto_icon then
		ImageToScreen(self.auto_icon,DIALOG_AUTO_ICON_DX,DIALOG_AUTO_ICON_DY)
	end
	
	if self.touchindex==1111 then
		filluprect(self.coloralpha)
	end
end

function AutoScene:idle()
	if self.state==speak_state_end then
		if self.autotick then
			if TimerGetTicks(am_timer)-self.autotick > DIALOG_AUTO_TICK then
				self.state=0
				drawevent()
			end
		else
			if self:voicefinish() and self.state==speak_state_end then
				self.autotick=TimerGetTicks(am_timer)
			end
		end
	end
end

function AutoScene:voicefinish()
	if not mp3isfinish(2) then
		return false
	end
	for i=1,4 do
		if not wavisfinish(i) then
			return false
		end
	end
	return true
end

function AutoScene:KeyDown(key)

	if key==PSP_BUTTON_CROSS then
		speakmode(speak_mode_sample)
		drawevent()
	elseif key==PSP_BUTTON_CIRCLE then
		if self.state==speak_state_end then
			self.state=0
			drawevent()
		elseif self.state==speak_state_newpage then
			textclear(true)
			self.state=speak_state_default
		end
	end

end

function AutoScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	if testuprect(dx,dy) then
		self.touchindex = 1111
		self.coloralpha = 0
		return
	else
		self.touchindex = false
	end
	
	self.touchText=true
end

function AutoScene:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.touchindex==1111 then
		if not testuprect(dx,dy) then
			self.touchindex = false
		end
		return
	end
end

function AutoScene:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount)
	if self.touchindex==1111 then
		speakmode(speak_mode_sample)
		drawevent()
		playfile(DIALOG_SOUND,4)
	end
	
	if not self.touchText then
		return	
	end
	self.touchText=false
	self:KeyDown(PSP_BUTTON_CIRCLE)
end


--[[
====================== 全局函数 ======================
]]--

function drawspeak()
	if speak_attr.msg then
		if scene then scene:fini() end
		scene = SpeakScene.new()
		scene:init()
		collectgarbage("collect")
	else
		drawevent()
	end
end

function drawskip()
	if speak_attr.msg then
		if scene then scene:fini() end
		scene = SkipScene.new()
		scene:init()
		collectgarbage("collect")
	else
		drawevent()
	end
end

function drawauto()
	if speak_attr.msg then
		if scene then scene:fini() end
		scene = AutoScene.new()
		scene:init()
		collectgarbage("collect")
	else
		drawevent()
	end
end

function say(tx)
	if DIALOG_MODE == DIALOG_HALFSCREEN then
		textclear()
	end

	speak_load_text(tx)

	if speakmode()==speak_mode_sample then
		drawspeak()
	elseif speakmode()==speak_mode_skip then
		drawskip()
	elseif speakmode()==speak_mode_auto then
		drawauto()
	end
end

function textxy(dx,dy)
	DIALOG_DX = dx
	DIALOG_DY = dy
	speak_attr.dx=dx
	speak_attr.dy=dy
end

function textclear(flag)
	if text_layer then
		text_layer:clear()
	end
	speak_attr.dx=DIALOG_DX
	speak_attr.dy=DIALOG_DY
	speak_attr.len_count=0
	speak_attr.line_count=0
	if not flag then
		speak_attr.msg=false
		speak_attr.state=0
	end
	pause(50)
end

function textmode(mode)
	DIALOG_MODE = mode
end
