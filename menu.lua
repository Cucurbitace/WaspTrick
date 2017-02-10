local function fancyPrint( r, g, b, text, x, y, offset, limit, align )
	local gs = g - 64
	if gs < 0 then gs = 0 end
	love.graphics.setColor( r - 64, gs, b - 64, 128 )
	for i = 1, 2 do
		if align then
			love.graphics.printf( text, x, y, limit, align )
		else
			love.graphics.print( text, x, y )
		end
		love.graphics.setColor( r, g, b, 255 )
		x = x - offset
		y = y - offset
	end
end
local menu = {}
menu.position = 1
menu.isActive = true
menu.options = {}
menu.options.isActive = false
menu.start = false
menu.credits = require( "credits" )
menu.colors = { 0, 160, 160, 160 }
function menu:reset()
	for _, element in pairs ( self.credits.staff ) do
		element.y = element.by
	end
	self.credits.isActive = false
	self:switch( - 2 )
end
function menu:switch( direction )
	self.position = self.position + direction
	if self.position > 4 then
		self.position = 1
	elseif self.position < 1 then
		self.position = 4
	end
	if self.position == 1 then
		menu:setColor( 0, 160, 160, 160 )
	elseif self.position == 2 then
		menu:setColor( 160, 0, 160, 160 )
	elseif self.position == 3 then
		menu:setColor( 160, 160, 0, 160 )
	elseif self.position == 4 then
		menu:setColor( 160, 160, 160, 0 )
	end
end
function menu:enter( position )
	if self.credits.isActive then
		self:reset()
	elseif self.options.isActive then
		if position == 4 then
			menu:switch( 1 )
			self.options.isActive = false
		end
	else
		if position == 1 then
			self.isActive = false
		elseif position == 2 then
			menu:switch( -1 )
			self.options.isActive = true
		elseif position == 3 then
			self.credits.isActive = true
		elseif position == 4 then
			file:close()
			love.event.quit()
		end
	end
end
function menu:setOption( direction )
	if self.position == 1 then
		options.zoom = options.zoom + direction
		if options.zoom < 1 then
			options.zoom = 1
		elseif options.zoom > 4 then
			options.zoom = 4
		else
			love.window.setMode( screen.w * options.zoom, screen.h * options.zoom, { fullscreen = options.fullscreen } )
		end
	elseif self.position == 2 then
		if options.filter == "linear" then
			options.filter = "nearest"
		else
			options.filter = "linear"
		end
		canvas:setFilter( options.filter, options.filter, 1 )
	elseif self.position == 3 then
		options.fullscreen = not options.fullscreen
		love.window.setMode( screen.w, screen.h, { fullscreen = options.fullscreen } )
	end
end
function menu:setColor( r, g, b, a ) self.colors = { r, g, b, a } end
function menu:update( dt )
	if self.credits.isActive then
		if love.keyboard.isDown( "down" ) then
			self.credits.speed = 200
		elseif love.keyboard.isDown ( "up" ) then
			self.credits.speed = 10
		else
			self.credits.speed = 50
		end
		for _, element in pairs ( self.credits.staff ) do
			element.y = element.y - dt * self.credits.speed
		end
		if self.credits.staff.you.y < -100 then
			self:reset()
		end
	end
