
--========================================
-- define base class
--========================================

PGBase=class(ClassBase)
function PGBase:ctor()
	-- constructed function
end
function PGBase:init() end
function PGBase:fini() end
function PGBase:update() end
function PGBase:render() end
function PGBase:idle() end

function PGBase:destory()
	self:fini()
end


--========================================
-- define scene base class
--========================================

PGSceneBase=class(SceneBase)	-- define scene base class

function PGSceneBase:ctor()
	-- constructed function
end

function PGSceneBase:init()
	
end

function PGSceneBase:fini()
	
end

function PGSceneBase:destory()
	self:fini()
end

function PGSceneBase:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount) end
function PGSceneBase:TouchMoved(id,dx,dy,prev_dx,prev_dy,tapCount) end
function PGSceneBase:TouchEnded(id,dx,dy,prev_dx,prev_dy,tapCount) end

function PGSceneBase:KeyDown(key) end
function PGSceneBase:KeyUp(key) end
function PGSceneBase:AnalogProc(x,y) end

-- 兼容lg
function PGSceneBase:key_up(key)
	self:KeyUp(key)
end

function PGSceneBase:key_down(key)
	self:KeyDown(key)
end

function PGSceneBase:analog_left(x,y)
	self:AnalogProc(x,y)
end

function PGSceneBase:ftouch_began(id,x,y,prev_x,prev_y,tapCount)
	self:TouchBegan(id,x,y,prev_x,prev_y,tapCount)
end

function PGSceneBase:ftouch_moved(id,x,y,prev_x,prev_y,tapCount)
	self:TouchMoved(id,x,y,prev_x,prev_y,tapCount)
end

function PGSceneBase:ftouch_ended(id,x,y,prev_x,prev_y,tapCount)
	self:TouchEnded(id,x,y,prev_x,prev_y,tapCount)
end


--========================================

FGBase=class(PGBase)

function FGBase:ctor()
	self.dx = 0
	self.dy = 0
	self.file = ""
	self.effect_p = false
	self.effect_type = false
	self.effect_timetick = false
	self.display = false

	self.image_p = {false,false}
	self.image_index = 0

	self.timetick = 1000
	self.sfadein = false

	self.dtype = 0
end

function FGBase:init()
	self.dx = 0
	self.dy = 0
	self.file = ""
	self.effect_p = false
	self.effect_type = false
	self.effect_timetick = false
	self.display = false

	self.image_p = {false,false}
	self.image_index = 0

	self.timetick = 1000
	self.sfadein = false

	self.dtype = 0
end

function FGBase:fini()
	self:unloadImage()
	self:unloadEffect()
	if self.temp_effect_p then
		EffectDelete(self.temp_effect_p)
		self.temp_effect_p=nil
	end
end

function FGBase:clone()
	local newBase = FGBase.new()
	newBase.dx = self.dx
	newBase.dy = self.dy
	newBase.file = self.file
	newBase.image_index = self.image_index
	if self.image_p[self.image_index+1] then
		newBase.image_p[newBase.image_index+1] = ImageClone(self.image_p[self.image_index+1])
	end
	return newBase
end

