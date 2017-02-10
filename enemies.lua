local function CheckCollision( x1, y1, w1, h1, x2, y2, w2, h2 )
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end
local enemies = {}
enemies.frames = {}
x = 0
for i = 1, 11 do
	local frame = love.graphics.newQuad( x, 128, 96, 96, sheet.w, sheet.h )
	table.insert( enemies.frames, frame )
	x = x + 96
end
enemies.pace = 1
enemies.buffer = 0
enemies.level = 1
enemies.wait = true
enemies.wasp = {}
x = 128
for i = 1, 3 do
	local wasp = {}
	wasp.out = false
	wasp.buffer = 0
	wasp.z = -1
	wasp.direction = 1
	wasp.index = 1
	wasp.timer = 0
	wasp.pace = 0.07
	wasp.x = x
	wasp.y = screen.h
	wasp.box = { x = x - 24, y = wasp.y - 32, w = 48, h = 48 }
	table.insert( enemies.wasp, wasp )
	x = x + 192
end
enemies.pattern = {}
function enemies:update( dt )
	local out = 0
	for _, enemy in pairs( self.wasp ) do
		if enemy.out then
			out = out + 1
			if enemy.buffer < 0 then
				enemy.buffer = enemy.buffer + dt
				if enemy.buffer > 0 then
					enemy.buffer = 0
				end
				if enemy.y == 120 then
					enemy.z = 1
				end
			elseif enemy.buffer == 0 then
				enemy.y = enemy.y + dt * ( 900 + self.level * 5 ) * enemy.z
			end
			if enemy.y < 120 then
				enemy.y = 120
				enemy.buffer = -love.math.random( 0.1, 1 )
			elseif enemy.y > screen.h then
				enemy.y = screen.h
				enemy.out = false
				enemy.z = -1
				self.buffer = self.pace
			end
		end
		if CheckCollision( enemy.box.x, enemy.box.y, enemy.box.w, enemy.box.h, player.box.x, player.box.y, player.box.w, player.box.h ) and not contact and not player.muteki then
			contact = true
			music:pause()
			player.fall = 300
			player.sounds.death:play()
		end
		-- Update animation
		if enemy.y < screen.h then
			enemy.timer = enemy.timer + dt
			if enemy.timer > enemy.pace then
				enemy.timer = 0
				enemy.index = enemy.index + 1
				if enemy.index > 11 then
					enemy.index = 1
				end
			end
			if enemy.x > player.x then
				enemy.direction = -1
			else
				enemy.direction = 1
			end
		end
		enemy.box.x, enemy.box.y = enemy.x - 24, enemy.y + 32
	end
	if out < self.level and self.buffer == 0 then
		local max
		if self.level < 3 then
			max = self.level
		else
			max = 3
		end
		for i = 1, max do
			local r = love.math.random( 1, 3 )
			if not self.wasp[ r ].out then
				self.wasp[ r ].out = true
				self.wasp[ r ].buffer = -love.math.random( 0.5, 1 ) / self.level
			end
		end
	end
	if self.buffer > 0 then
		self.buffer = self.buffer - dt
	elseif self.buffer < 0 then
		self.buffer = 0
	end
end
function enemies:draw()
	for _, enemy in pairs( self.wasp ) do
		love.graphics.draw( sheet.image, enemies.frames[ enemy.index ], enemy.x, math.floor( enemy.y ), 0, enemy.direction, 1, 48 )
	end
end
return enemies