local C = {paper = {0.96,0.94,0.87}, orange = {0.88,0.39,0.22}}
local function color(c) love.graphics.setColor(c) end
local drawHalloween = require("halloween")
local drawOcean = require("ocean")
local drawPirate = require("pirate")
local drawRobot = require("robot")
local drawSponge = require("sponge")
local drawCandy = require("candy")
local drawFruit = require("fruit")
local drawHero = require("heroes")
return function(x, y, skin, stride)
    local g = love.graphics
    stride = stride or 0
    color(skin.body)
    g.rectangle("fill", x + 22, y, 32, 27)
    g.rectangle("fill", x + 17, y + 21, 25, 27)
    g.rectangle("fill", x + 4, y + 31, 29, 23)
    g.polygon("fill", x + 6, y + 35, x - 13, y + 21, x - 9, y + 43, x + 10, y + 51)
    g.rectangle("fill", x + 35, y + 33, 14, 5)
    g.rectangle("fill", x + 44, y + 33, 5, 10)
    g.rectangle("fill", x + 10, y + 51, 7, stride == 0 and 15 or 9)
    g.rectangle("fill", x + 26, y + 49, 7, stride == 0 and 10 or 17)
    g.rectangle("fill", x + 10, y + (stride == 0 and 62 or 56), 14, 4)
    g.rectangle("fill", x + 26, y + (stride == 0 and 55 or 62), 14, 4)
    color(C.paper); g.rectangle("fill", x + 43, y + 7, 5, 5)
    g.rectangle("fill", x + 39, y + 22, 15, 3)
    color(skin.accent)
    if skin.special then
        -- Anatomical details stay outside the torso markings and preserve the
        -- dinosaur silhouette. These cosmetics never change the hitbox.
        if skin.special == 1 then -- faceted crystal plates
            for j = 0, 3 do
                local px, py = x + 13 - j * 6, y + 20 + j * 6
                g.polygon("fill", px,py+8, px-8,py-10, px+3,py-4, px+7,py+7)
            end
        elseif skin.special == 2 then -- molten back and tail fins
            for j = 0, 3 do
                local px, py = x + 16 - j * 7, y + 22 + j * 5
                g.polygon("fill", px,py+8, px-2,py-13, px-10,py+5)
                color({1,0.87,0.35}); g.rectangle("fill", px-4,py,3,6)
                color(skin.accent)
            end
        elseif skin.special == 3 then -- starry frill and orbital tail
            g.circle("line", x-3,y+29,13)
            for j = 0, 3 do
                local px, py = x + 12 - j*6, y + 15 + j*6
                g.polygon("fill", px,py-5, px+2,py-1, px+6,py+1,
                    px+2,py+3, px,py+7, px-2,py+3, px-6,py+1, px-2,py-1)
            end
        elseif skin.special == 4 then -- lightning-shaped dorsal sail
            g.polygon("fill", x+20,y+19, x+3,y+9, x+8,y+25,
                x-9,y+20, x-2,y+34, x-16,y+34, x+4,y+45, x+1,y+33, x+15,y+35)
        elseif skin.special == 5 then -- leafy plates
            for j = 0, 3 do
                local px, py = x + 16 - j*7, y + 19 + j*6
                g.ellipse("fill", px-3,py,6,10)
                color({0.17,0.42,0.22}); g.rectangle("fill", px-4,py-5,2,12)
                color(skin.accent)
            end
        elseif skin.special == 6 then -- three ribbons along the back
            for j = 0, 2 do
                color(j == 1 and {0.85,0.62,1} or skin.accent)
                g.polygon("fill", x+18-j*4,y+20, x+9-j*6,y+7+j*5,
                    x-14-j*2,y+17+j*5, x-8-j*2,y+22+j*5, x+7-j*4,y+17+j*5)
            end
        elseif skin.special == 7 then -- exposed bony dorsal armor
            for j = 0, 3 do
                local px, py = x + 16-j*7, y+22+j*5
                g.circle("fill", px,py,5)
                g.rectangle("fill", px-9,py-2,10,4)
            end
            g.rectangle("fill", x+29,y+9,4,12)
        else -- sun discs and triangular plates
            for j = 0, 3 do
                local px, py = x+13-j*7,y+18+j*6
                g.circle("fill", px,py,6)
                g.polygon("fill", px-6,py, px-12,py-8, px-9,py+7)
                color({1,0.97,0.69}); g.circle("fill", px,py,2)
                color(skin.accent)
            end
        end
        color(skin.accent)
        -- Five crests have different silhouettes; all are clear of the eye.
        if skin.crest == 1 then
            g.polygon("fill", x+24,y, x+23,y-17, x+31,y-4, x+37,y-23, x+43,y)
        elseif skin.crest == 2 then
            g.polygon("fill", x+25,y, x+26,y-18, x+49,y-18, x+51,y)
            color(skin.body); g.rectangle("fill", x+32,y-14,11,7)
        elseif skin.crest == 3 then
            g.polygon("fill", x+24,y, x+17,y-21, x+33,y-10, x+41,y-25, x+49,y)
        elseif skin.crest == 4 then
            for j = 0, 2 do g.circle("fill", x+27+j*10,y-6,7-j) end
        else
            g.polygon("fill", x+23,y, x+25,y-9, x+48,y-26, x+43,y-8, x+51,y)
        end
        color(skin.accent)
    end
    if skin.halloween then drawHalloween(x, y, skin) end
    if skin.ocean then drawOcean(x, y, skin) end
    if skin.pirate then drawPirate(x, y, skin) end
    if skin.robot then drawRobot(x, y, skin) end
    if skin.sponge then drawSponge(x, y, skin) end
    if skin.candy then drawCandy(x, y, skin) end
    if skin.fruit then drawFruit(x, y, skin) end
    if skin.hero then drawHero(x, y, skin) end
    if skin.pattern then
        -- Ten distinct masks on the torso, never covered by headpieces.
        local masks = {
            {1,1,1,0,0,0,0,0,0}, {0,0,0,1,1,1,0,0,0},
            {0,0,0,0,0,0,1,1,1}, {1,0,0,1,0,0,1,0,0},
            {0,1,0,0,1,0,0,1,0}, {0,0,1,0,0,1,0,0,1},
            {1,0,0,0,1,0,0,0,1}, {0,0,1,0,1,0,1,0,0},
            {1,0,1,0,1,0,1,0,1}, {0,1,0,1,0,1,0,1,0},
        }
        for cell, on in ipairs(masks[skin.pattern]) do
            if on == 1 then g.rectangle("fill", x + 10 + (cell-1)%3*7, y + 33 + math.floor((cell-1)/3)*6, 5, 4) end
        end
        if skin.hat then
            local shape = math.floor((skin.hat - 1) / 5)
            local badges = (skin.hat - 1) % 5 + 1
            color({0.12, 0.15, 0.23})
            g.rectangle("fill", x + 20, y - 7, 36, 7)
            if shape == 0 then -- cap
                g.rectangle("fill", x + 24, y - 16, 25, 10)
                g.rectangle("fill", x + 49, y - 7, 12, 5)
            elseif shape == 1 then -- crown
                for j = 0, 2 do g.polygon("fill", x+20+j*12,y-7,x+20+j*12,y-24,x+32+j*12,y-7) end
            elseif shape == 2 then -- helmet and side guards
                g.rectangle("fill", x + 20, y - 18, 36, 12, 7, 7)
                g.rectangle("fill", x + 17, y - 4, 6, 19)
                g.rectangle("fill", x + 54, y - 4, 6, 19)
            elseif shape == 3 then -- antenna
                g.rectangle("fill", x+35,y-24,4,18)
                g.circle("fill", x+37,y-26,6)
            else -- pointed wizard hat
                g.polygon("fill", x+22,y-7,x+36,y-32,x+53,y-7)
            end
            color(skin.accent)
            for j = 0, badges - 1 do g.rectangle("fill", x+22+j*6,y-5,4,3) end
        end
    end
    if skin.name == "Ember" then
        for i = 0, 2 do
            g.polygon("fill", x + 14 - i * 5, y + 22 + i * 9,
                x + 5 - i * 5, y + 16 + i * 9, x + 11 - i * 5, y + 31 + i * 9)
        end
    elseif skin.name == "Frost" then
        g.polygon("fill", x + 24, y, x + 27, y - 10, x + 32, y - 3,
            x + 38, y - 13, x + 43, y - 3, x + 49, y - 8, x + 51, y)
        g.rectangle("fill", x + 19, y + 35, 7, 12)
    elseif skin.name == "Neon" then
        g.rectangle("fill", x + 31, y + 5, 23, 10)
        g.rectangle("fill", x + 9, y + 34, 19, 5)
        g.rectangle("fill", x + 9, y + 43, 13, 4)
    elseif skin.name == "Explorer" then
        g.rectangle("fill", x + 16, y - 5, 43, 7)
        g.rectangle("fill", x + 26, y - 15, 24, 11)
        color(C.orange); g.rectangle("fill", x + 17, y + 25, 25, 6)
        g.rectangle("fill", x + 14, y + 29, 7, 15)
    end
end
