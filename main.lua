--Setting the Screenn dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--Setting the Virtual Screen dimensions
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--Setting the paddles speeds
PADDLE_SPEED = 200

--importing the librarys
Class = require 'class'
push = require 'push'

--importing objects
require 'Ball'
require 'Paddle'

function love.load()

    -- title of screen
    love.window.setTitle('Pong')

    --creating a seed to rng
    math.randomseed(os.time());

    --removing the blur filter for zooming.
    love.graphics.setDefaultFilter('nearest','nearest')

    --importing the font
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    --importing sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('sounds/point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    --Setting the scores variables
    player1score = 0
    player2score = 0

    --Setting the play who gonna server
    servingPlayer = math.random(2) == 1 and 1 or 2
    winningPlayer = 0

    --creating the paddle objects and setting the initial positions
    paddle1 = Paddle(5, 20 , 5 ,20)
    paddle2 = Paddle(VIRTUAL_WIDTH -10, VIRTUAL_HEIGHT -30 , 5 ,20)

    --setting the ball initial positions
    ball = Ball(VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 -2, 5 ,5)
    
    if servingPlayer == 1 then
        ball.dx = 100
    elseif servingPlayer == 2 then
        ball.dx = -100
    end
    --setting the gameState
    gameState = 'start'

    --gameMode setting 
    gameMode = 'Single Player'

    --using the push library to set the screen dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

-- resize function
function love.resize(w, h)
    push:resize(w, h)

end
--this function update the screen
function love.update(dt)

    --updating scores
    if ball.x <= 0 then
        player2score = player2score + 1
        servingPlayer = 1
        ball:reset()
        ball.dx = 100
        sounds['point_scored']:play()
        
        if player2score >= 10 then
            gameState = 'victory'
            winningPlayer = 2
        else
            gameState = 'serve'
        end
    end

    if ball.x >= VIRTUAL_WIDTH - 4 then
        player1score = player1score + 1
        servingPlayer = 2
        ball:reset()
        ball.dx = -100
        sounds['point_scored']:play()
        
        if player1score >= 10 then
            gameState = 'victory'
            winningPlayer = 1
        else
            gameState = 'serve'
        end
    end

    --cheking collides of the ball with the paddles
    if ball:collides(paddle1) or ball:collides(paddle2) then
        --deflect ball in x axis
        ball:increaseSpeed()
        ball.dx = -ball.dx
        sounds['paddle_hit']:play()
    end
    if ball.y <= 0 then
        ball.dy = -ball.dy
        ball.y = 0

        sounds['wall_hit']:play()
    elseif ball.y >= VIRTUAL_HEIGHT -4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4

        sounds['wall_hit']:play()
    end

    --setting w and s to move the left paddle up and down
    if love.keyboard.isDown('w') then
      paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
       paddle1.dy = PADDLE_SPEED 
    else 
        paddle1.dy = 0
    end

    --player2 IA
    if gameMode == 'Single Player' then
        if ball.dx > 0 and  gameState == 'play' then
            if ball.y > paddle2.y + paddle2.height and ball.y > paddle2.y then
                paddle2.dy = PADDLE_SPEED
            end
            if ball.y < paddle2.y + paddle2.height and ball.y < paddle2.y then
                paddle2.dy = -PADDLE_SPEED
            end
            if ball.y < paddle2.y + paddle2.height  and paddle2.y < ball.y then
                paddle2.dy = 0
            end
        elseif ball.dx <= 0 then
            paddle2.dy = 0
        end
    elseif gameMode == 'Multiplayer' then
            --setting up and down to move the left paddle up and down
        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end
    end

    --updating paddles positions
    paddle1:update(dt)
    paddle2:update(dt)

    if gameState == 'play' then 
        ball:update(dt)
    end
end


function love.keypressed(key)
    --set a fuction to quit the game when "esc" was pressed
    if key == 'escape' then
        love.event.quit()
    --setting a button to start the game
    elseif key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1score = 0
            player2score = 0
        end
    elseif key == 'tab' and gameState == 'start' then
        changeGameMode()
    end
end

function love.draw()

    --calling the push library
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1)

    --display a welcome message
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 32 , VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press enter to play", 0 , 44, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press tab to change game mode", 0 , 56, VIRTUAL_WIDTH, 'center')
        love.graphics.printf(gameMode, 0 , 20, VIRTUAL_WIDTH, 'center')
    -- display a serving message
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20 , VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to serve!", 0 , 32, VIRTUAL_WIDTH, 'center')
    --display a victory message
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10 , VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to restart", 0 , 42, VIRTUAL_WIDTH, 'center')
    end
        --Drawning the Ball
    ball:render()
    
    --Drawining the Paddles
    paddle1:render()
    paddle2:render()
      
    --Drawining the Scoreboard
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    --display fps
    displayFPS()
    
    --freeing the push library
    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0 ,1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(0,0,0,0)
end

function changeGameMode()
    if gameMode == 'Single Player' then
        gameMode = 'Multiplayer'
    elseif gameMode == "Multiplayer" then
        gameMode = 'Single Player'
    end
end