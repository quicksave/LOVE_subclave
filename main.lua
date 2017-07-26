

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
enemy.health = 3
enemy.bloodVol = 5

enemy.hitpoints =
{
    ["carot"] = {armor = 0, vitalDepth = 1.5, bleedRate = 0.01, vitalBleedRate = 0.07},
    ["subcl"] = {armor = 0, vitalDepth = 1}
}

enemy.updateBleedRate = function ()
end



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
    if feedbackMsgCounter > 7 then
        feedbackMsgCounter = 0
        feedbackLog = string
    else
        feedbackLog = feedbackLog .. "\n" ..  string
    end

    feedbackText:set ( feedbackLog )

end


--------------------------------------------


function drawKnife ()

end



--------------------------------------------------------------------------------
-------------------------------------------------------------------------- LOAD
--------------------------------------------------------------------------------

function love.load()
    myfont = love.graphics.newImageFont("imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"")


    messagesText = love.graphics.newText(myfont, "messages")
    inputText = love.graphics.newText(myfont, "input")
    feedbackText = love.graphics.newText(myfont, "feedback")

    love.graphics.setBackgroundColor( 70, 70, 70 )

end

--------------------------------------------------------------------------------




function love.keyreleased(key)
   if key == '1' then
    attack ( "carot" , "thrust", 1, 2, 2)
  elseif key == '2' then
     attack ( "subcl" , "pommel", 1, 0.5, 2)
  elseif key == '`' then
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
    --currentTime = love.timer.getTime() - start


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



-----------------------------------------------





end -- END UPDATE

--------------------------------------------------------------------------------
-------------------------------------------------------------------------- DRAW
--------------------------------------------------------------------------------
function love.draw()
    --love.graphics.print("button: "..currentbutton.."\njoy in: "..joystickInput.."\nlast button: "..lastbutton.."\nAxis X: "..axisdirX.."\nAxis Y: "..axisdirY, 0, 400)
    --love.graphics.print("button: "..currentbutton.."\njoy in: "..joystickInput, 0, 400)



    love.graphics.draw(messagesText, 0, 0 )
    love.graphics.draw(inputText, 0, 400 )
    love.graphics.draw(feedbackText, 0, 450 )




end
