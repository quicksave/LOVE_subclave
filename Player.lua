
local Player = {}

Player.new = function ()
    local self = {}
    self.stateStack = { idleState.new() }
    --self.activeState = idleState.new()
    self.tempState = nil


    self.handleInput = function (input)
        self.tempState = self.stateStack[ #self.stateStack ].handleInput (input)
        if not self.tempState then -- if return is not nil
            --self.activeState = nil
            if self.tempState == "pop" then
                table.remove (self.stateStack)
            elseif self.tempState == "handle" then

                self.handleDownStack (input)

            else
                table.insert( self.stateStack , self.tempState)
            end

            self.stateStack[ #self.stateStack ].enter()
        end

    end

    self.handleDownStack = function (input)
        local i = #self.stateStack - 1
        local ret = "handle"

        while self.stateStack[i] do --while stack entry is not nil
            ret = self.stateStack[i].handleInput (input)
            if ret ~= "handle" then
                return ret
            end
        end
        return nil
    end

    self.tick = function (dt)
        self.stateStack[ #self.stateStack ].tick (dt)
    end
end
