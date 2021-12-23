Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height


    self.dx = 0
    self.dy = ballSpeed

    self.inPlay = true

end

function Ball:new(x, y, width, height)

    self.x = x
    self.y = y
    self.width = width
    self.height = height


    self.dx = 0
    self.dy = 0

    self.inPlay = true

end

function Ball:update(dt)

    if self.inPlay == true then

        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt

        if self.y > VIRTUAL_HEIGHT - 25 then
            self.inPlay = false
        end
        
    end

end

function Ball:render()

    if self.inPlay then
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end

end