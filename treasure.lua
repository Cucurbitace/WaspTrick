local treasure = {}
treasure.spot = 4
local star = love.graphics.newImage( "graphics/star.png" )
local star1 = love.graphics.newQuad( 0, 0, 24, 24, 96, 24 )
local star2 = love.graphics.newQuad( 24, 0, 24, 24, 96, 24 )
local star3 = love.graphics.newQuad( 48, 0, 24, 24, 96, 24 )
local star4 = love.graphics.newQuad( 72, 0, 24, 24, 96, 24 )
treasure.particles = love.graphics.newParticleSystem( star, 32 )
treasure.init = true
treasure.value = 1700
treasure.particles:setQuads( star1, star2, star3, star4 )
treasure.particles:setParticleLifetime( 0.2, 0.4 )
treasure.particles:setSpeed( -150, 150 )
treasure.particles:setSpread( math.rad( 250 ) )
treasure.particles:setColors( 255, 255, 255, 255, 255, 255, 255, 0 )
treasure.particles:start()
treasure.particles:setSizes( 0.5, 0.75, 1 )
treasure.particles:setSizeVariation( 0 )
-- Chest --------------------------------------------------------------------------------------------------------------------- Chest --
treasure.chest = {}
treasure.chest.spawn = newAnimation( 768, 224, 4, 32, 32, 0.05, -272 )
treasure.chest.loop = newAnimation( 864, 224, 4, 32, 32, 0.05, -272, true )
treasure.chest.open = newAnimation( 0, 512, 14, 43, 32, 0.05, -272 )
treasure.chest.open.index = 14
local image = love.graphics.newImage( "graphics/coin_gold.png")
local coins = {}
for i = 1, 8 do
	local coin = love.graphics.newQuad( i * 32 - 32, 0, 32, 24, 256, 24 )
	table.insert( coins, coin )
end
treasure.chest.particles = love.graphics.newParticleSystem( image, 16 )
treasure.chest.particles:setParticleLifetime( 0.5, 1 )
treasure.chest.particles:setLinearAcceleration( -300, 400, 300, 200 )
treasure.chest.particles:setDirection( math.rad( 270 ) )
treasure.chest.particles:setColors( 255, 255, 255, 255, 255, 255, 255, 0 )
treasure.chest.particles:setSpeed( 80, 120 )
treasure.chest.particles:setQuads( coins[1], coins[2], coins[3], coins[4], coins[5], coins[6], coins[7], coins[8])
treasure.chest.particles:start()
treasure.stars = 8
treasure.direction = -1
treasure.isVisible = true
treasure.x, treasure.y = 624, 250
treasure.cIndex = 1
treasure.crystals = { loop = {}, spawn = {} }
local x, y = 416, 224
for i = 1, 6 do
	local crystal = {}
	crystal.loop = newAnimation( x, y, 8, 32, 32, 0.05, -272, true)
	crystal.spawn = newAnimation ( x + 256, y, 3, 32, 32, 0.05, -272 )
	table.insert (treasure.crystals, crystal )
	y = y + 32
end
treasure.active = treasure.crystals[ 1 ].spawn
function treasure:spawn( init )
	if init then self.direction = -1 end
	self.isVisible = true
	local r = love.math.random( 1, 10 )
	if r == 10 then
		self.value = 5000
		self.active = self.chest.spawn
		self.stars = 256
	else
		self.cIndex = love.math.random( 1, 6 )
		self.value = 1700
		self.active = self.crystals[ self.cIndex ].spawn
		self.stars = 16
	end
	if self.spot == 1 then
		self.spot = 4
	elseif self.spot == 4 then
		self.spot = 1
	end
	self.active.index = 1
	self.init = true
end
function treasure:update( dt )
	self.chest.particles:update( dt )
	if self.chest.open.index < 14 then
		self.chest.open:update( dt )
		if self.chest.open.index == 7 then
			self.chest.particles:emit( 16 )
		end
	end
	self.particles:update( dt )
	if self.particles:getCount() == 0 and not self.isVisible then
		self:spawn()
	end
	if self.isVisible then
		if self.init then
			self.active:update( dt )
			if self.active.index == 3 then
				self.init = false
				if self.value == 5000 then
					self.active = self.chest.loop
				else
					self.active = self.crystals[ self.cIndex ].loop
				end
			end
		else
			self.active:update( dt )
			if self.active.index == self.active.last then
				self.active.timer = -love.math.random( 1, 3 )
				self.active.index = 1
			end
		end
	end
end
function treasure:draw()
	if self.isVisible then
		love.graphics.draw( sheet.image, self.active.frames[ self.active.index ], 320, 233, 0, self.direction, 1, 302 )
	end
	love.graphics.draw( sheet.image, self.chest.open.frames[ self.chest.open.index], 320, 233, 0, -self.direction, 1, 311 )
	love.graphics.draw( self.chest.particles, self.x - 32, self.y )
end
return treasure