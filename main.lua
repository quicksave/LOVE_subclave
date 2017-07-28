
local tween = require 'tween'

local ignoreAllInputs = false

local attackMessage = "init"
local logText = "loginit"
local feedbackLog = "feedbackinit"

local messagesText
local logMsgCounter = 0
local feedbackMsgCounter = 0
--local myfont = love.graphics.newFont(14) -- the number denotes the font size


start = love.timer.getTime()
currentTime = 0

--------------------------------------------------------------------------------
-- it belongs in a library!

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------

enemy = {}


enemy.bloodMax = 5
enemy.bloodCurrent = 5
enemy.bleedRate = 0

enemy.shock = 0
enemy.weak = false
enemy.conscious = true
enemy.dead = false

enemy.stunned = false
enemy.stunRemaining = 0

enemy.hitpoints =
{
    ["carot"]   =   {   bleedRate = 0.167,  stun = 0,   wounded = false,    relPosX = 60,   relPosY = -10 },
    ["subcl"]   =   {   bleedRate = 0.200,  stun = 0,   wounded = false,    relPosX = 80,   relPosY = 7 },
    ["brach"]   =   {   bleedRate = 0.023,  stun = 0,   wounded = false,    relPosX = 110,  relPosY = 30 },
    ["kidneyR"] =   {   bleedRate = 0.010,  stun = 8,   wounded = false,    relPosX = 75,   relPosY = 140 },
    ["kidneyL"] =   {   bleedRate = 0.010,  stun = 7,   wounded = false,    relPosX = 45,   relPosY = 140 },
    ["stomach"] =   {   bleedRate = 0.030,  stun = 5,   wounded = false,    relPosX = 60,   relPosY = 120 },
}


enemy.originX = 500
enemy.originY = 200

enemy.draw = function ()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", enemy.originX, enemy.originY, 120, 180, 25)
    love.graphics.ellipse("fill", enemy.originX + 60, enemy.originY - 60, 30, 40, 100)

    for i,v in pairs{"carot", "subcl", "brach", "kidneyR", "kidneyL", "stomach"} do
        if enemy.hitpoints[v].wounded then
            love.graphics.setColor(255, 0, 255)
        else
            love.graphics.setColor(0, 0, 0)
        end
        love.graphics.circle( "fill", enemy.originX + enemy.hitpoints[v].relPosX, enemy.originY + enemy.hitpoints[v].relPosY, 5 )
    end

    --[[for i,v in ipairs(enemy.hitpoints) do

        local px = enemy.originX + enemy.hitpoints[v].relPosX
        local py = enemy.originY + enemy.hitpoints[v].relPosY

        if enemy.hitpoints[v].wounded then
            love.graphics.setColor(255, 0, 255)
        else
            love.graphics.setColor(0, 0, 0)
        end

        love.graphics.circle( "fill", px, py, 5 )
    end
    --]]
end


enemy.addWound = function ( hitpoint )
    if not enemy.hitpoints[hitpoint].wounded and not enemy.dead then
        enemy.bleedRate = enemy.bleedRate + enemy.hitpoints[hitpoint].bleedRate
        if enemy.conscious then
            enemy.stunRemaining = enemy.stunRemaining + enemy.hitpoints[hitpoint].stun
        end

        enemy.hitpoints[hitpoint].wounded = true

        addFeedback ("Vital stab to " .. hitpoint .. ", bleeding " .. enemy.bleedRate .. "L/s." .. " "..round(enemy.hitpoints[hitpoint].stun, 1) .. "s stun added.")
    else
        addFeedback ("Vital stab to " .. hitpoint .. " has little effect.")
    end
end

enemy.tick = function (dt)

    if enemy.dead then
        if enemy.bloodCurrent == 0 then
            return
        elseif enemy.bloodCurrent < 0.01 then
            enemy.bleedRate = 0
            enemy.bloodCurrent = 0
            addFeedback ("Enemy has stopped bleeding.")
        elseif enemy.bloodCurrent < 0.6 then
            enemy.bleedRate = 0.01
        elseif enemy.bloodCurrent < 1.6 then
            enemy.bleedRate = 0.03
        end

    end

----------------------------------- use dt

    enemy.bloodCurrent = enemy.bloodCurrent - (enemy.bleedRate * dt)

    if enemy.stunRemaining > 0 then

        enemy.stunRemaining = enemy.stunRemaining - dt
        if enemy.stunRemaining < 0 then enemy.stunRemaining = 0 end

        if enemy.stunRemaining == 0 then
            enemy.stunned = false
            --leave stun
            if enemy.conscious then addFeedback ("Enemy is no longer stunned.") end
        else
            enemy.stunned = true
            --enter stun
        end
    end

