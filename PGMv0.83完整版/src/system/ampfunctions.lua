
--========================================
-- define avg maker functions
--========================================

function bg(index,file,num,timeticks)
	if timeticks~=0 and timeticks>100 then timeticks=timeticks-100 end
	am_scene.bg[index]:load(file,num,timeticks,IMG_8888)
end

function bgnull(...)
	for i=1,AM_SCENE_BG_MAX do
		if arg[i] then
			am_scene.bg[arg[i]]:fini()
			am_scene.bg[arg[i]]:init()
		else
			break
		end
	end
end

function bgxy(index,dx,dy)
	if not dx then
		return am_scene.bg[index].dx,am_scene.bg[index].dy
	end
	am_scene.bg[index].dx = dx
	am_scene.bg[index].dy = dy
end

function bgon(index)
	am_scene.bg[index].display = true
end

function bgoff(index)
	am_scene.bg[index].display = false
end

function bgeff(index,num,timeticks)
	if num then
		if timeticks~=0 and timeticks>100 then timeticks=timeticks-100 end
		am_scene.bg[index]:seteffect_p(num,timeticks)
		return 1
	else
		if not am_scene.bg[index].effect_type then
			return 0
		elseif am_scene.bg[index].image_p[am_scene.bg[index].image_index+1] then
			return 1
		end
	end
	return -1
end

function bgmov(index1,index2)
	bgnull(index1)
	local temp=am_scene.bg[index1]
	am_scene.bg[index1] = am_scene.bg[index2]
	am_scene.bg[index2] = temp
	bgoff(index1)
end

function bgcpy(index1,index2)
	am_scene.bg[index1]:fini()
	am_scene.bg[index1] = am_scene.bg[index2]:clone()
	collectgarbage("collect")
end

function bgswap(index1,index2)
	local temp = am_scene.bg[index1]
	am_scene.bg[index1] = am_scene.bg[index2]
	am_scene.bg[index2] = temp
end

--======================================================

function fg(index,file,num,timeticks,...)
	local dtype = IMG_4444
	if arg[1] and arg[1]~=0 then dtype = arg[1] end
	if timeticks~=0 and timeticks>100 then timeticks=timeticks-100 end
	am_scene.fg[index]:load(file,num,timeticks,dtype)
end

function fgnull(...)
	for i=1,AM_SCENE_FG_MAX do
		if arg[i] then
			am_scene.fg[arg[i]]:fini()
			am_scene.fg[arg[i]]:init()
		else
			break
		end
	end
end

function fgxy(index,dx,dy)
	if not dx then
		return am_scene.fg[index].dx,am_scene.fg[index].dy
	end
	am_scene.fg[index].dx = dx
	am_scene.fg[index].dy = dy
end

function fgon(index)
	am_scene.fg[index].display = true
end

function fgoff(index)
	am_scene.fg[index].display = false
end

function fgeff(index,num,timeticks)
	if num then
		if timeticks~=0 and timeticks>100 then timeticks=timeticks-100 end
		am_scene.fg[index]:seteffect_p(num,timeticks)
		return 1
	else
		if not am_scene.fg[index].effect_type then
			return 0
		elseif am_scene.fg[index].image_p[am_scene.fg[index].image_index+1] then
			return 1
		end
	end
	return -1
end

function fgmov(index1,index2)
	fgnull(index1)
	local temp=am_scene.fg[index1]
	am_scene.fg[index1] = am_scene.fg[index2]
	am_scene.fg[index2] = temp
	fgoff(index1)
end

function fgcpy(index1,index2)
	am_scene.fg[index1]:fini()
	am_scene.fg[index1] = am_scene.fg[index2]:clone()
	collectgarbage("collect")
end

function fgswap(index1,index2)
	local temp = am_scene.fg[index1]
	am_scene.fg[index1] = am_scene.fg[index2]
	am_scene.fg[index2] = temp
end

--======================================================

function texfg(index,str,num,timeticks,...)
	--print(DIALOG_FONT_WIDTH,DIALOG_FONT_HEIGHT)
	if timeticks~=0 and timeticks>100 then timeticks=timeticks-100 end
	am_scene.texfg[index]:load(str,num,timeticks,am_font.pf,FONT_COLOR,...)