function FGBase:load(file,num,timeticks,dtype)
	-- load(file,num,timeticks,dtype)
	-- 删除效果器和后备图层,保证没有泄露
	self:unloadEffect()
	if self.image_p[2-self.image_index] then
		ImageFree(self.image_p[2-self.image_index])
		self.image_p[2-self.image_index] = false
	end
	self.sfadein = false
	self.timetick = timeticks

	self.dtype = dtype

	if num==0 or timeticks==0 then
		self:unloadImage()
		self.image_p[self.image_index+1] = CacheImageLoad(am_pack.res,file,dtype)
		self.file = file
		self.effect_type = false
	elseif num==am_effect.fadeout then
		self:unloadImage()
		self.image_p[self.image_index+1] = CacheImageLoad(am_pack.res,file,dtype)
		self.effect_p = EffectFadeOutCreate(255,0,timeticks)
		self.effect_type = num
	elseif num==am_effect.fadein then
		if self.image_p[self.image_index+1] then
			self.image_index = 1 - self.image_index
		end
		self.image_p[self.image_index+1] = CacheImageLoad(am_pack.res,file,dtype)
		self.effect_p = EffectFadeInCreate(0,255,timeticks)
		self.file = file
		self.effect_type = num
	elseif num==am_effect.shake then
		self:unloadImage()
		self.image_p[self.image_index+1] = CacheImageLoad(am_pack.res,file,dtype)
		self.effect_p = EffectShakeCreate(18,18,timeticks)
		self.file = file
		self.effect_type = num
	elseif num==am_effect.trans or num==am_effect.trans2 then
		if not am_matte.image_p then
			self:load(file,1,timeticks,dtype)
			return
		end
		if not self.image_p[self.image_index+1] then
			self.image_p[self.image_index+1] = ImageCreate(32,32,IMG_8888)
		end
		self.image_index = 1 - self.image_index
		self.image_p[self.image_index+1] = CacheImageLoad(am_pack.res,file,dtype)
		if num==am_effect.trans then
			self.effect_p = EffectTransCreate(am_matte.image_p,self.image_p[2-self.image_index],timeticks,0)
		elseif num==am_effect.trans2 then
			self.effect_p = EffectTransCreate(am_matte.image_p,self.image_p[2-self.image_index],timeticks,1)
		end
		self.file = file
		self.effect_type = num
	end
end

function FGBase:seteffect_p(num,timeticks)
	self:unloadEffect()
	if self.image_p[2-self.image_index] then
		ImageFree(self.image_p[2-self.image_index])
		self.image_p[2-self.image_index] = false
	end
	self.sfadein = false
	self.timetick = timeticks

	if num==am_effect.fadein then
		self.effect_p = EffectFadeInCreate(0,255,timeticks)
		self.effect_type = num
	elseif num==am_effect.fadeout then
		self.effect_p = EffectFadeOutCreate(255,0,timeticks)
		self.effect_type = num
	elseif num==am_effect.shake then
		self.effect_p = EffectShakeCreate(18,18,timeticks)
		self.effect_type = num
	else
		self:seteffect_p(am_effect.fadein,timeticks)
	end
end

function FGBase:unloadImage()
	for i=1,2 do
		if self.image_p[i] then
			ImageFree(self.image_p[i])
			self.image_p[i] = false
		end
	end
	self.file = ""
	self.image_index = 0
end

function FGBase:unloadEffect()
	if self.effect_p then
		EffectDelete(self.effect_p)
		self.effect_p = false
	end
end

