-- Main functions -------------------------------------------------------------------------------------------------------------------------
function reset() -- Reset all variables to initial state
	storm.particles:reset()
	treasure.particles:reset()
	treasure.chest.particles:reset()
	start = 1
	storm.isActive = false
	player.sounds.death:stop()
	player.orientation = 1
	player.isJumping = false
	player.x, player.y = 32, 198
	player.fall = 0
	player.limits = { ground = 198, left = 32, right = 608, jump = 192, speed = 390, vertical = 0, power = 400, gravity = 1550 }
	score.player = 0
	timer = 30
	contact = false
	treasure:spawn( true )
	treasure.spot = 4
	player.anim = player.idle
	player.spot = 1
	enemies.level = 1
	enemies.pace = 1
	for _, v in pairs( enemies.wasp ) do
		v.y = screen.h
		v.out = false
		v.z = -1
	end
end
function newAnimation( x, y, count, w, h, pace, offset, loop ) -- Create an animation. Use for player and wasps.
	local anim = {}
	anim.index = 1
	anim.timer = 0
	anim.last = count
	anim.pace = pace
	anim.frames = {}
	cx, cy = x, y
	for i = 1, count do
		local frame = love.graphics.newQuad( cx, cy, w, h, sheet.w, sheet.h )
		table.insert( anim.frames, frame )
		cx = cx + w
		if cx > sheet.w then
			cx = x
			cy = cy + h
		end
	end
	function anim:update( dt )
		self.timer = self.timer + dt
		if self.timer > self.pace then
			self.timer = 0
			self.index = self.index + 1
			if self.index > self.last then
				if loop then
					self.index = 1
				else
					self.index = self.last
				end
			end
		end
	end
	function anim:draw( x, y )
		love.graphics.draw( sheet.image, self.frames[ self.index ], math.floor( x ), math.floor( y ), 0, player.orientation, 1, offset )
	end
	return anim
end
function countDown( dt ) -- Just to have a good looking love.update.
	if start > 0 then
		start = start - dt
		if start < 0 then start = 0 end
	end
end
-- Love functions -------------------------------------------------------------------------------------------------------------------------
function love.load()
	gameOver = false
	pause = false
	start = 1
	dbug = false
	color = 255
	timer = 30
	contact = false
	canvas = love.graphics.newCanvas( 640, 360 )
	love.graphics.setBackgroundColor( 90, 88, 103 )
	screen = {}
	screen.w, screen.h = love.graphics.getDimensions()
	options = { zoom = 1, filter = "linear", fullscreen = false }
	sheet = { image = love.graphics.newImage( "graphics/sheet.png" ) }
	sheet.w, sheet.h = sheet.image:getDimensions()
	music = require( "music" )
	font = require( "font" )
	menu = require( "menu" )
	storm = require( "storm" )
	score = require( "score" )
	scenery = require( "scenery" )
	treasure = require( "treasure" )
	player = require( "player" )
	enemies = require( "enemies" )
end
function love.update( dt )
	if menu.isActive then
		menu:update( dt )
	else 
		if not pause and not gameOver then
			countDown( dt )
			storm:update( dt )
			score:update( dt )
			if start == 0 then
				timer = timer  - dt
				if timer < 0 then
					timer = 0
					contact = true
					music:pause()
					player.sounds.death:play()
				end
				treasure:update( dt )
				enemies:update( dt )
			end
			player:update( dt )
		end
	end
end
function love.draw()
	love.graphics.setCanvas( canvas )
	love.graphics.clear()
	love.graphics.setColor( color, color, color )
	scenery:draw()
	enemies:draw()
	treasure:draw()
	player:draw()
	love.graphics.draw( treasure.particles, treasure.x - 32, treasure.y )
	if storm.isActive then love.graphics.draw( storm.particles, 320, 0 ) end
	menu:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.setCanvas()
	love.graphics.draw( canvas, 0, 0, 0, options.zoom )
end
function love.keypressed( key )
	-- Escape key
	if key == "escape" then
		if menu.isActive then
			if menu.options.isActive then
				menu:switch( -menu.position + 1 )
				menu.options.isActive = false
			elseif menu.credits.isActive then
				menu:reset()
			else
				file:close()
				love.event.quit()
			end
		elseif start == 0 then
			pause = not pause
		end
	end
	-- Jumping keys
	if not player.isJumping and not menu.isActive and not pause and start == 0 then
		if key == "left" and player.spot > 1 then
			player:jumpTo( -1 )
		elseif key == "right" and player.spot < 4 then
			player:jumpTo( 1 )
		end
	end
	-- Menu
	if menu.isActive then
		if key == "return" then menu:enter( menu.position ) end
		if key == "up" and not menu.credits.isActive then
			menu:switch( -1 )
		elseif key == "down" and not menu.credits.isActive then
			menu:switch( 1 )
		end
		if key == "left" and menu.options.isActive then
			menu:setOption( -1 )
		elseif key == "right" and menu.options.isActive then
			menu:setOption( 1 )
		end
	elseif pause or gameOver then
		if key == "left" or key == "right" then
			if menu.position == 1 then
				menu:switch( 1 )
			else
				menu:switch( -1 )
			end
		end
		if key == "return" then
			if menu.position == 1 then
				if pause then
					file:close()
					love.event.quit()
				elseif gameOver then
					reset()
					pause = false
					gameOver = false
					music:play()
				end
			elseif menu.position == 2 then
				if pause then
					pause = false
				elseif gameOver then
					gameOver = false
					reset()
					menu:switch( -1 )
					menu.isActive = true
					music:play()
				end
			end
		end
	end
end