end

function texfgnull(...)
	for i=1,AM_SCENE_FG_MAX do
		if arg[i] then
			am_scene.texfg[arg[i]]:fini()
			am_scene.texfg[arg[i]]:init()
		else
			break
		end
	end
end

function texfgxy(index,dx,dy)
	if not dx then
		return am_scene.texfg[index].dx,am_scene.texfg[index].dy
	end
	am_scene.texfg[index].dx = dx
	am_scene.texfg[index].dy = dy
end

function texfgon(index)
	am_scene.texfg[index].display = true
end

function texfgoff(index)
	am_scene.texfg[index].display = false
end

function texfgeff(index,num,timeticks)
	if num then
		if timeticks~=0 and timeticks>100 then timeticks=timeticks-100 end
		am_scene.texfg[index]:seteffect_p(num,timeticks)
		return 1
	else
		if not am_scene.texfg[index].effect_type then
			return 0
		elseif am_scene.texfg[index].image_p[am_scene.texfg[index].image_index+1] then
			return 1
		end
	end
	return -1
end

function texfgmov(index1,index2)
	texfgnull(index1)
	local temp=am_scene.texfg[index1]
	am_scene.texfg[index1] = am_scene.texfg[index2]
	am_scene.texfg[index2] = temp
	texfgoff(index1)
end

function texfgcpy(index1,index2)
	am_scene.texfg[index1]:fini()
	am_scene.texfg[index1] = am_scene.texfg[index2]:clone()
	collectgarbage("collect")
end

function texfgswap(index1,index2)
	local temp = am_scene.texfg[index1]
	am_scene.texfg[index1] = am_scene.texfg[index2]
	am_scene.texfg[index2] = temp
end

--======================================================

function name(tx)
	if tx then
		texfg(32,tx,1,500)
		texfgxy(32,DIALOG_NAME_DX,DIALOG_NAME_DY)
		texfgon(32)
	else
		texfgnull(32)
	end
end

function namexy(dx,dy)
	DIALOG_NAME_DX = dx
	DIALOG_NAME_DY = dy
end

--======================================================

function tst(file)
	tstnull()
	am_matte.image_p = ImageLoad(am_pack.res,file,IMG_8888)
	am_matte.name = file
end

function tstnull()
	if am_matte.image_p then
		ImageFree(am_matte.image_p)
		am_matte.image_p = false
		am_matte.name = ""
	end
end

--======================================================

function mp3load(file,index)
	am_sound.mp3[index]:load(PGM_RES_FOLDER .. file)
	mp3volume(index,128)
end

function mp3play(index)
	am_sound.mp3[index]:play()
end

function mp3pause(index)
	am_sound.mp3[index]:pause()
end

function mp3resume(index)
	am_sound.mp3[index]:resume()
end

function mp3stop(index)
	am_sound.mp3[index]:stop()
end

function mp3replay(index)
	am_sound.mp3[index]:replay()
end

function mp3unload(index)
	am_sound.mp3[index]:unload()
end

function mp3volume(index,vol)
	am_sound.mp3[index]:volume(vol)
end

function mp3playtimes(index,times)
	am_sound.mp3[index]:settimes(times)
end

function mp3fadein(index,vol,speed,step)
	if temp_sound == nil then
		temp_sound = {}
		temp_sound.vol = 0
		temp_sound.speed = speed
		temp_sound.step = step
		temp_sound.count = 0
	end
	temp_sound.count = temp_sound.count + 1
	if temp_sound.count >= temp_sound.speed then
		temp_sound.count = 0
		temp_sound.vol = temp_sound.vol + temp_sound.step
		if temp_sound.vol >= vol then
			temp_sound.vol = vol
		end
	end
	mp3volume(index,temp_sound.vol)
	if temp_sound.vol~=128 then
		amp_loop()
	else
		temp_sound = nil
	end
end

function mp3fadeout(index,vol,speed,step)
	if temp_sound == nil then
		temp_sound = {}
		temp_sound.vol = vol
		temp_sound.speed = speed
		temp_sound.step = step
		temp_sound.count = 0
	end
	temp_sound.count = temp_sound.count + 1
	if temp_sound.count >= temp_sound.speed then
		temp_sound.count = 0
		temp_sound.vol = temp_sound.vol - temp_sound.step
		if temp_sound.vol <= 0 then
			temp_sound.vol = 0
		end
	end
	mp3volume(index,temp_sound.vol)
	if temp_sound.vol~=0 then
		amp_loop()
	else
		temp_sound = nil
	end
