
--love.filesystem.setRequirePath("?.lua;?/init.lua;"..love.filesystem.getSource().."/?.lua;"..love.filesystem.getSource().."/?/init.lua")

require 'tween'

require "ProtoPlayer"
require "ProtoEnemy"
require "ProtoKnife"
require "ControllerInput"
require "InputQueue"
require "attackAnim"

require "commonfnc"


local ignoreAllInputs = false

local attackMessage = "init"

--local messagesText

--local myfont = love.graphics.newFont(14) -- the number denotes the font size

local activeAnimation = {}

start = love.timer.getTime()
currentTime = 0

logText = "loginit"
logMsgCounter = 0

feedbackLog = "feedbackinit"
feedbackMsgCounter = 0
--playerStateInput = "none"


--------------------------------------------------------------------------------

--[[
function handleKBInput (key, pressed)
    if pressed then
        handleKBPressed(key)
    else
        handleKBReleased(key)
    end

end

function handleKBPressed (key)

end

function handleKBReleased (key)
    local kbToControllerTable =
        {
            ["1"]   =   "1x",
            ["2"]   =   "2x",
            ["3"]   =   "6x",
            ["4"]   =   "8x",
            ["5"]   =   "9x",
        }

    handleInput ( kbToControllerTable[key] )

    if key == '7' then
        player.handleInput("press_grab")
    end
    if key == '8' then
        player.handleInput("press_attack")
    end
    if key == '9' then
        player.handleInput("release_attack")
    end
    if key == '0' then
        player.handleInput("release_grab")
    end
end
--]]



function handleInput ( joydir, button )
    if ignoreAllInputs then return end

    local joybutton = joydir..button
    local dirtrbutton = joydir..button

    validAtkCmds =
        {
            ["1rightshoulder"]   =   "kidneyL",
            ["2rightshoulder"]   =   "kidneyR",
            ["6rightshoulder"]   =   "brach",
            ["8rightshoulder"]   =   "carot",
            ["9rightshoulder"]   =   "subcl",
        }
    validStateCmds =
        {
            ["LTpressed"]   =   "pressgrab",
            ["x"]           =   "pressattack",
            ["xreleased"]   =   "releaseattack",
            ["LTreleased"]  =   "releasegrab",
        }



    if validAtkCmds[joybutton] ~= nil then
        addMessage (joybutton)
        doAttackAnimation ( validAtkCmds[joybutton] )
    elseif validStateCmds[button] ~= nil then
        addMessage (button)
        player.handleInput( validStateCmds[button] )
    end



end


--[[
local ProtoAnimation = {}

ProtoAnimation.new = function (time)
    local self = {}

    self.blockInput = false
    self.isDone = false
    self.animTime = time

    self.tick = function (dt)

    end

    return self
end
--]]


function doAttackAnimation (hitpoint)

    table.insert (activeAnimation, attackAnim.new(enemy, hitpoint, 1, 0.5) )
    --ignoreAllInputs = false
end






--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-------------------------------------------------------------------------- LOAD
--------------------------------------------------------------------------------

function love.load()
    myfont = love.graphics.newImageFont("imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"")

    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    timeElapsedText = love.graphics.newText(myfont, "seconds")
    messagesText = love.graphics.newText(myfont, "messages")
    inputText = love.graphics.newText(myfont, "input")
    feedbackText = love.graphics.newText(myfont, "feedback")
    enemyStatusText = love.graphics.newText(myfont, "enemystatus")

    love.graphics.setBackgroundColor( 70, 70, 70 )


    player = ProtoPlayer.new()
    enemy = ProtoEnemy.new()
    knife = ProtoKnife.new(389,150)
    controller = ControllerInput.new( (love.joystick.getJoysticks())[1] )
    inputQ = InputQueue.new()


end

--------------------------------------------------------------------------------


function love.keyreleased(key)

    if key == '`' then
        debug.debug()
    end
end




function love.gamepadpressed(joystick, button)

    controller.updateButton(button, true)

    handleInput (controller.inputState.leftjoy ,  controller.activebutton)
    --addMessage (controller.inputState.leftjoy .. controller.activebutton)

end

function love.gamepadreleased( joystick, button )

    controller.updateButton(button, false)

    handleInput(5, button .. "released" )

end



--------------------------------------------------------------------------------
------------------------------------------------------------------------ UPDATE
--------------------------------------------------------------------------------


local attackAnimDone = false

function love.update(dt)
    currentTime = love.timer.getTime() - start



--------------------------------------------
    enemy.tick(dt)

    ignoreAllInputs = player.tick(dt)

    controller.tick()


--------------------------------------------



--[[
    if activeAnimation[1] ~= nil then

        ignoreAllInputs = true
        attackAnimDone = activeAnimation[1].tick(dt)

        if attackAnimDone then
            table.remove (activeAnimation)
        end
    else
        ignoreAllInputs = false
    end
--]]

    --[[

        if joyN and joystickPrevInput ~= 5 then
            addMessage(joystickInputHistory)

            joystickInputHistory = ""
        elseif not joyN and joystickInput ~= joystickPrevInput then
            joystickInputHistory = joystickInputHistory .. joystickInput
        end

end
--]]


----------------------------------------------

--inputText:set ( "button: "..currentbutton.."\njoy in: "..joystickInput.."\naxisX: "..axisdirX.."\naxisY: "..axisdirY )
--inputText:set ( "button: "..currentbutton.."\njoy in: "..joystickInput.."\n        LT: "..axisdirLT.."\n        RT: "..axisdirRT )
inputText:set ( "button: ".. controller.activebutton .."\njoy in: ".. controller.inputState.leftjoy)

enemyStatusText:set ( "Blood: ".. round(enemy.bloodCurrent,3) .. " L\nBleed: " .. enemy.bleedRate .. " L/s\nStunT: " .. enemy.stunRemaining )

timeElapsedText:set ( "Time:  "..round(currentTime, 1))

-----------------------------------------------

end -- END UPDATE







--------------------------------------------------------------------------------
-------------------------------------------------------------------------- DRAW
--------------------------------------------------------------------------------
function love.draw()
    --love.graphics.print("button: "..currentbutton.."\njoy in: "..joystickInput.."\nlast button: "..lastbutton.."\nAxis X: "..axisdirX.."\nAxis Y: "..axisdirY, 0, 400)
    --love.graphics.print("button: "..currentbutton.."\njoy in: "..joystickInput, 0, 400)

    love.graphics.setColor(200 - (1 - enemy.bloodCurrent / 5) * 100, 30, 0)
    love.graphics.ellipse("fill", 500, 250,  (1 - enemy.bloodCurrent / 5) * 400, (1 - enemy.bloodCurrent / 5) * 400, 100)

    enemy.draw ()

    if ignoreAllInputs then
        love.graphics.setColor( 255 , 255, 0 )
        love.graphics.ellipse("fill", 175, 280, 50, 50, 4)
    end


    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(messagesText, 0, 0 )
    love.graphics.draw(inputText, 0, 300 )
    love.graphics.draw(feedbackText, 0, 345 )

    love.graphics.draw(timeElapsedText, 250, 250 )
    love.graphics.draw(enemyStatusText, 250, 270 )

    knife.draw ()



end
