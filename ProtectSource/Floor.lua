Floor = Class{}

function Floor:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.inPlay = true

end

function Floor:update(dt)


end

function Floor:render()

    if self.inPlay then
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.width)
    end

end