-- Fruit markings decorate the shared T-rex body, head, short arms and tail.
return function(x, y, skin)
    local g, kind = love.graphics, skin.fruit
    g.setColor(skin.accent)
    if kind == "watermelon" or kind == "melon" then
        for i = 0, 2 do
            g.polygon("fill", x+8+i*8,y+34, x+11+i*8,y+34,
                x+15+i*7,y+51, x+12+i*7,y+51)
        end
        for i = 0, 2 do g.rectangle("fill",x+25+i*6,y+2,3,16) end
    elseif kind == "banana" then
        g.polygon("fill",x+8,y+34,x+13,y+34,x+20,y+47,x+31,y+50,x+28,y+53,x+17,y+50)
        g.rectangle("fill",x+49,y,5,5)
        g.polygon("fill",x-13,y+21,x-8,y+24,x-10,y+29)
    elseif kind == "orange" then
        for i = 0, 7 do
            g.circle("fill",x+10+(i%4)*7,y+36+math.floor(i/4)*9,1.6)
        end
        g.circle("fill",x+32,y+12,7)
        g.setColor(skin.body); g.circle("fill",x+32,y+12,4)
    elseif kind == "pear" then
        for i = 0, 8 do g.circle("fill",x+11+(i%3)*8,y+34+math.floor(i/3)*7,1) end
    elseif kind == "mango" then
        g.polygon("fill",x+6,y+35,x+14,y+33,x+31,y+47,x+28,y+53,x+16,y+48)
        g.ellipse("fill",x+29,y+13,5,8)
    elseif kind == "peach" then
        g.ellipse("fill",x+17,y+43,8,9)
        g.setColor(1,0.81,0.59); g.rectangle("fill",x+17,y+35,2,16)
        g.setColor(skin.accent); g.circle("fill",x+36,y+17,3)
    elseif kind == "strawberry" then
        -- Pale seeds across the torso and muzzle, clear of the eye and mouth.
        for i = 0, 8 do g.ellipse("fill",x+10+(i%3)*8,y+35+math.floor(i/3)*7,1.2,2) end
        for i = 0, 2 do g.ellipse("fill",x+27+i*5,y+15,1,2) end
    elseif kind == "kiwi" then
        g.ellipse("fill",x+19,y+42,11,10)
        g.setColor(0.83,0.93,0.51); g.ellipse("fill",x+19,y+42,8,8)
        g.setColor(0.98,0.95,0.76); g.ellipse("fill",x+19,y+42,3,5)
        g.setColor(skin.accent)
        for i = 0, 7 do
            local a = i*math.pi/4
            g.circle("fill",x+19+math.cos(a)*6,y+42+math.sin(a)*6,1)
        end
    elseif kind == "pineapple" then
        for i = 0, 3 do
            g.polygon("fill",x+7+i*6,y+34,x+9+i*6,y+34,x+28,y+53-i*4,x+26,y+53-i*4)
            g.polygon("fill",x+7+i*6,y+52,x+9+i*6,y+52,x+28,y+34+i*4,x+26,y+34+i*4)
        end
        g.setColor(0.22,0.49,0.19)
        g.polygon("fill",x+25,y,x+23,y-11,x+31,y-5,x+33,y-17,x+38,y-5,x+45,y-11,x+43,y)
    elseif kind == "cherry" then
        g.circle("fill",x+13,y+44,5); g.circle("fill",x+25,y+46,5)
        g.setColor(0.29,0.48,0.15)
        g.polygon("fill",x+12,y+40,x+18,y+33,x+21,y+33,x+25,y+42,x+23,y+43,x+19,y+36,x+14,y+42)
        g.setColor(1,0.77,0.73); g.circle("fill",x+12,y+43,1.5); g.circle("fill",x+24,y+45,1.5)
    elseif kind == "grape" then
        for row = 0, 2 do
            for col = 0, 2-row do
                g.circle("fill",x+12+col*7+row*3.5,y+36+row*7,3.4)
            end
        end
        g.circle("fill",x+30,y+12,3); g.circle("fill",x+36,y+15,3)
    elseif kind == "lemon" then
        g.ellipse("fill",x+19,y+42,11,9)
        g.setColor(1,0.98,0.71); g.ellipse("fill",x+19,y+42,8,6)
        g.setColor(skin.accent); g.circle("fill",x+19,y+42,1.5)
        for i = 0, 5 do
            local a = i*math.pi/3
            g.polygon("fill",x+19,y+42,x+19+math.cos(a)*8,y+42+math.sin(a)*6,
                x+19+math.cos(a+0.13)*8,y+42+math.sin(a+0.13)*6)
        end
    elseif kind == "coconut" then
        g.ellipse("fill",x+19,y+42,11,10)
        g.setColor(0.67,0.44,0.25); g.ellipse("fill",x+19,y+42,7,6)
        g.setColor(0.21,0.13,0.08)
        for i = 0, 2 do g.circle("fill",x+27+i*5,y+12+(i%2)*4,1.7) end
        for i = 0, 3 do g.rectangle("fill",x+8+i*6,y+34,1,5) end
    elseif kind == "dragonfruit" then
        g.ellipse("fill",x+19,y+42,11,10)
        g.setColor(0.16,0.12,0.17)
        for i = 0, 8 do g.circle("fill",x+12+(i%3)*7,y+36+math.floor(i/3)*6,0.9) end
        g.setColor(0.45,0.74,0.20)
        for i = 0, 2 do
            g.polygon("fill",x+25+i*5,y+5,x+29+i*5,y+7,x+26+i*5,y+13)
        end
    elseif kind == "blueberry" then
        g.circle("fill",x+19,y+42,10)
        g.setColor(0.13,0.18,0.39)
        for i = 0, 4 do
            local a = i*math.pi*2/5
            g.polygon("fill",x+19,y+42,x+19+math.cos(a)*6,y+42+math.sin(a)*6,
                x+19+math.cos(a+0.55)*3,y+42+math.sin(a+0.55)*3)
        end
        g.setColor(skin.accent); g.ellipse("fill",x+29,y+10,3,5)
    elseif kind == "raspberry" then
        for row = 0, 2 do
            for col = 0, 2 do
                g.circle("fill",x+12+col*7+(row%2)*2,y+36+row*6,3)
            end
        end
        g.setColor(skin.body)
        for row = 0, 2 do
            for col = 0, 2 do g.circle("fill",x+12+col*7+(row%2)*2,y+36+row*6,0.8) end
        end
    elseif kind == "pomegranate" then
        g.ellipse("fill",x+19,y+42,11,10)
        g.setColor(0.72,0.04,0.17)
        for i = 0, 8 do g.ellipse("fill",x+12+(i%3)*7,y+36+math.floor(i/3)*6,2,2.5) end
        g.setColor(skin.accent)
        g.polygon("fill",x+27,y,x+26,y-8,x+32,y-4,x+36,y-10,x+40,y-4,x+46,y-8,x+45,y)
    elseif kind == "avocado" then
        g.ellipse("fill",x+19,y+43,11,10); g.ellipse("fill",x+19,y+36,7,5)
        g.setColor(0.49,0.27,0.13); g.circle("fill",x+19,y+44,6)
        g.setColor(0.68,0.43,0.22); g.circle("fill",x+17,y+42,2)
    else -- glossy apple cheeks
        g.ellipse("fill",x+17,y+41,5,7)
        g.rectangle("fill",x+26,y+5,3,9)
    end
    g.setColor(0.38,0.25,0.12); g.rectangle("fill",x+33,y-8,4,9)
    g.setColor(0.22,0.49,0.19)
    g.polygon("fill",x+36,y-5,x+42,y-12,x+50,y-10,x+44,y-4)
end
