-- Costumes decorate the existing dinosaur: head, back, tail, arms and feet.
-- The torso remains clear for the ten markings; body colors stay visible.
return function(x, y, skin)
    local g = love.graphics
    local dark, bone = {0.10, 0.08, 0.16}, {1, 0.93, 0.75}
    local function color(c) g.setColor(c) end
    color(skin.accent)
    if skin.halloween == 1 then -- jack-o'-lantern head with dinosaur muzzle
        g.rectangle("fill", x+22,y,32,26,5,5)
        color({0.63,0.28,0.08})
        for j = 0, 2 do g.rectangle("fill", x+26+j*10,y+2,2,21) end
        color({0.36,0.65,0.20}); g.rectangle("fill", x+34,y-9,6,10)
        color(dark)
        g.polygon("fill", x+42,y+5,x+49,y+12,x+40,y+12)
        g.rectangle("fill", x+36,y+20,18,4)
        color(bone); g.rectangle("fill", x+43,y+20,3,3)
    elseif skin.halloween == 2 then -- ghost hood and floating tail wisps
        g.rectangle("fill", x+20,y-6,35,29,8,8)
        for j = 0, 2 do
            g.polygon("fill", x+20+j*11,y+18,x+24+j*11,y+30,x+31+j*11,y+18)
            g.circle("fill", x-9+j*7,y+25+j*6,4)
        end
        color(dark); g.rectangle("fill", x+42,y+5,6,9)
        g.rectangle("fill", x+45,y+20,9,4)
    elseif skin.halloween == 3 then -- skull, spine and bony tail
        color(bone); g.rectangle("fill", x+24,y+1,30,24,4,4)
        for j = 0, 3 do g.rectangle("fill", x+15-j*7,y+21+j*5,5,6) end
        g.rectangle("fill", x+35,y+33,14,3)
        color(dark); g.rectangle("fill", x+40,y+5,9,10)
        for j = 0, 3 do g.rectangle("fill", x+36+j*5,y+21,2,4) end
    elseif skin.halloween == 4 then -- high collar, cape and fangs
        color({0.44,0.08,0.17})
        g.polygon("fill", x+20,y+18,x+1,y+12,x-11,y+51,x+3,y+48,x+13,y+54,x+17,y+27)
        color(skin.accent)
        g.polygon("fill", x+22,y+25,x+10,y+9,x+25,y+15)
        g.rectangle("fill", x+39,y+7,10,3)
        color(bone)
        for j = 0, 1 do g.polygon("fill", x+41+j*8,y+24,x+43+j*8,y+31,x+45+j*8,y+24) end
    elseif skin.halloween == 5 then -- crooked witch hat, scarf and broom tail
        g.rectangle("fill", x+18,y-4,41,5)
        g.polygon("fill", x+24,y-4,x+30,y-14,x+48,y-11,x+51,y-4)
        color({1,0.62,0.12}); g.rectangle("fill", x+35,y-7,6,4)
        color(skin.accent); g.rectangle("fill", x+17,y+25,25,5)
        g.rectangle("fill", x+7,y+27,7,14)
        color({0.76,0.51,0.21})
        g.rectangle("fill", x-16,y+34,27,3)
        for j = 0, 3 do g.rectangle("fill", x-18,y+28+j*4,10,2) end
    elseif skin.halloween == 6 then -- head wraps and loose bandage tails
        for j = 0, 3 do g.rectangle("fill", x+22,y+j*7,32,4) end
        g.polygon("fill", x+17,y+24,x-10,y+17,x-14,y+21,x+16,y+29)
        g.polygon("fill", x+9,y+30,x-12,y+40,x-9,y+45,x+13,y+34)
        color(dark); g.rectangle("fill", x+38,y+6,14,8)
        color({1,0.64,0.16}); g.rectangle("fill", x+44,y+8,4,4)
    elseif skin.halloween == 7 then -- bat ears and scalloped wing
        g.polygon("fill", x+23,y,x+20,y-13,x+32,y-2,x+41,y-13,x+49,y)
        g.polygon("fill", x+18,y+23,x-13,y+8,x-14,y+27,x-5,y+23,
            x-5,y+35,x+4,y+31,x+6,y+45,x+17,y+36)
        color(dark); g.line(x+15,y+25,x-10,y+13)
        g.line(x+15,y+25,x-3,y+30); g.line(x+15,y+25,x+7,y+39)
        color(bone); g.polygon("fill", x+47,y+24,x+49,y+29,x+51,y+24)
    else -- web sail, spider and eight little legs on the head
        g.polygon("fill", x+17,y+23,x-13,y+9,x-13,y+42,x+10,y+48)
        color(dark)
        g.line(x+15,y+24,x-11,y+12); g.line(x+15,y+24,x-11,y+39)
        g.line(x+15,y+24,x+8,y+45); g.line(x-7,y+15,x-7,y+39,x+7,y+42)
        g.line(x+2,y+20,x+2,y+33,x+11,y+36)
        color(skin.accent); g.circle("fill", x+30,y+10,5)
        for j = 0, 3 do
            g.line(x+28,y+7+j*2,x+22,y+3+j*5)
            g.line(x+33,y+7+j*2,x+39,y+3+j*5)
        end
    end

    -- Five distinct Halloween charms above the costume. No charm covers eyes,
    -- torso markings or costume details, so every combination stays visible.
    color(skin.accent)
    if skin.charm == 1 then -- crescent moon
        g.circle("fill", x+36,y-24,8)
        color(skin.body); g.circle("fill", x+40,y-27,6)
    elseif skin.charm == 2 then -- candle
        g.rectangle("fill", x+31,y-27,10,11)
        color({1,0.58,0.12}); g.polygon("fill", x+33,y-29,x+36,y-35,x+39,y-29)
    elseif skin.charm == 3 then -- small bat
        g.polygon("fill", x+36,y-20,x+22,y-30,x+24,y-19,x+31,y-21,
            x+36,y-16,x+41,y-21,x+48,y-19,x+50,y-30)
    elseif skin.charm == 4 then -- tiny pumpkin
        color({1,0.52,0.10}); g.ellipse("fill", x+36,y-23,11,7)
        color({0.35,0.68,0.18}); g.rectangle("fill", x+34,y-34,4,5)
        color(dark); g.rectangle("fill", x+30,y-25,3,3); g.rectangle("fill", x+39,y-25,3,3)
    else -- paired curved horns
        g.polygon("fill", x+24,y-17,x+22,y-32,x+29,y-25,x+33,y-17)
        g.polygon("fill", x+41,y-17,x+46,y-32,x+48,y-23,x+47,y-17)
    end
    color(skin.accent)
end
