ProtoEnemy = {}

ProtoEnemy.new = function ()
    local self = {}

    self.bloodMax = 5
    self.bloodCurrent = 5
    self.bleedRate = 0

    self.shock = 0
    self.weak = false
    self.conscious = true
    self.dead = false

    self.stunned = false
    self.stunRemaining = 0

    self.hitpoints =
    {
        ["carot"]   =   {   bleedRate = 0.167,  stun = 0,   wounded = false,    relPosX = 60,   relPosY = -10 },
        ["subcl"]   =   {   bleedRate = 0.200,  stun = 0,   wounded = false,    relPosX = 80,   relPosY = 7 },
        ["brach"]   =   {   bleedRate = 0.023,  stun = 0,   wounded = false,    relPosX = 110,  relPosY = 30 },
        ["kidneyR"] =   {   bleedRate = 0.010,  stun = 8,   wounded = false,    relPosX = 75,   relPosY = 140 },
        ["kidneyL"] =   {   bleedRate = 0.010,  stun = 7,   wounded = false,    relPosX = 45,   relPosY = 140 },
        ["stomach"] =   {   bleedRate = 0.030,  stun = 5,   wounded = false,    relPosX = 60,   relPosY = 120 },
    }

    self.originX = 500
    self.originY = 200


    self.draw = function ()
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", self.originX, self.originY, 120, 180, 25)
        love.graphics.ellipse("fill", self.originX + 60, self.originY - 60, 30, 40, 100)

        for i,v in pairs{"carot", "subcl", "brach", "kidneyR", "kidneyL", "stomach"} do
            if self.hitpoints[v].wounded then
                love.graphics.setColor(255, 0, 255)
            else
                love.graphics.setColor(0, 0, 0)
            end
            love.graphics.circle( "fill", self.originX + self.hitpoints[v].relPosX, self.originY + self.hitpoints[v].relPosY, 5 )
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


    self.addWound = function ( hitpoint )
        if not self.hitpoints[hitpoint].wounded and not self.dead then
            self.bleedRate = self.bleedRate + self.hitpoints[hitpoint].bleedRate
            if self.conscious then
                self.stunRemaining = self.stunRemaining + self.hitpoints[hitpoint].stun
            end

            self.hitpoints[hitpoint].wounded = true

            addFeedback ("Vital stab to " .. hitpoint .. ", bleeding " .. self.bleedRate .. "L/s." .. " "..round(self.hitpoints[hitpoint].stun, 1) .. "s stun added.")
        else
            addFeedback ("Vital stab to " .. hitpoint .. " has little effect.")
        end
    end

    self.tick = function (dt)

        if self.dead then
            if self.bloodCurrent == 0 then
                return
            elseif self.bloodCurrent < 0.01 then
                self.bleedRate = 0
                self.bloodCurrent = 0
                addFeedback ("Enemy has stopped bleeding.")
            elseif self.bloodCurrent < 0.6 then
                self.bleedRate = 0.01
            elseif self.bloodCurrent < 1.6 then
                self.bleedRate = 0.03
            end

        end

    ----------------------------------- use dt

        self.bloodCurrent = self.bloodCurrent - (self.bleedRate * dt)

        if self.stunRemaining > 0 then

            self.stunRemaining = self.stunRemaining - dt
            if self.stunRemaining < 0 then self.stunRemaining = 0 end

            if self.stunRemaining == 0 then
                self.stunned = false
                --leave stun
                if self.conscious then addFeedback ("Enemy is no longer stunned.") end
            else
                self.stunned = true
                --enter stun
            end
        end

    ---------------------------------- end dt


        local bloodloss = 1 - self.bloodCurrent / self.bloodMax
        self.shock = math.floor( bloodloss * 10 )

        if self.shock >= 2 then
            if not self.weak then
                self.weak = true
                addFeedback ("Enemy seems weak.")
            end
            if self.shock >= 3 then
                if self.conscious then
                    self.conscious = false
                    addFeedback ("Enemy loses consciousness.")
                end
                if self.shock >= 5 then
                    if not self.dead then
                        self.dead = true
                        addFeedback ("Enemy appears ghostly pale.")
                    end
                end
            end
        end

    end -- end tick

    return self
end
