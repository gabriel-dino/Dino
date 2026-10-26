-- Persist cumulative totals; mission levels and rewards are derived, so a
-- completed mission cannot pay twice after a restart or reload.
local Progress = {}
Progress.__index = Progress
Progress.heroes = {
    {key = "godzilla", name = "Godzilla", cost = 200},
    {key = "kingkong", name = "King Kong", cost = 200},
}
Progress.upgrades = {
    {key = "jump", title = "Jump", detail = "+5% jump power / level", base = 50},
    {key = "magnet", title = "Coin magnet", detail = "+20px pickup range / level", base = 75},
    {key = "score", title = "Score", detail = "+10% score / level", base = 100},
    {key = "shield", title = "Shield", detail = "Blocks one hit every run", base = 150, max = 1},
}
local definitions = {
    {key = "coins", title = "Collect coins", base = 30, reward = 25},
    {key = "cacti", title = "Clear cacti", base = 20, reward = 50},
    {key = "points", title = "Earn score", base = 150, reward = 75},
}
function Progress.new(saved)
    local a, b, c = (saved or ""):match("^v1\n(%d+)\n(%d+)\n(%d+)\n?$")
    local v2 = {(saved or ""):match("^v2\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n?$")}
    if #v2 == 6 then a, b, c = v2[1], v2[2], v2[3] end
    local v3 = {(saved or ""):match("^v3\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n?$")}
    if #v3 == 7 then v2 = v3; a, b, c = v3[1], v3[2], v3[3] end
    local v4 = {(saved or ""):match("^v4\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n(%d+)\n([01])\n([01])\n?$")}
    if #v4 == 9 then v3 = v4; v2 = v4; a, b, c = v4[1], v4[2], v4[3] end
    local function value(n) return math.min(1000000000, tonumber(n) or 0) end
    return setmetatable({coins = value(a), cacti = value(b), points = value(c),
        heroes = {godzilla = v4[8] == "1", kingkong = v4[9] == "1"},
        upgrades = {shield = math.min(1, value(v3[7])), jump = math.min(5, value(v2[4])), magnet = math.min(5, value(v2[5])),
            score = math.min(5, value(v2[6]))}}, Progress)
end
function Progress:missions()
    local result = {}
    for _, def in ipairs(definitions) do
        local total = self[def.key]
        local level = math.floor((math.sqrt(1 + 8 * total / def.base) - 1) / 2)
        result[#result + 1] = {title = def.title, level = level,
            current = total - def.base * level * (level + 1) / 2,
            target = def.base * (level + 1), reward = def.reward}
    end
    return result
end
function Progress:wallet()
    local total = self.coins
    for _, mission in ipairs(self:missions()) do total = total + mission.level * mission.reward end
    for _, def in ipairs(Progress.upgrades) do
        local level = self.upgrades[def.key]
        total = total - def.base * level * (level + 1) / 2
    end
    for _, hero in ipairs(Progress.heroes) do
        if self.heroes[hero.key] then total = total - hero.cost end
    end
    return total
end
function Progress:ownsSkin(skin)
    return not skin.hero or self.heroes[skin.hero] == true
end
function Progress:buyHero(key)
    for _, hero in ipairs(Progress.heroes) do
        if hero.key == key then
            if self.heroes[key] then return false, "Already owned" end
            if self:wallet() < hero.cost then return false, "Not enough coins" end
            self.heroes[key] = true
            return true
        end
    end
    return false, "Unknown hero"
end
function Progress:buy(key)
    for _, def in ipairs(Progress.upgrades) do
        if def.key == key then
            local level = self.upgrades[key]
            if level >= (def.max or 5) then return false, "Maximum level reached" end
            local cost = def.base * (level + 1)
            if self:wallet() < cost then return false, "Not enough coins" end
            self.upgrades[key] = level + 1
            return true
        end
    end
    return false, "Unknown upgrade"
end
function Progress:add(coins, cacti, points)
    local before = self:missions()
    self.coins = self.coins + coins
    self.cacti = self.cacti + cacti
    self.points = self.points + points
    local completed, bonus = 0, 0
    for i, mission in ipairs(self:missions()) do
        local count = mission.level - before[i].level
        completed, bonus = completed + count, bonus + count * mission.reward
    end
    return completed, bonus
end
function Progress:serialize()
    return string.format("v4\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", self.coins, self.cacti, self.points,
        self.upgrades.jump, self.upgrades.magnet, self.upgrades.score, self.upgrades.shield,
        self.heroes.godzilla and 1 or 0, self.heroes.kingkong and 1 or 0)
end
return Progress
