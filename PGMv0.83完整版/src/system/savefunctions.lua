
--========================================
-- define game save functions
--========================================

function GetSaveFolderPath()
	if PGMPSP then
		return "ms0:/psp/PGMSAVEDATA"
	elseif PGMIOS then
		return "../Documents/PGMSAVEDATA"
	elseif PGMPC then
		return "PGMSAVEDATA"
	elseif PGMARD then
		return "PGMSAVEDATA"
	end
	return "PGMSAVEDATA"
end

function GetGameDataFolderPath(num)
	if num < 10 then
		return GAME_NAME .. "000" .. num
	elseif num < 100 then
		return GAME_NAME .. "00" .. num
	elseif num < 1000 then
		return GAME_NAME .. "0" .. num
	else
		return GAME_NAME ..  num
	end
end

function GetFullGameDataFolderPath(num)
	return GetSaveFolderPath() .. "/" .. GetGameDataFolderPath(num)
end

function GetFullPubGameDataFolderPath()
	return GetSaveFolderPath() .. "/" .. GAME_NAME .. "SYS"
end

function CreatePGMSaveFolder()
	FolderCreate( GetSaveFolderPath() )
end

function CreateGameDataBuffer()
	-- malloc 64kb
	local buffer,size = PGBufferCreate(1024 * 64)
	local offset = 0

	-- read success flag
	MEMNUMCPY(buffer+offset,65535,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)

	if call_menu_flag then
		MEMNUMCPY(buffer+offset,1,MEM_UINT8)
	end
	offset = offset + MEMMODESIZE(MEM_UINT8)

	-- value
	for i=1,TABLE_VALUE_MAX do
		MEMNUMCPY(buffer+offset,value[i],MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
	end
	-- event
	for i=1,TABLE_EVENT_MAX do
		MEMNUMCPY(buffer+offset,event[i],MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
	end
	-- line
	for i=1,TABLE_LINE_MAX do
		MEMSTRCPY(buffer+offset,line[i],MEM_UINT8_128)
		offset = offset + MEMMODESIZE(MEM_UINT8_128)
	end

	-- font
	MEMSTRCPY(buffer+offset,FONT_PATH,MEM_UINT8_64)
	offset = offset + MEMMODESIZE(MEM_UINT8_64)
	MEMNUMCPY(buffer+offset,FONT_SIZE,MEM_UINT8)
	offset = offset + MEMMODESIZE(MEM_UINT8)
	MEMNUMCPY(buffer+offset,FONT_COLOR,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)

	-- matte
	MEMSTRCPY(buffer+offset,am_matte.name,MEM_UINT8_32)
	offset = offset + MEMMODESIZE(MEM_UINT8_32)

	-- screen color
	MEMNUMCPY(buffer+offset,am_scene.r,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)
	MEMNUMCPY(buffer+offset,am_scene.g,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)
	MEMNUMCPY(buffer+offset,am_scene.b,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)
	MEMNUMCPY(buffer+offset,am_scene.a,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)

	-- bg * x
	for i=1,AM_SCENE_BG_MAX do
		local bg = am_scene.bg[i]
		MEMSTRCPY(buffer+offset,bg.file,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		MEMNUMCPY(buffer+offset,bg.dx,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		MEMNUMCPY(buffer+offset,bg.dy,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		if bg.display then
			MEMNUMCPY(buffer+offset,1,MEM_SINT8)
		else
			MEMNUMCPY(buffer+offset,0,MEM_SINT8)
		end
		offset = offset + MEMMODESIZE(MEM_SINT8)
		MEMNUMCPY(buffer+offset,bg.dtype,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
	end

	-- fg * x
	for i=1,AM_SCENE_FG_MAX do
		local fg = am_scene.fg[i]
		MEMSTRCPY(buffer+offset,fg.file,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		MEMNUMCPY(buffer+offset,fg.dx,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		MEMNUMCPY(buffer+offset,fg.dy,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		if fg.display then
			MEMNUMCPY(buffer+offset,1,MEM_SINT8)
		else
			MEMNUMCPY(buffer+offset,0,MEM_SINT8)
		end
		offset = offset + MEMMODESIZE(MEM_SINT8)
		MEMNUMCPY(buffer+offset,fg.dtype,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
	end

	-- texfg * x
	for i=1,AM_SCENE_FG_MAX do
		-- str,dx,dy,display,w,h
		local texfg = am_scene.texfg[i]
		MEMSTRCPY(buffer+offset,texfg.str,MEM_UINT8_128)
		offset = offset + MEMMODESIZE(MEM_UINT8_128)
		MEMNUMCPY(buffer+offset,texfg.dx,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		MEMNUMCPY(buffer+offset,texfg.dy,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		if texfg.display then
			MEMNUMCPY(buffer+offset,1,MEM_SINT8)
		else
			MEMNUMCPY(buffer+offset,0,MEM_SINT8)
		end
		offset = offset + MEMMODESIZE(MEM_SINT8)
		MEMNUMCPY(buffer+offset,texfg.quad_w,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		MEMNUMCPY(buffer+offset,texfg.quad_h,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
	end

	-- mp3 * 2
	for i=1,2 do
		-- name,vol,playtimes
		local mp3 = am_sound.mp3[i]
		MEMSTRCPY(buffer+offset,mp3.name,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		MEMNUMCPY(buffer+offset,mp3.vol,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
		MEMNUMCPY(buffer+offset,mp3.playtimes,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
	end

	-- wav * 4
	for i=1,4 do
		-- name,vol,playtimes
		local wav = am_sound.wav[i]
		MEMSTRCPY(buffer+offset,wav.name,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		MEMNUMCPY(buffer+offset,wav.vol,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
		MEMNUMCPY(buffer+offset,wav.playtimes,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
	end

	-- rect * x
	for i=1,AM_RECT_MAX do
		local rect = am_rect[i]
		MEMSTRCPY(buffer+offset,rect.script,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		MEMNUMCPY(buffer+offset,rect.top,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		MEMNUMCPY(buffer+offset,rect.bottom,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		MEMNUMCPY(buffer+offset,rect.left,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		MEMNUMCPY(buffer+offset,rect.right,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
	end

	-- event script
	for i=1,16 do
		-- name,curr_i
		local scr = am_script[i]
		if scr then
			MEMSTRCPY(buffer+offset,EScriptName(scr),MEM_UINT8_64)
			offset = offset + MEMMODESIZE(MEM_UINT8_64)
			MEMNUMCPY(buffer+offset,EScriptCurrLine(scr),MEM_SINT32)
			offset = offset + MEMMODESIZE(MEM_SINT32)
		else
			offset = offset + 68
		end
	end

	-- ramus
	if am_ramus then
		for i=1,16 do
			-- string
			if am_ramus.sel[i] then
				--print(am_ramus.test[i].string,am_ramus.label[i])
				MEMSTRCPY(buffer+offset,am_ramus.sel[i],MEM_UINT8_64)
				offset = offset + MEMMODESIZE(MEM_UINT8_64)
				MEMNUMCPY(buffer+offset,am_ramus.label[i],MEM_SINT32)
				offset = offset + MEMMODESIZE(MEM_SINT32)
			else
				offset = offset + MEMMODESIZE(MEM_UINT8_64)
				offset = offset + MEMMODESIZE(MEM_SINT32)
			end
		end
	else
		offset = offset + ((MEMMODESIZE(MEM_UINT8_64)+MEMMODESIZE(MEM_SINT32)) * 16)
	end

	-- ini,dialog,speed,dx,dy,mode
	if speak_attribute().msg then
		MEMSTRCPY(buffer+offset,speak_attribute().msg,MEM_UINT8_1024)
		offset = offset + MEMMODESIZE(MEM_UINT8_1024)
	else
		offset = offset + MEMMODESIZE(MEM_UINT8_1024)
	end


	MEMNUMCPY(buffer+offset,DIALOG_FONT_WIDTH,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_FONT_HEIGHT,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_LINELEN,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_LINEMAX,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_SPEED,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_MODE,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)

	MEMNUMCPY(buffer+offset,DIALOG_DX,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_DY,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_NAME_DX,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	MEMNUMCPY(buffer+offset,DIALOG_NAME_DY,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)

	return buffer,size
end

function CreateGameDataInfoBuffer()
	local buffer,size = PGBufferCreate(1024 * 8)
	local offset = 0

	-- gamename,version,time,msg
	MEMSTRCPY(buffer+offset,GAME_NAME,MEM_UINT8_64)
	offset = offset + MEMMODESIZE(MEM_UINT8_64)
	MEMNUMCPY(buffer+offset,GAME_VERSION,MEM_FLOAT)
	offset = offset + MEMMODESIZE(MEM_FLOAT)

	local time = localtime()
	MEMNUMCPY(buffer+offset,time.year,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.month,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.day,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.hour,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.minutes,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.seconds,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)

	MEMSTRCPY(buffer+offset,GAME_MSG,MEM_UINT8_128)
	offset = offset + MEMMODESIZE(MEM_UINT8_128)

	return buffer,size
end

function LoadGameData(buffer)
	local offset = 0

	-- test
	local flag = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	if flag~=65535 then print("buffer have invalid data.") return end

	stageclear()

	if MEMGETNUM(buffer+offset,MEM_UINT8)==1 then
		call_menu_flag = true
	else
		call_menu_flag = false
	end
	offset = offset + MEMMODESIZE(MEM_UINT8)

	for i=1,TABLE_VALUE_MAX do
		value[i] = MEMGETNUM(buffer+offset,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
	end
	for i=1,TABLE_EVENT_MAX do
		event[i] = MEMGETNUM(buffer+offset,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
	end
	for i=1,TABLE_LINE_MAX do
		line[i] = MEMGETSTR(buffer+offset,MEM_UINT8_128)
		if not line[i] then
			line[i]=""
		end
		offset = offset + MEMMODESIZE(MEM_UINT8_128)
	end

	-- font
	FONT_PATH = MEMGETSTR(buffer+offset,MEM_UINT8_64)
	offset = offset + MEMMODESIZE(MEM_UINT8_64)
	FONT_SIZE = MEMGETNUM(buffer+offset,MEM_UINT8)
	offset = offset + MEMMODESIZE(MEM_UINT8)
	FONT_COLOR = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	-- font init
	if am_font.pf then
		FontDelete(am_font.pf)
		am_font.pf = nil
	end
	am_font_getinstance()

	-- matte
	local matte = MEMGETSTR(buffer+offset,MEM_UINT8_32)
	offset = offset + MEMMODESIZE(MEM_UINT8_32)
	if matte then
		tstnull()
		tst(matte)
	end

	-- screen color
	am_scene.r = MEMGETNUM(buffer+offset,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)
	am_scene.g = MEMGETNUM(buffer+offset,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)
	am_scene.b = MEMGETNUM(buffer+offset,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)
	am_scene.a = MEMGETNUM(buffer+offset,MEM_SINT8)
	offset = offset + MEMMODESIZE(MEM_SINT8)
	screencolor(am_scene.r,am_scene.g,am_scene.b,am_scene.a)

	-- bg * x
	local _bg = {}
	for i=1,AM_SCENE_BG_MAX do
		_bg.file = MEMGETSTR(buffer+offset,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		_bg.dx = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		_bg.dy = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		_bg.display = MEMGETNUM(buffer+offset,MEM_SINT8)
		offset = offset + MEMMODESIZE(MEM_SINT8)
		_bg.dtype = MEMGETNUM(buffer+offset,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)

		if _bg.file then
			bg(i,_bg.file,0,0)
		end
		bgxy(i,_bg.dx,_bg.dy)
		if _bg.display==1 then
			bgon(i)
		end
	end

	-- fg * x
	local _fg = {}
	for i=1,AM_SCENE_FG_MAX do
		_fg.file = MEMGETSTR(buffer+offset,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		_fg.dx = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		_fg.dy = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		_fg.display = MEMGETNUM(buffer+offset,MEM_SINT8)
		offset = offset + MEMMODESIZE(MEM_SINT8)
		_fg.dtype = MEMGETNUM(buffer+offset,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)

		if _fg.file then
			if _fg.dtype~=IMG_4444 then
				fg(i,_fg.file,0,0,_fg.dtype)
			else
				fg(i,_fg.file,0,0)
			end
		end
		fgxy(i,_fg.dx,_fg.dy)
		if _fg.display==1 then
			fgon(i)
		end
	end

	-- texfg * x
	local _texfg = {}
	for i=1,AM_SCENE_FG_MAX do
		-- str,dx,dy,display,w,h
		_texfg.str = MEMGETSTR(buffer+offset,MEM_UINT8_128)
		offset = offset + MEMMODESIZE(MEM_UINT8_128)
		_texfg.dx = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		_texfg.dy = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		_texfg.display = MEMGETNUM(buffer+offset,MEM_SINT8)
		offset = offset + MEMMODESIZE(MEM_SINT8)
		_texfg.w = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		_texfg.h = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)

		if _texfg.str then
			texfg(i,_texfg.str,0,0,_texfg.w,_texfg.h)
		end
		texfgxy(i,_texfg.dx,_texfg.dy)
		if _texfg.display==1 then
			texfgon(i)
		end
	end

	local temp_folder = PGM_RES_FOLDER
	PGM_RES_FOLDER = ""

	-- mp3 * 2
	local mp3 = {}
	for i=1,2 do
		-- name,vol,playtimes
		mp3.name = MEMGETSTR(buffer+offset,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		mp3.vol = MEMGETNUM(buffer+offset,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
		mp3.playtimes = MEMGETNUM(buffer+offset,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
		if mp3.name and mp3.playtimes==0 then
			mp3load(mp3.name,i)
			mp3playtimes(i,mp3.playtimes)
			mp3volume(i,mp3.vol)
			mp3play(i)
		end
	end

	-- wav * 4
	local wav = {}
	for i=1,4 do
		-- name,vol,playtimes
		wav.name = MEMGETSTR(buffer+offset,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		wav.vol = MEMGETNUM(buffer+offset,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
		wav.playtimes = MEMGETNUM(buffer+offset,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
		if wav.name and wav.name~="buffer" and wav.playtimes==0 then
			wavload(wav.name,i)
			wavplaytimes(i,wav.playtimes)
			wavvolume(i,wav.vol)
			wavplay(i)
		end
	end

	-- rect * x
	for i=1,AM_RECT_MAX do
		am_rect[i].script = MEMGETSTR(buffer+offset,MEM_UINT8_64)
		if not am_rect[i].script then am_rect[i].script="" end
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		am_rect[i].top = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		am_rect[i].bottom = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		am_rect[i].left = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
		am_rect[i].right = MEMGETNUM(buffer+offset,MEM_SINT16)
		offset = offset + MEMMODESIZE(MEM_SINT16)
	end

	-- event script
	stacknull()
	for i=1,16 do
		-- name,curr_i
		local name = MEMGETSTR(buffer+offset,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		local label = MEMGETNUM(buffer+offset,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
		if name then
			run(name)
			goto(label)
		end
	end

	-- ramus
	am_ramus_fini()
	local ramus = {}
	for i=1,16 do
		-- string
		ramus[i] = {}
		ramus[i].str = MEMGETSTR(buffer+offset,MEM_UINT8_64)
		offset = offset + MEMMODESIZE(MEM_UINT8_64)
		ramus[i].label = MEMGETNUM(buffer+offset,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
	end

	if ramus[1].str then
		am_ramus = PGRamusButton.new(
			ramus[1].str,ramus[1].label,
			ramus[2].str,ramus[2].label,
			ramus[3].str,ramus[3].label,
			ramus[4].str,ramus[4].label,
			ramus[5].str,ramus[5].label,
			ramus[6].str,ramus[6].label,
			ramus[7].str,ramus[7].label,
			ramus[8].str,ramus[8].label,
			ramus[9].str,ramus[9].label,
			ramus[10].str,ramus[10].label,
			ramus[11].str,ramus[11].label,
			ramus[12].str,ramus[12].label,
			ramus[13].str,ramus[13].label,
			ramus[14].str,ramus[14].label,
			ramus[15].str,ramus[15].label,
			ramus[16].str,ramus[16].label)
		am_ramus:init()
	end

	-- dialog

	local dia_str = MEMGETSTR(buffer+offset,MEM_UINT8_1024)
	offset = offset + MEMMODESIZE(MEM_UINT8_1024)

	DIALOG_FONT_WIDTH = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_FONT_HEIGHT = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_LINELEN = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_LINEMAX = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_SPEED = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_MODE = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)

	DIALOG_DX = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_DY = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_NAME_DX = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)
	DIALOG_NAME_DY = MEMGETNUM(buffer+offset,MEM_UINT16)
	offset = offset + MEMMODESIZE(MEM_UINT16)

	speak_attribute_reset()

	textclear()

	if dia_str then
		speak_attribute().msg=dia_str
	end

	PGM_RES_FOLDER = temp_folder

end

function LoadGameDataInfo(buffer)
	-- get version
	local offset = 0
	local info = {}

	if MEMGETSTR(buffer+offset,MEM_UINT8_64)~=GAME_NAME then
		print("this game data can not be read.")
		return nil
	end
	info.gamename = MEMGETSTR(buffer+offset,MEM_UINT8_64)
	offset = offset + MEMMODESIZE(MEM_UINT8_64)

	if MEMGETNUM(buffer+offset,MEM_FLOAT)~=1.0 then
		print("this info can not be read.")
		return nil
	end
	info.version = MEMGETNUM(buffer+offset,MEM_FLOAT)
	offset = offset + MEMMODESIZE(MEM_FLOAT)

	-- time,msg
	info.time = {}
	info.time.year = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.month = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.day = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.hour = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.minutes = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.seconds = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)

	info.msg = MEMGETSTR(buffer+offset,MEM_UINT8_128)
	offset = offset + MEMMODESIZE(MEM_UINT8_128)

	return info
end

function SaveGameScreen( filename )
	-- save screen
	local screen = ScreenToImage()
	ImageToFile( screen, filename )
	ImageFree( screen )
end

function amp_save(num,screen)
	-- init
	amp_save_callback()

	local game_buffer,gamebuf_size = CreateGameDataBuffer()
	local info_buffer,infobuf_size = CreateGameDataInfoBuffer()

	-- save
	local folder = GetFullGameDataFolderPath(num)
	FolderCreate( folder )
	WriteBuffer(game_buffer, folder .. "/DATA.BIN", gamebuf_size)
	WriteBuffer(info_buffer, folder .. "/DATA.SFO", infobuf_size)
	if screen then
		ImageToFile( screen, folder .. "/PIC.TGA" )
	end

	-- fini
	PGBufferDelete( game_buffer )
	PGBufferDelete( info_buffer )
end

function amp_load(num)
	-- init
	local folder = GetFullGameDataFolderPath(num)
	local game_buffer,gamebuf_size = PGBufferCreate( folder .. "/DATA.BIN")

	-- load
	LoadGameData( game_buffer )

	-- fini
	PGBufferDelete( game_buffer )
	
	amp_load_callback()
end

function amp_deldata(num)
	FolderDelete( GetFullGameDataFolderPath(num) )
end


function CreatePubGameDataBuffer()
	local buffer,size = PGBufferCreate(1024 * 64)
	local offset = 0

	if not pub_value or not pub_event then
		print("pub data is nil.")
		return nil,nil
	end

	-- read success flag
	MEMNUMCPY(buffer+offset,65535,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)

	-- pub_value
	for i=1,TABLE_VALUE_MAX do
		MEMNUMCPY(buffer+offset,pub_value[i],MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
	end
	-- pub_event
	for i=1,TABLE_EVENT_MAX do
		MEMNUMCPY(buffer+offset,pub_event[i],MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
	end
	-- line
	for i=1,TABLE_LINE_MAX do
		MEMSTRCPY(buffer+offset,pub_line[i],MEM_UINT8_128)
		offset = offset + MEMMODESIZE(MEM_UINT8_128)
	end
	return buffer,size
end

function CreatePubGameDataInfoBuffer()
	local buffer,size = PGBufferCreate(1024 * 8)
	local offset = 0

	-- gamename,version,time,msg
	MEMSTRCPY(buffer+offset,GAME_NAME,MEM_UINT8_64)
	offset = offset + MEMMODESIZE(MEM_UINT8_64)
	MEMNUMCPY(buffer+offset,GAME_VERSION,MEM_FLOAT)
	offset = offset + MEMMODESIZE(MEM_FLOAT)

	local time = localtime()
	MEMNUMCPY(buffer+offset,time.year,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.month,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.day,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.hour,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.minutes,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	MEMNUMCPY(buffer+offset,time.seconds,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)

	return buffer,size
end

function LoadPubGameData(buffer)
	local offset = 0

	-- test
	local flag = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	if flag~=65535 then print("buffer have invalid data.") return end

	-- pub_value
	for i=1,TABLE_VALUE_MAX do
		pub_value[i] = MEMGETNUM(buffer+offset,MEM_SINT32)
		offset = offset + MEMMODESIZE(MEM_SINT32)
	end
	-- pub_event
	for i=1,TABLE_EVENT_MAX do
		pub_event[i] = MEMGETNUM(buffer+offset,MEM_UINT8)
		offset = offset + MEMMODESIZE(MEM_UINT8)
	end
	-- pub_line
	for i=1,TABLE_LINE_MAX do
		pub_line[i] = MEMGETSTR(buffer+offset,MEM_UINT8_128)
		if not pub_line[i] then
			pub_line[i]=""
		end
		offset = offset + MEMMODESIZE(MEM_UINT8_128)
	end
end

function LoadPubGameDataInfo(buffer)
	local offset = 0
	local info = {}

	if MEMGETSTR(buffer+offset,MEM_UINT8_64)~=GAME_NAME then
		print("this game data can not be read.")
		return nil
	end
	info.gamename = MEMGETSTR(buffer+offset,MEM_UINT8_64)
	offset = offset + MEMMODESIZE(MEM_UINT8_64)

	if MEMGETNUM(buffer+offset,MEM_FLOAT)~=1.0 then
		print("this info can not be read.")
		return nil
	end
	info.version = MEMGETNUM(buffer+offset,MEM_FLOAT)
	offset = offset + MEMMODESIZE(MEM_FLOAT)

	-- time,msg
	info.time = {}
	info.time.year = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.month = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.day = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.hour = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.minutes = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)
	info.time.seconds = MEMGETNUM(buffer+offset,MEM_SINT32)
	offset = offset + MEMMODESIZE(MEM_SINT32)

	return info
end

function amp_pubsave()
	-- init
	local game_buffer,gamebuf_size = CreatePubGameDataBuffer()
	local info_buffer,infobuf_size = CreatePubGameDataInfoBuffer()

	-- save
	local folder = GetFullPubGameDataFolderPath()
	FolderCreate( folder )
	WriteBuffer(game_buffer, folder .. "/DATA.BIN", gamebuf_size)
	WriteBuffer(info_buffer, folder .. "/DATA.SFO", infobuf_size)

	-- fini
	PGBufferDelete( game_buffer )
	PGBufferDelete( info_buffer )
end

function amp_pubload()
	-- init
	local folder = GetFullPubGameDataFolderPath()
	if FileIsExist(folder .. "/DATA.SFO") then
		local game_buffer,gamebuf_size = PGBufferCreate( folder .. "/DATA.BIN")
		-- load
		LoadPubGameData( game_buffer )
		-- fini
		PGBufferDelete( game_buffer )
		return true
	end
	return false
end

function amp_delpubdata()
	FolderDelete( GetFullPubGameDataFolderPath() )
end

--=======================================================

function psp_save(bg)
	local buffer,size = CreateGameDataBuffer()
	local icon0buf,icon0size = PGBufferCreate(am_pack.res,PSP_GAME_ICON0)
	--local icon1buf,icon1size = PGBufferCreate(am_pack.res,PSP_GAME_ICON1)
	local pic1buf,pic1size = PGBufferCreate(am_pack.res,PSP_GAME_PIC1)
	local snd0buf,snd0size = PGBufferCreate(am_pack.res,PSP_GAME_SND0)
	local image = bg
	if not bg then image=0 end
	CallPspSaveSystem(PSP_GAME_SAVEMODE,image,
		GAME_NAME,"0000","DATA.BIN",GAME_SAVELISTSIZE,
		GAME_NAME,"GAME DATA",GAME_MSG,
		buffer,size,
		icon0buf,icon0size,
		pic1buf,pic1size,
		0,0,
		snd0buf,snd0size)
	PGBufferDelete(buffer)
	PGBufferDelete(icon0buf)
	--PGBufferDelete(icon1buf)
	PGBufferDelete(pic1buf)
	PGBufferDelete(snd0buf)

	--psp_pubsave(bg)
end

function psp_load(bg)
	local buffer,size = PGBufferCreate(1024*64)
	local image = bg
	if not bg then image=0 end
	CallPspSaveSystem(PSP_GAME_LOADMODE,image,
		GAME_NAME,"0000","DATA.BIN",GAME_SAVELISTSIZE,
		GAME_NAME,"GAME DATA",GAME_MSG,
		buffer,size,
		0,0,0,0,0,0,0,0)
	LoadGameData(buffer)
	PGBufferDelete(buffer)

	--psp_pubload(bg)
end

function psp_pubsave(bg)
	-- init
	local buffer,size = CreatePubGameDataBuffer()
	local icon0buf,icon0size = PGBufferCreate(am_pack.res,PSP_GAME_ICON0)
	local image = bg
	if not bg then image=0 end

	-- save
	CallPspSaveSystem(PSP_UTILITY_SAVEDATA_AUTOSAVE,image,
		GAME_NAME.."SYS","0000","DATA.BIN",GAME_SAVELISTSIZE,
		GAME_NAME,"PUBLIC DATA","NO DETAILS",
		buffer,size,
		icon0buf,icon0size,
		0,0,0,0,0,0)

	-- fini
	PGBufferDelete( buffer )
	PGBufferDelete( icon0buf )
end

function psp_pubload(bg)
	local buffer,size = PGBufferCreate(1024 * 64)
	local image = bg
	if not bg then image=0 end

	-- load
	CallPspSaveSystem(PSP_UTILITY_SAVEDATA_AUTOLOAD,image,
		GAME_NAME.."SYS","0000","DATA.BIN",GAME_SAVELISTSIZE,
		GAME_NAME,"PUBLIC DATA","NO DETAILS",
		buffer,size,
		0,0,0,0,0,0,0,0)
	LoadPubGameData(buffer )

	-- fini
	PGBufferDelete( buffer )
end
