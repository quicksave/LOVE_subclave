InputQueue = {}

InputQueue.new = function ()
    local self = {}

    self.q = {first = 1, last = 0}

    self.push = function (value)
        local last = self.q.last + 1
        self.q.last = last
        self.q[last] = value
    end

    self.pop = function ()
        local first = self.q.first
        if first > self.q.last then error("list is empty") end
        local value = self.q[first]
        self.q[first] = nil        -- to allow garbage collection
        self.q.first = first + 1
        return value
    end

    self.pushpop = function (value)
        self.push (value)
        return self.pop()
    end


    self.string = function()
        local string = ""
        for i=self.q.first,self.q.last do
            string = string .. self.q[i]
        end

        return string
    end

    self.tick = function (input)
        if input ~= "none" then
            self.push (input)
        end
    end

    self.push("5")
    self.push("5")
    self.push("5")
    self.push("5")
    self.push("5")

    return self
end
