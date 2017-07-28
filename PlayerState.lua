

local IdleState = {}

IdleState.new = function ()
    local self = {}

    self.enter = function ()
        --do stuff when entering this state
    end

    self.handleInput = function (input)
        if input == "press_grab" then
            -- do grab
            return GrabState.new()
        elseif input == "press_drawknife" then
            return KnifeFwdState.new()
        end

        return nil
    end

    self.tick = function (dt)
        -- idle
    end


    return self
end

--------------------------------------------------------------------------------

local KnifeFwdState = {}

KnifeFwdState.new = function ()
    local self = {}

    self.enter = function ()
        --do stuff when entering this state
    end

    self.handleInput = function (input)
        if input == "press_switchgrip" then
            -- do grab
            return KnifeRevState.new()
        else
            --no state above
        end

        return nil
    end

    self.tick = function (dt)
        -- idle
    end


    return self
end

--------------------------------------------------------------------------------

local KnifeRevState = {}

KnifeRevState.new = function ()
    local self = {}

    self.enter = function ()
        --do stuff when entering this state
    end

    self.handleInput = function (input)
        if input == "press_switchgrip" then
            -- do grab
            return KnifeFwdState.new()
        else
            --no state above
        end

        return nil
    end

    self.tick = function (dt)
        -- idle
    end


    return self
end

--------------------------------------------------------------------------------

local GrabState = {}

GrabState.new = function ()
    local self = {}

    self.enter = function ()
        --do stuff when entering this state
    end

    self.handleInput = function (input)
        if input == "release_grab" then
            -- release grab to idle
            return "pop"
        elseif input == "press_attack" then
            return attackState.new()
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
        --do stuff when entering this state
    end

    self.handleInput = function (input)
        if input == "release_attack" then
            -- release attack button to to grab
            return "pop"
        else

        end

        return nil
    end

    self.tick = function (dt)
        -- attackidle
    end


    return self
end

--------------------------------------------------------------------------------
