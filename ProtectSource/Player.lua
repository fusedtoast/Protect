Player = Class{}

local MOVE_SPEED = 300

local GRAVITY = 3000

local TERMINAL_VELOCITY = 1000

local JUMP_VELOCITY = 1000

local COMBO_JUMP_VELOCITY = 950

function Player:init()

    self.width = 32
    self.height = 32

    self.x = VIRTUAL_WIDTH / 2
    self.y = VIRTUAL_HEIGHT - FLOOR_SIZE * 3

    self.dx = 0
    self.dy = 0

    self.state = 'idle'

    self.onGround = false

    self.behaviors = {
        ['idle'] = function(dt)

            if love.keyboard.wasPressed('up') then
                self:jump(dt)
            elseif love.keyboard.isDown('left') then
                self.dy = 0
                self.x = self.x - MOVE_SPEED * dt
            elseif love.keyboard.isDown('right') then
                self.dy = 0
                self.x = self.x + MOVE_SPEED * dt
            else
                self.dx = 0
                self.dy = 0
            end

            if self.onGround == true then
                self.state = 'idle'
            else
                self.state = 'jumping'
            end

        end,
        ['walking'] = function(dt)

            if love.keyboard.wasPressed('up') then
                self:jump(dt)
            elseif love.keyboard.isDown('left') then
                self.dy = 0
                self.x = self.x - MOVE_SPEED * dt
            elseif love.keyboard.isDown('right') then
                self.dy = 0
                self.x = self.x + MOVE_SPEED * dt
            else
                if self.onGround == true then
                    self.dy = 0
                    self.state = 'idle'
                else
                    self.state = 'jumping'
                end
            end

            if self.onGround == true then
                self.dy = 0
                self.state = 'walking'
            else
                self.state = 'jumping'
            end

        end,
        ['jumping'] = function(dt)

            
            if love.keyboard.isDown('left') then
                self.x = self.x - MOVE_SPEED * 2 * dt
            elseif love.keyboard.isDown('right') then
                self.x = self.x + MOVE_SPEED * 2 * dt
            else
                self.dx = 0
            end

            if self.onGround == true then
                self.state = 'idle'
            else
                self.state = 'jumping'
            end

            if player.y > VIRTUAL_HEIGHT then
                gameState = 'end'
                
            end

            self.dy = self.dy + GRAVITY * dt

        end
    }

end


function Player:checkSides()
    if player.x < 0 then
        player.x = 0
        player.dx = 0
    end

    if player.x + player.width > VIRTUAL_WIDTH then
        player.x = VIRTUAL_WIDTH - player.width
        player.dx = 0
    end
end

function Player:halfJump(dt)

    self.dy = - COMBO_JUMP_VELOCITY
    self.state = 'jumping'
    self.onGround = false
    sounds['jump']:play()

end

function Player:jump(dt)

    self.dy = -JUMP_VELOCITY
    self.state = 'jumping'
    self.onGround = false
    sounds['jump']:play()

end


function Player:collides(floor)

    if self.x + self.width >= floor.x and self.x <= floor.x + floor.width then
        if self.y + self.height >= floor.y - 4 and self.y <= floor.y + floor.height then
            return true
        end
    end

end


function Player:update(dt)

    self.behaviors[self.state](dt)

    

    self.y = self.y + self.dy * dt

    player:checkSides()

end

function Player:render()

    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

end