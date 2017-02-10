local storm = {}
storm.isActive = false
storm.buffer = 0
local data = love.image.newImageData( 1, 8 )
local alpha = 0
for i = 0, 7 do
	data:setPixel( 0, i, 255, 255, 255, alpha )
	alpha = alpha + 31
end
storm.drop = love.graphics.newImage( data )
storm.particles = love.graphics.newParticleSystem( storm.drop, 68000 )
storm.particles:setEmissionRate( 1024 )
storm.particles:setSpeed( 400, 900 )
storm.particles:setParticleLifetime( 4, 5 )
storm.particles:setAreaSpread( "normal", 320, 0 )
storm.particles:setDirection( math.rad( 90 ) )
storm.particles:setSpread( math.rad( 20 ) )
function storm:update( dt )
	if self.isActive then
		self.particles:update( dt )
		love.graphics.setBackgroundColor( 90, 88, 103 )
		self.buffer = self.buffer - dt
		if self.buffer < 0 then
			color = 0
			love.graphics.setBackgroundColor( 255, 255, 255 )
		end
		if color == 0 then
			self.buffer = love.math.random ( 2, 4 )
		end
		if color < 255 then
			color = color + dt * 700
			if color > 255 then
				color = 255
			end
		end
	end
end
return storm