end

function mp3isfinish(index)
	return am_sound.mp3[index]:IsFinish()
end

--======================================================

function wavload(file,index)
	am_sound.wav[index]:load(PGM_RES_FOLDER .. file)
	wavvolume(index,128)
end

function wavloadbuf(buffer,size,index)
	am_sound.wav[index]:loadbuf(buffer,size)
end

function wavplay(index)
	am_sound.wav[index]:play()
end

function wavpause(index)
	am_sound.wav[index]:pause()
end

function wavresume(index)
	am_sound.wav[index]:resume()
end

function wavstop(index)
	am_sound.wav[index]:stop()
end

function wavreplay(index)
	am_sound.wav[index]:replay()
end

function wavunload(index)
	am_sound.wav[index]:unload()
end

function wavvolume(index,vol)
	am_sound.wav[index]:volume(vol)
end

function wavplaytimes(index,times)
	am_sound.wav[index]:settimes(times)
end

function wavfadein(index,vol,speed,step)
	if temp_sound == nil then
		temp_sound = {}
		temp_sound.vol = 0
		temp_sound.speed = speed
		temp_sound.step = step
		temp_sound.count = 0
	end
	temp_sound.count = temp_sound.count + 1
	if temp_sound.count >= temp_sound.speed then
		temp_sound.count = 0
		temp_sound.vol = temp_sound.vol + temp_sound.step
		if temp_sound.vol >= vol then
			temp_sound.vol = vol
		end
	end
	wavvolume(index,temp_sound.vol)
	if temp_sound.vol~=128 then
		amp_loop()
	else
		temp_sound = nil
	end
end

function wavfadeout(index,vol,speed,step)
	if temp_sound == nil then
		temp_sound = {}
		temp_sound.vol = vol
		temp_sound.speed = speed
		temp_sound.step = step
		temp_sound.count = 0
	end
	temp_sound.count = temp_sound.count + 1
	if temp_sound.count >= temp_sound.speed then
		temp_sound.count = 0
		temp_sound.vol = temp_sound.vol - temp_sound.step
		if temp_sound.vol <= 0 then
			temp_sound.vol = 0
		end
	end
	wavvolume(index,temp_sound.vol)
	if temp_sound.vol~=0 then
		amp_loop()
	else
		temp_sound = nil
	end
end

function wavisfinish(index)
	return am_sound.wav[index]:IsFinish()
end

--======================================================

function playfile(file,index)
	if string.sub(file,-3)=="mp3" then
		if index==2 and scene.EventScene and
			speakmode()==speak_mode_skip then
			return
		end
		mp3load(file,index)
		if index==2 then mp3playtimes(index,1) end
		mp3play(index)
	elseif string.sub(file,-3)=="wav" then
		if speakmode()==speak_mode_skip and scene.EventScene then
			return
		end
		wavload(file,index)
		wavplay(index)
	end
end

function stopfile(pos,index)
	if pos=="mp3" then
		mp3stop(index)
	elseif pos=="wav" then
		wavstop(index)
	end
end

function pmplay(file)
	if PGMPSP then
		local pmp = MovieCreate(PGM_RES_FOLDER .. file)
		MoviePlay(pmp)
		repeat until MovieEos(pmp)
		MovieDelete(pmp)
	else
		print("pmp play fail ...")
	end
end

--======================================================

function Print(...)
	print(...)
end

function run(file)
	if string.sub(file,-3)~=".ev" then
		print("run <" .. file .. "> fail. suffix not \".ev\" ...")
		return
	end
	am_script.stackCount = am_script.stackCount + 1
	am_script[am_script.stackCount] = CacheEScriptCreate(am_pack.script,file)
	EScriptBack( am_script[am_script.stackCount] )
end

function jump(file)
	exit()
	run(file)
end

