
--[[
	±êÓï
]]--
local poster_img={
	"a1.png",
	"a2.png",
	"a3.png",
	"a4.png",
	"a5.png",
	"a6.png",
	"a7.png",
}

HelperScene=class(PGSceneBase)

function HelperScene:ctor(o,wait_time,key)
	if type(o)=="table" then
		self.o=o
		self.index=1
		for i=1,64 do
			if not o[i] then
				self.max=i-1
				break
			end
		end
		self.bg=ImageLoad(am_pack.res,o[self.index],IMG_8888)
	else
		self.bg=ImageLoad(am_pack.res,o,IMG_8888)
	end
	self.lasttick=0
	self.wait=wait_time
	self.key=key
	self.state=1

	if not wait_time then
		self.wait=0
	end
	if not key then
		self.key=PSP_BUTTON_CROSS
	end

	self.scale=0.2
end

function HelperScene:fini()
	if self.bg then
		ImageFree(self.bg)
		self.bg=nil	
	end
end

function HelperScene:update()
	if self.state==1 then
		self.scale=self.scale*1.2
		if self.scale>=1 then
			self.scale=1
			self.state=2
			self.lasttick=TimerGetTicks(am_timer)
		end
	elseif self.state==3 then
		self.scale=self.scale*0.82
		if self.scale<=0.1 then
			self.scale=0.1
			self.state=4
		end
	end
end

function HelperScene:render()
	if self.state~=2 then
		for i=1,2 do
			am_scene.bg[i]:render()
		end	
	end
	if self.bg and self.scale>0.1 then
		DrawImage(self.bg,0,0,0,0,240-240*self.scale,136-136*self.scale,480*self.scale,272*self.scale)
	end
end

function HelperScene:idle()
	if self.state==4 then
		drawevent()
	end
end

function HelperScene:PrevImage(num)
	self.index=self.index-num
	if num==1 then
		if self.index<1  then
			self.index=self.max
		end
	else
		if self.index<1 then
			self.index=1
		end
	end
	if self.bg then
		ImageFree(self.bg)
	end
	self.bg=ImageLoad(am_pack.res,self.o[self.index],IMG_8888)
end

function HelperScene:NextImage(num)
	self.index=self.index+num
	if num==1 then
		if self.index>self.max  then
			self.index=1
		end
	else
		if self.index>self.max then
			self.index=self.max
		end
	end
	if self.bg then
		ImageFree(self.bg)
	end
	self.bg=ImageLoad(am_pack.res,self.o[self.index],IMG_8888)
end

function HelperScene:KeyDown(key)
	if TimerGetTicks(am_timer)-self.lasttick < self.wait then
		return
	end
	if self.state~=2 then
		return
	end

	if self.o then
		if key==PSP_BUTTON_LEFT then
			self:PrevImage(1)
		elseif key==PSP_BUTTON_RIGHT then
			self:NextImage(1)
		elseif key==PSP_BUTTON_LEFT_TRIGGER then
			if self.index~=1 then
				self:PrevImage(5)
			end
		elseif key==PSP_BUTTON_RIGHT_TRIGGER then
			if self.index~=self.max then
				self:NextImage(5)
			end
		elseif key==self.key then
			self.state=3
		end
	else
		if key==self.key then
			self.state=3
		end
	end
end

function HelperScene:TouchBegan(id,dx,dy,prev_dx,prev_dy,tapCount)
	if TimerGetTicks(am_timer)-self.lasttick < self.wait then
		return
	end
	if self.state~=2 then
		return
	end
	self.state=3
end

--=============================================================

function drawhelper(...)
	if scene then scene:fini() end
	scene = HelperScene.new(...)
	scene:init()
	collectgarbage("collect")
end

function show_poster(wait_time)
	if poster_max then
		return
	end
	poster_max=10
	for i=1,64 do
		if not poster_img[i] then
			poster_max=i-1
			break
		end
	end
	drawhelper(poster_img[rand(1,poster_max)],wait_time)
end

function show_helper(filename)
	drawhelper(filename)
end

function show_strategy(o)
	drawhelper(o)
end
