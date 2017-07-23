--[[

local weapons =
{
    melee =
    {
        unarmed =
        {
            name = "Unarmed",
            attack =
            {
                jab =
                {
                    damage = 1,
                    pen = 1
                },
                swing =
                {
                    damage = 1,
                    pen = 1
                },
                pommel =
                {
                    damage = 1,
                    pen = 1
                }
            }
        },

        knifeFighting =
        {
            name = "fighting knife"
        }
    }
}

return weapons
--]]

local weapons = {};

weapons.new = function ( id , type )
    local weapon = {}
    weapon.id = id
    weapon.displayName = "weapon"
    weapon.type = type

    weapon.attacks = {}

    local attacks = weapon.attacks
    if type == "melee" then
        attacks.thrust.dmg = 1
        attacks.thrust.pen = 1

        attacks.swing.dmg = 1
        attacks.swing.pen = 1

        attacks.pommel.dmg = 1
        attacks.pommel.pen = 1
    else
        attacks.shot.dmg = 1
        attacks.shot.pen = 1
        attacks.shot.range = 1
    end


    return weapon
end
