-- Dessert costumes leave the torso grid and base body colors visible.
return function(x, y, skin)
    local g = love.graphics
    local cream, chocolate = {1,0.95,0.82}, {0.31,0.15,0.09}
    local function color(c) g.setColor(c) end
    local function sprinkles(px, py)
        for j = 0, 5 do
            color(j % 2 == 0 and {1,0.27,0.48} or {0.24,0.83,0.86})
            g.rectangle("fill",px+j*4,py+(j%3)*3,3,2)
        end
    end
    g.setLineWidth(1)
    if skin.candy == 1 then -- scoops along the back, melted frosting
        for j = 0, 2 do
            color(j == 1 and cream or skin.accent)
            g.circle("fill",x+13-j*9,y+20+j*7,7)
        end
        color(cream); g.rectangle("fill",x+23,y,30,4)
        for j = 0, 3 do g.rectangle("fill",x+24+j*8,y+2,4,5+j%2*3) end
        sprinkles(x+25,y+1)
    elseif skin.candy == 2 then -- segmented chocolate bar on the head
        color(chocolate); g.rectangle("fill",x+23,y+1,29,19,2,2)
        color(skin.body)
        for row = 0, 1 do
            for col = 0, 2 do g.rectangle("fill",x+25+col*9,y+3+row*8,7,6) end
        end
        color({0.91,0.72,0.26}); g.polygon("fill",x-12,y+22,x+4,y+34,x+1,y+42,x-8,y+38)
    elseif skin.candy == 3 then -- gummy bear ears and glossy candy tail
        color(skin.body); g.circle("fill",x+26,y-2,6); g.circle("fill",x+48,y-2,6)
        g.circle("fill",x-5,y+30,10)
        color(cream); g.ellipse("fill",x-8,y+26,2,4)
        g.rectangle("fill",x+26,y+4,3,10)
    elseif skin.candy == 4 then -- wrapped candies on the back
        for j = 0, 2 do
            local px, py = x+12-j*9,y+21+j*7
            color(cream)
            g.polygon("fill",px-4,py,px-11,py-6,px-10,py+6)
            g.polygon("fill",px+4,py,px+10,py-6,px+11,py+6)
            color(skin.accent); g.circle("fill",px,py,5)
            color(skin.body); g.rectangle("fill",px-1,py-4,2,8)
        end
    elseif skin.candy == 5 then -- frosted donut ring behind the head
        color({0.82,0.48,0.19}); g.circle("fill",x+5,y+22,14)
        color(skin.accent); g.circle("fill",x+5,y+22,11)
        color(skin.body); g.circle("fill",x+5,y+22,5)
        sprinkles(x-6,y+14)
        color(skin.accent); g.rectangle("fill",x+23,y+1,30,4)
    elseif skin.candy == 6 then -- cupcake wrapper and whipped frosting
        color(skin.accent); g.rectangle("fill",x+4,y+50,29,6)
        color({0.92,0.40,0.58})
        for j = 0, 5 do g.rectangle("fill",x+5+j*5,y+50,2,6) end
        color(cream)
        for j = 0, 2 do g.circle("fill",x+12-j*8,y+19+j*7,7) end
        color({0.92,0.15,0.23}); g.circle("fill",x+14,y+10,4)
    elseif skin.candy == 7 then -- pillowy marshmallows along the spine
        for j = 0, 2 do
            color(cream); g.rectangle("fill",x+6-j*8,y+14+j*8,11,13,4,4)
            color({1,0.63,0.76}); g.rectangle("fill",x+7-j*8,y+23+j*8,9,3,2,2)
        end
        color({1,0.63,0.76}); g.ellipse("fill",x+27,y+17,4,2)
    else -- chocolate chip cookie plates
        for j = 0, 2 do
            local px, py = x+11-j*8,y+18+j*8
            color({0.88,0.62,0.30}); g.circle("fill",px,py,8)
            color(chocolate); g.rectangle("fill",px-4,py-4,3,3)
            g.rectangle("fill",px+2,py,3,3); g.rectangle("fill",px-3,py+3,2,2)
        end
    end
    -- Five separate toppings distinguish head silhouettes without hiding eyes.
    color(cream)
    if skin.topping == 1 then -- swirled lollipop
        g.rectangle("fill",x+36,y-21,3,18)
        color({1,0.25,0.48}); g.circle("fill",x+37,y-26,10)
        color(cream); g.arc("line","open",x+37,y-26,7,0,math.pi*1.6)
        g.arc("line","open",x+37,y-26,3,math.pi,math.pi*2.6)
    elseif skin.topping == 2 then -- candy cane
        g.rectangle("fill",x+34,y-28,5,24)
        g.arc("line","open",x+42,y-27,6,math.pi,math.pi*2)
        color({0.95,0.19,0.28})
        for j = 0, 3 do g.rectangle("fill",x+34,y-26+j*6,5,3) end
    elseif skin.topping == 3 then -- cherry pair
        color({0.30,0.57,0.21}); g.line(x+37,y-26,x+30,y-14,x+43,y-15,x+37,y-26)
        color({0.91,0.12,0.25}); g.circle("fill",x+29,y-13,6); g.circle("fill",x+44,y-14,6)
    elseif skin.topping == 4 then -- ice cream cone
        color({0.85,0.57,0.27}); g.polygon("fill",x+29,y-18,x+45,y-18,x+37,y-3)
        color(cream); g.circle("fill",x+37,y-24,10)
        sprinkles(x+26,y-29)
    else -- wrapped bonbon
        color({0.31,0.80,0.84})
        g.polygon("fill",x+28,y-19,x+20,y-27,x+20,y-10)
        g.polygon("fill",x+46,y-19,x+54,y-27,x+54,y-10)
        color({1,0.37,0.64}); g.ellipse("fill",x+37,y-19,10,8)
        color(cream); g.rectangle("fill",x+35,y-26,4,14)
    end
    color(skin.accent)
end
