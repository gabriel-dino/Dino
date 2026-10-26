local skins = {
    {name = "Classic", body = {0.16, 0.23, 0.20}, accent = {0.65, 0.75, 0.50}},
    {name = "Ember", body = {0.72, 0.25, 0.14}, accent = {1, 0.70, 0.24}},
    {name = "Frost", body = {0.17, 0.43, 0.64}, accent = {0.65, 0.91, 0.98}},
    {name = "Neon", body = {0.37, 0.23, 0.57}, accent = {0.65, 0.96, 0.33}},
    {name = "Explorer", body = {0.43, 0.34, 0.23}, accent = {0.89, 0.68, 0.34}},
}

local function hue(h)
    local c, x = 0.48, 0.48 * (1 - math.abs((h / 60) % 2 - 1))
    local values = {{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}}
    local v = values[math.floor(h / 60) + 1]
    return {v[1] + 0.19, v[2] + 0.19, v[3] + 0.19}
end
-- A bijection over 20 palettes x 10 markings x 25 headpieces.
-- Original skins retain their names so existing saves remain compatible.
-- Coprime permutation keeps nearby catalog entries visually varied.
for n = 0, 4999 do
    local code = (n * 137) % 5000
    local palette = code % 20 + 1
    local pattern = math.floor(code / 20) % 10 + 1
    local hat = math.floor(code / 200) + 1
    local id = #skins + 1
    skins[id] = {name = string.format("Dino %04d", id),
        body = hue((palette - 1) * 18), accent = {1, 0.88, 0.55},
        pattern = pattern, hat = hat, palette = palette}
end

-- Append only: old IDs and saved names keep selecting the same dinosaurs.
-- 137 is coprime to 6767, so every code appears exactly once. The code
-- decomposes into 17 palettes x 10 markings x 5 crests x 8 special families
-- (the final family is partial), giving 6767 distinct visible combinations.
local families = {
    {name = "Crystal", accent = {0.65, 0.98, 1}},
    {name = "Magma", accent = {1, 0.52, 0.14}},
    {name = "Cosmic", accent = {0.96, 0.72, 1}},
    {name = "Storm", accent = {1, 0.94, 0.38}},
    {name = "Grove", accent = {0.70, 1, 0.42}},
    {name = "Aurora", accent = {0.40, 1, 0.83}},
    {name = "Fossil", accent = {1, 0.90, 0.68}},
    {name = "Solar", accent = {1, 0.77, 0.30}},
}
for n = 0, 6766 do
    local code = (n * 137) % 6767
    local palette = code % 17 + 1
    local pattern = math.floor(code / 17) % 10 + 1
    local crest = math.floor(code / 170) % 5 + 1
    local family = math.floor(code / 850) + 1
    local theme = families[family]
    skins[#skins + 1] = {
        name = string.format("%s %03d", theme.name, code % 850 + 1),
        body = hue((palette - 1) * 360 / 17), accent = theme.accent,
        palette = palette, pattern = pattern, crest = crest, special = family,
    }
end
-- A new append-only collection: 6767 Halloween dinosaurs. The same bijective
-- decomposition gives 17 palettes, 10 markings, 5 charms and 8 costumes.
local halloween = {
    {name = "Pumpkin", tags = "dovleac", accent = {1, 0.62, 0.12}},
    {name = "Ghost", tags = "fantoma fantomă", accent = {0.78, 1, 0.91}},
    {name = "Skeleton", tags = "schelet", accent = {1, 0.93, 0.75}},
    {name = "Vampire", tags = "vampir", accent = {1, 0.25, 0.35}},
    {name = "Witch", tags = "vrajitoare vrăjitoare", accent = {0.83, 0.58, 1}},
    {name = "Mummy", tags = "mumie", accent = {0.96, 0.85, 0.58}},
    {name = "Bat", tags = "liliac", accent = {0.80, 0.60, 0.98}},
    {name = "Spider", tags = "paianjen păianjen", accent = {0.62, 1, 0.35}},
}
for n = 0, 6766 do
    local code = (n * 137) % 6767
    local palette = code % 17 + 1
    local family = math.floor(code / 850) + 1
    local theme = halloween[family]
    local body = hue((palette - 1) * 360 / 17)
    for i = 1, 3 do body[i] = body[i] * 0.65 end
    skins[#skins + 1] = {
        name = string.format("%s %03d", theme.name, code % 850 + 1),
        tags = "Halloween " .. theme.tags,
        body = body, accent = theme.accent, palette = palette,
        pattern = math.floor(code / 17) % 10 + 1,
        charm = math.floor(code / 170) % 5 + 1, halloween = family,
    }
