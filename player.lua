local player = {}
player.muteki = false
player.fall = 0
player.death = love.graphics.newQuad( 192, 64, 64, 64, sheet.w, sheet.h )
player.sounds = {} 
player.sounds.jump = love.audio.newSource( "audio/Jump_00.mp3" )
player.sounds.jump:setVolume( 0.5 )
player.sounds.collect = love.audio.newSource( "audio/Collect_Point_00.mp3" )
player.sounds.death = love.audio.newSource( "audio/Hero_Death_00.mp3" )
player.limits = { ground = 198, left = 32, right = 608, jump = 192, speed = 390, vertical = 0, power = 400, gravity = 1550 }
player.spot = 1
player.isJumping = false
player.x, player.y = 32, 198
player.box = { x = player.x - 16, y = player.y + 16, w = 32, h = 32 }
player.orientation = 1
player.jump = newAnimation( 0, 0, 20, 64, 64, 0.02, 32 )
player.idle = newAnimation( 576, 64, 8, 64, 64, 0.1, 32, true )
player.anim = player.idle
function player:jumpTo( direction )
	self.sounds.jump:play()
	self.orientation = direction
	self.isJumping = true
	self.limits.vertical = self.limits.power
	self.anim = self.jump
	self.anim.index = 1
end
function player:land( x, spot )
	self.x = x
	self.spot = spot
	self.isJumping = false
	self.limits.vertical = 0
	self.y = self.limits.ground
	self.anim = self.idle
	self.anim.index = 1
	if treasure.isVisible and treasure.spot == spot then
		self.sounds.collect:play()
		score.player = score.player + treasure.value
		enemies.pace = enemies.pace - 0.02
		if enemies.pace < 0.1 then
			enemies.pace = 0.1
		end
		if treasure.spot == 1 then
			treasure.x = 52
			self.orientation = 1
			treasure.direction = -1
		elseif treasure.spot == 4 then
			treasure.x = 632
			self.orientation = -1
			treasure.direction = 1
		end
		if treasure.value == 5000 then
			treasure.chest.open.index = 1
		end
		treasure.particles:emit( 16 )
		treasure.isVisible = false
		timer = math.ceil( timer / 10 ) * 10 
	else
		score.player = score.player + 50
	end
end
function player:update( dt )
	self.anim:update( dt )
	if self.isJumping and not contact then
		local before = self.limits.left + self.limits.jump * ( self.spot - 2 )
		local after = self.limits.left + self.limits.jump * self.spot
		self.x = self.x + dt * self.orientation * self.limits.speed
		self.y = self.y - self.limits.vertical * dt
		self.limits.vertical = self.limits.vertical - dt * self.limits.gravity
		if self.x < self.limits.left then
			self:land( self.limits.left, 1 )
		elseif self.x > self.limits.right then
			self:land( self.limits.right, 4 )
		elseif self.x > after then
			self:land( after, self.spot + 1 )
		elseif self.x < before then
			self:land( before, self.spot - 1 )
		end
	end
	if contact then
		self.y = self.y - self.fall * dt
		self.fall = self.fall - dt * 740
		if self.y > screen.h then
			gameOver = true
			file:write( tostring( score.self ) )
		end
	end
	self.box.x, self.box.y = self.x -16, self.y + 16
end
function player:draw()
	if contact then
		love.graphics.draw( sheet.image, self.death, math.floor( self.x ), math.floor( self.y ), 0, self.orientation, 1, 32 )
	else
		self.anim:draw( self.x, self.y )
	end
end
return player