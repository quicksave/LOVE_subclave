

IdleState = {}

IdleState.new = function (player)
    local self = {}

    self.name = "idle"
    self.player = player
    self.ignoreInput = false

    self.enter = function ()
        --do stuff when entering this state
        addMessage ("Entered state: IDLE")
    end

    self.handleInput = function ( input)
        if input == "pressgrab" then
            return GrabState.new(self.player)
        end

        return nil
    end

    self.tick = function (dt)

        return self.ignoreInput
    end


    return self
end

--------------------------------------------------------------------------------

GrabState = {}

GrabState.new = function (player)
    local self = {}

    self.name = "grab"
    self.player = player
    self.ignoreInput = false

    self.enter = function ()
        --do stuff when entering this state
        addMessage ("Entered state: GRAB")
    end

    self.handleInput = function (input)
        if input == "releasegrab" then
            return IdleState.new(self.player)
        elseif input == "pressattack" then
            return AttackStartupState.new(self.player)
        end

        return nil
    end

    self.tick = function (dt)
        -- grabidle
        return self.ignoreInput
    end


    return self
end

--------------------------------------------------------------------------------

AttackStartupState = {}

AttackStartupState.new = function (player)
    local self = {}

    self.name = "attackstartup"
    self.player = player

    self.time = 1
    self.ignoreInput = true

    self.enter = function ()
        addMessage ("Entered state: AttackStartup")


    end
    self.exit = function ()

    end

    self.handleInput = function (input)
        if input == "enterattackwindow" then
            return AttackWindowState.new(self.player)
        end

        return nil
    end

    self.tick = function (dt)
        if self.time - dt <= 0 then
            self.isDone = true

            self.player.handleInput("enterattackwindow")
        else
            self.time = self.time - dt
        end

        return self.ignoreInput
    end


    return self
end

--------------------------------------------------------------------------------

AttackWindowState = {}

AttackWindowState.new = function (player)
    local self = {}

    self.name = "attackwindow"
    self.player = player

    self.time = 1
    self.ignoreInput = false

    self.enter = function ()
        addMessage ("Entered state: AttackWindow")

        enemy.addWound ("kidneyR")
    end
    self.exit = function ()

    end

    self.handleInput = function (input)
        if input == "releaseattack" then
            return AttackRecoveryState.new(self.player)
        end

        return nil
    end

    self.tick = function (dt)

        return self.ignoreInput
    end


    return self
end

--------------------------------------------------------------------------------

AttackRecoveryState = {}

AttackRecoveryState.new = function (player)
    local self = {}

    self.name = "attackrecovery"
    self.player = player

    self.time = 0.5
    self.ignoreInput = true

    self.enter = function ()
        addMessage ("Entered state: AttackRecovery")


    end
    self.exit = function ()

    end

    self.handleInput = function (input)
        if input == "exitattackrecovery" then
            return GrabState.new(self.player)
        end

        return nil
    end

    self.tick = function (dt)
        if self.time - dt <= 0 then
            self.isDone = true
            self.player.handleInput("exitattackrecovery")
        else
            self.time = self.time - dt
        end

        return self.ignoreInput
    end


    return self
end