end
-- Ocean collection: append 6767 combinations without changing saved IDs/names.
-- Each code is unique (137 and 6767 are coprime), decomposed into 17 aquatic
-- palettes x 10 markings x 5 ornaments x 8 families (last family partial).
local ocean = {
    {name = "Shark", tags = "rechin", accent = {0.72, 0.91, 1}},
    {name = "Octopus", tags = "caracatita caracatiță", accent = {1, 0.56, 0.74}},
    {name = "Coral", tags = "corali recif reef", accent = {1, 0.62, 0.40}},
    {name = "Abyss", tags = "abis abisal angler", accent = {0.65, 1, 0.38}},
    {name = "Jellyfish", tags = "meduza meduză", accent = {0.89, 0.72, 1}},
    {name = "Turtle", tags = "testoasa țestoasă carapace", accent = {0.68, 0.91, 0.44}},
    {name = "Seahorse", tags = "calut căluț mare", accent = {1, 0.83, 0.40}},
    {name = "Pearl", tags = "perla perlă scoica scoică", accent = {1, 0.84, 0.93}},
}
for n = 0, 6766 do
    local code = (n * 137) % 6767
    local palette = code % 17 + 1
    local family = math.floor(code / 850) + 1
    local theme = ocean[family]
    skins[#skins + 1] = {
        name = string.format("%s %03d", theme.name, code % 850 + 1),
        tags = "Ocean oceanic marin acvatic " .. theme.tags,
        body = hue(150 + (palette - 1) * 150 / 17), accent = theme.accent,
        palette = palette, pattern = math.floor(code / 17) % 10 + 1,
        ornament = math.floor(code / 170) % 5 + 1, ocean = family,
    }
end
-- Pirate collection: append exactly 6767 combinations, preserving old saves.
-- The coprime permutation covers 17 palettes x 10 markings x 5 insignias
-- across eight costumes (the eighth contains the remaining 817 variants).
local pirates = {
    {name = "Captain", tags = "capitan căpitan", accent = {1, 0.80, 0.30}},
    {name = "Corsair", tags = "corsar bandana bandană", accent = {1, 0.43, 0.38}},
    {name = "Raider", tags = "jefuitor sabie", accent = {0.82, 0.92, 1}},
    {name = "Sailor", tags = "marinar franghie frânghie", accent = {0.92, 0.95, 1}},
    {name = "Gunner", tags = "tunar tun", accent = {1, 0.64, 0.24}},
    {name = "Admiral", tags = "amiral", accent = {1, 0.91, 0.48}},
    {name = "Treasure", tags = "comoara comoară aur", accent = {1, 0.72, 0.16}},
    {name = "Kraken", tags = "kraken tentacule", accent = {0.63, 1, 0.77}},
}
for n = 0, 6766 do
    local code = (n * 137) % 6767
    local palette = code % 17 + 1
    local family = math.floor(code / 850) + 1
    local theme = pirates[family]
    local body = hue((palette - 1) * 360 / 17)
    for channel = 1, 3 do body[channel] = body[channel] * 0.85 end
    skins[#skins + 1] = {
        name = string.format("%s %03d", theme.name, code % 850 + 1),
        tags = "Pirate pirat pirati pirați " .. theme.tags,
        body = body, accent = theme.accent, palette = palette,
        pattern = math.floor(code / 17) % 10 + 1,
        insignia = math.floor(code / 170) % 5 + 1, pirate = family,
    }
