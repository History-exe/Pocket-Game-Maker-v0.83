
--========================================
-- define event scene class
--========================================

PGEventScene=class(PGSceneBase)

function PGEventScene:ctor()
	--not thing to do
	self.EventScene=true
end

function PGEventScene:update()
	am_scene_update()
	FrameEvScriptUpdate()
end

function PGEventScene:render()
	am_scene_render()
end


function FrameEvScriptUpdate()
	if not am_script.ispause then
		local count = am_script.stackCount
		if am_script.stackCount~=0 then
			if not EScriptIsEnd(am_script[am_script.stackCount]) then
				if EScriptCurrLine(am_script[am_script.stackCount])>=1 then
					EScriptDoline(am_script[am_script.stackCount])
				end
				if am_script.stackCount==count then
					EScriptNext(am_script[am_script.stackCount])
				elseif am_script.stackCount<count and am_script.stackCount~=0 then
					EScriptNext(am_script[am_script.stackCount])
				end
			else
				exit()
				if am_script.stackCount~=0 then
					EScriptNext(am_script[am_script.stackCount])
				end
			end
		end
	else
		if TimerGetTicks(am_timer) - am_script.lasttick >= am_script.pausetimes then
			am_script.ispause = false
			am_script.pausetimes = 0
			am_script.lasttick = TimerGetTicks(am_timer)
		end
	end
end

-- ================================================

function drawevent()
	if scene then scene:fini() end
	if am_ramus then
		scene = PGRamusScene.new()
	else
		if speaking() then
			if speakmode()==speak_mode_sample then
				scene = SpeakScene.new()
			elseif speakmode()==speak_mode_skip then
				scene = SkipScene.new()
			elseif speakmode()==speak_mode_auto then
				scene = AutoScene.new()
			end
		else
			scene = PGEventScene.new()
		end
	end
	scene:init()
	collectgarbage("collect")
end
