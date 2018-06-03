
ColorButton=class(ClassBase)

function ColorButton:ctor()
	self.img=false
	self.dx=0
	self.dy=0
	self.ispress=false

	self.w=0
	self.h=0
	
	self.xd=0
	self.yd=0
end

function ColorButton:destory()
	if self.img then
		ImageFree(self.img)
		self.img=false
	end
end

function ColorButton:loadImage(filename)
	if self.img then
		ImageFree(self.img)
	end
	self.img=ImageLoad(am_pack.res,filename,IMG_4444)
	self.w=ImageGetW(self.img)
	self.h=ImageGetH(self.img)
end

function ColorButton:render(img1,img2,xd,yd)
	if not self.ispress then
		if img1 then
			ImageToScreen(img1,self.dx,self.dy)
		end
	else
		if img2 then
			if xd and yd then
				ImageToScreen(img2,self.dx+xd,self.dy+yd)
			else
				ImageToScreen(img2,self.dx,self.dy)
			end
		end
	end
	if self.img then
		ImageToScreen(self.img,self.dx+self.xd,self.dy+self.yd)
	end
end

function ColorButton:testrect(x,y)
	if x > self.dx and x < self.dx+self.w and
		y > self.dy and y < self.dy+self.h then
		return true
	end
	return false
end

function ColorButton:press_down()
	self.ispress=true
end

function ColorButton:press_up()
	self.ispress=false
end