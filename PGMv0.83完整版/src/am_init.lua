
-- ================================================================
-- include
-- ================================================================






-- ================================================================
-- game msg var
-- ================================================================
-- 如果想使用psp官方存档,GAME_NAME不得超过12个字符
GAME_NAME = "AMT"
GAME_VERSION = 1.0
GAME_MSG = "avg maker template msg"
GAME_SAVELISTSIZE = 8
GAME_SAVEMODE = PGMPC

-- create game save folder (PGMSAVEDATA)
CreatePGMSaveFolder()

-- only use in psp
PSP_GAME_ICON0 = "icon0.png"
PSP_GAME_ICON1 = "icon1.pmf"
PSP_GAME_PIC1 = "pic1.png"
PSP_GAME_SND0 = "snd0.at3"
PSP_GAME_SAVEMODE = PSP_UTILITY_SAVEDATA_LISTSAVE
PSP_GAME_LOADMODE = PSP_UTILITY_SAVEDATA_LISTLOAD

function chapters(msg)
	GAME_MSG = msg
end

DEFAULT_SOUND = "sound_bi.wav"


-- ================================================================
-- font msg constant var
-- ================================================================
FONT_PATH = "fz.ttf"
FONT_SIZE = 11
FONT_COLOR = MAKE_RGBA_4444(0,0,0,255)
am_font_getinstance()


-- ================================================================
-- dialog module constant var
-- ================================================================
DIALOG_ICON = "win_wait_a.png"
DIALOG_ICON_SPEED = 50
DIALOG_ICON_DX = 410
DIALOG_ICON_DY = 258
DIALOG_ICON_SIZE = 22

DIALOG_SPEED = 16
DIALOG_FONT_WIDTH = 16
DIALOG_FONT_HEIGHT = 18
DIALOG_LINELEN = 50	-- 行字符数量限制
DIALOG_LINEMAX = 3	-- 行数量限制
DIALOG_DX = 35
DIALOG_DY = 234

DIALOG_NAME_DX = 76
DIALOG_NAME_DY = 168

DIALOG_AUTO_ICON = "auto.png"
DIALOG_AUTO_ICON_DX = 0
DIALOG_AUTO_ICON_DY = 0
DIALOG_AUTO_ICON_TICK = 350
DIALOG_AUTO_TICK = 2000
DIALOG_SOUND = "sound_bi.wav"

DIALOG_HALFSCREEN = 1
DIALOG_FULLSCREEN = 2
DIALOG_MODE = DIALOG_HALFSCREEN


-- ================================================================
-- title module constant var
-- ================================================================
TITLE_ICON = "hand_icon01.png"
TITLE_ICON_DX = 335
TITLE_ICON_DY = 153
TITLE_ICON_STEP_DX = 0
TITLE_ICON_STEP_DY = 36
TITLE_ICON_INDEX = 0	-- select result
TITLE_BUTTON = {"title_start.png","title_load.png","title_quit.png"}
TITLE_BUTTON_DX = 380
TITLE_BUTTON_DY = 150
TITLE_BUTTON_STEP_DX = 0
TITLE_BUTTON_STEP_DY = 36
TITLE_BUTTON_COUNT = 3
TITLE_SOUND = "sound_bi.wav"
TITLE_CONTROL_MODE = 2	-- 1左右控制、2上下控制

function title_callback()
	drawevent()
end

function SET_TITLE_BUTTON(...)
	for i=1,20 do
		if not arg[i] then
			break
		end
		TITLE_BUTTON[i]=arg[i]
		TITLE_BUTTON_COUNT=i
	end
end

function SET_TITLE_COORD(x,y,step_x,step_y)
	TITLE_BUTTON_DX = x
	TITLE_BUTTON_DY = y
	TITLE_BUTTON_STEP_DX = step_x
	TITLE_BUTTON_STEP_DY = step_y
end

function SET_TITLE_ICON(file,x,y,step_x,step_y,mode)
	TITLE_ICON = file
	TITLE_ICON_DX = x
	TITLE_ICON_DY = y
	TITLE_ICON_STEP_DX = step_x
	TITLE_ICON_STEP_DY = step_y

	if mode==1 then
		TITLE_CONTROL_MODE = 1
	else
		TITLE_CONTROL_MODE = 2
	end
end


