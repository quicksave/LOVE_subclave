
local Player = {}

Player.new = function (state)
    local self = {}
    --self.stateStack = { idleState.new() }
    self.activeState = state
    self.tempState = nil


    self.handleInput = function (input)
        self.tempState = self.activeState.handleInput (input)
        if not self.tempState then -- if return is not nil
            self.activeState = self.tempState
            self.activeState.enter()
        end
    end

    self.tick = function (dt)
        self.activeState.tick (dt)
    end
end
