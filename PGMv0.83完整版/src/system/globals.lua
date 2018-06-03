
--=====================================
-- global var
--=====================================

--============================
value = {}	-- 系统用变量
event = {}	-- 事件用标记
line = {}
pub_event = {}
pub_value = {}
pub_line = {}
TABLE_VALUE_MAX = 128
TABLE_EVENT_MAX = 512
TABLE_LINE_MAX = 64
--============================

am_font = {pf=false}
am_matte = {name="",image_p=false}
am_scene = {r=0,g=0,b=0,a=255}
am_sound = {}
am_rect = {dx=0,dy=0}
am_script = {stackCount=0,pausetimes=0,ispause=false,lasttick=0}
am_effect = {fadein=1,fadeout=2,shake=3,trans=4,trans2=5}
am_pack = {res=gmdata(),script=gmcode()}

am_ramus = false
full_dialog = false

call_menu_flag = true

am_timer = TimerCreate()
TimerStart(am_timer)

AM_SCENE_BG_MAX = 2
AM_SCENE_FG_MAX = 32
AM_RECT_MAX = 32

am_scene.bg = {}
am_scene.fg = {}
am_scene.texfg = {}
for i=1,AM_SCENE_BG_MAX do
	am_scene.bg[i] = FGBase.new()
end
for i=1,AM_SCENE_FG_MAX do
	am_scene.fg[i] = FGBase.new()
	am_scene.texfg[i] = TexFgBase.new()
end

am_sound.mp3 = {SoundBase.new("mp3"),SoundBase.new("mp3")}
am_sound.wav = {}
for i=1,4 do
	am_sound.wav[i] = SoundBase.new("wav")
end

for i=1,AM_RECT_MAX do
	am_rect[i] = {left=0,right=0,top=0,bottom=0,script=""}
end


--=====================================
-- global var end
--=====================================

function am_font_getinstance()
	if not am_font.pf then
		am_font.pf = FontCreate(PGM_RES_FOLDER .. FONT_PATH,FONT_SIZE)
		FontSetColor(am_font.pf,FONT_COLOR)
	end
	return am_font.pf
end

function am_scene_update()
	
end

function am_scene_render()
	for i=1,AM_SCENE_BG_MAX do
		am_scene.bg[i]:render()
	end

	for i=1,AM_SCENE_FG_MAX do
		am_scene.fg[i]:render()
	end

	for i=1,AM_SCENE_FG_MAX do
		am_scene.texfg[i]:render()
	end

	text_layer_render()
	am_ramus_render()
end

function am_script_clear()
	if am_script.stackCount==0 then return end
	for i=1,am_script.stackCount do
		EScriptDelete(am_script[i])
	end
	am_script = {stackCount=0,pausetimes=0,ispause=false,lasttick=0}
end

function am_rect_reset(index)
	if am_rect[index] then
		am_rect[index].left = 0
		am_rect[index].right = 0
		am_rect[index].top = 0
		am_rect[index].bottom = 0
		am_rect[index].script = ""
	end
end

function am_rect_allreset()
	am_rect.dx = 0
	am_rect.dy = 0
	for i=1,AM_RECT_MAX do am_rect_reset(i) end
end

function am_ramus_update()
	if am_ramus then am_ramus:update() end
end

function am_ramus_render()
	if am_ramus then am_ramus:render() end
end

function am_ramus_fini()
	if am_ramus then
		am_ramus:fini() am_ramus=false
	end
end

function am_var_reset(v)
	for i=1,TABLE_VALUE_MAX do
		value[i] = v
		pub_value[i] = v
	end
	for i=1,TABLE_EVENT_MAX do
		event[i] = v
		pub_event[i] = v
	end
	for i=1,TABLE_LINE_MAX do
		line[i]=""
		pub_line[i]=""
	end
end

am_var_reset(0)