-- ================================================================
-- find module constant var
-- ================================================================
FIND_ICON = "find_icon.png"
FIND_ICON_DX = 480/2-16
FIND_ICON_DY = 272/2-16
FIND_ICON_SPEED = 2
FIND_ANALOG_SPEED = 0.35
FIND_SOUND = "sound_bi.wav"

function find_callback()
	jumprectscr(findtest())
	drawevent()
end


-- ================================================================
-- menu module constant var
-- ================================================================
MENU_BOX = "menu_box.png"
MENU_BOX_DX = 142
MENU_BOX_DY = -8
MENU_ICON = "hand_icon01.png"
MENU_ICON_DX = 170
MENU_ICON_DY = 78
MENU_ICON_STEP_DX = 0
MENU_ICON_STEP_DY = 26
MENU_ICON_INDEX = 0	-- select result
MENU_BUTTON = {"menu_skip.png","menu_auto.png","menu_load.png","menu_save.png","menu_quit.png"}
MENU_BUTTON_DX = 210
MENU_BUTTON_DY = 80
MENU_BUTTON_STEP_DX = 0
MENU_BUTTON_STEP_DY = 26
MENU_BUTTON_COUNT = 5
MENU_SOUND = "sound_bi.wav"
MENU_CONTROL_MODE = 2	-- 1左右控制、2上下控制

function menu_callback()
	if menutest()==5 then
		allclear()
		stacknull()
		jump("am_start.ev")
		drawevent()
	elseif menutest()==1 then
		drawskip()
		speakmode(speak_mode_skip)
	elseif menutest()==2 then
		drawauto()
		speakmode(speak_mode_auto)
	elseif menutest()==3 then
		drawload()
	elseif menutest()==4 then
		drawsave()
	else drawevent() end
end


-- ================================================================
-- ramus module constant var
-- ================================================================
RAMUS_ICON = "hand_icon02.png"
RAMUS_ICON_DX = 120
RAMUS_ICON_DY = 74
RAMUS_ICON_STEP_DX = 0
RAMUS_ICON_STEP_DY = 35
RAMUS_BUTTON_BG = "ramus_bg.png"
RAMUS_BUTTON_BG_DX = 60
RAMUS_BUTTON_BG_DY = 60
RAMUS_BUTTON_DX = 94
RAMUS_BUTTON_DY = 68
RAMUS_BUTTON_STEP_DX = 0
RAMUS_BUTTON_STEP_DY = 35
RAMUS_BUTTON_ICON_MODE = 2
RAMUS_BUTTON_INDEX = 0	-- select result
RAMUS_SOUND = "sound_bi.wav"

function ramus_callback()
	-- not thing to do
end

function SET_RAMUS_ICON(file,x,y,step_x,step_y)
	RAMUS_ICON = file
	RAMUS_ICON_DX = x
	RAMUS_ICON_DY = y
	RAMUS_ICON_STEP_DX = step_x
	RAMUS_ICON_STEP_DY = step_y
end

function SET_RAMUS_BUTTON(bg,x,y,step_x,step_y)
	RAMUS_BUTTON_BG = bg
	RAMUS_BUTTON_BG_DX = x
	RAMUS_BUTTON_BG_DY = y
	RAMUS_BUTTON_DX = x+35
	RAMUS_BUTTON_DY = y+6
	RAMUS_BUTTON_STEP_DX = step_x
	RAMUS_BUTTON_STEP_DY = step_y
end


-- ================================================================
-- save module constant var
-- ================================================================
SAVE_UI_FILE = "save_ui.png"
SAVE_UI_ICON = ""
SAVE_UI_LOADING = "save_loading.png"
SAVE_UI_DEFAULT = "pgmlogo.png"
SAVE_SOUND = "sound_bi.wav"


-- ================================================================
-- 攻略用到的图片,引擎默认按L键呼出攻略
-- ================================================================
--[[
	攻略
]]--
strategy_img={
	"攻略1.png",
	"攻略2.png",
	"攻略3.png",
}


-- ================================================================
-- define user functions
-- ================================================================

function pubdata_checkup()
	run("pubdata.ev")
end

function amp_save_callback()
	-- 存档前的函数回调
end

function amp_load_callback()
	-- 读档后的函数回调
end





-- ================================================================
-- run event script
-- ================================================================
jump "am_start.ev" drawevent()