-- Aquatic details preserve the dinosaur's head, legs and tail. The five
-- ornaments sit above the head, apart from family details and torso markings.
return function(x, y, skin)
    local g = love.graphics
    local dark = {0.08, 0.18, 0.27}
    local function color(c) g.setColor(c) end
    color(skin.accent)
    if skin.ocean == 1 then -- shark dorsal fin, tail flukes and gills
        g.polygon("fill", x+19,y+24,x+1,y+6,x+3,y+33)
        g.polygon("fill", x-8,y+33,x-18,y+17,x-16,y+45)
        for j = 0, 2 do g.rectangle("fill", x+26+j*5,y+15,2,8) end
        for j = 0, 2 do g.polygon("fill", x+39+j*5,y+25,x+41+j*5,y+29,x+43+j*5,y+25) end
    elseif skin.ocean == 2 then -- curled tentacles with round suckers
        for j = 0, 2 do
            local px, py = x-12+j*8,y+21+j*7
            color(skin.accent)
            g.rectangle("fill",px,py,6,20,3,3)
            g.rectangle("fill",px,py+16,13,5,2,2)
            g.circle("fill",px+10,py+16,4)
            color(dark); g.circle("fill",px+3,py+5,1.5); g.circle("fill",px+3,py+12,1.5)
        end
    elseif skin.ocean == 3 then -- branching coral along the back
        for j = 0, 2 do
            local px, py = x+12-j*8,y+21+j*6
            g.rectangle("fill",px,py-13,4,23)
            g.rectangle("fill",px-6,py-7,7,4)
            g.rectangle("fill",px-6,py-14,4,10)
            g.rectangle("fill",px+3,py-2,8,4)
            g.rectangle("fill",px+8,py-9,4,10)
        end
    elseif skin.ocean == 4 then -- angler lure and luminous dorsal spots
        g.rectangle("fill",x+20,y-9,4,13)
        g.rectangle("fill",x+20,y-12,31,4)
        g.rectangle("fill",x+48,y-11,3,9)
        g.circle("fill",x+49,y-1,5)
        for j = 0, 3 do g.circle("fill",x+14-j*8,y+24+j*5,3) end
        color(dark); g.rectangle("fill",x+39,y+5,12,10)
        color(skin.accent); g.rectangle("fill",x+44,y+8,4,4)
    elseif skin.ocean == 5 then -- jellyfish bell and trailing ribbons
        g.ellipse("fill",x+37,y-3,19,10)
        g.rectangle("fill",x+18,y-3,38,6)
        for j = 0, 2 do
            local px = x+5-j*7
            g.rectangle("fill",px,y+17,3,17+j*3)
            g.rectangle("fill",px-4,y+31+j*3,7,3)
            g.rectangle("fill",px-4,y+31+j*3,3,10)
        end
        color({1,0.94,1}); g.circle("fill",x+31,y-7,3)
    elseif skin.ocean == 6 then -- patterned shell on the dinosaur's back
        g.ellipse("fill",x+5,y+29,14,20)
        color(dark)
        g.polygon("line",x+4,y+15,x+13,y+23,x+12,y+35,x+3,y+42,x-5,y+34,x-5,y+22)
        g.line(x-5,y+22,x-8,y+17); g.line(x-5,y+34,x-8,y+41)
        g.line(x+4,y+15,x+5,y+10); g.line(x+3,y+42,x+3,y+48)
        color(skin.accent); g.rectangle("fill",x+30,y+16,5,6)
    elseif skin.ocean == 7 then -- curled tail and seahorse dorsal frill
        g.circle("fill",x-5,y+35,12)
        color(skin.body); g.circle("fill",x-4,y+33,7)
        color(skin.accent); g.rectangle("fill",x-6,y+34,8,4)
        for j = 0, 3 do
            g.polygon("fill",x+18,y+16+j*7,x+6,y+13+j*7,x+15,y+23+j*7)
        end
        g.rectangle("fill",x+33,y-9,6,10)
        g.circle("fill",x+36,y-9,4)
    else -- scalloped shell and pearl at the neck
        for j = 0, 3 do
            g.polygon("fill",x+17,y+35,x-10+j*8,y+10,x-4+j*8,y+9)
            g.circle("fill",x-7+j*8,y+10,4)
        end
        color(dark)
        for j = 0, 2 do g.line(x+15,y+31,x-3+j*8,y+13) end
        color({1,0.98,0.94}); g.circle("fill",x+24,y+26,6)
        color({1,0.72,0.86}); g.circle("fill",x+22,y+24,2)
    end
    color(skin.accent)
    if skin.ornament == 1 then -- five-point starfish
        local points = {}
        for i = 0, 9 do
            local angle, radius = -math.pi/2+i*math.pi/5, i%2 == 0 and 10 or 4
            points[#points+1] = x+36+math.cos(angle)*radius
            points[#points+1] = y-24+math.sin(angle)*radius
        end
        g.polygon("fill",points)
    elseif skin.ornament == 2 then -- trident
        g.rectangle("fill",x+34,y-31,3,17)
        g.rectangle("fill",x+26,y-25,19,3)
        g.rectangle("fill",x+26,y-32,3,10); g.rectangle("fill",x+42,y-32,3,10)
    elseif skin.ornament == 3 then -- scallop shell
        g.polygon("fill",x+35,y-15,x+23,y-29,x+27,y-33,x+44,y-33,x+49,y-29)
        color(dark); g.line(x+35,y-18,x+29,y-29); g.line(x+36,y-18,x+41,y-29)
    elseif skin.ornament == 4 then -- three bubbles
        g.circle("line",x+29,y-22,6); g.circle("line",x+41,y-29,4)
        g.circle("fill",x+45,y-18,3)
    else -- anchor
        g.circle("line",x+36,y-30,4)
        g.rectangle("fill",x+35,y-27,3,13)
        g.rectangle("fill",x+29,y-25,15,3)
        g.polygon("fill",x+24,y-21,x+28,y-15,x+36,y-12,x+45,y-16,x+48,y-22,
            x+43,y-19,x+42,y-17,x+30,y-17,x+29,y-20)
    end
    color(skin.accent)
end
