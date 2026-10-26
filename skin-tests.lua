-- Run inside LÖVE; checks actual rendered pixels, not just IDs or names.
return function()
    local skins, draw = require("skins"), require("dino")
    local I18n = require("i18n")
    local font = love.graphics.newFont("assets/fonts/NotoSans-Regular.ttf", 15)
    local chinese = love.graphics.newFont("assets/fonts/NotoSansSC-Regular.otf", 15)
    font:setFallbacks(chinese)
    for _, language in ipairs(I18n.languages) do
        assert(font:hasGlyphs(language.name), "Missing language-name glyph: " .. language.code)
        for key, text in pairs(I18n.translations[language.code]) do
            assert(font:hasGlyphs(text), "Missing glyph: " .. language.code .. " / " .. key)
        end
    end
    font:release(); chinese:release()
    assert(#skins == 52399, "Expected 52374 existing + 23 fruit skins + 2 heroes")
    local names, images = {}, {}
    local canvas = love.graphics.newCanvas(100, 120)
    love.graphics.push("all")
    for id, skin in ipairs(skins) do
        assert(not names[skin.name], "Duplicate name: " .. skin.name)
        names[skin.name] = true
        love.graphics.setCanvas(canvas)
        love.graphics.origin()
        love.graphics.clear(0, 0, 0, 0)
        draw(20, 40, skin, 0)
        love.graphics.setCanvas()
        local pixels = canvas:newImageData()
        local hash = love.data.hash("sha256", pixels:getString())
        assert(not images[hash], "Identical rendered skins: " .. id .. " and " .. tostring(images[hash]))
        images[hash] = id
        pixels:release()
    end
    -- The new decorations must retain every pixel of the shared T-rex body in
    -- both strides: head, jaw, tail, short arms, legs and feet remain intact.
    for stride = 0, 1 do
        local function render(skin)
            love.graphics.setCanvas(canvas); love.graphics.origin(); love.graphics.clear(0,0,0,0)
            draw(20,40,skin,stride); love.graphics.setCanvas()
            return canvas:newImageData()
        end
        local base = render(skins[1])
        for id = 52388, #skins do
            local fruit = render(skins[id])
            for y = 0, 119 do
                for x = 0, 99 do
                    local _, _, _, a = base:getPixel(x,y)
                    local _, _, _, b = fruit:getPixel(x,y)
                    assert(a == 0 or b > 0, "Missing T-rex body pixel: " .. id)
                end
            end
            fruit:release()
        end
        base:release()
    end
    love.graphics.pop()
    canvas:release()
    print("SKINS_OK: 52399 distinct names/images; ten languages have complete glyphs; new fruits preserve the T-rex in both strides")
end
