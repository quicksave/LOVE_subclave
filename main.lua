
--love.filesystem.setRequirePath("?.lua;?/init.lua;"..love.filesystem.getSource().."/?.lua;"..love.filesystem.getSource().."/?/init.lua")

require 'tween'

require "ProtoPlayer"
require "ProtoEnemy"
require "ProtoKnife"
require "attackAnim"
require "round"


local ignoreAllInputs = false

local attackMessage = "init"
local logText = "loginit"
local feedbackLog = "feedbackinit"

local messagesText
local logMsgCounter = 0
local feedbackMsgCounter = 0
--local myfont = love.graphics.newFont(14) -- the number denotes the font size

local activeAnimation = {}

start = love.timer.getTime()
currentTime = 0

playerStateInput = "none"


--------------------------------------------------------------------------------

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
    --[[
    local kbToControllerTable =
        {
            ["1"]   =   "1x",
            ["2"]   =   "2x",
            ["3"]   =   "6x",
            ["4"]   =   "8x",
            ["5"]   =   "9x",
        }

    handleInput ( kbToControllerTable[key] )
    --]]

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



function handleInput ( dirButton )
    if ignoreAllInputs then return end

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
            ["a"]   =   "pressgrab",
            ["b"]   =   "pressattack",
            ["x"]   =   "releaseattack",
            ["y"]   =   "releasegrab",
        }

    if validAtkCmds[dirButton] ~= nil then
        doAttackAnimation ( validAtkCmds[dirButton] )
        --addMessage (validAtkCmds[dirButton])
    elseif validStateCmds[dirButton] ~= nil then
        player.handleInput( validStateCmds[dirButton] )
        --addMessage( validStateCmds[dirButton] )
    end



end



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



function doAttackAnimation (hitpoint)

    table.insert (activeAnimation, attackAnim.new(enemy, hitpoint, 1, 0.5) )
    --ignoreAllInputs = false
end



--------------------------------------------------------------------------------


function addMessage (string)
    logText = logText .. "\n" ..  string
    logMsgCounter = logMsgCounter + 1
    if logMsgCounter > 16 then
        --messagesText:clear()
        logMsgCounter = 0
        logText = string
    end

    messagesText:set ( logText )

end

function addFeedback (string)
    feedbackMsgCounter = feedbackMsgCounter + 1
    if feedbackMsgCounter > 14 then
        feedbackMsgCounter = 0
        feedbackLog = round(currentTime, 1) ..": ".. string
    else
        feedbackLog = feedbackLog .. "\n" ..  round(currentTime, 1) ..": ".. string
    end

    feedbackText:set ( feedbackLog )

end


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


end

--------------------------------------------------------------------------------

local connectedJoysticks = love.joystick.getJoysticks()
local activeJoystick = connectedJoysticks[1]
local axisdirX = 0
local axisdirY = 0

local joyDirThreshold = 0.5
local joyR = false
local joyL = false
local joyU = false
local joyD = false

local joystickInput = 5
local joystickInputHistory = ""
local joyN = false

----------------------------------------

function love.keyreleased(key)

    if key == '`' then
        debug.debug()
    else
        kbReleased = key
    end


    if key == '7' then
        player.handleInput( "press_grab" )
    end
    if key == '8' then
        player.handleInput( "press_attack" )
    end
    if key == '9' then
        player.handleInput( "release_attack" )
    end
    if key == '0' then
        player.handleInput( "release_grab" )
    end
end



local currentbutton = "none"
local lastbutton = "none"
local lastpadaxis = "none"

function love.gamepadpressed(joystick, button)
    lastbutton = button
    currentbutton = button


    if joystickInput == 5 then
        handleInput (button)
        addMessage (button)
    else
        handleInput (joystickInput .. button)
        addMessage(joystickInput .. button)
    end
    --table.insert (currentbuttons, button)


end

function love.gamepadreleased( joystick, button )
    if button == currentbutton then
        currentbutton = "none"
    end
end


--------------------------------------------------------------------------------
------------------------------------------------------------------------ UPDATE
--------------------------------------------------------------------------------


local attackAnimDone = false

function love.update(dt)
    currentTime = love.timer.getTime() - start


--------------------------------------------
    enemy.tick(dt)

    player.tick(dt)

    if activeAnimation[1] ~= nil then

        ignoreAllInputs = true
        attackAnimDone = activeAnimation[1].tick(dt)

        if attackAnimDone then
            table.remove (activeAnimation)
        end
    else
        ignoreAllInputs = false
    end
--------------------------------------------


    axisdirX = activeJoystick:getAxis(1)
    axisdirY = activeJoystick:getAxis(2)

    axisdirXabs = math.abs(axisdirX)
    axisdirYabs = math.abs(axisdirY)

    axisCombinedAmp = axisdirXabs + axisdirYabs

    if axisdirXabs > .8 or axisdirYabs > .8 or axisCombinedAmp > 1.3 or axisCombinedAmp < .3  then

        joystickPrevInput = joystickInput

        joyN = false

        joyR = false
        joyL = false
        joyU = false
        joyD = false

        joyR = axisdirX > joyDirThreshold
        joyL = axisdirX < -joyDirThreshold
        joyU = axisdirY < -joyDirThreshold
        joyD = axisdirY > joyDirThreshold

        if joyR then
            if joyU then
                joystickInput = 9
            elseif joyD then
                joystickInput = 3
            else
                joystickInput = 6
            end
        elseif joyL then
            if joyU then
                joystickInput = 7
            elseif joyD then
                joystickInput = 1
            else
                joystickInput = 4
            end
        else
            if joyU then
                joystickInput = 8
            elseif joyD then
                joystickInput = 2
            else
                joystickInput = 5
                joyN = true
            end
        end


        if joyN and joystickPrevInput ~= 5 then
            addMessage(joystickInputHistory)

            joystickInputHistory = ""
        elseif not joyN and joystickInput ~= joystickPrevInput then
            joystickInputHistory = joystickInputHistory .. joystickInput
        end

    end










----------------------------------------------

inputText:set ( "button: "..currentbutton.."\njoy in: "..joystickInput )

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
