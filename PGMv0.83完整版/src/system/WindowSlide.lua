
local state={stand=0,slide=1,auto=2}
local mode={LR=0,UD=1}

WindowSlide=class(ClassBase)

function WindowSlide:ctor()
	self.mdx=0
	self.mdy=0		--全局坐标
	
	self.mwx=0
	self.mwy=0		--窗口固定点
	
	self.endDx=0
	self.endDy=0
	
	self.dxV=0
	self.dyV=0

	self.w=PGM_ORI_SCREEN_WIDTH
	self.h=PGM_ORI_SCREEN_HEIGHT	--页面大小

	self.windowCount=1	--窗口数量

	self.state=state.stand
	self.mode=mode.LR
	self.ispress=false
	
	self.outFlag=false
	
	self.callback=false
	
	self.screen={left=0,right=0,top=0,bottom=0,HalfWidth=0,HalfHeight=0,}
	
	self.showBox=true

	--首页和末页是否可以滑动
	self.lrFlag={true,true}
	self.lrBorder={0,0,0,0}
end

function WindowSlide:init(x,y,w,h)
	self.mwx=x
	self.mwy=y
	self.w=w
	self.h=h
	
	self.mdx=0
	self.mdy=0
	
	self.lrBorder[1]=-self.w
	self.lrBorder[2]=self.w
	self.lrBorder[3]=-self.h
	self.lrBorder[4]=self.h

	self.screen.left=w*0.33
	self.screen.right=w*(1-0.33)
	self.screen.top=h*0.33
	self.screen.bottom=h*(1-0.33)
	self.screen.HalfWidth=w/2
	self.screen.HalfHeight=h/2
end

function WindowSlide:Getdx()
	return self.mwx+self.mdx
end

function WindowSlide:Getdy()
	return self.mwy+self.mdy
end

function WindowSlide:GetW()
	return self.w
end

function WindowSlide:GetH()
	return self.h
end

function WindowSlide:pageCount()
	return self.windowCount
end

function WindowSlide:hotpoint(x,y)
	if x > self.mwx and x < self.mwx+self.w and y > self.mwy and y < self.mwy+self.h then
		for i=1,self.windowCount do
			if self.mode==mode.LR then
				local dx=self.mwx+self.mdx+(i-1)*self.w
				if x > dx and x < dx+self.w and y > self.mwy and y < self.mwy+self.h then
					return i
				end
			elseif self.mode==mode.UD then
				local dy=self.mwy+self.mdy+(i-1)*self.h
				if x > self.mwx and x < self.mwx+self.w and y > dy and y < dy+self.h then
					return i
				end
			end		
		end
	end
	return -1
end

function WindowSlide:currIndex()
	if not self:isMoving() then
		return self:hotpoint(self.mwx+self.w/2,self.mwy+self.h/2)	
	end
	return -1
end