function FGBase:render()
	-- index 位置必为该显示的图片
	-- 1-index 位置为暂时数据,效果器完成后必自动销毁
	if not self.display then return end
	if not self.image_p[self.image_index+1] then return end
	if self.effect_type then
		if not self.effect_p then return end
		if self.effect_type==am_effect.fadein then
			if self.image_p[2-self.image_index] and not self.sfadein then
				self.sfadein = 1
				self.temp_effect_p=EffectFadeOutCreate(255,0,self.timetick*0.88)
			end
			if self.sfadein==1 then
				-- fadein fg
				--print("fadein fg1")
				--ImageToScreen(self.image_p[2-self.image_index],self.dx,self.dy)
				EffectDrawImage(self.temp_effect_p,self.image_p[2-self.image_index],self.dx,self.dy)
				EffectDrawImage(self.effect_p,self.image_p[self.image_index+1],self.dx,self.dy)
				if EffectGetState(self.effect_p)==EFFECT_STOP then
					self:unloadEffect()
					--self.effect_p = EffectFadeOutCreate(255,0,self.timetick*0.2)
					--self.sfadein = 2
					ImageFree(self.image_p[2-self.image_index])
					self.image_p[2-self.image_index] = false
					self.sfadein = false
					self.effect_type = false
					if self.temp_effect_p then
						EffectDelete(self.temp_effect_p)
						self.temp_effect_p=nil
					end
				end
				--print("1",self.sfadein)
			elseif self.sfadein==2 then
				--print("fadein fg2")
				EffectDrawImage(self.effect_p,self.image_p[2-self.image_index],self.dx,self.dy)
				ImageToScreen(self.image_p[self.image_index+1],self.dx,self.dy)
				if EffectGetState(self.effect_p)==EFFECT_STOP then
					self:unloadEffect()
					ImageFree(self.image_p[2-self.image_index])
					self.image_p[2-self.image_index] = false
					self.sfadein = false
					self.effect_type = false
				end
				--print("2",self.sfadein)
			else
				EffectDrawImage(self.effect_p,self.image_p[self.image_index+1],self.dx,self.dy)
				if EffectGetState(self.effect_p)==EFFECT_STOP then
					self:unloadEffect()
					self.effect_type = false
				end
			end
		elseif self.effect_type==am_effect.shake then
			EffectDrawImage(self.effect_p,self.image_p[self.image_index+1],self.dx,self.dy)
			if EffectGetState(self.effect_p)==EFFECT_STOP then
				self:unloadEffect()
				self.effect_type = false
			end
		elseif self.effect_type==am_effect.fadeout then
			EffectDrawImage(self.effect_p,self.image_p[self.image_index+1],self.dx,self.dy)
			if EffectGetState(self.effect_p)==EFFECT_STOP then
				self:unloadEffect()
				self:unloadImage()
				self.display = false
				self.effect_type = false
			end
		elseif self.effect_type==am_effect.trans or self.effect_type==am_effect.trans2 then
			-- trans , 确保前面的遮片过渡创建必定有效
			EffectDrawImage(self.effect_p,self.image_p[self.image_index+1],self.dx,self.dy)
			if EffectGetState(self.effect_p)==EFFECT_STOP then
				self:unloadEffect()
				self.effect_type = false
				ImageFree(self.image_p[2-self.image_index])
				self.image_p[2-self.image_index] = false
			end
		end
	else
		if self.image_p[self.image_index+1] then
			ImageToScreen(self.image_p[self.image_index+1],self.dx,self.dy)
		end
	end
end


--========================================
-- define texfg class
--========================================

TexFgBase=class(FGBase)

function TexFgBase:ctor()
	self.str = ""
	self.quad_w=240
	self.quad_h=40
end

function TexFgBase:fini()
	self:unloadImage()
	self:unloadEffect()
	self.str = ""
end

function TexFgBase:clone()
	local texfgbase=TexFgBase.new()
	texfgbase.dx=self.dx
	texfgbase.dy=self.dy
	texfgbase.image_index=self.image_index
	texfgbase.str=self.str
	texfgbase.quad_w=self.quad_w
	texfgbase.quad_h=self.quad_h
	if self.image_p[self.image_index+1] then
		texfgbase.image_p[self.image_index+1] = ImageClone(self.image_p[self.image_index+1])
	end
	return texfgbase
end

function TexFgBase:load(str,num,timeticks,pFont,color,...)
	self:unloadEffect()
	self:unloadImage()
	self.sfadein = false
	self.timetick = timeticks

	self.str = str
	if not str then
		self.str=""
	end

	if arg[1] and arg[2] then
		self.image_p[self.image_index+1]=texfg_quad_create(
			am_font.pf,FONT_COLOR,self.str,
			math.abs(arg[1]),math.abs(arg[2]),
			DIALOG_FONT_WIDTH,DIALOG_FONT_HEIGHT)
		self.quad_w=arg[1]
		self.quad_h=arg[2]
	else
		self.image_p[self.image_index+1]=texfg_quad_create(
			am_font.pf,FONT_COLOR,self.str,
			240,40,DIALOG_FONT_WIDTH,DIALOG_FONT_HEIGHT)
		self.quad_w=240
		self.quad_h=40
	end

	if num==0 or timeticks==0 then
		self.effect_type = false
	elseif num==am_effect.fadeout then
		self.effect_p = EffectFadeOutCreate(255,0,timeticks)
		self.effect_type = num
	elseif num==am_effect.fadein then
		self.effect_p = EffectFadeInCreate(0,255,timeticks)
		self.effect_type = num
	elseif num==am_effect.shake then
		self.effect_p = EffectShakeCreate(18,18,timeticks)
		self.effect_type = num
	else
		self.effect_type = false
	end
end



-- =====================================================

SoundBase=class(PGBase)

