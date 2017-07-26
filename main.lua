

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
    ["carot"]   =   {   bleedRate = 0.167,  stun = 0,   wounded = false},
    ["subcl"]   =   {   bleedRate = 0.200,  stun = 0,   wounded = false},
    ["brach"]   =   {   bleedRate = 0.023,  stun = 0,   wounded = false},
    ["kidneyR"]  =   {   bleedRate = 0.010,  stun = 7,   wounded = false},
    ["kidneyL"]  =   {   bleedRate = 0.010,  stun = 7,   wounded = false},
    ["stomach"] =   {   bleedRate = 0.030,  stun = 5,   wounded = false},
}



enemy.addWound = function ( hitpoint )
    if not enemy.hitpoints[hitpoint].wounded or enemy.dead then
        enemy.bleedRate = enemy.bleedRate + enemy.hitpoints[hitpoint].bleedRate
        enemy.stunRemaining = enemy.stunRemaining + enemy.hitpoints[hitpoint].stun

        enemy.hitpoints[hitpoint].wounded = true

        addFeedback ("Vital stab to " .. hitpoint .. ", bleeding " .. enemy.bleedRate .. "L/s." .. " Stunned " .. math.ceil(enemy.stunRemaining) .. " seconds.")
    else
        addFeedback ("Vital stab to" .. hitpoint .. " to little effect.")
    end
end

enemy.tick = function (dt)

    if enemy.dead then
        if enemy.bloodCurrent == 0 then
            return
        elseif enemy.bloodCurrent < 0.1 then
            enemy.bleedRate = 0
            enemy.bloodCurrent = 0
            addFeedback ("Enemy has stopped bleeding.")
        elseif enemy.bloodCurrent < 0.6 then
            enemy.bleedRate = 0.01
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
            addFeedback ("Enemy is no longer stunned.")
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

character = {}
    character.new = function()
    end



function attack (point, type, damage, pen, depth)
    local armorPend = false
    local vitalHit = false
    local damageMulti = 1
    local totalDamage = 0

    attackMessage = point .. ", " .. type .. ", " .. damage .. "dmg, " .. pen .. "pen, " .. depth .. "in.        "


    if pen > enemy.hitpoints[point].armor then

        armorPend = true
        attackMessage = attackMessage .. "Penetrated. "

        totalDamage = damage

        if depth > enemy.hitpoints[point].vitalDepth then

            vitalHit = true
            attackMessage = attackMessage .. "Vital hit. "

            damageMulti = 2

        end

    end

    totalDamage = totalDamage * damageMulti

    attackMessage = attackMessage .. "Total Damage " .. totalDamage

    addFeedback (attackMessage)

    return attackMessage
end



--------------------------------------------


function addMessage (string)
    logText = logText .. "\n" ..  string
    logMsgCounter = logMsgCounter + 1
    if logMsgCounter > 20 then
        --messagesText:clear()
        logMsgCounter = 0
        logText = string
    end

    messagesText:set ( logText )

end

function addFeedback (string)
    feedbackMsgCounter = feedbackMsgCounter + 1
    if feedbackMsgCounter > 10 then
        feedbackMsgCounter = 0
        feedbackLog = math.floor(currentTime) ..": ".. string
    else
        feedbackLog = feedbackLog .. "\n" ..  math.floor(currentTime) ..": ".. string
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


function love.update(dt)
    currentTime = love.timer.getTime() - start


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


        if (joyN and joystickPrevInput ~= 5) then
            addMessage(joystickInputHistory)
            joystickInputHistory = ""
        elseif not joyN and joystickInput ~= joystickPrevInput then
            joystickInputHistory = joystickInputHistory .. joystickInput
        end

    end


----------------------------------------------


inputText:set ( "button: "..currentbutton.."\njoy in: "..joystickInput )

enemyStatusText:set ( "Blood: ".. enemy.bloodCurrent .. "L\nBleed: " .. enemy.bleedRate .. "L/s\nStunT: " .. enemy.stunRemaining )

timeElapsedText:set ( "Time: "..math.floor(currentTime).." seconds" )

-----------------------------------------------


    enemy.tick (dt)


end -- END UPDATE

--------------------------------------------------------------------------------
-------------------------------------------------------------------------- DRAW
--------------------------------------------------------------------------------
function love.draw()
    --love.graphics.print("button: "..currentbutton.."\njoy in: "..joystickInput.."\nlast button: "..lastbutton.."\nAxis X: "..axisdirX.."\nAxis Y: "..axisdirY, 0, 400)
    --love.graphics.print("button: "..currentbutton.."\njoy in: "..joystickInput, 0, 400)


    love.graphics.draw(messagesText, 0, 0 )
    love.graphics.draw(inputText, 0, 380 )
    love.graphics.draw(feedbackText, 0, 430 )

    love.graphics.draw(timeElapsedText, 250, 300 )
    love.graphics.draw(enemyStatusText, 250, 330 )


end
