

local attackMessage = "init"
local logText = "loginit"

local messagesText
local logMsgCounter = 0
--local myfont = love.graphics.newFont(14) -- the number denotes the font size
myfont = love.graphics.newImageFont("imagefont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")

start = love.timer.getTime()
currentTime = 0

--------------------------------------------------------------------------------

enemy = {}
enemy.blood = 3

enemy.hitpoints =
{
    ["head"] = {armor = 1, vitalDepth = 1},
    ["chest"] = {armor = 1, vitalDepth = 1}
}



--------------------------------------------------------------------------------





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

    return attackMessage
end














-------------------------------







function addMessage (string)
    logText = logText .. "\n" ..  string
    logMsgCounter = logMsgCounter + 1
    if logMsgCounter > 20 then
        --messagesText:clear()
        logMsgCounter = 0
        logText = "cleared"
    end

    messagesText:set ( logText )

end






--------------------------------------------------------------------------------
function love.load()
    messagesText = love.graphics.newText(myfont, "default")

end

--------------------------------------------------------------------------------







function love.keyreleased(key)
   if key == '1' then
     addMessage ( attack ( "head" , "thrust", 1, 2, 2) )
  elseif key == '2' then
     addMessage ( attack ( "chest" , "pommel", 1, 0.5, 2) )
  elseif key == '`' then
      debug.debug()
   end
end




function love.update(dt)
    --currentTime = love.timer.getTime() - start

    --messagesText:add (" aids " .. math.floor(currentTime) .. "\n" .. attackMessage, 50, 50)
end

function love.draw()
    --love.graphics.print("Hello World", 400, 300)









    love.graphics.draw(messagesText, 0, 0 )


end