function SoundBase:ctor(pos)
	self.pos = pos
	self.voice_p = SoundCreate(self.pos)
	self.name = ""
	self.vol = 128
	if self.pos=="mp3" then
		self.playtimes = 0
	elseif self.pos=="wav" then
		self.playtimes = 1
	else
		self.playtimes = 1
		print("SoundBase.new error.")
	end
	self.isplayed = false
	--print(pos,self.playtimes)
	--print(self.pos,self.pos==pos,"\n")
end

function SoundBase:init()
	if self.voice_p==false then
		self.voice_p = SoundCreate(self.pos)
	end
	self.name = ""
	self.vol = 128
	if self.pos=="mp3" then
		self.playtimes = 0
	elseif self.pos=="wav" then
		self.playtimes = 1
	else
		self.playtimes = 1
		print("SoundBase.new error.")
	end
	self.isplayed = false
end

function SoundBase:fini()
	self:unload()
	if self.voice_p then
		SoundDelete(self.voice_p)
		self.voice_p = false
	end
end

function SoundBase:load(filename)
	self.name = filename
	if self.voice_p then
		SoundUnload(self.voice_p)
		SoundLoad(self.voice_p,filename)
	end
	if self.pos=="mp3" then
		self.playtimes = 0
	elseif self.pos=="wav" then
		self.playtimes = 1
	end
	self.isplayed = false
end

function SoundBase:loadbuf(buffer,size)
	self.name = "buffer"
	if self.voice_p then
		SoundUnload(self.voice_p)
		--SoundLoad(self.voice_p,filename)
		SoundLoad(self.voice_p,buffer,size)
	end
	if self.pos=="mp3" then
		self.playtimes = 0
	elseif self.pos=="wav" then
		self.playtimes = 1
	end
	self.isplayed = false
end

function SoundBase:unload()
	if self.voice_p then
		SoundUnload(self.voice_p)
	end
	self.name = ""
end

function SoundBase:play()
	if self.voice_p then
		SoundPlay(self.voice_p,self.playtimes)
		self.isplayed = true
	end
end

function SoundBase:pause()
	if self.voice_p then
		SoundPause(self.voice_p)
	end
end

function SoundBase:resume()
	if self.voice_p then
		SoundResume(self.voice_p)
	end
end

function SoundBase:stop()
	if self.voice_p then
		SoundUnload(self.voice_p)
	end
end

function SoundBase:replay()
	self:rewind()
	self:play()
end

function SoundBase:rewind()
	if self.voice_p and SoundEos(self.voice_p) then
		SoundRewind(self.voice_p)
	end
end

function SoundBase:volume(vol)
	if self.voice_p then
		SoundVolume(self.voice_p,vol)
		self.vol = vol
	end
end

function SoundBase:settimes(t)
	self.playtimes = t
end

function SoundBase:IsFinish()
	if self.voice_p and string.len(self.name)>0 and self.isplayed then
		return SoundEos(self.voice_p)
	end
	--print("no sound play.")
	return true
end


-- =====================================================

PGColorButton=class(PGBase)

function PGColorButton:ctor(...)
	if arg[2]==nil then
		self.image_p = CacheImageLoad(arg[1],IMG_4444)
	else
		-- ImageLoad(pack,filename,dtype)
		self.image_p = CacheImageLoad(arg[1],arg[2],IMG_4444)
	end
	self.dx = 0
	self.dy = 0
	self.ispress = false
	self.w = ImageGetW(self.image_p)
	self.h = ImageGetH(self.image_p) / 2
	self.alpha = 255
end

function PGColorButton:init()
	
end

function PGColorButton:fini()
	if self.image_p then
		ImageFree(self.image_p)
		self.image_p = nil
	end
end

function PGColorButton:update()
	if self.image_p then
		ImageSetMask(self.image_p,MAKE_RGBA_4444(255,255,255,self.alpha))
	end
end

function PGColorButton:render()
	if self.image_p then
		if not self.ispress then
			DrawImage(self.image_p,0,0,self.w,self.h,self.dx,self.dy,self.w,self.h)
		else
			DrawImage(self.image_p,0,self.h,self.w,self.h,self.dx,self.dy,self.w,self.h)
		end
	end
end

