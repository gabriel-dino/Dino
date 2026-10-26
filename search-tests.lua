local skins, Search = require("skins"), require("skin-search")
assert(#Search.find(skins, "") == #skins)
assert(Search.find(skins, "  fRoSt  ")[1] == 3)
assert(Search.find(skins, "#11772")[1] == 11772)
assert(Search.find(skins, "5006")[1] == 5006)
assert(#Search.find(skins, "99999") == 0)
assert(#Search.find(skins, "%") == 0, "Search must treat patterns literally")
assert(#Search.find(skins, "Crystal") == 850)
assert(#skins == 52399)
assert(#Search.find(skins, "Halloween") == 6767)
assert(#Search.find(skins, "dovleac") == 850)
assert(#Search.find(skins, "fantomă") == 850)
assert(Search.find(skins, "18539")[1] == 18539)
local halloweenNames = {}
local halloweenFamilies = {}
for id = 11773, 18539 do
    local skin = skins[id]
    assert(skin.halloween and skin.charm and skin.pattern)
    assert(not halloweenNames[skin.name], "Duplicate Halloween name")
    halloweenNames[skin.name] = true
    halloweenFamilies[skin.halloween] = (halloweenFamilies[skin.halloween] or 0) + 1
end
for family = 1, 8 do
    assert(halloweenFamilies[family] == (family == 8 and 817 or 850))
end

assert(#Search.find(skins, "Ocean") == 6767)
assert(#Search.find(skins, "oceanic") == 6767)
assert(#Search.find(skins, "rechin") == 850)
assert(#Search.find(skins, "caracatiță") == 850)
assert(#Search.find(skins, "meduza") == 1667)
assert(Search.find(skins, "#25306")[1] == 25306)
local oceanFamilies = {}
for id = 18540, 25306 do
    local skin = skins[id]
    assert(skin.ocean and skin.ornament and skin.pattern)
    oceanFamilies[skin.ocean] = (oceanFamilies[skin.ocean] or 0) + 1
end
for family = 1, 8 do
    assert(oceanFamilies[family] == (family == 8 and 817 or 850))
end

for _, query in ipairs({'Pirate', 'pirati', 'pirați'}) do
    assert(#Search.find(skins, query) == 6767)
end
assert(#Search.find(skins, "căpitan") == 850)
assert(#Search.find(skins, "bandana") == 850)
assert(Search.find(skins, "#32073")[1] == 32073)
local pirateFamilies = {}
for id = 25307, 32073 do
    local skin = skins[id]
    assert(skin.pirate and skin.insignia and skin.pattern)
    pirateFamilies[skin.pirate] = (pirateFamilies[skin.pirate] or 0) + 1
end
for family = 1, 8 do
    assert(pirateFamilies[family] == (family == 8 and 817 or 850))
end

for _, query in ipairs({'Robot', 'roboti', 'roboți'}) do
    assert(#Search.find(skins, query) == 6767)
end
assert(#Search.find(skins, "oțel") == 850)
assert(#Search.find(skins, "hologramă") == 850)
assert(Search.find(skins, "#38840")[1] == 38840)
local robotFamilies = {}
for id = 32074, 38840 do
    local skin = skins[id]
    assert(skin.robot and skin.hardware and skin.pattern)
    robotFamilies[skin.robot] = (robotFamilies[skin.robot] or 0) + 1
end
for family = 1, 8 do
    assert(robotFamilies[family] == (family == 8 and 817 or 850))
end


for _, query in ipairs({"SpongeBob", "bikini bottom", "desene animate"}) do
    assert(#Search.find(skins, query) == 6767)
end
local spongeFamilies = {}
for id = 38841, 45607 do
    local skin = skins[id]
    assert(skin.sponge and skin.souvenir and skin.pattern)
    spongeFamilies[skin.sponge] = (spongeFamilies[skin.sponge] or 0) + 1
end
for family = 1, 8 do
    assert(spongeFamilies[family] == (family == 8 and 817 or 850))
end
assert(Search.find(skins, "#45607")[1] == 45607)

for _, term in ipairs({"SWEETS", "Candy", "dulciuri", "sweets"}) do
    assert(#Search.find(skins, term) == 6767)
end
assert(#Search.find(skins, "înghețată") == 850)
assert(#Search.find(skins, "ciocolata") == 850)
local candyFamilies, candyCodes = {}, {}
for id = 45608, 52374 do
    local skin = skins[id]
    assert(skin.candy and skin.topping and skin.pattern)
    local code = table.concat({skin.candy, skin.palette, skin.pattern, skin.topping}, ":")
    assert(not candyCodes[code], "Duplicate candy combination")
    candyCodes[code] = true
    candyFamilies[skin.candy] = (candyFamilies[skin.candy] or 0) + 1
end
for family = 1, 8 do
    assert(candyFamilies[family] == (family == 8 and 817 or 850))
end
assert(Search.find(skins, "#45608")[1] == 45608)
assert(Search.find(skins, "#52374")[1] == 52374)

-- Exercise the real input handlers without touching the player's save files.
local saved, focused = {}, false
love = {
    graphics = {
        setDefaultFilter = function() end,
        newFont = function() return {setFilter = function() end, setFallbacks = function() end} end,
        getDimensions = function() return 1100, 680 end,
    },
    filesystem = {
        read = function() return nil end,
        write = function(name, value) saved[name] = value; return true end,
    },
    keyboard = {setTextInput = function(value) focused = value end},
    math = {random = function(max) return max or 0.5 end},
}
dofile("main.lua")
love.load()
love.keypressed("c"); love.textinput("c") -- opening key must not enter the query
love.textinput("11772"); love.keypressed("return")
assert(saved["skin.txt"] == skins[11772].name, "Five-digit ID must select original skin")
love.keypressed("delete")
for letter in ("Crystal"):gmatch(".") do love.keypressed(letter:lower()); love.textinput(letter) end
assert(focused, "Typing C, R and U must not activate game shortcuts")
love.keypressed("end"); love.keypressed("return")
local crystals = Search.find(skins, "Crystal")
assert(saved["skin.txt"] == skins[crystals[841]].name, "Filtered pagination must retain original IDs")
love.mousepressed(150, 200, 1, false)
assert(saved["skin.txt"] == skins[crystals[841]].name, "Filtered card click must select original ID")
love.mousepressed(900, 125, 1, false)
assert(saved["skin.txt"] == skins[crystals[#crystals]].name, "Random uses filtered results")
love.mousepressed(100, 125, 1, false)
love.keypressed("delete"); love.textinput("No such dino")
local previous = saved["skin.txt"]
love.keypressed("end"); love.keypressed("return"); love.mousepressed(900, 125, 1, false)
assert(saved["skin.txt"] == previous, "Empty results must not select anything")
love.mousepressed(810, 125, 1, false); love.textinput("Frost")
love.keypressed("return"); assert(saved["skin.txt"] == "Frost")
love.keypressed("delete"); love.textinput("ă"); love.keypressed("backspace")
love.textinput("Frost"); love.keypressed("return")
assert(saved["skin.txt"] == "Frost", "Backspace must remove a complete UTF-8 character")
love.keypressed("delete"); love.textinput("Ocean"); love.keypressed("return")
assert(saved["skin.txt"] == skins[18540].name, "Ocean search must select first ocean dinosaur")
love.keypressed("delete"); love.textinput("25306"); love.keypressed("return")
assert(saved["skin.txt"] == skins[25306].name, "Last ocean ID must be selectable")
love.keypressed("delete"); love.textinput("pirați"); love.keypressed("return")
assert(saved["skin.txt"] == skins[25307].name, "Pirate search must select first pirate dinosaur")
love.keypressed("delete"); love.textinput("32073"); love.keypressed("return")
assert(saved["skin.txt"] == skins[32073].name, "Last pirate ID must be selectable")
love.keypressed("delete"); love.textinput("roboți"); love.keypressed("return")
assert(saved["skin.txt"] == skins[32074].name, "Robot search must select first robotic dinosaur")
love.keypressed("delete"); love.textinput("38840"); love.keypressed("return")
assert(saved["skin.txt"] == skins[38840].name, "Last robot ID must be selectable")
love.keypressed("delete"); love.textinput("SpongeBob"); love.keypressed("return")
assert(saved["skin.txt"] == skins[38841].name)
love.keypressed("delete"); love.textinput("45607"); love.keypressed("return")
assert(saved["skin.txt"] == skins[45607].name)

love.keypressed("delete"); love.textinput("dulciuri"); love.keypressed("return")
assert(saved["skin.txt"] == skins[45608].name)
love.keypressed("delete"); love.textinput("52374"); love.keypressed("return")
assert(saved["skin.txt"] == skins[52374].name)

love.keypressed("escape"); assert(not focused)
print("OK: name/ID search, 5-digit IDs, literal matching, typing shortcuts, pagination, card selection, random, empty results, clear, UTF-8, close")
