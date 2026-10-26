local Game = require("game")
local Progress = require("progress")
local progress, saveTimer, dirty, notice, noticeTime = nil, 0, false, "", 0
local game, fonts, best, muted, sounds
local skins = require("skins")
local drawDino = require("dino")
local Search = require("skin-search")
local utf8 = require("utf8")
local I18n = require("i18n")
local t = I18n.t
local languageMenu = false
local catalog, page, query = false, 1, ""
local searchFocused = false
local openingCatalog = false
local results = Search.find(skins, query)
local shop = false
local perPage = 20
local pageCount = math.ceil(#skins / perPage)
local selectedSkin = 1
local mobile = false
local touches = {}
local W, H, ground = 1100, 680, 478
local C = {ink = {0.16, 0.23, 0.20}, paper = {0.96, 0.94, 0.87},
    green = {0.22, 0.38, 0.28}, pale = {0.86, 0.87, 0.77}, orange = {0.88, 0.39, 0.22}}
local function color(c, a) love.graphics.setColor(c[1], c[2], c[3], a or 1) end
local function label(text, font, x, y, c, maxWidth)
    text = t(text)
    color(c or C.ink); love.graphics.setFont(fonts[font])
    local scale = maxWidth and math.min(1, maxWidth / math.max(1, fonts[font]:getWidth(text))) or 1
    love.graphics.print(text, x, y, 0, scale, scale)
end
local function center(text, font, y, c, maxWidth)
    text = t(text)
    local scale = math.min(1, (maxWidth or 980) / math.max(1, fonts[font]:getWidth(text)))
    color(c or C.ink); love.graphics.setFont(fonts[font])
    love.graphics.push(); love.graphics.translate(W/2, y); love.graphics.scale(scale)
    love.graphics.printf(text, -W/2/scale, 0, W/scale, "center"); love.graphics.pop()
end
local function tone(freq, duration)
    local data = love.sound.newSoundData(math.floor(22050 * duration), 22050, 16, 1)
    for i = 0, data:getSampleCount() - 1 do
        local t = i / 22050
        data:setSample(i, math.sin(t * freq * math.pi * 2) * 0.12 * (1 - t / duration))
    end
    return love.audio.newSource(data, "static")
end
local function play(name)
    if not muted and sounds[name] then sounds[name]:stop(); sounds[name]:play() end
end
local function saveProgress()
    if dirty then
        local ok = love.filesystem.write("progress.txt", progress:serialize())
        if ok then dirty, saveTimer = false, 0 end
    end
end
function love.quit() saveProgress() end
function love.load()
    mobile = love.system and love.system.getOS() == "Android" or false
    love.graphics.setDefaultFilter("nearest", "nearest")
    I18n.setLanguage(love.filesystem.read("language.txt"))
    fonts = {}
    for key, size in pairs({tiny = 12, small = 15, medium = 22, big = 48, score = 30}) do
        fonts[key] = love.graphics.newFont("assets/fonts/NotoSans-Regular.ttf", size)
        local chinese = love.graphics.newFont("assets/fonts/NotoSansSC-Regular.otf", size)
        chinese:setFilter("linear", "linear")
        fonts[key]:setFallbacks(chinese)
    end
    for _, font in pairs(fonts) do font:setFilter("linear", "linear") end
    game, muted, sounds = Game.new(love.math.random), false, {}
    local savedProgress = love.filesystem.read("progress.txt")
    progress = Progress.new(savedProgress)
    game.upgrades = progress.upgrades
    game:reset()
    local savedRecord = love.filesystem.read("record.txt")
    best = math.max(0, tonumber(savedRecord) or 0)
    local savedSkin = love.filesystem.read("skin.txt")
    selectedSkin = 1
    for i, skin in ipairs(skins) do
        if savedSkin == skin.name and progress:ownsSkin(skin) then selectedSkin = i end
    end
    local ok, result = pcall(function() return {jump = tone(540, 0.09), dead = tone(110, 0.25), point = tone(880, 0.12), coin = tone(1150, 0.06), mission = tone(1450, 0.25)} end)
    if ok then sounds = result end
end
local function jump()
    if game:jump() then play("jump") end
end
local function selectSkin(index)
    local skin = skins[index]
    if not progress:ownsSkin(skin) then
        local ok, reason = progress:buyHero(skin.hero)
        if not ok then notice, noticeTime = t(reason), 4; return end
        dirty = true
        saveProgress()
        notice, noticeTime = t("Unlocked: %s", skin.name), 4
        play("mission")
    end
    selectedSkin = index
    love.filesystem.write("skin.txt", skins[index].name)
end
local function focusSearch(focused)
    searchFocused = focused
    love.keyboard.setTextInput(focused)
end
local function filterSkins()
    results = Search.find(skins, query)
    pageCount = math.max(1, math.ceil(#results / perPage))
    page = 1
end
local function closeCatalog()
    catalog = false
    focusSearch(false)
end
local function randomResult()
    local available = {}
    for slot, id in ipairs(results) do
        if progress:ownsSkin(skins[id]) then available[#available+1] = slot end
    end
    if #available == 0 then return end
    local slot = available[love.math.random(#available)]
    selectSkin(results[slot])
    page = math.floor((slot-1)/perPage)+1
end
local function buyUpgrade(index)
    local def = Progress.upgrades[index]
    local ok, reason = progress:buy(def.key)
    if ok then
        if def.key == "shield" then game.shields = game.shields + 1 end
        dirty = true
        saveProgress()
        notice = t("%s upgraded for ALL dinos!", t(def.title))
        play("mission")
    else notice = t(reason) end
    noticeTime = 4
end
local function toggleLanguages()
    languageMenu = not languageMenu
    focusSearch(false)
    if languageMenu and game.state == "running" then game:pause() end
end
-- Shared geometry keeps all ten language buttons within the desktop/mobile canvas.
local function languageButton(index)
    return 130 + ((index-1)%2)*440, 154 + math.floor((index-1)/2)*82, 400, 68
end
local function chooseLanguage(index)
    local language = I18n.languages[index]
    if not language then return end
    I18n.setLanguage(language.code)
    love.filesystem.write("language.txt", language.code)
    noticeTime = 0
    if catalog then filterSkins() end
    languageMenu = false
end
function love.keypressed(key, scancode, repeated)
    if key == "acback" then key = "escape" end
    if languageMenu then
        if key == "escape" or key == "l" then toggleLanguages()
        else chooseLanguage(key == "0" and 10 or tonumber(key)) end
        return
    end
    if key == "l" and not searchFocused then toggleLanguages(); return end
    if catalog then
        if key == "escape" or (key == "c" and not searchFocused) then closeCatalog()
        elseif key == "tab" then focusSearch(not searchFocused)
        elseif key == "left" or key == "pageup" then page = math.max(1, page - 1)
        elseif key == "right" or key == "pagedown" then page = math.min(pageCount, page + 1)
        elseif key == "home" then page = 1
        elseif key == "end" then page = pageCount
        elseif key == "backspace" and searchFocused then
            local last = utf8.offset(query, -1)
            if last then query = query:sub(1, last-1); filterSkins() end
        elseif key == "delete" and searchFocused then query = ""; filterSkins()
        elseif key == "return" or key == "kpenter" then
            local id = results[(page-1)*perPage + 1]
            if id then selectSkin(id) end
        elseif key == "r" and not searchFocused then randomResult()
        end
        return
    end
    if repeated then return end
    if key == "u" or (shop and key == "escape") then
        shop = not shop
        catalog = false
        love.keyboard.setTextInput(false)
        if shop and game.state == "running" then game:pause() end
        return
    end
    if shop then
        local index = tonumber(key)
        if index and Progress.upgrades[index] then buyUpgrade(index) end
        return
    end
    if key == "c" then
        catalog = true
        openingCatalog = true
        query = ""
        filterSkins()
        page = math.floor((selectedSkin - 1) / perPage) + 1
        if game.state == "running" then game:pause() end
        focusSearch(not mobile)
        return
    end
    local number = tonumber(key)
    if number and number >= 1 and number <= 5 then selectSkin(number)
    elseif key == "space" or key == "up" or key == "w" then jump()
    elseif key == "down" or key == "s" then game:duck(true)
    elseif key == "p" or key == "escape" then game:pause()
    elseif key == "r" then saveProgress(); game:reset()
    elseif key == "m" then muted = not muted end
end
function love.textinput(text)
    if openingCatalog then
        openingCatalog = false
        if text:lower() == "c" then return end
    end
    if catalog and searchFocused then
        local combined = query .. text:gsub("%c", "")
        local limit = utf8.offset(combined, 65)
        query = limit and combined:sub(1, limit-1) or combined
        filterSkins()
    end
end
function love.wheelmoved(x, y)
    if catalog and y ~= 0 then page = math.max(1, math.min(pageCount, page + (y > 0 and -1 or 1))) end
end
function love.keyreleased(key)
    if key == "down" or key == "s" then game:duck(love.keyboard.isDown("down", "s")) end
    if key == "space" or key == "up" or key == "w" then game:release() end
end
local function pointerPosition(x, y)
    local width, height = love.graphics.getDimensions()
    local scale = math.min(width / W, height / H)
    return (x - (width - W * scale) / 2) / scale, (y - (height - H * scale) / 2) / scale
end
local function pointerPressed(x, y)
    x, y = pointerPosition(x, y)
    if x < 0 or x > W or y < 0 or y > H then return end
    if languageMenu then
        if x >= 886 and x <= 1046 and y >= 590 and y <= 644 then toggleLanguages(); return end
        for i = 1, #I18n.languages do
            local left, top, width, height = languageButton(i)
            if x >= left and x <= left+width and y >= top and y <= top+height then chooseLanguage(i); return end
        end
        return
    end
    local languageX = (catalog or shop) and 780 or 255
    if x >= languageX and x <= languageX+266 and y >= 25 and y <= 59 then toggleLanguages(); return end
    if shop then
        if x >= 886 and x <= 1046 and y >= 590 and y <= 644 then love.keypressed("u"); return end
        for i = 1, #Progress.upgrades do
            if x >= 54 and x <= 1046 and y >= 165 + (i-1)*90 and y <= 245 + (i-1)*90 then
                buyUpgrade(i); return
            end
        end
        return
    end
    if catalog then
        if x >= 54 and x <= 834 and y >= 106 and y <= 150 then
            focusSearch(true)
            if x >= 786 then query = ""; filterSkins() end
            return
        end
        focusSearch(false)
        if x >= 854 and x <= 1046 and y >= 106 and y <= 150 then randomResult(); return end
        if y >= 590 and y <= 644 then
            if x >= 54 and x <= 214 then page = math.max(1, page-1)
            elseif x >= 230 and x <= 390 then page = math.min(pageCount, page+1)
            elseif x >= 886 and x <= 1046 then closeCatalog() end
        end
        for slot = 1, perPage do
            local left, top = 54 + ((slot-1)%5)*200, 163 + math.floor((slot-1)/5)*101
            local id = results[(page-1)*perPage + slot]
            if id and x >= left and x <= left+188 and y >= top and y <= top+91 then
                selectSkin(id)
                return
            end
        end
        return
    end
    if mobile and y >= 606 and y <= 666 then
        if x >= 54 and x <= 209 then game:duck(true); return "duck"
        elseif x >= 225 and x <= 345 then love.keypressed("p"); return
        elseif x >= 361 and x <= 481 then love.keypressed("r"); return
        elseif x >= 497 and x <= 617 then love.keypressed("m"); return end
    end
    if x >= 650 and x <= 865 and y >= 606 and y <= (mobile and 666 or 647) then love.keypressed("u"); return end
    if x >= 54 and x <= 1046 and y >= 540 and y <= 596 then
        love.keypressed("c")
        return
    end
    if game.state == "paused" then game:pause(); return end
    jump()
    return "jump"
end
function love.mousepressed(x, y, button, isTouch)
    if button == 1 and not isTouch then pointerPressed(x, y) end
end
function love.mousereleased(x, y, button, isTouch)
    if button == 1 and not isTouch then game:release() end
end
local function touchHeld(action)
    for _, held in pairs(touches) do if held == action then return true end end
    return false
end
function love.touchpressed(id, x, y) touches[id] = pointerPressed(x, y) end
function love.touchreleased(id)
    local action = touches[id]
    touches[id] = nil
    if action == "jump" and not touchHeld("jump") then game:release() end
    if action == "duck" then game:duck(touchHeld("duck") or love.keyboard.isDown("down", "s")) end
end
function love.touchmoved(id, x, y)
    if touches[id] == "duck" then
        x, y = pointerPosition(x, y)
        if x < 54 or x > 209 or y < 606 or y > 666 then love.touchreleased(id) end
    end
end
function love.focus(focused)
    if not focused then
        saveProgress()
        touches = {}
        game:duck(false)
        game:release()
        if game.state == "running" then game:pause() end
    end
end
function love.visible(visible)
    if not visible then love.focus(false) end
end
function love.update(dt)
    openingCatalog = false
    saveTimer = saveTimer + dt
    if saveTimer >= 1 then saveProgress() end
    noticeTime = math.max(0, noticeTime - dt)
    if catalog or shop or languageMenu then return end
    local before, passed, collected, score = game.state, game.passed, game.collected, game.score
    -- Small substeps keep collision detection stable during a slow frame.
    dt = math.min(dt, 0.1)
    while dt > 0 do local step = math.min(dt, 1 / 120); game:update(step); dt = dt - step end
    local coins, cacti, points = game.collected - collected, game.passed - passed, game.score - score
    if coins > 0 or cacti > 0 or points > 0 then
        local completed, bonus = progress:add(coins, cacti, points)
        dirty = true
        if completed > 0 then
            notice, noticeTime = t("MISSION COMPLETE! +%d coins", bonus), 4
            play("mission")
            saveProgress()
        elseif coins > 0 then play("coin"); saveProgress() end
    end
    if before == "running" and game.state == "dead" then
        saveProgress()
        play("dead")
        if game.score > best then best = game.score; love.filesystem.write("record.txt", tostring(best)) end
    elseif game.passed > passed and game.passed % 5 == 0 then play("point") end
end
local function dino(x, y, skinIndex, preview)
    local stride = not preview and game.state == "running" and game.player.y == 0 and math.floor(game.time * 12) % 2 or 0
    if not preview then
        local g = love.graphics
        g.push(); g.translate(x, y); g.scale(game.player.w/44, game.player.h/66)
        drawDino(0, 0, skins[skinIndex or selectedSkin], stride)
        g.pop()
    else drawDino(x, y, skins[skinIndex or selectedSkin], stride) end
end
local function cactus(x, h, width)
    color(C.green)
    local function stem(px, height)
        local y = ground - height
        love.graphics.rectangle("fill", px + 12, y, 12, height, 5, 5)
        love.graphics.rectangle("fill", px, y + 19, 8, 24, 4, 4)
        love.graphics.rectangle("fill", px + 3, y + 36, 14, 8)
        love.graphics.rectangle("fill", px + 28, y + 11, 8, 24, 4, 4)
        love.graphics.rectangle("fill", px + 20, y + 28, 13, 8)
    end
    stem(x, h)
    if width > 40 then stem(x + 30, h - 10) end
end
local function bird(o)
    local g = love.graphics
    local x, y = o.x, ground - o.y - o.h
    local flap = math.sin(game.time * 18 + o.x * 0.01) * 12
    color({0.38, 0.27, 0.46})
    g.ellipse("fill", x+31, y+17, 18, 10)
    g.circle("fill", x+12, y+10, 10)
    g.polygon("fill", x+41,y+15, x+56,y+7, x+52,y+24)
    color({0.55, 0.39, 0.63})
    g.polygon("fill", x+23,y+15, x+36,y+2+flap, x+45,y+15, x+32,y+22)
    color(C.orange); g.polygon("fill", x+4,y+9, x-6,y+14, x+5,y+17)
    color(C.paper); g.circle("fill", x+10,y+7, 3)
    color(C.ink); g.circle("fill", x+9,y+7, 1.5)
end
function love.draw()
    local g = love.graphics
    local zone = game:zone()
    g.clear(zone == "JUNGLE" and {0.85, 0.93, 0.82} or zone == "SNOW" and {0.89, 0.95, 0.99} or C.paper)
    local scale = math.min(g.getWidth() / W, g.getHeight() / H)
    g.push(); g.translate((g.getWidth() - W * scale) / 2, (g.getHeight() - H * scale) / 2); g.scale(scale)
    label("D / R", "medium", 54, 39)
    label(zone .. " RUN", "tiny", 132, 46, nil, 112)
    label("COINS", "tiny", 560, 33)
    label(tostring(progress:wallet()), "score", 557, 53)
    label(t("RUN +%d", game.collected), "tiny", 668, 66, C.green)
    label("BEST", "tiny", 791, 33)
    label(string.format("%05d", best), "score", 787, 53)
    label("SCORE", "tiny", 943, 33)
    label(string.format("%05d", game.score), "score", 938, 53)
    color(C.pale); g.setLineWidth(1); g.line(54, 106, 1046, 106)
    color({0.92, 0.79, 0.48}); g.circle("fill", 852, 240, 43)
    color(C.pale)
    for i = 0, 5 do
        local x = ((i * 263 - game.distance * 0.09) % 1450) - 160
        g.polygon("fill", x, ground, x + 140, 335 + (i % 2) * 27, x + 290, ground)
    end
    color({0.91, 0.90, 0.81})
    for i = 0, 4 do
        local x = ((i * 330 - game.distance * 0.17) % 1600) - 250
        g.polygon("fill", x, ground, x + 180, 411, x + 380, ground)
    end
    if zone == "JUNGLE" then
        for i = 0, 7 do
            local x = ((i*183 - game.distance*0.22) % 1450) - 140
            color({0.38, 0.44, 0.28}); g.rectangle("fill", x+24, 329, 12, 149)
            color({0.28, 0.52, 0.33}); g.ellipse("fill", x+30, 335, 53, 74)
        end
    elseif zone == "SNOW" then
        color({0.98, 0.99, 1})
        for i = 0, 5 do
            local x = ((i*263 - game.distance*0.09) % 1450) - 160
            local peak = 335 + (i%2)*27
            g.polygon("fill", x+98,peak+43, x+140,peak, x+187,peak+43)
        end
        for i = 1, 40 do
            local x = (i*97 - game.distance*0.08) % W
            local y = 120 + (i*53 + game.time*30) % 350
            g.circle("fill", x, y, 2)
        end
    end
    color(C.ink); g.setLineWidth(2); g.line(54, ground, 1046, ground)
    for i = 0, 28 do
        local x = 54 + ((i * 79 - game.distance) % 991)
        color(C.ink, 0.22); g.rectangle("fill", x, ground + 13 + (i % 3) * 12, 3 + i % 7, 2)
    end
    for _, coin in ipairs(game.coins) do
        local cy = ground - coin.y
        color({0.94, 0.65, 0.13}); g.circle("fill", coin.x, cy, 11)
        color({1, 0.88, 0.43}); g.setLineWidth(2); g.circle("line", coin.x, cy, 8)
        g.rectangle("fill", coin.x-2, cy-5, 4, 10)
    end
    for _, o in ipairs(game.obstacles) do
        if not o.broken then
            if o.kind == "bird" then bird(o) else cactus(o.x, o.h, o.w) end
        end
    end
    color(C.ink, 0.10); g.ellipse("fill", game.player.x+game.player.w/2, ground + 3, 36 - math.min(game.player.y / 10, 12), 5)
    dino(game.player.x, ground - game.player.h - game.player.y)
    local cx, cy = game.player.x + game.player.w/2, ground - game.player.y - game.player.h/2
    if game.shields > 0 then
        color({0.25, 0.65, 0.85}, 0.18); g.ellipse("fill", cx, cy, 48, game.player.h/2+12)
        color({0.25, 0.65, 0.85}, 0.8); g.setLineWidth(2); g.ellipse("line", cx, cy, 48, game.player.h/2+12)
    end
    if game.shieldFlash > 0 then
        local t = 1 - game.shieldFlash / 0.8
        color({0.25, 0.65, 0.85}, 1-t); g.setLineWidth(3)
        for i = 1, 12 do
            local angle = i * math.pi / 6
            local r = 40 + t * 70
            local x, y = cx + math.cos(angle)*r, cy + math.sin(angle)*r
            g.line(x, y, x + math.cos(angle)*12, y + math.sin(angle)*12)
        end
        label("SHIELD SAVED YOU!", "small", 76, 400, C.green)
    end
    if progress.upgrades.shield > 0 then label(t("SHIELD %d/1", game.shields), "tiny", 355, 65, C.green) end
    if game.state == "ready" then
        center("One dino. Endless desert.", "big", 153)
        center(mobile and "Tap to jump. Hold DUCK for middle birds." or "Low birds: jump. Middle birds: DOWN / S to duck.", "small", 219)
        color(C.ink); g.rectangle("fill", 389, 281, 322, 52, 8, 8)
        center(mobile and "TAP TO START" or "SPACE / CLICK TO START", "small", 299, C.paper)
    elseif game.state == "dead" or game.state == "paused" then
        color(C.paper, 0.94); g.rectangle("fill", 298, 157, 504, 224, 14, 14)
        center(game.state == "dead" and "Give it another run." or "Adventure on pause.", "score", 188, nil, 470)
        center(game.state == "dead" and t("Score %d / Cacti %d / Birds %d / Coins +%d", game.score, game.passed, game.birdsPassed, game.collected) or "The desert can wait.", "small", 245, nil, 470)
        center(mobile and (game.state == "dead" and "TAP to try again" or "TAP to continue") or
            (game.state == "dead" and "SPACE or CLICK to try again" or "P or ESC to continue"), "small", 311, C.green, 470)
    end
    for i, mission in ipairs(progress:missions()) do
        local x = 54 + (i-1)*335
        color(C.paper); g.rectangle("fill",x,489,322,44,5,5)
        label(t(mission.title) .. "  " .. mission.current .. "/" .. mission.target, "small", x+8,492, nil, 222)
        label(t("+%d coins", mission.reward), "tiny",x+236,494,C.green, 78)
        color(C.pale); g.rectangle("fill",x+8,516,306,5,2,2)
        color(C.green); g.rectangle("fill",x+8,516,306*mission.current/mission.target,5,2,2)
    end
    if noticeTime > 0 then
        color(C.ink); g.rectangle("fill",330,113,440,32,7,7)
        center(notice,"small",121,C.paper)
    end
    color(C.pale); g.rectangle("fill", 54, 540, 992, 56, 7, 7)
    label(t("SKIN #%d / %d   %s", selectedSkin, #skins, t(skins[selectedSkin].name)), "medium", 76, 555, nil, 675)
    label(mobile and "TAP  Browse collection" or "C / CLICK  Browse collection", "small", 776, 560, C.green, 250)
    if mobile then
        local buttons = {{54,155,"DUCK"}, {225,120,game.state == "paused" and "RESUME" or "PAUSE"},
            {361,120,"RESET"}, {497,120,muted and "SOUND OFF" or "SOUND ON"}, {650,215,"UPGRADES"}, {881,165,"JUMP"}}
        for _, button in ipairs(buttons) do
            color(C.pale); g.rectangle("fill", button[1], 606, button[2], 60, 7, 7)
            color(C.green); g.setFont(fonts.small); g.printf(t(button[3]), button[1], 627, button[2], "center")
        end
    else
        label("SPACE jump   DOWN / S duck   P pause   R restart", "small", 54, 618, nil, 585)
        label("U / CLICK  Upgrades", "small", 670, 618, C.green, 220)
        label(muted and "M  sound off" or "M  sound on", "small", 910, 618, nil, 136)
    end
    if catalog then
        color(C.paper); g.rectangle("fill", 0, 0, W, H)
        label("THE DINO COLLECTION", "score", 54, 29, nil, 710)
        label(t("%d / %d skins | Heroes: 200 coins each", #results, #skins), "small", 54, 73, C.green)
        label(t("COINS: %d", progress:wallet()), "small", 780, 73, C.green, 266)
        color(searchFocused and C.pale or {0.92,0.91,0.84})
        g.rectangle("fill",54,106,780,44,7,7)
        color(searchFocused and C.green or C.pale); g.setLineWidth(2)
        g.rectangle("line",54,106,780,44,7,7)
        local visibleQuery = query
        while fonts.medium:getWidth(visibleQuery) > 690 do
            visibleQuery = visibleQuery:sub(utf8.offset(visibleQuery, 2))
        end
        label(query == "" and t("Search name or ID...") or visibleQuery,
            "medium", 68,116, query == "" and C.green or C.ink)
        if searchFocused then
            color(C.green)
            g.rectangle("fill", 68 + (query == "" and 0 or fonts.medium:getWidth(visibleQuery)), 116, 2, 25)
        end
        label("X", "medium", 801,116,C.green)
        color(C.pale); g.rectangle("fill",854,106,192,44,7,7)
        label("RANDOM", "small", 884,120,C.green, 152)
        if #results == 0 then
            center("No skins found. Try another name or ID.", "medium", 310, C.green)
            center("Click X or press Delete to clear the search.", "small", 346, C.green)
        end
        for slot = 1, perPage do
            local id = results[(page-1)*perPage + slot]
            if id then
                local x, y = 54 + ((slot-1)%5)*200, 163 + math.floor((slot-1)/5)*101
                color(id == selectedSkin and C.pale or {0.92,0.91,0.84})
                g.rectangle("fill", x, y, 188, 91, 7, 7)
                color(id == selectedSkin and C.green or C.pale)
                g.setLineWidth(id == selectedSkin and 2 or 1)
                g.rectangle("line", x, y, 188, 91, 7, 7)
                g.push(); g.translate(x+23,y+32); g.scale(0.7); dino(0,0,id,true); g.pop()
                label("#" .. id, "tiny", x+86,y+16,C.green)
                label(skins[id].name, "small", x+86,y+36, nil, 96)
                label(id == selectedSkin and "SELECTED" or (progress:ownsSkin(skins[id]) and "SELECT" or "BUY 200"), "tiny", x+86,y+62,C.green, 96)
            end
        end
        color(C.pale)
        g.rectangle("fill",54,590,160,54,7,7); g.rectangle("fill",230,590,160,54,7,7)
        g.rectangle("fill",886,590,160,54,7,7)
        label("< PREVIOUS", "small", 66,609, nil, 140); label("NEXT >", "small",244,609, nil, 140)
        label(t("Page %d / %d", page, pageCount), "medium", 430,604, nil, 430)
        label((mobile and "" or "ESC  ") .. t("CLOSE"), "small",900,609, nil, 140)
        label(mobile and "Tap a skin to select or buy. Tap search to type." or
            "ENTER select/buy | TAB search | ARROWS / SCROLL pages", "tiny",54,657,C.green, 992)
        if noticeTime > 0 then
            color(C.ink); g.rectangle("fill",280,550,540,32,7,7)
            center(notice, "small", 555, C.paper)
        end
    end
    if shop then
        color(C.paper); g.rectangle("fill", 0, 0, W, H)
        label("UPGRADES FOR ALL DINOS", "score", 54, 29, nil, 710)
        label("One purchase boosts every dino. Levels are saved. Shield recharges every run.", "small", 54, 78, C.green, 992)
        label(t("COINS: %d", progress:wallet()), "medium", 54, 116)
        for i, def in ipairs(Progress.upgrades) do
            local y = 165 + (i-1)*90
            local level = progress.upgrades[def.key]
            local cost = def.base * (level + 1)
            local maxLevel = def.max or 5
            color(C.pale); g.rectangle("fill", 54, y, 992, 80, 8, 8)
            label(i .. "  " .. t(def.title) .. "   " .. level .. "/" .. maxLevel, "medium", 76, y+16, nil, 680)
            label(t(def.detail) .. " / " .. t("Applies to all %d dinos", #skins), "small", 76, y+49, C.green, 680)
            label(level == maxLevel and t("MAX LEVEL") or t("BUY: %d coins", cost), "medium", 794, y+35,
                level < maxLevel and progress:wallet() < cost and C.orange or C.green, 235)
        end
        if noticeTime > 0 then center(notice, "medium", 540, C.green) end
        color(C.pale); g.rectangle("fill", 886, 590, 160, 54, 7, 7)
        label((mobile and "" or "U / ESC ") .. t("CLOSE"), "small", 900, 609, nil, 140)
        label(mobile and "Tap an upgrade to buy" or "Click an upgrade or press 1 / 2 / 3 / 4 to buy", "small", 54, 610, nil, 810)
    end
    local languageX = (catalog or shop) and 780 or 255
    color(C.pale); g.rectangle("fill", languageX, 25, 266, 34, 7, 7)
    label("L  " .. t("Language") .. " / 语言", "small", languageX+12, 31, C.green, 242)
    if languageMenu then
        color(C.paper); g.rectangle("fill", 0, 0, W, H)
        center("Choose language", "score", 70)
        for i, language in ipairs(I18n.languages) do
            local x, y, width, height = languageButton(i)
            color(language.code == I18n.language and C.green or C.pale)
            g.rectangle("fill", x, y, width, height, 8, 8)
            label((i == 10 and "0" or i) .. "  " .. language.name, "medium", x+24, y+17,
                language.code == I18n.language and C.paper or C.ink, width-48)
        end
        color(C.pale); g.rectangle("fill",886,590,160,54,7,7)
        label("CLOSE", "small", 906,609, nil, 130)
    end
    g.pop()
end
