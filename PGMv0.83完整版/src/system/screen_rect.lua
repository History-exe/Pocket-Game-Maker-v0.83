
local up_rect = {
	left=0,
	right=PGM_ORI_SCREEN_WIDTH,
	top=0,
	bottom=PGM_ORI_SCREEN_HEIGHT*0.30
}

local down_rect = {
	left=0,
	right=PGM_ORI_SCREEN_WIDTH,
	top=PGM_ORI_SCREEN_HEIGHT*0.60,
	bottom=PGM_ORI_SCREEN_HEIGHT
}

local left_rect = {
	left=0,
	right=PGM_ORI_SCREEN_WIDTH * 0.25,
	top=0,
	bottom=PGM_ORI_SCREEN_HEIGHT
}

local right_rect = {
	left=PGM_ORI_SCREEN_WIDTH * 0.75,
	right=PGM_ORI_SCREEN_WIDTH,
	top=0,
	bottom=PGM_ORI_SCREEN_HEIGHT
}

function testuprect(dx,dy)
	if dx > up_rect.left and dx < up_rect.right and dy > up_rect.top and dy < up_rect.bottom then
		return true
	end
	return false
end

function testdownrect(dx,dy)
	if dx > down_rect.left and dx < down_rect.right and dy > down_rect.top and dy < down_rect.bottom then
		return true
	end
	return false
end

function testleftrect(dx,dy)
	if dx > left_rect.left and dx < left_rect.right and dy > left_rect.top and dy < left_rect.bottom then
		return true
	end
	return false
end

function testrightrect(dx,dy)
	if dx > right_rect.left and dx < right_rect.right and dy > right_rect.top and dy < right_rect.bottom then
		return true
	end
	return false
end

function filluprect(alpha)
	FillRect(up_rect.left+10,up_rect.top+10,(up_rect.right-up_rect.left)-20,(up_rect.bottom-up_rect.top)-20,MAKE_RGBA_4444(255,255,255,alpha),IMG_4444)
end

function filldownrect(alpha)
	FillRect(down_rect.left+10,down_rect.top+10,(down_rect.right-down_rect.left)-20,(down_rect.bottom-down_rect.top)-20,MAKE_RGBA_4444(255,255,255,alpha),IMG_4444)
end

function fillleftrect(alpha)
	FillRect(left_rect.left+10,left_rect.top+10,(left_rect.right-left_rect.left)-20,(left_rect.bottom-left_rect.top)-20,MAKE_RGBA_4444(255,255,255,alpha),IMG_4444)
end

function fillrightrect(alpha)
	FillRect(right_rect.left+10,right_rect.top+10,(right_rect.right-right_rect.left)-20,(right_rect.bottom-right_rect.top)-20,MAKE_RGBA_4444(255,255,255,alpha),IMG_4444)
end