end
-- Robot collection: append 6767 unique combinations; existing saves stay valid.
-- Coprime permutation, then 17 metallic palettes x 10 circuit markings x
-- 5 hardware modules x 8 robot families (last family has 817 variants).
local robots = {
    {name = "Steel", tags = "otel oțel metal armura armură", accent = {0.84,0.93,1}},
    {name = "Laser", tags = "laser circuite", accent = {0.40,1,0.74}},
    {name = "Rust", tags = "rugina rugină rotite rotițe", accent = {1,0.58,0.25}},
    {name = "Astronaut", tags = "astronaut spatiu spațiu", accent = {0.70,0.87,1}},
    {name = "Hologram", tags = "holograma hologramă", accent = {0.66,0.96,1}},
    {name = "Magnet", tags = "magnet bobine", accent = {1,0.42,0.53}},
    {name = "Reactor", tags = "reactor nucleu energie", accent = {0.72,1,0.30}},
    {name = "Mecha", tags = "mecha mecanic blindaj", accent = {1,0.80,0.36}},
}
for n = 0, 6766 do
    local code = (n * 137) % 6767
    local palette = code % 17 + 1
    local family = math.floor(code / 850) + 1
    local theme = robots[family]
    local body = hue((palette - 1) * 360 / 17)
    for channel = 1, 3 do body[channel] = 0.13 + body[channel] * 0.45 end
    if family == 5 then body[4] = 0.68 end
    skins[#skins + 1] = {
        name = string.format("%s %03d", theme.name, code % 850 + 1),
        tags = "Robot roboti roboți " .. theme.tags,
        body = body, accent = theme.accent, palette = palette,
        pattern = math.floor(code / 17) % 10 + 1,
        hardware = math.floor(code / 170) % 5 + 1, robot = family,
    }
end
-- Append-only SpongeBob-inspired cartoon costumes, with 6767 unique codes.
local spongeThemes = {
    {name = "SpongeBob", tags = "burete sponge", body = {1,0.85,0.16}},
    {name = "Patrick", tags = "patrick stea starfish", body = {1,0.57,0.66}},
    {name = "Squidward", tags = "squidward calamar", body = {0.46,0.79,0.72}},
    {name = "Sandy", tags = "sandy veverita veveriță", body = {0.78,0.58,0.34}},
    {name = "Krabs", tags = "krabs crab", body = {0.96,0.30,0.25}},
    {name = "Plankton", tags = "plankton plancton", body = {0.46,0.72,0.23}},
    {name = "Gary", tags = "gary melc snail", body = {0.54,0.76,0.91}},
    {name = "Jelly", tags = "meduza meduză jellyfish", body = {0.94,0.49,0.83}},
}
for n = 0, 6766 do
    local code = (n * 137) % 6767
    local palette = code % 17 + 1
    local family = math.floor(code / 850) + 1
    local theme = spongeThemes[family]
    local body = {}
    for channel = 1, 3 do
        body[channel] = theme.body[channel] * (0.65 + (palette-1)*0.02)
    end
    skins[#skins + 1] = {
        name = string.format("SB %s %03d", theme.name, code % 850 + 1),
        tags = "SpongeBob Bikini Bottom desene animate cartoon " .. theme.tags,
        body = body, accent = {0.22,0.19,0.12}, palette = palette,
        pattern = math.floor(code / 17) % 10 + 1,
        souvenir = math.floor(code / 170) % 5 + 1, sponge = family,
    }
end
-- Candy collection: append exactly 6767 costumes, keeping every old ID stable.
local candyThemes = {
    {name = "Ice Cream", tags = "inghetata înghețată", body = {1,0.64,0.78}, accent = {0.48,0.23,0.12}},
    {name = "Chocolate", tags = "ciocolata ciocolată", body = {0.57,0.29,0.13}, accent = {1,0.85,0.54}},
    {name = "Gummy", tags = "jeleu jeleuri", body = {0.35,0.91,0.45}, accent = {1,0.96,0.77}},
    {name = "Lollipop", tags = "acadea acadele", body = {0.98,0.40,0.56}, accent = {1,0.95,0.81}},
    {name = "Donut", tags = "gogoasa gogoașă gogosi gogoși", body = {0.93,0.64,0.30}, accent = {1,0.43,0.71}},
    {name = "Cupcake", tags = "briosa brioșă briose brioșe", body = {0.65,0.51,0.95}, accent = {1,0.92,0.72}},
    {name = "Marshmallow", tags = "bezea bezele", body = {1,0.88,0.92}, accent = {0.62,0.30,0.66}},
    {name = "Cookie", tags = "biscuit biscuiti biscuiți", body = {0.89,0.67,0.38}, accent = {0.31,0.15,0.09}},
}
for n = 0, 6766 do
    local code = (n * 137) % 6767
    local palette = code % 17 + 1
    local family = math.floor(code / 850) + 1
    local theme, body = candyThemes[family], {}
    for channel = 1, 3 do
        body[channel] = theme.body[channel] * (0.65 + (palette - 1) * 0.02)
    end
    skins[#skins + 1] = {
        name = string.format("SWEETS %s %03d", theme.name, code % 850 + 1),
        tags = "SWEETS Candy dulciuri dulce desert dessert " .. theme.tags,
        body = body, accent = theme.accent, palette = palette,
        pattern = math.floor(code / 17) % 10 + 1,
        topping = math.floor(code / 170) % 5 + 1, candy = family,
    }
