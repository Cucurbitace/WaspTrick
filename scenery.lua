local function newGround( x, y, count, w, h, step )
	local cx, cy = x, y
	ground = {}
	ground.tiles = {}
	for i = 1, count do
		local tile = love.graphics.newQuad( cx, cy, w, h, sheet.w, sheet.h )
		table.insert( ground.tiles, tile )
		cx = cx + w
		if cx == x + step * w then
			cx = x
			cy = cy + h
		end
	end
	function ground:draw( x, y )
		local cx, cy = x, y
		for i, v in pairs( self.tiles ) do
			love.graphics.draw( sheet.image, v, cx, cy )
			cx = cx + w
			if i % step == 0 then
				cx = x
				cy = cy + h
			end
		end
	end
	return ground
end
local scenery = {}
scenery.canopee = newGround( 128, 416, 1, 640, 96, 1 )
scenery.tree = newGround( 768, 320, 1, 320, 192, 1 )
scenery.spike = {}
scenery.spike.right = newGround( 0, 224, 1, 32, 96, 1 )
scenery.spike.left = newGround( 64, 352, 1, 32, 96, 1 )
scenery.flower = newGround( 0, 352, 1, 64, 96, 1 )
scenery.edge = {}
scenery.edge.left = newGround( 64, 224, 9, 32, 32, 2 )
scenery.edge.right = newGround( 32, 224, 9, 32, 32, 2 )
scenery.leaf = newGround( 128, 224, 12, 32, 32, 3 )
scenery.leaves = {}
local x = 224
local y = 224
for i = 1, 6 do
	local leaf = love.graphics.newQuad( x, y, 64, 64, sheet.w, sheet.h )
	table.insert( scenery.leaves, leaf )
	x = x + 64
	if i % 3 == 0 then
		x = 224
		y = y + 64
	end
end
scenery.blocks = {}
x, y = 768, 256
for i = 1, 7 do
	local block = newGround( x, y, 1, 32, 64, 1 )
	table.insert( scenery.blocks, block )
	x = x + 32
end
local block = newGround( 992, 288, 1, 32, 32, 1 )
table.insert( scenery.blocks, block )
function scenery:draw()
	self.tree:draw( 130, 108 )
	for i = 1, 3 do self.canopee:draw( 0, 32 * ( i - 1 ) - 16 ) end
	for i = 1, 3 do
		self.spike.right:draw( 624, 96 * ( i - 1 ) )
		self.spike.left:draw( -16, 96 * ( i - 1 ) )
	end
	self.flower:draw( 64, 200 )
	for i = 1, 17 do
		local index
		if i < 4 then
			index = i
		elseif i > 14 then
			index = i - 10
		else
			index = 4
		end
		self.blocks[ index ]:draw( 16 + i * 32, 272 )
		self.blocks[ 8 ]:draw( 16 + i * 32, 336 )
	end
	for i, leaf in pairs( self.leaves ) do
		love.graphics.draw( sheet.image, leaf, i * 96, 246 )
	end
	self.edge.left:draw( 0, 232 )
	self.edge.right:draw( 576, 232 )
	self.leaf:draw( 176, 232 )
	self.leaf:draw( 368, 232 )
end
return scenery