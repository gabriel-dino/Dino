-- Pirate costumes decorate the dinosaur without changing its movement or
-- collisions. Insignias occupy the space above hats, away from torso markings.
return function(x, y, skin)
    local g = love.graphics
    local dark, gold, ivory = {0.10,0.12,0.17}, {1,0.76,0.22}, {1,0.94,0.80}
    local function color(c) g.setColor(c) end
    color(skin.accent)
    if skin.pirate == 1 then -- captain's gold-edged tricorn and coat tails
        g.polygon("fill",x+17,y,x+21,y-12,x+35,y-5,x+53,y-12,x+59,y)
        color(dark); g.polygon("fill",x+23,y-1,x+25,y-8,x+35,y-2,x+50,y-8,x+53,y-1)
        color(skin.accent)
        g.polygon("fill",x+18,y+24,x+1,y+25,x-7,y+51,x+3,y+46,x+12,y+52)
        g.rectangle("fill",x+34,y+27,9,3)
    elseif skin.pirate == 2 then -- tied bandana and long scarf tails
        g.rectangle("fill",x+21,y-5,34,8)
        g.circle("fill",x+20,y,5)
        g.polygon("fill",x+20,y+2,x+2,y-9,x+4,y+2,x+18,y+7)
        g.polygon("fill",x+19,y+3,x+5,y+18,x+15,y+18,x+23,y+5)
        for j = 0, 2 do g.rectangle("fill",x+2+j*4,y+30,2,17) end
    elseif skin.pirate == 3 then -- bicorn and cutlass behind the back
        g.polygon("fill",x+17,y,x+20,y-10,x+28,y-5,x+43,y-5,x+56,y-10,x+59,y)
        color(dark); g.rectangle("fill",x+28,y-5,18,4)
        color(skin.accent)
        g.polygon("fill",x-15,y+15,x-10,y+14,x+12,y+47,x+8,y+50)
        color(gold); g.rectangle("fill",x+1,y+40,14,4)
        color(dark); g.rectangle("fill",x+9,y+46,4,9)
    elseif skin.pirate == 4 then -- sailor cap and coiled rope
        g.rectangle("fill",x+23,y-8,28,7,3,3)
        color({0.18,0.31,0.57}); g.rectangle("fill",x+19,y-2,37,4)
        color(skin.accent)
        for j = 0, 2 do g.rectangle("fill",x+23,y+17+j*4,12,2) end
        color({0.79,0.58,0.32})
        g.ellipse("line",x+2,y+26,10,13); g.ellipse("line",x+2,y+26,6,9)
        g.rectangle("fill",x-8,y+34,3,15)
    elseif skin.pirate == 5 then -- iron helmet and miniature tail cannon
        color(dark); g.rectangle("fill",x+20,y-3,37,5)
        g.rectangle("fill",x+25,y-12,26,10,4,4)
        color(skin.accent); g.rectangle("fill",x+29,y-9,18,3)
        color(dark); g.rectangle("fill",x-17,y+23,26,10,3,3)
        color(skin.accent); g.rectangle("fill",x-17,y+22,4,12)
        color({0.55,0.32,0.16}); g.circle("fill",x,y+38,7)
        color(gold); g.circle("fill",x,y+38,3)
    elseif skin.pirate == 6 then -- tall admiral hat and fringed epaulettes
        g.rectangle("fill",x+18,y-2,41,4)
        g.rectangle("fill",x+25,y-13,27,12)
        color(dark); g.rectangle("fill",x+29,y-9,19,5)
        color(skin.accent)
        g.rectangle("fill",x+12,y+24,10,4); g.rectangle("fill",x+34,y+27,12,4)
        for j = 0, 2 do
            g.rectangle("fill",x+12+j*4,y+28,2,7)
            g.rectangle("fill",x+35+j*4,y+31,2,6)
        end
        g.rectangle("fill",x+3,y+49,25,3)
    elseif skin.pirate == 7 then -- jeweled crown and treasure chest by the tail
        g.polygon("fill",x+22,y,x+22,y-12,x+30,y-5,x+37,y-13,x+44,y-5,x+52,y-12,x+52,y)
        color({0.28,0.81,0.80}); g.rectangle("fill",x+34,y-5,6,5)
        color({0.48,0.26,0.13}); g.rectangle("fill",x-13,y+21,24,22,3,3)
        color(gold); g.rectangle("fill",x-14,y+24,26,4)
        g.rectangle("fill",x-10,y+22,3,20); g.rectangle("fill",x+5,y+22,3,20)
        g.rectangle("fill",x-3,y+27,5,7)
    else -- kraken pirate with curled tentacles and a sea captain's hat
        g.polygon("fill",x+18,y,x+24,y-10,x+35,y-5,x+48,y-10,x+57,y)
        color(dark); g.rectangle("fill",x+27,y-4,19,3)
        for j = 0, 2 do
            local px, py = x-12+j*8,y+20+j*7
            color(skin.accent); g.rectangle("fill",px,py,5,18,2,2)
            g.rectangle("fill",px,py+14,12,5,2,2)
            color(dark); g.circle("fill",px+2,py+5,1.5)
        end
    end
    -- The eye patch and gold hoop keep every costume recognizably pirate.
    color(dark); g.rectangle("fill",x+24,y+7,29,2)
    g.rectangle("fill",x+41,y+4,10,10,2,2)
    color(gold); g.circle("line",x+25,y+19,3)

    color(skin.accent)
    if skin.insignia == 1 then -- Jolly Roger flag
        g.rectangle("fill",x+27,y-35,3,20)
        color(dark); g.rectangle("fill",x+30,y-34,19,13)
        color(ivory); g.rectangle("fill",x+36,y-31,7,5)
        g.rectangle("fill",x+38,y-26,3,3)
    elseif skin.insignia == 2 then -- skull and crossed bones
        g.line(x+26,y-18,x+46,y-29); g.line(x+26,y-29,x+46,y-18)
        g.rectangle("fill",x+29,y-33,14,11,3,3)
        g.rectangle("fill",x+33,y-23,6,5)
        color(dark); g.rectangle("fill",x+32,y-29,3,3); g.rectangle("fill",x+38,y-29,3,3)
    elseif skin.insignia == 3 then -- compass rose
        g.polygon("fill",x+36,y-35,x+40,y-27,x+49,y-24,x+40,y-21,
            x+36,y-14,x+32,y-21,x+23,y-24,x+32,y-27)
        color(dark); g.circle("fill",x+36,y-24,3)
    elseif skin.insignia == 4 then -- crossed cutlasses
        g.polygon("fill",x+26,y-34,x+30,y-34,x+46,y-16,x+42,y-16)
        g.polygon("fill",x+43,y-34,x+47,y-34,x+30,y-16,x+26,y-16)
        color(gold); g.rectangle("fill",x+23,y-21,10,3); g.rectangle("fill",x+40,y-21,10,3)
    else -- doubloon
        color(gold); g.circle("fill",x+36,y-25,10)
        color(dark); g.circle("line",x+36,y-25,7)
        g.rectangle("fill",x+35,y-30,3,10)
    end
    color(skin.accent)
end
