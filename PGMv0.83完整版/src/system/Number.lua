
--local dot = ImageLoad(am_pack.res,"数字小数点.png",IMG_4444)
--local mao = ImageLoad(am_pack.res,"数字冒号.png",IMG_4444)

NumberButton=class(ClassBase)

function NumberButton:ctor(t)
	self.img={}
	for i=1,10 do
		self.img[i]=t[i]
	end
end

function NumberButton:destory()
	self.img=nil
end

function NumberButton:render(num,dx,dy,_mode,_scale)
	local mode=_mode
	local scale=_scale
	local number=tostring( math.floor(num) )
	if not scale then scale=1.0 end
	if not mode then mode=-1 end
	if mode==-1 then
		for i=1,string.len(number) do
			local img=self.img[ string.byte(number,i)-47 ]
			DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
			dx=dx+ImageGetW(img)*scale
		end
	elseif mode==1 then
		for i=string.len(number),1,-1 do
			local img=self.img[ string.byte(number,i)-47 ]
			dx=dx-ImageGetW(img)*scale
			DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
		end
	elseif mode==0 then
		local w=0
		dy=dy-ImageGetH(self.img[1])*scale*0.5
		for i=1,string.len(number) do
			local img=self.img[ string.byte(number,i)-47 ]
			w=w+ImageGetW(img)*scale	
		end
		dx=dx-w*0.5
		self:render(num,dx,dy,-1,scale)
	end
end

function NumberButton:floatRender(num,dx,dy,_mode,_scale)
	local mode=_mode
	local scale=_scale
	local number=tostring( num )
	--print(number)
	if not scale then scale=1.0 end
	if not mode then mode=-1 end
	if mode==-1 then
		for i=1,string.len(number) do
			if string.byte(number,i)==0x2E then
				-- 小数点
				local img=dot
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
				dx=dx+ImageGetW(img)*scale
			else
				local img=self.img[ string.byte(number,i)-47 ]
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
				dx=dx+ImageGetW(img)*scale
			end
		end
	elseif mode==1 then
		for i=string.len(number),1,-1 do
			if string.byte(number,i)==0x2E then
				-- 小数点
				local img=dot
				dx=dx-ImageGetW(img)*scale
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
			else
				local img=self.img[ string.byte(number,i)-47 ]
				dx=dx-ImageGetW(img)*scale
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
			end
		end
	elseif mode==0 then
		local w=0
		dy=dy-ImageGetH(self.img[1])*scale*0.5
		for i=1,string.len(number) do
			if string.byte(number,i)==0x2E then
				local img=dot
				w=w+ImageGetW(img)*scale
			else
				local img=self.img[ string.byte(number,i)-47 ]
				w=w+ImageGetW(img)*scale
			end
		end
		dx=dx-w*0.5
		self:floatRender(num,dx,dy,-1,scale)
	end
end

function NumberButton:dataRender(hour,minute,second,dx,dy,_mode,_scale)
	local mode=_mode
	local scale=_scale
	local h,m,sec=0,0,0
	if tonumber(hour) < 10 then h="0"..hour else h=hour end
	if tonumber(minute) < 10 then m="0"..minute else m=minute end
	if tonumber(second) < 10 then sec="0"..second else sec=second end
	local number = h .. ":" .. m .. ":" .. sec
	--print(number)
	if not scale then scale=1.0 end
	if not mode then mode=-1 end
	if mode==-1 then
		for i=1,string.len(number) do
			if string.byte(number,i)==0x3A then
				-- 冒号
				local img=mao
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
				dx=dx+ImageGetW(img)*scale
			else
				local img=self.img[ string.byte(number,i)-47 ]
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
				dx=dx+ImageGetW(img)*scale
			end
		end
	elseif mode==1 then
		for i=string.len(number),1,-1 do
			if string.byte(number,i)==0x3A then
				-- 冒号
				local img=mao
				dx=dx-ImageGetW(img)*scale
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
			else
				local img=self.img[ string.byte(number,i)-47 ]
				dx=dx-ImageGetW(img)*scale
				DrawImage(img,0,0,0,0,dx,dy,ImageGetW(img)*scale,ImageGetH(img)*scale)
			end
		end
	elseif mode==0 then
		local w=0
		dy=dy-ImageGetH(self.img[1])*scale*0.5
		for i=1,string.len(number) do
			if string.byte(number,i)==0x3A then
				local img=mao
				w=w+ImageGetW(img)*scale
			else
				local img=self.img[ string.byte(number,i)-47 ]
				w=w+ImageGetW(img)*scale
			end
		end
		dx=dx-w*0.5
		self:dataRender(hour,minute,second,dx,dy,-1,scale)
	end
end
