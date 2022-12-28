push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('Pong')

  -- "seed" the RNG so that calls to random are always random
  -- use the current time, since that will vary on startup every time
  math.randomseed(os.time())

  -- more "retro-looking" font object we can use for any text
  smallFont = love.graphics.newFont('font.ttf', 8)

  -- set LÖVE2D's active font to the smallFont object
  love.graphics.setFont(smallFont)
  
  sounds = {
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

  -- initialize window with virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
      fullscreen = false,
      resizable = true,
      vsync = true
  })

  -- initialize our player paddles; make them global so that they can be
  -- detected by other functions and modules
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  -- place a ball in the middle of the screen
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

  -- game state variable used to transition between different parts of the game
  -- (used for beginning, menus, main game, high score list, etc.)
  -- we will use this to determine behavior during render and update
  gameState = 'start'
end

function love.update(dt)
  
  if gameState == 'serve' then
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end
  elseif gameState =='play' then

  if ball:collides(player1) then
    ball.dx = -ball.dx * 1.03
    ball.x = player1.x + 5

    if ball.dy < 0 then
      ball.dy = -math.random(10, 150)
    else
      ball.dy = math.random(10, 150)
    end

    sounds['paddle_hit']:play()
  end

  if ball:collides(player2) then
    ball.dx = -ball.dx * 1.03
    ball.x = player2.x - 4

    if ball.dy < 0 then
      ball.dy = -math.random(10, 150)
    else
      ball.dy = math.random(10, 150)

  end
      sounds['paddle_hit']:play()

  end

  if ball.y <= 0 then
    ball.y = 0
    ball.dy = -ball.dy
    sounds['wall_hit']:play()
  end

  if ball.y >= VIRTUAL_HEIGHT - 4 then
    ball.y = VIRTUAL_HEIGHT - 4
    ball.dy = -ball.dy
    sounds['wall_hit']:play()
  end
  
  if ball.x < 0 then
    servingPlayer = 1
    player2Score = player2Score + 1
    sounds['score']:play()
    
    if player2Score == 10 then
      winningPlayer = 2
      gameState = 'done'
    else
      gameState = 'serve'
      ball:reset()
    end
  end
  
  if ball.x > VIRTUAL_WIDTH then
    servingPlayer = 2
    player1Score = player1Score + 1
    sounds['score']:play()
    
    if player1Score == 10 then
      winningPlayer = 1
      gameState = 'done'
    else
      gameState = 'serve'
      ball:reset()
    end
  end
end

    if ball.x < 0 then
      servingPlayer = 1
      player2Score = player2Score + 1
      sounds['score']:play()
      
      if player2Score == 10 then
        winningPlayer = 2
        gameState = 'done'
      else
        gameState = 'serve'
        ball:reset()
      end
    end
    
    if ball.x > VIRTUAL_WIDTH then
      servingPlayer = 2
      player1Score = player1Score + 1
      sounds['score']:play()
      
      if player1Score == 10 then winningPlayer = 1
        gameState = 'done'
      else
        gameState = 'serve'
        ball:reset()
      end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end


--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'

            -- ball's new reset method
            ball:reset()
        end
  elseif gameState == 'done' then
    gameState = 'serve'
    
    ball:reset()
    
    player1Score = 0
    player2Score = 0
    
    if winningPlayer == 1 then
      servingPlayer = 2
    else
      servingPlayer = 1
    end
end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw different things based on the state of the game
    love.graphics.setFont(smallFont)

    if gameState == 'start' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('Bienvenido amigue', 0, 10, VIRTUAL_WIDTH, 'center')
      love.graphics.printf('Presiona Enter loco para iniciar', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('Jugador ' .. tostring(servingPlayer) .. "Sirve", 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
    elseif gameState == 'done' then
      love.graphics.setFont(largeFont)
      love.graphics.printf('Jugador ' .. tostring(winningPlayer) .. 'gano', 0, 10, VIRTUAL_WIDTH, 'center')
      love.graphics.setFont(smallFont)
      love.graphics.printf('Presiona enter locoman', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- render paddles, now using their class's render method
    player1:render()
    player2:render()

    -- render ball using its class's render method
    ball:render()

    displayFPS()

    -- end rendering at virtual resolution
    push:apply('end')
end

function displayFPS()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(0, 255/255, 0, 255/255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end