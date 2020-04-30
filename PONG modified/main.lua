push = require 'push'
Class = require 'class'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1020
WINDOW_HEIGHT = 640

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
	love.graphics.setDefaultFilter('nearest','nearest')

	love.window.setTitle('PONG')

	math.randomseed(os.time())

	retroFont = love.graphics.newFont('font.ttf',8)
	winFont = love.graphics.newFont('font.ttf',16)
	love.graphics.setFont(retroFont)

	scoreFont = love.graphics.newFont('font.ttf',32)

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
		['score'] = love.audio.newSource('sounds/score.wav','static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static'),
		['win'] = love.audio.newSource('sounds/win.wav','static')
	}

	push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
		fullscreen = false,
		resizable = true,
		vsync = true
	})

	startingTime = os.time()
	playerScore = 0

	player1 = Paddle(10,30,5,20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

	ball = Ball(VIRTUAL_WIDTH/2 - 2,VIRTUAL_HEIGHT/2 - 2,4,4) 

	gameState = 'start'
end

function love.resize(w,h)
	push:resize(w,h)
end

function love.update(dt)

	if gameState == 'play' then

		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5

			if ball.dy < 0 then
				ball.dy = -math.random(10,150)
			else
				ball.dy = math.random(10,150)
			end
			sounds['paddle_hit']:play()
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4

			if ball.dy < 0 then
				ball.dy = -math.random(10,150)
			else
				ball.dy = math.random(10,150)
			end

			sounds['paddle_hit']:play()
		end
			
		if ball.y < 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end

		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end

		playerScore = os.time() - startingTime
	
		if ball.x < 0 then
			gameState = 'done'
			sounds['win']:play()
		end
	
		if ball.x > VIRTUAL_WIDTH then
			gameState = 'done'
			sounds['win']:play()
		end

	end

	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
	player2:update(dt)
	
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'start'

			ball:reset()

			playerScore = 0
			startingTime = os.time()
		end
	end
end

function love.draw()
	push:apply('start')

	love.graphics.clear(40/250,45/250,52/250,255)

	love.graphics.setFont(retroFont)

	if gameState == 'start' then
		love.graphics.printf('Welcome to Pong!',0,10,VIRTUAL_WIDTH,'center')
		love.graphics.printf('Press Enter to begin!',0,20,VIRTUAL_WIDTH,'center')
	elseif gameState == 'play' then
		displayScore()
	elseif gameState == 'done' then
		love.graphics.setFont(winFont)
		love.graphics.printf('Your Score = '..tostring(math.floor(playerScore/60))..' : '..tostring(math.floor((playerScore%60)/2)),0,10,VIRTUAL_WIDTH,'center')
		love.graphics.setFont(retroFont)
		love.graphics.printf('Press Enter to restart!',0,30,VIRTUAL_WIDTH,'center')
	end

	player1:render()
	player2:render()

	ball:render()

	displayFPS()

	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(retroFont)
	love.graphics.setColor(0,255,0,255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()),10,10)
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(math.floor(playerScore/60))..':'..tostring(math.floor((playerScore%60)/2)),VIRTUAL_WIDTH/2 - 22,
		30)
end
