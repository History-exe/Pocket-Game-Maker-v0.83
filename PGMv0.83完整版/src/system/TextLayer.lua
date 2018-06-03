
DialogLayer=class(PGBase)

function DialogLayer:ctor()
	self.quad={}
	self.mdx=0
	self.mdy=0
	self.w=0
	self.h=0
end

function DialogLayer:init(x,y,w,h,dtype)
	self.mdx=x
	self.mdy=y
	self.w=w
	self.h=h
	self.quad[1]=ImageCreate(w,h,dtype)
end

function DialogLayer:fini()
	for i=1,10 do
		if self.quad[i] then
			ImageFree(self.quad[i])
			self.quad[i]=false
		else
			break
		end
	end
end

function DialogLayer:render(index)
	if self.quad[index] then
		ImageToScreen(self.quad[index],self.mdx,self.mdy)
	end
end

function DialogLayer:clear()
	for i=1,10 do
		if self.quad[i] then
			ImageClear(self.quad[i])
		else
			break
		end
	end
end

function texfg_quad_create(font_p,color,str,w,h,font_width,font_height)
	local layer=DialogLayer.new()
	layer:init(0,0,w,h,IMG_4444)
	string_to_quad(font_p,color,str,layer.quad,0,2,font_width,font_height,200,100)
	local quad=layer.quad[1]
	layer=nil
	return quad
end

function string_to_quad(font_p,color,str,quad,mdx,mdy,font_width,font_height,linelen,linemax)
	-- °Ñ×Ö·û´®Ð´ÈëquadÍ¼²ã±í
	local quad_i=1	--Í¼²ãË÷Òý
	local word_table=DialogCreate(str)
	local code_table={count=0}
	local dx,dy=mdx,mdy
	local len_count,line_count=0,0

	FontSetColor(font_p,color)

	for i=1,word_table.count do
		local unit=word_table[i]
		if unit.type==PGD_SINT8 then
			FontDraw(font_p,quad[quad_i],unit.value,dx,dy)
			dx=dx+FontTextSize(font_p,unit.value)
			len_count=len_count+1
		elseif unit.type==PGD_UINT8 then
			FontDraw(font_p,quad[quad_i],unit.value,dx,dy)
			dx=dx+font_width
			len_count=len_count+2
		elseif unit.type==PGD_NEWLINE then
			if unit.value==0 then
				unit.value=1
			end
			line_count=line_count+unit.value
			dy=dy+font_height*unit.value
			dx=mdx
		elseif unit.type==PGD_COLOR then
			code_table.count=code_table.count+1
			code_table[ code_table.count ] = {type=unit.type,value=unit.value}
			FontSetColor(font_p,unit.value)
		elseif unit.type==PGD_DCOLOR then
			code_table.count=code_table.count-1
			if code_table.count <= 0 then
				code_table.count=0
				FontSetColor(font_p,color)
			else
				FontSetColor(font_p,code_table[ code_table.count ].value)
			end
		end

		if len_count >= linelen-1 then
			len_count=0
			line_count=line_count+1
			dy=dy+font_height
			dx=mdx
		end

		if line_count >= linemax then
			dx=mdx
			dy=mdy
			len_count=0
			line_count=0
			quad_i=quad_i+1
			if not quad[ quad_i ] then
				quad[quad_i]=ImageClone(quad[quad_i-1])
				ImageClear(quad[quad_i])
			else
				ImageClear(quad[quad_i])
			end
		end
	end

	FontSetColor(font_p,color)
end
