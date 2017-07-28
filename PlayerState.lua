

local IdleState = {}

IdleState.new = function ()
    local self = {}

    self.enter = function ()
        --do stuff when entering this state
        addMessage ("Entered state: IDLE")
    end

    self.handleInput = function (player, input)
        if input == "press_grab" then
            return GrabState
        end

        return nil
    end

    self.tick = function (dt)

    end


    return self
end

--------------------------------------------------------------------------------

local GrabState = {}

GrabState.new = function ()
    local self = {}

    self.enter = function ()
        --do stuff when entering this state
        addMessage ("Entered state: GRAB")
    end

    self.handleInput = function (input)
        if input == "release_grab" then
            return IdleState
        elseif input == "press_attack" then
            return attackState
        end

        return nil
    end

    self.tick = function (dt)
        -- grabidle
    end


    return self
end

--------------------------------------------------------------------------------

local attackState = {}

attackState.new = function ()
    local self = {}

    self.enter = function ()
        addMessage ("Entered state: ATTACK")
        --do stuff when entering this state
    end

    self.handleInput = function (input)
        if input == "release_attack" then
            return GrabState
        end

        return nil
    end

    self.tick = function (dt)
        -- attackidle
    end


    return self
end

--------------------------------------------------------------------------------