---------------------------------- end dt


    local bloodloss = 1 - enemy.bloodCurrent / enemy.bloodMax
    enemy.shock = math.floor( bloodloss * 10 )

    if enemy.shock >= 2 then
        if not enemy.weak then
            enemy.weak = true
            addFeedback ("Enemy seems weak.")
        end
        if enemy.shock >= 3 then
            if enemy.conscious then
                enemy.conscious = false
                addFeedback ("Enemy loses consciousness.")
            end
            if enemy.shock >= 5 then
                if not enemy.dead then
                    enemy.dead = true
                    addFeedback ("Enemy appears ghostly pale.")
                end
            end
        end
    end



end -- end tick



--------------------------------------------------------------------------------
local attackAnimActive = {}


local attackAnim = {}

attackAnim.new = function (hitpoint, startup, recovery)
    local self = {}
    self.name = "defaultAttackAnimation"
    self.targetPoint = hitpoint
    self.startupTime = startup
    self.recoveryTime = recovery
    self.animTimeElapsed = 0
    self.starting = true
    self.recovered = false

    self.tick = function (buttonreleased, dt)
        self.animTimeElapsed = self.animTimeElapsed + dt

        if self.recovered then return self.recovered end

        if self.starting then
            self.startupTime = self.startupTime - dt
            if self.startupTime <= 0 then
                self.starting = false
                enemy.addWound ( hitpoint )
            end
        else

            self.recoveryTime = self.recoveryTime - dt
            if self.recoveryTime <= 0 then
                self.recovered = true

                addMessage ("Animation done ("..round(self.animTimeElapsed, 1).."s)")

            end
        end

        return self.recovered
    end

    return self
end


--[[
animation.tick ( dt  )
    timeremaining
    isdone = false

    move object at distance/timeremaining * dt

    timeremaining = timeremaining - dt

    if timeremaining <= 0 then idone = true; return isdone end


attack.tick
    active anim = {}
    anim.startup = animation.new (object, animdata )
    anim.atkactive = animation.new (object, animdata , buttonh)
    anim.recovery = animation.new (object, animdata )



anim.new (object, animdata, button)
    animdata.path
    animdata.time

animdata.new ( path, totaltime, cmdToExec, execTime <0-1> )


--]]






    --------------------------------------------------------------------------------

function handleInput ( dirButton )
    if ignoreAllInputs then return end

    validCmds =
        {
            ["1x"]   =   "kidneyL",
            ["2x"]   =   "kidneyR",
            ["6x"]   =   "brach",
            ["8x"]   =   "carot",
            ["9x"]   =   "subcl",
        }

    if validCmds[dirButton] ~= nil then
        doAttackAnimation ( validCmds[dirButton] )
        --addMessage (validCmds[dirButton])
    end
end



function doAttackAnimation (hitpoint)

    attackAnimActive[1] = attackAnim.new(hitpoint, 1, 0.5)
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


    timeElapsedText = love.graphics.newText(myfont, "seconds")
    messagesText = love.graphics.newText(myfont, "messages")
    inputText = love.graphics.newText(myfont, "input")
    feedbackText = love.graphics.newText(myfont, "feedback")
    enemyStatusText = love.graphics.newText(myfont, "enemystatus")

    love.graphics.setBackgroundColor( 70, 70, 70 )

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
    if key == '1' then
        enemy.addWound( "kidneyL" )
    end
    if key == '2' then
        enemy.addWound( "kidneyR" )
    end
    if key == '3' then
        enemy.addWound( "carot" )
    end
    if key == '4' then
        enemy.addWound( "subcl" )
    end
    if key == '5' then
        enemy.addWound( "brach" )
    end
    if key == '6' then
        enemy.addWound( "stomach" )
    end
    if key == '`' then
        debug.debug()
    end
end



local currentbutton = "none"
local lastbutton = "none"
local lastpadaxis = "none"

function love.gamepadpressed(joystick, button)
    lastbutton = button
    currentbutton = button

    addMessage(joystickInput .. button)

    handleInput (joystickInput .. button)

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
    enemy.tick (dt)

    if attackAnimActive[1] ~= nil then

        ignoreAllInputs = true
        attackAnimDone = attackAnimActive[1].tick(dt)

        if attackAnimDone then
            attackAnimActive[1] = nil
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

enemyStatusText:set ( "Blood: ".. enemy.bloodCurrent .. " L\nBleed: " .. enemy.bleedRate .. " L/s\nStunT: " .. enemy.stunRemaining )

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




end
