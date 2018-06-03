
spirit_mode={unknown=0,once=1,loop=2,onceback=3,oncefade=4,fadein=5,fadeout=6,unuse=255}

game_spirit=class(ClassBase)

function game_spirit:ctor()
	-- 使用说明:设置动画频率、设置桢数量、设置桢区域表、设置动画状态
	
	self.quad=false		-- 动画贴图,由外部设置,无须释放
	self.timer=TimerCreate()
	TimerStart(self.timer)
	self.lasttick=TimerGetTicks(self.timer)
	self.ticks=35		-- 动画播放频率
	self.alpha=255		-- 透明值
	self.alphaV=0
	
	self.dx=0
	self.dy=0
	
	self.display=false	-- 显示开关
	
	self.rect_max=3
	self.rect_index=0	-- 动画桢索引
	self.rect_list={
		-- 播放区域,例子{x=0,y=0,w=32,h=32}
	}
	
	self.mode=spirit_mode.unknown
end

function game_spirit:destory()
	TimerDelete(self.timer)
end

function game_spirit:update()
	if TimerGetTicks(self.timer)-self.lasttick > self.ticks then
		self.lasttick=TimerGetTicks(self.timer)
		if self.mode==spirit_mode.once then
			self.rect_index=self.rect_index+1
			if self.rect_index > self.rect_max then
				self.rect_index=self.rect_max
				self.mode=spirit_mode.unknown
			end
		elseif self.mode==spirit_mode.loop then
			self.rect_index=self.rect_index+1
			if self.rect_index > self.rect_max then
				self.rect_index=1
			end
		elseif self.mode==spirit_mode.onceback then
			self.rect_index=self.rect_index+1
			if self.rect_index > self.rect_max then
				self.rect_index=1
				self.mode=spirit_mode.unknown
			end
		elseif self.mode==spirit_mode.oncefade then
			self.rect_index=self.rect_index+1
			if self.rect_index > self.rect_max then
				self.rect_index=self.rect_max
				self.mode=spirit_mode.fadeout
			end
		elseif self.mode==spirit_mode.fadein then
			self.alpha=self.alpha+self.alphaV
			if self.alpha>=255 then
				self.alpha=255
				self.mode=spirit_mode.unknown
			end
		elseif self.mode==spirit_mode.fadeout then
			self.alpha=self.alpha-self.alphaV
			if self.alpha<=0 then
				self.alpha=0
				self.mode=spirit_mode.unknown
			end
		end
	end
end

function game_spirit:RenderAt(dx,dy,width,height)
	if self.quad then
		local rect=self.rect_list[ self.rect_index ]
		if rect then
			if width then
				self:DrawImageMask(self.quad,rect.x,rect.y,rect.w,rect.h,dx,dy,width,height,MAKE_RGBA_4444(255,255,255,self.alpha))
			else
				self:DrawImageMask(self.quad,rect.x,rect.y,rect.w,rect.h,dx,dy,rect.w,rect.h,MAKE_RGBA_4444(255,255,255,self.alpha))
			end
		end
	end
end

function game_spirit:RenderWith(mdx,mdy)
	if self.quad then
		local rect=self.rect_list[ self.rect_index ]
		if rect then
			self:DrawImageMask(self.quad,rect.x,rect.y,rect.w,rect.h,self.dx+mdx,self.dy+mdy,rect.w,rect.h,MAKE_RGBA_4444(255,255,255,self.alpha))
		end
	end
end

function game_spirit:render()
	self:RenderWith(0,0)
end

function game_spirit:DrawImageMask(img,sx,sy,sw,sh,dx,dy,dw,dh,mask)
	if self.display then
		DrawImageMask(img,sx,sy,sw,sh,dx,dy,dw,dh,mask)
	end
end

function game_spirit:SetQuad(quad)
	self.quad=quad
end

function game_spirit:SetTicks(t)
	self.ticks=t
end

function game_spirit:SetIndex(i)
	self.rect_index=i
end

function game_spirit:SetRectList(t)
	self.rect_list=t
end

function game_spirit:SetAlpha(a)
	self.alpha=a
end

function game_spirit:SetAlphaV(v)
	self.alphaV=v
end

function game_spirit:SetMode(m)
	self.mode=m
end

function game_spirit:SetXY(x,y)
	self.dx=x
	self.dy=y
end