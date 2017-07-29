attackAnim = {}

attackAnim.new = function (target, hitpoint, startup, recovery)
    local self = {}
    self.name = "defaultAttackAnimation"
    self.targetPoint = hitpoint
    self.startupTime = startup
    self.recoveryTime = recovery
    self.animTimeElapsed = 0
    self.starting = true
    self.recovered = false

    self.tick = function (dt)
        self.animTimeElapsed = self.animTimeElapsed + dt

        if self.recovered then return self.recovered end

        if self.starting then
            self.startupTime = self.startupTime - dt
            if self.startupTime <= 0 then
                self.starting = false
                target.addWound ( hitpoint )
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
