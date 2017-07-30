ProtoKnife = {}

ProtoKnife.new = function (x,y)
    local self = {}

    self.x = x
    self.y = y
    self.w = 11
    self.h = 50

    self.activequad = 1

    self.img = love.graphics.newImage("pixelknife.png")
    self.quads =
    {
        love.graphics.newQuad(0,       0, self.w, self.h, self.img:getDimensions()),
        love.graphics.newQuad(self.w,  0, self.w, self.h, self.img:getDimensions()),
        love.graphics.newQuad(self.w*2,0, self.w, self.h, self.img:getDimensions()),
        love.graphics.newQuad(self.w*3,0, self.w, self.h, self.img:getDimensions()),
    }


    self.draw = function()
        love.graphics.draw(self.img, self.quads[self.activequad], x, y, 0, 2, 2)
    end

    return self
end
