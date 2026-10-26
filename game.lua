-- Pure Lua simulation: rendering and input live in main.lua.
local Game = {}
Game.__index = Game
function Game.new(random, upgrades, playerScale)
    local self = setmetatable({random = random or math.random, playerScale = playerScale or 1.35,
        upgrades = upgrades or {jump = 0, magnet = 0, score = 0}}, Game)
    self:reset()
    return self
end
function Game:reset()
    self.state, self.time, self.distance, self.score = "ready", 0, 0, 0
    self.speed, self.spawn, self.obstacles = 330, 1.6, {}
    self.duckHeld = false
    self.player = {x = 170, y = 0, vy = 0, w = 44 * self.playerScale, h = 66 * self.playerScale}
    self.shields = self.upgrades.shield or 0
    self.shieldFlash, self.invulnerable = 0, 0
    self.passed, self.birdsPassed = 0, 0
    self.coins, self.collected = {}, 0
    self.coinSpawn = 0.35 + self.random() * 0.9
end
function Game:spawnCoins()
    local count = 1 + math.min(5, math.floor(self.random() * 6))
    local x = 1140 + self.random() * 160
    for _ = 1, count do
        local y = 26 + self.random() * 94
        local safe = true
        for _, o in ipairs(self.obstacles) do
            if not o.broken and x > o.x - 20 and x < o.x + o.w + 20
                and y > (o.y or 0) - 16 and y < (o.y or 0) + o.h + 16 then safe = false end
        end
        if safe then table.insert(self.coins, {x = x, y = y}) end
        x = x + 36 + self.random() * 28
    end
    self.coinSpawn = 0.7 + self.random() * 1.8
end
function Game:duck(held)
    self.duckHeld = held
    local p = self.player
    p.ducking = held and p.y == 0 and self.state ~= "dead"
    p.h = (p.ducking and 34 or 66) * self.playerScale
end
function Game:zone()
    return ({"DESERT", "JUNGLE", "SNOW"})[math.floor(self.score / 250) % 3 + 1]
end
function Game:jump()
    if self.state == "dead" then self:reset() end
    if self.state == "ready" then self.state = "running" end
    if self.state == "running" and self.player.y == 0 and self.player.vy == 0 then
        self.player.ducking, self.player.h = false, 66 * self.playerScale
        self.player.vy = 720 * (1 + 0.05 * self.upgrades.jump)
        return true
    end
end
function Game:release()
    if self.player.vy > 330 then self.player.vy = 330 end
end
function Game:pause()
    if self.state == "running" then self.state = "paused"
    elseif self.state == "paused" then self.state = "running" end
end
function Game:update(dt)
    if self.state ~= "running" then return end
    self.shieldFlash = math.max(0, self.shieldFlash - dt)
    self.invulnerable = math.max(0, self.invulnerable - dt)
    self.time = self.time + dt
    self.speed = math.min(650, 330 + self.time * 3.5)
    self.distance = self.distance + self.speed * dt
    self.score = math.floor(self.distance / 35 * (1 + 0.1 * self.upgrades.score))
    local p = self.player
    p.vy = p.vy - 1900 * dt
    p.y = math.max(0, p.y + p.vy * dt)
    if p.y == 0 then p.vy = 0 end
    self:duck(self.duckHeld)
    self.spawn = self.spawn - dt
    if self.spawn <= 0 then
        local bird = self.time >= 12 and self.random() < 0.3
        local heightRoll = bird and self.random() or 0
        local low = bird and heightRoll < 1/3
        local birdHeight = low and 24 or (heightRoll < 2/3 and 48 or 100)
        if bird then
            table.insert(self.obstacles, {kind = "bird", x = 1140, y = birdHeight,
                w = 56, h = 30, passed = false})
        else
            local wide = self.random() > 0.65
            table.insert(self.obstacles, {kind = "cactus", x = 1140, y = 0,
                w = wide and 66 or 36, h = wide and 54 or 68, passed = false})
        end
        -- Both entities move at the same speed. Remove any overlap with a
        -- newly spawned obstacle while the coins are still outside the screen.
        local obstacle = self.obstacles[#self.obstacles]
        for i = #self.coins, 1, -1 do
            local coin = self.coins[i]
            if coin.x > obstacle.x - 20 and coin.x < obstacle.x + obstacle.w + 20
                and coin.y > obstacle.y - 16 and coin.y < obstacle.y + obstacle.h + 16 then
                table.remove(self.coins, i)
            end
        end
        -- At least 1.25 seconds between obstacles, even at maximum speed.
        self.spawn = 1.25 + self.random() * 0.65
    end
    self.coinSpawn = self.coinSpawn - dt
    if self.coinSpawn <= 0 then self:spawnCoins() end
    for i = #self.obstacles, 1, -1 do
        local o = self.obstacles[i]
        o.x = o.x - self.speed * dt
        if not o.broken and p.x + p.w - 7 > o.x + 5 and p.x + 7 < o.x + o.w - 5
            and p.y + 7 < (o.y or 0) + o.h
            and p.y + p.h - 3 > (o.y or 0) then
            if self.invulnerable > 0 then
                o.broken = true
            elseif self.shields > 0 then
                self.shields = self.shields - 1
                self.shieldFlash, self.invulnerable = 0.8, 0.8
                o.broken = true
            else
                self.state = "dead"
                return
            end
        end
        if not o.broken and not o.passed and o.x + o.w < p.x then
            o.passed = true
            if o.kind == "bird" then self.birdsPassed = self.birdsPassed + 1
            else self.passed = self.passed + 1 end
        end
        if o.x < -100 then table.remove(self.obstacles, i) end
    end
    for i = #self.coins, 1, -1 do
        local coin = self.coins[i]
        coin.x = coin.x - self.speed * dt
        local nearestX = math.max(p.x + 5, math.min(coin.x, p.x + p.w - 4))
        local nearestY = math.max(p.y + 4, math.min(coin.y, p.y + p.h - 3))
        if (coin.x - nearestX)^2 + (coin.y - nearestY)^2 <= (12 + 20 * self.upgrades.magnet)^2 then
            self.collected = self.collected + 1
            table.remove(self.coins, i)
        elseif coin.x < -30 then table.remove(self.coins, i) end
    end
end
return Game
