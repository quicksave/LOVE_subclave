

IdleState = {}

IdleState.new = function ()
    local self = {}

    self.name = "idle"

    self.enter = function ()
        --do stuff when entering this state
        addMessage ("Entered state: IDLE")
    end

    self.handleInput = function ( input)
        if input == "pressgrab" then
            return GrabState.new()
        end

        return nil
    end

    self.tick = function (dt)

    end


    return self
end

--------------------------------------------------------------------------------

GrabState = {}

GrabState.new = function ()
    local self = {}

    self.name = "grab"

    self.enter = function ()
        --do stuff when entering this state
        addMessage ("Entered state: GRAB")
    end

    self.handleInput = function (input)
        if input == "releasegrab" then
            return IdleState.new()
        elseif input == "pressattack" then
            return AttackState.new()
        end

        return nil
    end

    self.tick = function (dt)
        -- grabidle
    end


    return self
end

--------------------------------------------------------------------------------

AttackState = {}

AttackState.new = function ()
    local self = {}

    self.name = "attack"

    self.enter = function ()
        addMessage ("Entered state: ATTACK")
        
    end
    self.exit = function ()
        addMessage ("Exit state: ATTACK")

    end

    self.handleInput = function (input)
        if input == "releaseattack" then
            self.exit()
            return GrabState.new()
        end

        return nil
    end

    self.tick = function (dt)
        -- attackidle
    end


    return self
end

--------------------------------------------------------------------------------
