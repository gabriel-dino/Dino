-- Cartoon costumes drawn in native geometry; torso markings stay uncovered.
return function(x, y, skin)
    local g = love.graphics
    local ink, white = {0.22,0.19,0.12}, {1,1,0.96}
    local function color(c) g.setColor(c) end
    local function eye(px, py, radius)
        color(white); g.circle("fill",px,py,radius)
        color(ink); g.circle("line",px,py,radius)
        color({0.23,0.65,0.94}); g.circle("fill",px+1,py,2.5)
        color(ink); g.circle("fill",px+2,py,1.5)
    end
    g.setLineWidth(1)
    color(white); g.rectangle("fill",x+17,y+28,25,4)
    color({0.49,0.29,0.13}); g.rectangle("fill",x+5,y+50,28,5)
    if skin.sponge == 1 then
        color({0.63,0.52,0.10})
        for j = 0, 3 do g.ellipse("fill",x+25+j*8,y+2+(j%2)*16,2,3) end
        color({0.94,0.22,0.18}); g.polygon("fill",x+33,y+28,x+30,y+32,x+35,y+32)
    elseif skin.sponge == 2 then
        color({0.56,0.89,0.27}); g.rectangle("fill",x+5,y+50,28,6)
        color({0.65,0.30,0.77}); g.circle("fill",x+10,y+52,3); g.circle("fill",x+27,y+53,3)
        color(skin.body); g.polygon("fill",x+23,y,x+37,y-14,x+49,y)
    elseif skin.sponge == 3 then
        color(skin.body); g.ellipse("fill",x+52,y+17,5,9)
        color({0.58,0.34,0.17}); g.rectangle("fill",x+32,y+28,10,4)
    elseif skin.sponge == 4 then
        color(white); g.circle("line",x+38,y+12,23)
        g.rectangle("fill",x+20,y+26,30,4)
        color({1,0.48,0.70}); g.circle("fill",x+18,y-6,5)
        color({1,0.86,0.23}); g.circle("fill",x+18,y-6,2)
    elseif skin.sponge == 5 then
        color(skin.body)
        g.circle("fill",x-8,y+22,8); g.circle("fill",x+50,y+35,7)
        color(ink); g.line(x-9,y+16,x-7,y+23,x-2,y+18)
        color({0.32,0.55,0.88}); g.rectangle("fill",x+5,y+50,28,5)
    elseif skin.sponge == 6 then
        color(ink); g.line(x+27,y,x+24,y-12); g.line(x+44,y,x+48,y-12)
    elseif skin.sponge == 7 then
        color({0.97,0.57,0.68}); g.circle("fill",x-4,y+24,14)
        color({0.62,0.28,0.55}); g.circle("line",x-4,y+24,10)
        g.arc("line","open",x-4,y+24,5,0,math.pi*1.7)
    else
        color({1,0.65,0.88}); g.ellipse("fill",x-5,y+20,13,8)
        for j = 0, 2 do g.line(x-13+j*7,y+25,x-16+j*7,y+34,x-12+j*7,y+39) end
    end
    if skin.sponge == 6 then
        eye(x+40,y+10,9)
        color({0.83,0.12,0.11}); g.circle("fill",x+42,y+10,3)
    else
        eye(x+32,y+8,6); eye(x+46,y+8,6)
    end
    color(ink); g.arc("line","open",x+40,y+15,9,0,math.pi)
    color(white); g.rectangle("fill",x+37,y+21,4,5); g.rectangle("fill",x+42,y+21,4,5)

    -- Five separated souvenirs, above the face and outside the pattern mask.
    color(ink)
    if skin.souvenir == 1 then
        g.rectangle("fill",x+34,y-23,3,18)
        color({0.70,0.77,0.81}); g.rectangle("fill",x+29,y-33,13,12,2,2)
        color(ink); g.line(x+33,y-30,x+33,y-25); g.line(x+38,y-30,x+38,y-25)
    elseif skin.souvenir == 2 then
        g.line(x+35,y-6,x+35,y-22)
        color({0.36,0.70,0.87}); g.ellipse("line",x+35,y-29,12,7)
        g.line(x+25,y-30,x+35,y-23,x+45,y-30)
    elseif skin.souvenir == 3 then
        color({1,0.68,0.17}); g.ellipse("fill",x+36,y-18,9,11)
        color(ink); g.line(x+30,y-23,x+42,y-13); g.line(x+30,y-13,x+42,y-23)
        color({0.25,0.65,0.27}); g.polygon("fill",x+36,y-26,x+26,y-36,x+35,y-31,x+39,y-38,x+42,y-29)
    elseif skin.souvenir == 4 then
        color({0.35,0.76,0.95}); g.circle("line",x+36,y-23,12)
        color(white); g.arc("line","open",x+36,y-23,9,3.4,4.7)
    else
        color(white); g.rectangle("fill",x+24,y-16,26,10)
        g.circle("fill",x+28,y-20,7); g.circle("fill",x+38,y-24,8); g.circle("fill",x+47,y-20,7)
        color({0.90,0.24,0.19}); g.rectangle("fill",x+24,y-9,26,3)
    end
    color(skin.accent)
end
