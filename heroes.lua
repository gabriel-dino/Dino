-- Hero costumes keep the same T-rex silhouette and gameplay dimensions.
return function(x, y, skin)
    local g = love.graphics
    if skin.hero == "godzilla" then
        g.setColor(skin.accent)
        for i = 0, 4 do
            local px, py = x+20-i*7, y+20+i*5
            g.polygon("fill",px,py+8,px-9,py-11,px+3,py-6,px+5,py+6)
        end
        g.setColor(0.55,0.68,0.53)
        for i = 0, 2 do g.rectangle("fill",x+18,y+32+i*7,12,3) end
        g.setColor(1,0.85,0.35); g.rectangle("fill",x+43,y+7,5,3)
    else
        g.setColor(skin.accent)
        g.rectangle("fill",x+25,y+12,16,10,4,4)
        g.ellipse("fill",x+22,y+41,12,13)
        g.setColor(0.20,0.13,0.10)
        for i = 0, 3 do g.polygon("fill",x+7+i*6,y+32,x+10+i*6,y+39,x+13+i*6,y+31) end
        -- A fur collar and clenched fist evoke Kong without replacing the T-rex.
        g.rectangle("fill",x+42,y+34,9,10,2,2)
        g.rectangle("fill",x+39,y+3,13,3)
        g.setColor(0.95,0.77,0.41); g.rectangle("fill",x+43,y+7,5,3)
    end
end