end
local fruits = {
    {"Mango", "mango", "mango", {1,0.63,0.12}, {0.94,0.26,0.18}},
    {"Red Apple", "mar măr rosu roșu", "apple", {0.88,0.16,0.19}, {1,0.66,0.49}},
    {"Green Apple", "mar măr verde", "apple", {0.36,0.73,0.20}, {0.83,0.95,0.48}},
    {"Yellow Apple", "mar măr galben", "apple", {0.99,0.81,0.19}, {1,0.96,0.65}},
    {"Yellow Pear", "para pară galbena galbenă", "pear", {0.88,0.77,0.20}, {0.57,0.43,0.14}},
    {"Banana", "banana banană", "banana", {1,0.85,0.20}, {0.49,0.31,0.12}},
    {"Orange", "portocala portocală clasica clasică", "orange", {1,0.48,0.09}, {1,0.79,0.31}},
    {"Blood Orange", "portocala portocală rosie roșie", "orange", {0.85,0.22,0.12}, {1,0.56,0.27}},
    {"Green Watermelon", "pepene verde", "watermelon", {0.20,0.63,0.29}, {0.08,0.31,0.16}},
    {"Yellow Melon", "pepene galben", "melon", {0.98,0.81,0.26}, {0.76,0.48,0.10}},
    {"Peach", "piersica piersică", "peach", {1,0.62,0.44}, {0.89,0.26,0.32}},
}
for _, fruit in ipairs(fruits) do
    skins[#skins+1] = {name = "FRUIT " .. fruit[1], tags = "fruit fruct fructe " .. fruit[2],
        fruit = fruit[3], body = fruit[4], accent = fruit[5]}
end
skins[#skins+1] = {name = "Godzilla", tags = "heroes hero eroi erou godzilla", hero = "godzilla",
    body = {0.19,0.30,0.28}, accent = {0.26,0.87,1}}
skins[#skins+1] = {name = "King Kong", tags = "heroes hero eroi erou king kong", hero = "kingkong",
    body = {0.33,0.22,0.16}, accent = {0.65,0.45,0.28}}
-- Append new fruit species after the heroes so every saved name and ID stays stable.
local newFruits = {
    {"Strawberry", "capsuna căpșună capsuni căpșuni", "strawberry", {0.92,0.16,0.28}, {1,0.89,0.54}},
    {"Kiwi", "kiwi", "kiwi", {0.48,0.67,0.21}, {0.18,0.23,0.10}},
    {"Pineapple", "ananas", "pineapple", {0.97,0.73,0.18}, {0.62,0.36,0.08}},
    {"Cherry", "cireasa cireașă cirese cireșe", "cherry", {0.67,0.06,0.19}, {0.98,0.36,0.42}},
    {"Grape", "strugure struguri", "grape", {0.43,0.20,0.67}, {0.76,0.57,0.93}},
    {"Lemon", "lamaie lămâie", "lemon", {1,0.91,0.23}, {0.83,0.62,0.07}},
    {"Coconut", "cocos nuca nucă", "coconut", {0.44,0.27,0.16}, {0.94,0.89,0.76}},
    {"Dragon Fruit", "pitaya fructul dragonului", "dragonfruit", {0.93,0.17,0.53}, {0.97,0.93,0.89}},
    {"Blueberry", "afina afină afine", "blueberry", {0.22,0.30,0.64}, {0.55,0.64,0.90}},
    {"Raspberry", "zmeura zmeură", "raspberry", {0.78,0.08,0.33}, {0.98,0.44,0.61}},
    {"Pomegranate", "rodie rodii", "pomegranate", {0.60,0.12,0.18}, {0.99,0.73,0.58}},
    {"Avocado", "avocado", "avocado", {0.22,0.41,0.15}, {0.80,0.89,0.43}},
}
for _, fruit in ipairs(newFruits) do
    skins[#skins+1] = {name = "FRUIT " .. fruit[1], tags = "fruit fruct fructe " .. fruit[2],
        fruit = fruit[3], body = fruit[4], accent = fruit[5]}
end
return skins
