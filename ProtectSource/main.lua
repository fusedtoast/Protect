--WINDOW_WIDTH = 432
--WINDOW_HEIGHT = 243

VIRTUAL_WIDTH = 800
VIRTUAL_HEIGHT = 600

FLOOR_SIZE = 67 --original number was 36, width 432, height 243

BALLTIME = 60

Class = require 'class'
--push = require 'push'

require 'Ball'
require 'Floor'
require 'Player'

listOfBalls = {}
listOfFloors = {}

playerScore = 0
comboPoints = 0

highScore = 0

ballSpeed = 0

noBallTimer = BALLTIME

bombardLeft = 0
bombardRight = VIRTUAL_WIDTH

playedLose = false

--[[
    runs when the game starts up.  Only once.  Just to initialize game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('ProtectTheLand')

    --love.window.setMode( 432, 243)

    gameState = 'start'

    smallfont = love.graphics.newFont('font.TTF', 16)
    scoreFont = love.graphics.newFont('font.TTF', 32)
    love.graphics.setFont(smallfont)

    sounds = {
        ['dot_collect'] = love.audio.newSource('dot_collect.wav', 'static'),
        ['dot_drop'] = love.audio.newSource('dot_drop.wav', 'static'),
        ['jump'] = love.audio.newSource('jump.wav', 'static'),
        ['land_lost'] = love.audio.newSource('land_lost.wav', 'static'),
        ['lose'] = love.audio.newSource('lose.wav', 'static')
    }

    --push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        --fullscreen = false,
        --vsync = true
    --})


    reset()
    
end

function reset()

    math.randomseed(os.time())

    listOfBalls = {}
    listOfFloors = {}

    highScore = math.max(playerScore, highScore)

    playerScore = 0

    ballSpeed = 75

    for i=1, 12 do
        table.insert(listOfFloors, Floor(FLOOR_SIZE * i - FLOOR_SIZE, VIRTUAL_HEIGHT - FLOOR_SIZE, FLOOR_SIZE, FLOOR_SIZE))
    end

    player = Player()

    love.keyboard.keysPressed = {}
    
    playedLose = false

end

function love.update(dt)

    
    if gameState == 'play' then

        local count = 12

        -- variables for figuring out the far left and far right of play field so balls only drop in play area
        leftSet = false
        rightSet = false

        for i,v in ipairs(listOfFloors) do
            v:update(dt)


            -- check if balls hit floors and destroy land if so
            for j, k in ipairs(listOfBalls) do
                if k.x + (k.width/2) > v.x and k.x < v.x + v.width then
                    if k.y > v.y then

                        if v.inPlay == true then
                            sounds['land_lost']:play()
                        end
                        v.inPlay = false
                        k.inPlay = false
                        
                        
                    end
                end
            end

            if v.inPlay then
                if player:collides(v) then
                    -- checking specifically if player collides with sides of floors while falling
                    if player.y + player.height > v.y + 20 then
                        if player.x + player.width > v.x + v.width then
                            player.dx = 0
                            player.x = v.x + v.width
                            player.state = 'jumping'
                        elseif player.x < v.x then
                            player.dx = 0
                            player.x = v.x - player.width
                            player.state = 'jumping'
                        end
                    else

                        player.dy = 0
                        player.y = v.y - player.height
                        player.state = 'idle'
                        comboPoints = 0
                        
                    end
                end
            else
                -- adding up how many floors are left
                count = count - 1
            end

            -- if one floor is left, end game
            if count == 1 then

                gameState = 'end'

            end

            --check for right and left side of field so balls only spawn where needed basically
            if v.inPlay == true then
                bombardRight = v.x + v.width
            end

            if leftSet == false and v.inPlay == true then
                bombardLeft = v.x
                leftSet = true
            end
        end

        for i,v in ipairs(listOfBalls) do
            local scored = false
            if player.y < v.y + v.height
                and player.y + player.height > v.y
                and v.x + v.width > player.x
                and v.x < player.x + player.width then
                    
                    if v.inPlay == true then
                        v.inPlay = false
                        scored = true
                        sounds['dot_collect']:play()
                        if player.state == 'jumping' then
                            player:halfJump(dt)
                            love.ballDrop()
                        end
                        
                    end
            end

            if scored == true then

                if player.state == 'jumping' then
                    comboPoints = comboPoints + 1
                end
                playerScore = playerScore + 1 + comboPoints
            end

            v:update(dt)
        end

        player:update(dt)

    
        

        if math.random(1,500) == 5 or noBallTimer <= 0 then

            love.ballDrop()

        else

            decrement = 5 * dt
            noBallTimer = noBallTimer - decrement
 
        end


        love.keyboard.keysPressed = {}

    end

end

function love.ballDrop()

    table.insert(listOfBalls, Ball(math.random(bombardLeft + 1,bombardRight - 16), 0, 16, 16))
    ballSpeed = ballSpeed + 2
    noBallTimer = BALLTIME
    sounds['dot_drop']:play()

end


function love.keyboard.wasPressed(key)

    return love.keyboard.keysPressed[key]

end

function love.keypressed(key)

    if key == 'escape' then

        love.event.quit()

    end

    if key == 'return' or key == 'kpenter' then

        if gameState == 'start' then

            reset()

            gameState = 'play'
        elseif gameState == 'end' then
            gameState = 'start'
        end

    end


    love.keyboard.keysPressed[key] = true

end

function love.draw()

    --push:apply('start')

    if gameState == 'play' then

        for i,v in ipairs(listOfFloors) do
            v:render()
        end

        for i,v in ipairs(listOfBalls) do
            v:render()
        end

        displayScore()

        player:render()
    
    elseif gameState == 'start' then

        displayStart()
    
    elseif gameState == 'end' then


        displayEnd()

    end

    --push:apply('end')

    

end

function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print('Score: '..tostring(playerScore), 50, 30)
    love.graphics.print('High Score: '..tostring(highScore), VIRTUAL_WIDTH - 300, 30)
end

function displayStart()
    -- start display
    love.graphics.setFont(scoreFont)
    love.graphics.print('Press Enter To Play', 30, 40)
    love.graphics.print('Use Arrow Keys To Move and Jump', 30, 80)
    love.graphics.print('Protect The Land', 30, 120)
end

function displayEnd()
    -- end display
    love.graphics.setFont(scoreFont)
    love.graphics.print('Your Score Was '..tostring(playerScore), 30, 30)
    love.graphics.print('Press Enter To Continue', 30, 60)
    if playedLose == false then
        sounds['lose']:play()
        playedLose = true
    end
    
end