end
function menu:draw()
	if self.isActive then
		if self.credits.isActive then
			love.graphics.setColor( 32, 0, 64, 192 )
			love.graphics.rectangle( "fill", 0, 0, screen.w, screen.h )
			for i, v in pairs( self.credits.staff ) do
				if v.title then
					love.graphics.setFont( font.label )
					fancyPrint( 255, 255, 255, v.title, 0, v.y, 2, screen.w, "center")
				else
					love.graphics.setFont( font.credits )
					fancyPrint( 255, 160, 0, v.name, 0, v.y, 2, screen.w, "center")
					if v.image then
						local x = math.floor( screen.w / 2 - v.image:getWidth() / 2 )
						local h = v.image:getHeight() + 20
						love.graphics.setColor( 255, 255, 255 )
						love.graphics.draw( v.image, x, math.floor( v.y + 20 ) )
						fancyPrint( 170, 160, 255, v.url, 0, v.y + h, 2, screen.w, "center")
					elseif v.url then
						fancyPrint( 170, 160, 255, v.url, 0, v.y + 20, 2, screen.w, "center")
					end
				end
			end
		elseif self.options.isActive then
			love.graphics.setFont( font.menu )
			fancyPrint( 255, self.colors[1], 0, "Zoom", 0, 150, 3, 550, "center" )
			fancyPrint( 170, self.colors[1], 255, "X"..options.zoom, 120, 150, 3, 500, "center" )
			fancyPrint( 255, self.colors[2], 0, "Filter", 0, 200, 3, 550, "center" )
			fancyPrint( 170, self.colors[2], 255, options.filter, 160, 200, 3, 500, "center" )
			fancyPrint( 255, self.colors[3], 0, "Fullscreen", 0, 250, 3, 480, "center" )
			fancyPrint( 170, self.colors[3], 255, tostring( options.fullscreen ), 150, 250, 3, 500, "center" )
			fancyPrint( 255, self.colors[4], 0, "Back", 0, 300, 3, screen.w, "center" )
		else
			love.graphics.setFont( font.title )
			fancyPrint( 255, 96, 0, "Wasp Trick",0, 80, 4, screen.w, "center" )
			love.graphics.setFont( font.menu )
			fancyPrint( 255, self.colors[1], 0, "Start", 0, 150, 3, screen.w, "center" )
			fancyPrint( 255, self.colors[2], 0, "Options", 0, 200, 3, screen.w, "center" )
			fancyPrint( 255, self.colors[3], 0, "Credits", 0, 250, 3, screen.w, "center" )
			fancyPrint( 255, self.colors[4], 0, "Exit", 0, 300, 3, screen.w, "center" )
		end
	else
		love.graphics.setFont( font.title )
		if start > 0.5 then
			fancyPrint( 255, 160, 0, "READY", 0, 160, 3, screen.w, "center" )
		elseif start < 0.5 and start > 0 then
			fancyPrint( 255, 160, 0, "GO!", 0, 160, 3, screen.w, "center" )
		end
		love.graphics.setFont( font.score )
		fancyPrint( 255, 160, 0, "BEST", 0, score.yLabel, 2, 212, "center" )
		fancyPrint( 255, 160, 0, "TIME", 212, score.yLabel, 2, 212, "center" )
		fancyPrint( 255, 160, 0, "SCORE", 414, score.yLabel, 2, 212, "center" )
		fancyPrint( 170, 160, 255, score.best, 0, score.yValue, 2, 212, "center" )
		fancyPrint( 170, 160, 255, math.floor( timer ), 212, score.yValue, 2, 212, "center" )
		fancyPrint( 170, 160, 255, score.player, 414, score.yValue, 2, 212, "center" )
		if pause then
			love.graphics.setFont( font.title )
			fancyPrint( 255, 255, 255, "Pause", 0, 100, 3, screen.w, "center")
			love.graphics.setFont( font.menu )
			fancyPrint( 255, 160, 0, "Do you want to quit?", 0, 175, 2, screen.w, "center" )
			fancyPrint( 170, self.colors[1], 255, "Yes", 0, 230, 3, 500, "center" )
			fancyPrint( 170, self.colors[2], 255, "No", 60, 230, 3, 640, "center" )
		elseif gameOver then
			love.graphics.setFont( font.title )
			fancyPrint( 255, 160, 0, "Game Over", 0, 100, 3, screen.w, "center" )
			love.graphics.setFont( font.menu )
			fancyPrint( 255, 160, 0, "retry?", 0, 175, 2, screen.w, "center" )
			fancyPrint( 170, self.colors[1], 255, "Yes", 0, 230, 3, 500, "center" )
			fancyPrint( 170, self.colors[2], 255, "No", 60, 230, 3, 640, "center" )
		end
	end
end
return menu