local score = {}
score.yLabel = 16
score.yValue = 37
file = love.filesystem.newFile( "score" )
if love.filesystem.exists( "score" ) then
	file:open( "r" )
	score.best = tonumber( tostring(file:read() ) )
	if score.best == nil then
		score.best = 0
	end
	file:close()
	file:open( "w" )
else
	info = "new"
	file:open( "w" )
	file:write( "0" )
	score.best = 0
end
score.player = 0
function score:update( dt )
	if self.player > self.best then self.best = self.player end
	if self.player > 20000 and enemies.level == 1 then
		enemies.level = 2
	elseif self.player > 50000 and enemies.level == 2 then
		enemies.level = 3
	elseif self.player > 100000 and enemies.level == 3 then
		enemies.level = 4
		storm.isActive = true
	elseif self.player > 200000 then
		enemies.level = 5
	elseif self.player > 300000 then
		enemies.level = 6
	end
end
return score