function WindowSlide:update()
	if self.ispress then
		if self.mode==mode.LR then
			if (self.mdx > self.screen.left and self.dxV > 0) or
				(self.mdx+(self.windowCount*self.w) < self.screen.right and self.dxV < 0) then
				self.dxV=self.dxV*0.45
			end
			self.mdx=self.mdx+self.dxV
			if PGMIOS or PGMARD then
				self.dxV=self.dxV*0.65
			else
				self.dxV=0
			end
			if not self.lrFlag[1] and self.mdx > 0 then
				self.mdx=0
			end
			if not self.lrFlag[2] and self.mdx < -((self.windowCount-1)*self.w) then
				self.mdx=-(self.windowCount-1)*self.w
			end
		elseif self.mode==mode.UD then
			if (self.mdy > self.screen.top and self.dyV > 0) or
				(self.mdy+(self.windowCount*self.h) < self.screen.bottom and self.dyV < 0) then
				self.dyV=self.dyV*0.45
			end
			self.mdy=self.mdy+self.dyV
			if PGMIOS or PGMARD then
				self.dyV=self.dyV*0.65
			else
				self.dyV=0
			end
			if not self.lrFlag[1] and self.mdy > 0 then
				self.mdy=0
			end
			if not self.lrFlag[2] and self.mdy < -((self.windowCount-1)*self.h) then
				self.mdy=-(self.windowCount-1)*self.h
			end
		end
	else
		if self.mode==mode.LR then
			self.mdx=self.mdx+self.dxV
			--self.dxV=self.dxV*0.98
			if (self.mdx > self.screen.left and self.dxV > 0) or
				(self.mdx+(self.windowCount*self.w) < self.screen.right and self.dxV < 0) then
				if not self.outFlag then
					self.dxV=self.dxV*0.45
					if math.abs(self.dxV) < 1 then
						self.state=state.auto
						self.outFlag=true
					else
						return
					end
				end
			end
			if not self.lrFlag[1] and self.mdx > 0 then
				self.mdx=0
			end
			if not self.lrFlag[2] and self.mdx < -((self.windowCount-1)*self.w) then
				self.mdx=-(self.windowCount-1)*self.w
			end
			--[[if self.state==state.slide then
				if (self.mdx >= self.mwx) or (self.mdx <= self.mwx-((self.windowCount-1)*self.w)) then
					self.state=state.auto
				end
			else]]--
			if self.state==state.auto then
				-- 自动对齐
				if self.mdx >= 0 then
					self.dxV=-(self.mdx/6)
					if math.abs(self.dxV) < 0.1 then
						self.state=state.stand
						self.dxV=0
						self.mdx=0
					end
				elseif self.mdx <= -((self.windowCount-1)*self.w) then
					self.dxV=-((self.windowCount-1)*self.w+self.mdx)/6
					if math.abs(self.dxV) < 0.1 then
						self.state=state.stand
						self.dxV=0
						self.mdx=-(self.windowCount-1)*self.w
					end
				else
					self.dxV=(self.endDx-self.mdx)/6
					if math.abs(self.dxV) < 0.1 then
						self.state=state.stand
						self.dxV=0
						self.mdx=self.endDx
					end
				end
			end
		elseif self.mode==mode.UD then
			self.mdy=self.mdy+self.dyV
			--self.dxV=self.dxV*0.98
			if (self.mdy > self.screen.top and self.dyV > 0) or
				(self.mdy+(self.windowCount*self.h) < self.screen.bottom and self.dyV < 0) then
				if not self.outFlag then
					self.dyV=self.dyV*0.45
					if math.abs(self.dyV) < 1 then
						self.state=state.auto
						self.outFlag=true
					else
						return
					end
				end
			end
			if not self.lrFlag[1] and self.mdy > 0 then
				self.mdy=0
			end
			if not self.lrFlag[2] and self.mdy < -((self.windowCount-1)*self.h) then
				self.mdy=-(self.windowCount-1)*self.h
			end
			--[[if self.state==state.slide then
				if (self.mdx >= self.mwx) or (self.mdx <= self.mwx-((self.windowCount-1)*self.w)) then
					self.state=state.auto
				end
			else]]--
			if self.state==state.auto then
				-- 自动对齐
				if self.mdy >= 0 then
					self.dyV=-(self.mdy/6)
					if math.abs(self.dyV) < 0.1 then
						self.state=state.stand
						self.dyV=0
						self.mdy=0
					end
				elseif self.mdy <= -((self.windowCount-1)*self.h) then
					self.dyV=-((self.windowCount-1)*self.h+self.mdy)/6
					if math.abs(self.dyV) < 0.1 then
						self.state=state.stand
						self.dyV=0
						self.mdy=-((self.windowCount-1)*self.h)
					end
				else
					self.dyV=(self.endDy-self.mdy)/6
					if math.abs(self.dyV) < 0.1 then
						self.state=state.stand
						self.dyV=0
						self.mdy=self.endDy
					end
				end
			end
		end
	end
	
	--print(self.state)
end

function WindowSlide:render(obj_list)
	if self.showBox then
		DrawRect(self.mwx,self.mwy,self.w,self.h,MAKE_RGBA_4444(255,0,0,255),IMG_4444)	
	end

	--[[if self.callback then
		self.callback(self,obj_list)
	end]]--
end

