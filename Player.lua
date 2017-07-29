--love.filesystem.setRequirePath("?.lua;?/init.lua;"..love.filesystem.getSource().."/?.lua;"..love.filesystem.getSource().."/?/init.lua")

require "PlayerState"

Player = {}

Player.new = function ()
    local self = {}
    --self.stateStack = { idleState.new() }

    self.activeState = IdleState.new()
    self.tempState = nil


    self.handleInput = function (input)
        self.tempState = self.activeState.handleInput (input)
        if not self.tempState then -- if return is not nil
            self.activeState = nil
            self.activeState = self.tempState
            self.activeState.enter()
        end
    end

    self.tick = function (dt)
        self.activeState.tick (dt)
    end
end
