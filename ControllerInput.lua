ControllerInput = {}

ControllerInput.new = function (joystick)
    local self = {}

    self.joystick = joystick

    self.activebutton = "none"

    self.inputState =
    {
        leftjoy = 5,
        buttons =
            {
                ["a"] = false,
                ["b"] = false,
                ["x"] = false,
                ["y"] = false,
                ["back"] = false,
                ["guide"] = false,
                ["start"] = false,
                ["leftstick"] = false,
                ["rightstick"] = false,
                ["leftshoulder"] = false,
                ["rightshoulder"] = false,
                ["dpup"] = false,
                ["dpdown"] = false,
                ["dpleft"] = false,
                ["dpright"] = false,
            },
        LT = false,
        RT = false,
    }
    self.prevInputState = copy(self.inputState, false)


    self.updateJoyState = function ()
        local axisX = self.joystick:getGamepadAxis("leftx")
        local axisY = self.joystick:getGamepadAxis("lefty")

        local axisLT = self.joystick:getGamepadAxis("triggerleft")
        local axisRT = self.joystick:getGamepadAxis("triggerright")

        local axisdirXabs = math.abs(axisX)
        local axisdirYabs = math.abs(axisY)
        local axisCombinedAmp = axisdirXabs + axisdirYabs

        local joyDirThreshold = 0.5
        local joyR = false
        local joyL = false
        local joyU = false
        local joyD = false
        local joystickInput = self.inputState.leftjoy

        local triggerThreshold = 0.3
        local joyLT = self.inputState.LT
        local joyRT = self.inputState.RT

        -- left stick
        if axisdirXabs > .8 or axisdirYabs > .8 or axisCombinedAmp > 1.3 or axisCombinedAmp < .3  then

            joyR = false
            joyL = false
            joyU = false
            joyD = false

            joyR = axisX > joyDirThreshold
            joyL = axisX < -joyDirThreshold
            joyU = axisY < -joyDirThreshold
            joyD = axisY > joyDirThreshold

            if joyR then
                if joyU then
                    joystickInput = 9
                elseif joyD then
                    joystickInput = 3
                else
                    joystickInput = 6
                end
            elseif joyL then
                if joyU then
                    joystickInput = 7
                elseif joyD then
                    joystickInput = 1
                else
                    joystickInput = 4
                end
            else
                if joyU then
                    joystickInput = 8
                elseif joyD then
                    joystickInput = 2
                else
                    joystickInput = 5
                end
            end
        end

        -- triggers
        if axisLT > triggerThreshold then
            joyLT = true
        else
            joyLT = false
        end
        if axisRT > triggerThreshold then
            joyRT = true
        else
            joyRT = false
        end

        --commit to inputState
        self.inputState.leftjoy = joystickInput
        self.inputState.LT = joyLT
        self.inputState.RT = joyRT
    end


    self.updateButton = function (button, isDown)
        if button ~= "none" then
            self.prevInputState = copy(self.inputState, false)
            self.inputState.buttons[button] = isDown

            if not self.prevInputState.buttons[self.activebutton] and isDown then
                self.activebutton = button
            end
        end


        --[[
        --untested example of generic for / ipairs iterator

        for i, v in ipairs(self.inputState.buttons) do
            if self.joystick:isGamepadDown(v) then
                self.inputState.buttons[v] = true
            else
                self.inputState.buttons[v] = false
            end
        end
        --]]
    end


    self.tick = function()
        self.prevInputState = copy(self.inputState, false)
        self.updateJoyState()


        if self.prevInputState.LT and not self.inputState.LT then
            --fire LT release
            handleInput(5,"LTreleased")
        elseif not self.prevInputState.LT and self.inputState.LT then
            --fire LT press
            handleInput(5,"LTpressed")
        end

        if self.prevInputState.RT and not self.inputState.RT then
            --fire RT release
            handleInput(5,"RTreleased")
        elseif not self.prevInputState.RT and self.inputState.RT then
            --fire RT press
            handleInput(5,"RTpressed")
        end
    end

    return self
end
