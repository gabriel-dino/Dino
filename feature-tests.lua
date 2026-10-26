local Game, Progress, skins = require("game"), require("progress"), require("skins")
local I18n, Search = require("i18n"), require("skin-search")
assert(#skins == 52399 and skins[52374].candy and skins[52375].fruit == "mango")
for i = 52375, 52385 do assert(skins[i].fruit and not skins[i].hero) end
assert(skins[52386].hero == "godzilla" and skins[52387].hero == "kingkong")
local species = {}
for i = 52375, 52385 do species[skins[i].fruit] = true end
for i = 52388, #skins do
    local skin = skins[i]
    assert(skin.fruit and not skin.hero and not species[skin.fruit], "New fruit must be a different species")
    species[skin.fruit] = true
end
assert(#Search.find(skins, "fruit") == 23)
local poor = Progress.new()
assert(not poor:buyHero("godzilla") and poor:wallet() == 0)
assert(not poor:ownsSkin(skins[52386]) and poor:ownsSkin(skins[52385]))
local rich = Progress.new("v3\n1000\n20\n150\n1\n1\n1\n1\n")
local balance = rich:wallet()
for _, key in ipairs({"godzilla", "kingkong"}) do
    assert(rich:buyHero(key))
    local after = rich:wallet()
    assert(after == balance - 200)
    assert(not rich:buyHero(key) and rich:wallet() == after)
    balance = after
end
local restored = Progress.new(rich:serialize())
assert(restored:wallet() == balance and restored.heroes.godzilla and restored.heroes.kingkong)
assert(restored.upgrades.jump == 1 and restored.upgrades.shield == 1)
assert(Progress.new("v4\ninvalid"):wallet() == 0)
for _, version in ipairs({"v1\n20\n0\n0\n", "v2\n20\n0\n0\n0\n0\n0\n", "v3\n20\n0\n0\n0\n0\n0\n0\n"}) do
    local old = Progress.new(version)
    assert(old:wallet() == 20 and not old.heroes.godzilla and not old.heroes.kingkong)
    assert(Progress.new(old:serialize()):wallet() == 20)
end
print("OK: fruit IDs, hero prices, ownership, duplicate purchases, save/reload and v1-v3 migration")

-- A deterministic generator verifies that real random draws change count,
-- position, height and delay without tying coins to obstacle spawns.
local seed = 12345
local function random()
    seed = seed * 16807 % 2147483647
    return (seed - 1) / 2147483646
end
local game = Game.new(random)
assert(game.player.w == 44*1.35 and game.player.h == 66*1.35)
local counts, heights, positions, delays = {}, {}, {}, {}
for _ = 1, 80 do
    game.coins = {}
    game:spawnCoins()
    counts[#game.coins] = true
    delays[game.coinSpawn] = true
    assert(#game.coins >= 1 and #game.coins <= 6)
    assert(game.coinSpawn >= 0.7 and game.coinSpawn <= 2.5)
    for i, coin in ipairs(game.coins) do
        assert(coin.y >= 26 and coin.y <= 120 and coin.x >= 1140)
        if i > 1 then assert(coin.x - game.coins[i-1].x >= 36) end
        heights[coin.y], positions[coin.x] = true, true
    end
end
local function size(values) local n=0; for _ in pairs(values) do n=n+1 end; return n end
assert(size(counts) == 6 and size(heights) > 80 and size(positions) > 80 and size(delays) == 80)
game.state, game.spawn, game.coinSpawn = "running", 999, 0
game.coins = {}; game:update(1/120)
assert(#game.coins > 0 and #game.obstacles == 0)
game:pause(); local delay = game.coinSpawn; game:update(1); assert(game.coinSpawn == delay)
game:reset(); game.state, game.spawn = "running", 999
game:duck(true); assert(game.player.h == 34*1.35)
game.obstacles = {{kind="bird", x=190, y=48, w=56, h=30}}
game:update(1/120); assert(game.state == "running", "Larger duck must fit under middle birds")
game:duck(false); game:update(1/120); assert(game.state == "dead")
game:reset(); game.state, game.spawn = "running", 999
game.obstacles = {{kind="bird", x=190, y=100, w=56, h=30}}
game:update(1/120); assert(game.state == "running", "Larger standing dino must fit under high birds")
print("OK: random coin counts/positions/heights/delays, independent spawning, pause and enlarged collision geometry")

assert(I18n.setLanguage(nil) == "en" and I18n.t("COINS") == "COINS")
assert(#I18n.languages == 10)
for _, language in ipairs(I18n.languages) do
    I18n.setLanguage(language.code)
    assert(I18n.t("COINS") ~= "")
    for key, value in pairs(I18n.translations.en) do
        local translated = assert(I18n.translations[language.code][key])
        local function formats(text) return table.concat((function()
            local result = {}; for spec in text:gmatch("%%[ds]") do result[#result+1] = spec end; return result
        end)(), ",") end
        assert(formats(value) == formats(translated), "Mismatched placeholders: " .. key)
    end
    for id = 52388, #skins do
        assert(Search.find(skins, I18n.t(skins[id].name))[1] == id, "Localized fruit search: " .. language.code)
    end
end
I18n.setLanguage("zh"); assert(Search.find(skins, "芒果")[1] == 52375)
I18n.setLanguage("ro"); assert(Search.find(skins, "MĂR ROȘU")[1] == 52376)
for _, example in ipairs({{"fr", "PÊCHE", 52385}, {"de", "GRÜNER APFEL", 52377},
    {"tr", "ÇİLEK", 52388}, {"tr", "KIRMIZI ELMA", 52376},
    {"pl", "BORÓWKA", 52396}, {"pl", "ŻÓŁTE JABŁKO", 52378}}) do
    I18n.setLanguage(example[1]); assert(Search.find(skins, example[2])[1] == example[3])
end
assert(I18n.setLanguage("invalid") == "en")

-- Exercise actual handlers with in-memory saves, including locked selection
-- through Enter, click, random and a forged previous skin selection.
local saved = {["skin.txt"] = "Godzilla"}
local focused = false
local windowWidth, windowHeight = 1100, 680
love = {
    graphics = {setDefaultFilter=function() end, newFont=function() return {setFilter=function() end, setFallbacks=function() end} end,
        getDimensions=function() return windowWidth,windowHeight end},
    filesystem = {read=function(name) return saved[name] end,
        write=function(name,value) saved[name]=value; return true end},
    keyboard = {setTextInput=function(value) focused=value end, isDown=function() return false end},
    math = {random=function(max) return max or 0.5 end},
}
dofile("main.lua"); love.load()
love.keypressed("c"); love.textinput("Godzilla"); love.keypressed("return")
assert(saved["progress.txt"] == nil, "Insufficient funds must not buy a hero")
love.mousepressed(100,200,1,false)
assert(saved["progress.txt"] == nil)
love.keypressed("escape"); love.keypressed("c"); love.textinput("heroes")
love.mousepressed(900,125,1,false)
assert(saved["progress.txt"] == nil, "Random must never buy a locked hero")
love.keypressed("escape"); love.keypressed("1"); assert(saved["skin.txt"] == "Classic")
saved["progress.txt"] = "v1\n1000\n0\n0\n"
dofile("main.lua"); love.load()
love.keypressed("c"); love.textinput("Godzilla"); love.keypressed("return")
assert(saved["skin.txt"] == "Godzilla")
local bought = Progress.new(saved["progress.txt"])
assert(bought.heroes.godzilla and bought:wallet() == Progress.new("v1\n1000\n0\n0\n"):wallet()-200)
local purchasedSave = saved["progress.txt"]
love.keypressed("return"); assert(saved["progress.txt"] == purchasedSave)
love.keypressed("escape")
for i, language in ipairs(I18n.languages) do
    love.keypressed("l"); love.keypressed(i == 10 and "0" or tostring(i))
    assert(saved["language.txt"] == language.code and I18n.language == language.code)
end
dofile("main.lua"); love.load(); assert(I18n.language == "pl", "Language must persist after reload")
love.mousepressed(300,40,1,false); love.mousepressed(200,270,1,false)
assert(I18n.language == "zh" and saved["language.txt"] == "zh")
love.keypressed("c"); love.mousepressed(900,40,1,false); love.keypressed("escape")
assert(not focused, "Closing language selection must not reopen the keyboard")
love.keypressed("escape")
-- Hit every language button using actual mouse and Android touch handlers.
for _, viewport in ipairs({{1100,680}, {640,420}, {1600,720}}) do
    windowWidth, windowHeight = viewport[1], viewport[2]
    local scale = math.min(windowWidth/1100, windowHeight/680)
    for _, touch in ipairs({false, true}) do
        for i, language in ipairs(I18n.languages) do
            love.keypressed("l")
            local x, y = 330 + ((i-1)%2)*440, 188 + math.floor((i-1)/2)*82
            x, y = x*scale+(windowWidth-1100*scale)/2, y*scale+(windowHeight-680*scale)/2
            if touch then love.touchpressed("language-test", x, y)
            else love.mousepressed(x, y, 1, false) end
            assert(saved["language.txt"] == language.code, "Language button must be reachable")
        end
    end
end
love.keypressed("c"); love.textinput("avocado"); love.keypressed("return")
assert(saved["skin.txt"] == "FRUIT Avocado", "New fruits must be free and selectable")
dofile("main.lua"); love.load()
assert(saved["skin.txt"] == "FRUIT Avocado" and I18n.language == "pl")
print("OK: ten complete translations, format placeholders, localized search, hero purchase, keyboard/mouse/touch language selection and persistence")
