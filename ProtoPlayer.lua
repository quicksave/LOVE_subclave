--love.filesystem.setRequirePath("?.lua;?/init.lua;"..love.filesystem.getSource().."/?.lua;"..love.filesystem.getSource().."/?/init.lua")

require "PlayerState"

ProtoPlayer = {}

ProtoPlayer.new = function ()
    local self = {}
    --self.stateStack = { idleState.new() }

    self.activeState = IdleState.new()
    self.tempState = nil


    self.handleInput = function (input)
        --addMessage (self.activeState.name)
        self.tempState = self.activeState.handleInput (input)
        --addMessage ("return: "..self.tempState.name)
        if self.tempState then -- if return is not nil
            self.activeState = nil
            self.activeState = self.tempState
            self.activeState.enter()
        end
    end

    self.tick = function (dt)
        self.activeState.tick (dt)
    end

    return self
end