function exit()
	if am_script==nil then return true end
	if am_script.stackCount > 0 then
		EScriptDelete(am_script[am_script.stackCount])
		am_script[am_script.stackCount] = nil
		am_script.stackCount = am_script.stackCount - 1
	end
	-- if stack null then return true
	return am_script.stackCount==0
end

function goto(label)
	if am_script.stackCount==0 then return end
	EScriptJump(am_script[am_script.stackCount],label)
end

function gotoif(condition,label)
	if condition==true then goto(label) end
end

function doif(condition,s_code)
	if condition==true then PGDoString(s_code) end
end

function amp_loop()
	if am_script.stackCount==0 then return end
	EScriptBack(am_script[am_script.stackCount])
end

function pause(t)
	if am_script then
		am_script.pausetimes = t
		am_script.ispause = true
		am_script.lasttick = TimerGetTicks(am_timer)
	end
end

function stacknull()
	repeat until exit()
end

function printallev()
	for i=1,am_script.stackCount do
		EScriptPrint(am_script[i])
	end
end

--======================================================

function allclear(flag)
	if not flag then
		for i=1,AM_SCENE_BG_MAX do bgnull(i) end
		for i=1,AM_SCENE_FG_MAX do fgnull(i) texfgnull(i) end
		for i=1,2 do mp3unload(i) end
		for i=1,4 do wavunload(i) end
		tstnull()
		name()
		textclear()
		am_ramus_fini()
		CacheClear()
	elseif flag=="bg" then
		for i=1,AM_SCENE_BG_MAX do bgnull(i) end
	elseif flag=="fg" then
		for i=1,AM_SCENE_FG_MAX do fgnull(i) end
	elseif flag=="texfg" then
		for i=1,AM_SCENE_FG_MAX do texfgnull(i) end
	elseif flag=="mp3" then
		for i=1,2 do mp3unload(i) end
	elseif flag=="wav" then
		for i=1,4 do wavunload(i) end
	elseif flag=="text" then
		name()
		textclear()
	elseif flag=="sel" then
		am_ramus_fini()
	elseif flag=="mask" then
		tstnull()
	end

	am_script.ispause=false
	collectgarbage("collect")
end

function stageclear()
	allclear()
	am_rect_allreset()
end


--======================================================
-- draw functions
--======================================================

function drawscenebase()
	if scene then scene:fini() end
	scene = PGSceneBase.new()
	scene:init()
	collectgarbage("collect")
end

--======================================================

function setrect(index,left,right,top,bottom)
	if am_rect[index] then
		am_rect[index].left = left
		am_rect[index].right = right
		am_rect[index].top = top
		am_rect[index].bottom = bottom
	end
end

function setrectscr(index,script)
	if am_rect[index] then am_rect[index].script = script end
end

function delrect(index)
	am_rect_reset(index)
end

function testrect(dx,dy)
	for i=32,1,-1 do
		if dx > am_rect[i].left and dx < am_rect[i].right and dy > am_rect[i].top and dy < am_rect[i].bottom then
			return i
		end
	end
	return -1
end

function runrectscr(index)
	if am_rect[index] and am_rect[index].script then run(am_rect[index].script) end
end

function jumprectscr(index)
	if am_rect[index] and am_rect[index].script then
		jump(am_rect[index].script)
	end
end

function findtest()
	return testrect(am_rect.dx,am_rect.dy)
end

function printrect(index)
	if am_rect[index] then
		print("=============================")
		print("NO." .. index .. ":")
		print("left = " .. am_rect[index].left)
		print("right = " .. am_rect[index].right)
		print("top = " .. am_rect[index].top)
		print("bottom = " .. am_rect[index].bottom)
		print("script = \"" .. am_rect[index].script .. "\"")
	end
	print("\n")
end

function printallrect()
	for i=1,32 do printrect(i) end
end

--======================================================

function AllVarReset(v)
	if not v then
		am_var_reset(0)
	else
		am_var_reset(v)
	end
end

function callmenuon()
	call_menu_flag = true
end

function callmenuoff()
	call_menu_flag = false
end

function screencolor(r,g,b,a)
	am_scene.r = r
	am_scene.g = g
	am_scene.b = b
	am_scene.a = a
	SetScreenColor(r,g,b,a)
end

function QUIT()
	PGSetState(PGM_QUIT)
end