function WindowSlide:setMode(m)
	if m==mode.LR then
		self.mode=m
	else
		self.mode=mode.UD
	end
end

function WindowSlide:setCount(c)
	self.windowCount=c
end

function WindowSlide:SetLrflag(first,last)
	if first then
		self.lrFlag[1]=true
	else
		self.lrFlag[1]=false
	end
	if last then
		self.lrFlag[2]=true
	else
		self.lrFlag[2]=false
	end
end

function WindowSlide:SetLrBorder(...)
	for i=1,4 do
		self.lrBorder[i]=arg[i]
	end
end

function WindowSlide:setClip()
	SetClip(self.mwx,self.mwy,self.w,self.h)
end

function WindowSlide:resetClip()
	ResetClip()
end

function WindowSlide:canShow(index)
	if self.mode==mode.LR then
		local dx=self.mdx+(index-1)*self.w
		if dx > self.lrBorder[1] and dx < self.lrBorder[2] then
			return true
		end
	elseif self.mode==mode.UD then
		local dy=self.mdy+(index-1)*self.h
		if dy > self.lrBorder[3] and dy < self.lrBorder[4] then
			return true
		end
	end
	return false
end

function WindowSlide:isMoving()
	return self.state~=state.stand
end

function WindowSlide:turnTo(pageIndex)
	if self.mode==mode.LR then
		self.mdx=-((pageIndex-1)*self.w)
	elseif self.mode==mode.UD then
		self.mdy=-((pageIndex-1)*self.h)
	end
	self:press_down()
	self:press_up()
end

function WindowSlide:autoProce()
	if self.mode==mode.LR then
		if math.abs(self.dxV) > 5 then
			--local index=(self.mwx-(self.mwx+self.mdx))/self.w
			local index=-(self.mdx/self.w)
			if self.dxV > 0 then
				index=index-1
			else
				index=index+1
			end
			if index-math.floor(index) > 0.5 then
				self.endDx=-math.ceil(index)*self.w
			else
				self.endDx=-math.floor(index)*self.w
			end
			--[[
			if self.endDx >= self.mwx then
				self.endDx = self.mwx
			elseif self.endDx <= (self.mwx+self.mdx)-((self.windowCount-1)*self.w) then
				self.endDx = (self.mwx+self.mdx)-((self.windowCount-1)*self.w)
			end
			]]--
			self.state=state.auto
		else
			--local index=(self.mwx-(self.mwx+self.mdx))/self.w
			local index=-(self.mdx/self.w)
			if index-math.floor(index) > 0.5 then
				self.endDx=-math.ceil(index)*self.w
			else
				self.endDx=-math.floor(index)*self.w
			end
			self.state=state.auto
			--print(index)
		end
	elseif self.mode==mode.UD then
		if math.abs(self.dyV) > 5 then
			local index=(self.mwy-(self.mwy+self.mdy))/self.h
			if self.dyV > 0 then
				index=index-1
			else
				index=index+1
			end
			if index-math.floor(index) > 0.5 then
				self.endDy=-math.ceil(index)*self.h
			else
				self.endDy=-math.floor(index)*self.h
			end
			--[[
			if self.endDy >= self.mwy then
				self.endDy = self.mwy
			elseif self.endDy <= (self.mwy+self.mdy)-((self.windowCount-1)*self.h) then
				self.endDy = (self.mwy+self.mdy)-((self.windowCount-1)*self.h)
			end
			]]--
			self.state=state.auto
		else
			local index=(self.mwy-(self.mwy+self.mdy))/self.h
			if index-math.floor(index) > 0.5 then
				self.endDy=-math.ceil(index)*self.h
			else
				self.endDy=-math.floor(index)*self.h
			end
			self.state=state.auto
		end
	end
end

function WindowSlide:press_down()
	self.ispress=true
	self.outFlag=false
	self.dxV=0
	self.dyV=0
end

function WindowSlide:move(xv,yv)
	--self:setV(dx-prev_dx,dy-prev_dy)
	self.dxV=xv
	self.dyV=yv
	self.state=state.slide
end

function WindowSlide:press_up()
	self.ispress=false
	self:autoProce()
end

