-- Robotic armor keeps the dinosaur silhouette and leaves circuit markings
-- unobstructed on the torso. Head modules remain distinct in catalog previews.
return function(x, y, skin)
    local g = love.graphics
    local dark, metal = {0.08,0.13,0.20}, {0.66,0.72,0.79}
    local function color(c) g.setColor(c) end
    local function gear(px, py)
        g.circle("fill",px,py,9)
        for j = 0, 3 do
            local angle = j*math.pi/2
            g.rectangle("fill",px+math.cos(angle)*9-2,py+math.sin(angle)*9-2,4,4)
        end
        color(dark); g.circle("fill",px,py,4); color(skin.accent)
    end
    color(skin.accent)
    if skin.robot == 1 then -- riveted steel plates
        g.rectangle("fill",x+21,y-5,34,6)
        g.rectangle("fill",x-8,y+23,14,22,2,2)
        g.rectangle("fill",x+25,y+16,11,8)
        color(dark)
        for j = 0, 2 do g.rectangle("fill",x-5,y+26+j*7,3,3) end
        g.rectangle("fill",x+28,y+18,3,3)
    elseif skin.robot == 2 then -- laser visor and circuit sail
        g.rectangle("fill",x+20,y-3,34,3)
        g.rectangle("fill",x+29,y+5,25,8)
        g.rectangle("fill",x+9,y+15,4,17)
        g.rectangle("fill",x-10,y+18,22,3)
        g.rectangle("fill",x-10,y+18,3,19)
        for j = 0, 2 do g.circle("fill",x-9+j*8,y+35-j*6,3) end
        color(dark); g.rectangle("fill",x+32,y+7,18,3)
    elseif skin.robot == 3 then -- rusty gear train and mismatched head plates
        gear(x-6,y+28); gear(x+6,y+18)
        color({0.57,0.29,0.15}); g.rectangle("fill",x+22,y-5,32,6)
        g.rectangle("fill",x+25,y+16,11,7)
        color(skin.accent); g.rectangle("fill",x+27,y-3,3,3)
        g.rectangle("fill",x+43,y-3,3,3)
        g.rectangle("fill",x-6,y+39,11,5)
    elseif skin.robot == 4 then -- space helmet, oxygen pack and thruster
        g.rectangle("fill",x+18,y-7,40,35,8,8)
        color(dark); g.rectangle("fill",x+24,y+1,31,20,5,5)
        color({0.25,0.61,0.84}); g.rectangle("fill",x+29,y+4,24,13,3,3)
        color(skin.accent); g.rectangle("fill",x+31,y+5,3,8)
        g.rectangle("fill",x-9,y+17,21,27,3,3)
        color(dark); g.rectangle("fill",x-5,y+20,5,17)
        g.rectangle("fill",x+3,y+20,5,17)
        color({1,0.62,0.24}); g.polygon("fill",x-5,y+44,x-2,y+52,x+1,y+44)
    elseif skin.robot == 5 then -- translucent dinosaur with scan lines
        for j = 0, 3 do g.rectangle("fill",x+23,y+2+j*6,30,1) end
        g.rectangle("fill",x+21,y-4,35,2)
        g.polygon("line",x+15,y+22,x-13,y+14,x-10,y+45,x+6,y+51)
        for j = 0, 2 do g.rectangle("fill",x-11,y+20+j*9,13,1) end
        g.rectangle("fill",x+33,y+25,8,2)
    elseif skin.robot == 6 then -- horseshoe magnet and copper coils
        g.rectangle("fill",x-13,y+15,7,25)
        g.rectangle("fill",x+3,y+15,7,25)
        g.rectangle("fill",x-10,y+35,17,7)
        color({0.76,0.85,0.96})
        g.rectangle("fill",x-13,y+13,7,7); g.rectangle("fill",x+3,y+13,7,7)
        color({0.93,0.60,0.29})
        for j = 0, 3 do g.rectangle("fill",x+23,y-8+j*3,13,2) end
    elseif skin.robot == 7 then -- glowing neck core and cooling fins
        color(dark); g.rectangle("fill",x-9,y+16,20,30,3,3)
        color(skin.accent)
        for j = 0, 3 do g.rectangle("fill",x-7,y+20+j*6,16,3) end
        g.circle("fill",x+36,y+25,9)
        color(dark); g.circle("fill",x+36,y+25,6)
        color({1,1,0.78}); g.circle("fill",x+36,y+25,3)
        color(skin.accent); g.rectangle("fill",x+25,y-5,27,5)
    else -- heavy mecha shoulder armor and angular dorsal panels
        g.polygon("fill",x+19,y+22,x+2,y+9,x-1,y+23,x-14,y+20,
            x-11,y+38,x+1,y+45,x+13,y+34)
        g.rectangle("fill",x+32,y+26,19,9,2,2)
        g.polygon("fill",x+20,y+1,x+25,y-9,x+53,y-9,x+58,y+2)
        color(dark); g.rectangle("fill",x+27,y-5,23,4)
        g.line(x-7,y+24,x+7,y+28,x+5,y+37)
    end
    -- An LED eye is shared by every robotic dinosaur, including the helmet.
    color(dark); g.rectangle("fill",x+39,y+5,14,10)
    color(skin.accent); g.rectangle("fill",x+42,y+8,8,3)

    color(skin.accent)
    if skin.hardware == 1 then -- aerial with a glowing tip
        g.rectangle("fill",x+35,y-30,3,17)
        g.circle("fill",x+36,y-31,4)
        color(dark); g.rectangle("fill",x+30,y-16,13,3)
    elseif skin.hardware == 2 then -- satellite dish
        g.polygon("fill",x+24,y-32,x+48,y-32,x+43,y-23,x+30,y-23)
        g.rectangle("fill",x+35,y-23,3,10)
        color(dark); g.rectangle("fill",x+35,y-34,3,8)
    elseif skin.hardware == 3 then -- floating mechanical cog
        gear(x+36,y-24)
    elseif skin.hardware == 4 then -- three illuminated coil loops
        for j = 0, 2 do g.ellipse("line",x+28+j*8,y-25,4,8) end
        g.rectangle("fill",x+26,y-17,22,3)
    else -- paired sensor towers
        g.rectangle("fill",x+26,y-30,4,17)
        g.rectangle("fill",x+44,y-30,4,17)
        g.rectangle("fill",x+23,y-34,10,7)
        g.rectangle("fill",x+41,y-34,10,7)
        color(dark); g.rectangle("fill",x+26,y-32,3,3)
        g.rectangle("fill",x+44,y-32,3,3)
    end
    color(skin.accent)
end
