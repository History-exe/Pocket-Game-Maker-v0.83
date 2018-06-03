
-- ==============================================
-- from: http://blog.codingnow.com/cloud/LuaOO/
local _class={}

function class(super)
	local class_type={}
	class_type.ctor=false
	class_type.super=super
	class_type.new=function(...)
			local obj={}
			do
				local create
				create = function(c,...)
					if c.super then
						create(c.super,...)
					end
					if c.ctor then
						c.ctor(obj,...)
					end
				end

				create(class_type,...)
			end
			setmetatable(obj,{ __index=_class[class_type] })
			return obj
	end
	local vtbl={}
	_class[class_type]=vtbl
	setmetatable(class_type,{__newindex=
		function(t,k,v)
			vtbl[k]=v
		end
	})
	if super then
		setmetatable(vtbl,{__index=
			function(t,k)
				local ret=_class[super][k]
				vtbl[k]=ret
				return ret
			end
		})
	end
	return class_type
end

local _count=0

local function ClearSomeVar(count)
	_count=_count+1
	if _count>=count then
		_count=0
		collectgarbage("collect")
	end
end

math.randomseed(os.time())
math.random()

-- ==============================================
-- class base
ClassBase=class()
function ClassBase:ctor() end
function ClassBase:destory() end
function ClassBase:update() end
function ClassBase:render() end
function ClassBase:idle() end
	
-- ==============================================
-- object base
ObjectBase=class(ClassBase)
function ObjectBase:ctor() end
function ObjectBase:hotpoint(x,y) end
function ObjectBase:touch_down(x,y,prev_x,prev_y,tapCount) end
function ObjectBase:touch_move(x,y,prev_x,prev_y,tapCount) end
function ObjectBase:touch_up(x,y,prev_x,prev_y,tapCount) end

-- ==============================================
-- scene class
SceneBase=class(ObjectBase)
function SceneBase:ctor()
	--ClearSomeVar(10)
end
function SceneBase:key_up(key) end
function SceneBase:key_down(key) end
function SceneBase:analog_left(x,y) end
function SceneBase:analog_right(x,y) end
function SceneBase:ftouch_began(id,x,y,prev_x,prev_y,tapCount) end
function SceneBase:ftouch_moved(id,x,y,prev_x,prev_y,tapCount) end
function SceneBase:ftouch_ended(id,x,y,prev_x,prev_y,tapCount) end
function SceneBase:htouch_began(id,x,y,prev_x,prev_y,tapCount) end
function SceneBase:htouch_moved(id,x,y,prev_x,prev_y,tapCount) end
function SceneBase:htouch_ended(id,x,y,prev_x,prev_y,tapCount) end

function SceneBase:inputProc()
	InputProc()
end

function SceneBase:loop()
	self:update()
	BeginScene()
	self:render()
	EndScene()
	self:idle()
end

-- ==============================================
-- class's create and destory
function new(_class,...)
	return _class.new(...)
end

function delete(_class)
	return _class:destory()
end

function sprintf(str,...)
	return string.format(str,...)
end

function rand(...)
	return math.random(...)
end
