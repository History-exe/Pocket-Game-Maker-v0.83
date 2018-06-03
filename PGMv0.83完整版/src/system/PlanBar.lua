
PlanBar=class(ClassBase)

function PlanBar:ctor()
	self.imgBg=false
	self.imgBar=false
	self.dx=0
	self.dy=0
	
	self.xd=0	--进度条x偏移
	self.yd=0	--进度条y偏移
	
	self.v=0	--进度条动态增量值
	self.scale=1.0
	self.e_scale=1.0
	
	self.times=0		--满槽记数器
	self.max_times=0	--满槽记数
	
	self.ispause=false
end

function PlanBar:destory()
	if self.imgBg then
		ImageFree(self.imgBg)
		self.imgBg=false
	end
	if self.imgBar then
		ImageFree(self.imgBar)
		self.imgBar=false
	end
end

function PlanBar:update()
	if self.ispause then
		return
	end
	self.v=self.v*1.025
	self.scale=self.scale+self.v
	if self.v > 0 then
		if self.scale >= self.e_scale then
			self.scale=self.e_scale
			self.times=self.times+1
			if self.times>=self.max_times then
				self.v=0
				self.times=0
				self.max_times=0
			else
				self.ispause=true
			end
		end
	elseif self.v < 0 then
		if self.scale <= self.e_scale then
			self.scale=self.e_scale
			self.v=0
		end
	end
end

function PlanBar:render(x,y,w,h)
	if self.imgBg then
		ImageToScreen(self.imgBg,self.dx,self.dy)
	end
	if self.imgBar then
		SetClip(self.dx+self.xd,self.dy+self.yd,ImageGetW(self.imgBar)*self.scale,ImageGetH(self.imgBar))
		ImageToScreen(self.imgBar,self.dx+self.xd,self.dy+self.yd)
		ResetClip()
	end
end

function PlanBar:special_render(mode,x,y,w,h)
	if self.imgBg then
		ImageToScreen(self.imgBg,self.dx,self.dy)
	end
	-- mode: 1上下滚,2左右滚
	if self.imgBar then
		local xx,yy,ww,hh=x,y,w,h
		if self.dx+self.xd > x then
			xx=self.dx+self.xd			
		end
		if self.dy+self.yd > y then
			yy=self.dy+self.yd
		end
		if self.dx+self.xd+ImageGetW(self.imgBar)*self.scale < xx+w then
			ww=ImageGetW(self.imgBar)*self.scale
		else
			xx=x
		end
		if self.dy+self.yd+ImageGetH(self.imgBar) < yy+h then
			hh=(y+h)-yy
		else
			yy=y
		end
		SetClip(xx,yy,ww,hh)
		ImageToScreen(self.imgBar,self.dx+self.xd,self.dy+self.yd)
		SetClip(x,y,w,h)
	end
end

function PlanBar:loadImg(imgBg,imgBar)
	if self.imgBg then
		ImageFree(self.imgBg)	
	end
	if self.imgBar then
		ImageFree(self.imgBar)	
	end
	self.imgBg=ImageLoad(am_pack.res,imgBg,IMG_4444)
	self.imgBar=ImageLoad(am_pack.res,imgBar,IMG_4444)
end

function PlanBar:GetBarW()
	if self.imgBar then
		return ImageGetW(self.imgBar)	
	end
	return 0
end

function PlanBar:GetScaleBarW()
	if self.imgBar then
		return ImageGetW(self.imgBar)*self.scale	
	end
	return 0
end

function PlanBar:IsPause()
	return self.ispause==true
end

function PlanBar:UnPause()
	self.ispause=false
end

-- =======================================================================

PlanBar2=class(PlanBar)

function PlanBar2:render()
	if self.imgBg then
		ImageToScreen(self.imgBg,self.dx,self.dy)
	end
	if self.imgBar then
		local w = ImageGetW(self.imgBar)*self.scale
		local bgW = 0
		if self.imgBg then
			bgW = ImageGetW(self.imgBg)
		end
		SetClip(self.dx+self.xd+bgW-w,self.dy+self.yd,w,ImageGetH(self.imgBar))
		ImageToScreen(self.imgBar,self.dx+self.xd,self.dy+self.yd)
		ResetClip()
	end
end
