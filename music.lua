local music = love.audio.newSource( "audio/Jungle.ogg", "stream" )
music:setLooping( true )
music:play()
return music