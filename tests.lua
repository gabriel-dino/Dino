local Game = require("game")
local function advance(g, seconds)
    for _ = 1, math.floor(seconds * 120) do g:update(1 / 120) end
end
local g = Game.new(function() return 0.5 end)
assert(g.state == "ready")
g:update(1); assert(g.distance == 0)
assert(g:jump()); assert(not g:jump())
advance(g, 0.2); assert(g.player.y > 80)
g:release(); assert(g.player.vy <= 330)
advance(g, 0.6); assert(g.player.y == 0)
g:pause(); local d = g.distance; advance(g, 1); assert(g.distance == d)
g:pause(); assert(g.state == "running")
g.obstacles = {{x = 190, w = 36, h = 68}}
g:update(1 / 120); assert(g.state == "dead")
g:jump(); assert(g.state == "running" and #g.obstacles == 0 and g.score == 0)
g.player.y, g.player.vy = 100, 0
g.obstacles = {{x = 190, w = 36, h = 68}}
g:update(1 / 120); assert(g.state == "running")
g.obstacles = {{x = 125, w = 36, h = 68}}
g:update(1 / 120); assert(g.passed == 1)
g:reset(); g.state = "running"; g.spawn = 999; advance(g, 2)
assert(g.score > 0 and g.speed > 330)
print("OK: start, jump, release, landing, pause, collision, restart, clearance, score")

g:reset(); g.state = "running"; g.spawn = 999
g.coins = {{x = 194, y = 34}, {x = 194, y = 142}, {x = -40, y = 34}}
g:update(1/120)
assert(g.collected == 1 and #g.coins == 1, "Ground pickup, high miss, offscreen cleanup")
g.player.y = 110; g.player.vy = 0
g:update(1/120); assert(g.collected == 2 and #g.coins == 0)
g.coins = {{x = 194, y = 142}}; g:pause()
g:update(1); assert(g.collected == 2 and g.coins[1].x == 194)
g:reset(); assert(g.collected == 0)
g.state = "running"; g.spawn = 999; g.coinSpawn = 0; g:update(1/120)
assert(#g.coins == 4, "Coin groups spawn independently of obstacles")
local Progress = require("progress")
local p = Progress.new()
local count, bonus = p:add(29, 19, 149)
assert(count == 0 and bonus == 0 and p:wallet() == 29)
count, bonus = p:add(1, 1, 1)
assert(count == 3 and bonus == 150 and p:wallet() == 180)
for _, m in ipairs(p:missions()) do assert(m.level == 1 and m.current == 0) end
local loaded = Progress.new(p:serialize())
assert(loaded:wallet() == 180)
count, bonus = loaded:add(0, 0, 0); assert(count == 0 and bonus == 0)
count, bonus = loaded:add(60, 0, 0)
assert(count == 1 and bonus == 25 and loaded:wallet() == 265)
assert(loaded:missions()[1].target == 90)
assert(Progress.new("broken save"):wallet() == 0)
g:reset(); assert(loaded:wallet() == 265, "Run reset must preserve long-term progress")
print("OK: coin height, pickup, cleanup, pause, spawn, mission thresholds, rewards, save/reload, reset")

local legacy = Progress.new("v1\n1000\n0\n0\n")
assert(legacy.upgrades.jump == 0 and legacy:wallet() == 1175)
local wallet = legacy:wallet()
assert(legacy:buy("jump")); assert(legacy:wallet() == wallet - 50)
assert(legacy:buy("magnet")); assert(legacy:buy("score"))
local restored = Progress.new(legacy:serialize())
assert(restored:wallet() == legacy:wallet() and restored.upgrades.jump == 1)
local sharedGame = Game.new(function() return 0.5 end, restored.upgrades)
for _ in ipairs(require("skins")) do
    sharedGame:reset(); sharedGame:jump()
    assert(sharedGame.player.vy == 756, "All skins share upgraded jump after reset")
end
sharedGame.spawn = 999
sharedGame.coins = {{x = 230, y = 34}}
sharedGame:update(1/120)
assert(sharedGame.collected == 1, "Magnet reaches coins outside normal pickup range")
sharedGame.distance = 350; sharedGame:update(1/120)
assert(sharedGame.score == 11, "Score multiplier applies")
local poor = Progress.new()
assert(not poor:buy("jump") and poor.upgrades.jump == 0 and poor:wallet() == 0)
assert(not poor:buy("invalid"))
local rich = Progress.new("v1\n10000\n0\n0\n")
for _ = 1, 5 do assert(rich:buy("jump")) end
wallet = rich:wallet()
assert(not rich:buy("jump") and rich:wallet() == wallet)
assert(wallet == 10625 - 750, "Each level is charged exactly once")
print("OK: global upgrades, all 52399 skins, costs, insufficient funds, cap, effects, legacy saves, reload")

local old = Progress.new("v2\n1000\n0\n0\n1\n1\n1\n")
assert(old.upgrades.shield == 0 and old.upgrades.jump == 1)
wallet = old:wallet()
assert(old:buy("shield") and old:wallet() == wallet - 150)
assert(not old:buy("shield"))
local shieldSave = Progress.new(old:serialize())
assert(shieldSave.upgrades.shield == 1 and shieldSave:wallet() == old:wallet())
local protected = Game.new(function() return 0.5 end, shieldSave.upgrades)
protected.state = "running"; protected.spawn = 999
protected.obstacles = {{x = 190, w = 36, h = 68}}
protected:update(1/120)
assert(protected.state == "running" and protected.shields == 0 and protected.shieldFlash > 0)
protected:update(1/120)
assert(protected.state == "running", "Same cactus cannot hit again")
protected:pause(); local flash = protected.shieldFlash
protected:update(1); assert(protected.shieldFlash == flash)
protected:pause(); advance(protected, 1)
assert(protected.passed == 0, "Broken cactus cannot earn clearance reward")
protected.obstacles = {{x = 190, w = 36, h = 68}}
protected:update(1/120); assert(protected.state == "dead", "Next hit ends run")
protected:jump(); assert(protected.shields == 1 and protected.shieldFlash == 0)
for _ in ipairs(require("skins")) do
    protected:reset(); assert(protected.shields == 1)
end
print("OK: shield purchase, save migration, hit protection, break effect, pause, next hit, recharge, all skins")

local function flying(y, playerY, shield)
    local run = Game.new(function() return 0.2 end, {jump = 0, magnet = 0, score = 0, shield = shield or 0})
    run.state, run.spawn = "running", 999
    run.player.y = playerY or 0
    run.obstacles = {{kind = "bird", x = 190, y = y, w = 56, h = 30}}
    run:update(1/120)
    return run
end
assert(flying(32).state == "dead", "Low bird hits grounded player")
assert(flying(32, 90).state == "running", "Jump clears low bird")
assert(flying(100).state == "running", "Grounded player fits under high bird")
assert(flying(100, 90).state == "dead", "Jumping into high bird collides")
local birdShield = flying(32, 0, 1)
assert(birdShield.state == "running" and birdShield.shields == 0 and birdShield.shieldFlash > 0)
local birds = Game.new(function() return 0.2 end)
birds.state, birds.time, birds.spawn = "running", 12, 0
birds:update(1/120)
assert(birds.obstacles[1].kind == "bird" and birds.obstacles[1].y == 24)
birds:pause(); local birdX = birds.obstacles[1].x
birds:update(1); assert(birds.obstacles[1].x == birdX)
birds:pause(); birds.spawn = 999
birds.obstacles = {{kind = "bird", x = 100, y = 100, w = 56, h = 30}}
birds:update(1/120)
assert(birds.birdsPassed == 1 and birds.passed == 0, "Birds do not count as cacti missions")
birds:update(1/120); assert(birds.birdsPassed == 1)
birds.obstacles[1].x = -101; birds:update(1/120); assert(#birds.obstacles == 0)
birds:reset(); assert(birds.birdsPassed == 0)
local early = Game.new(function() return 0.2 end)
early.state, early.spawn = "running", 0; early:update(1/120)
assert(early.obstacles[1].kind == "cactus", "Birds start after warmup")
local choices = {0.5, 0.2, 0.8, 0.5}
local high = Game.new(function() return table.remove(choices, 1) or 0.5 end)
high.state, high.time, high.spawn = "running", 12, 0; high:update(1/120)
assert(high.obstacles[1].y == 100)
print("OK: low/high birds, jump clearance, shield, spawn, warmup, pause, cleanup, separate counters")

local duck = Game.new(function() return 0.5 end)
duck.state, duck.spawn = "running", 999
duck:duck(true)
assert(duck.player.h == 34 * duck.playerScale and duck.player.ducking)
duck.obstacles = {{kind = "bird", x = 190, y = 48, w = 56, h = 30}}
duck:update(1/120); assert(duck.state == "running", "Duck clears middle bird")
duck:duck(false); duck:update(1/120)
assert(duck.state == "dead", "Standing collides with middle bird")
duck:reset(); duck.state, duck.spawn = "running", 999; duck:duck(true)
duck.obstacles = {{kind = "bird", x = 190, y = 24, w = 56, h = 30}}
duck:update(1/120); assert(duck.state == "dead", "Low birds still require jumping")
duck:reset(); duck:duck(true); assert(duck:jump())
assert(duck.player.h == 66 * duck.playerScale and not duck.player.ducking)
duck.spawn = 999; duck.coins = {}; advance(duck, 1)
assert(duck.player.y == 0 and duck.player.h == 34 * duck.playerScale, "Held duck resumes on landing")
duck:duck(false); assert(duck.player.h == 66 * duck.playerScale)
duck:duck(true); duck:reset(); assert(not duck.duckHeld and duck.player.h == 66 * duck.playerScale)
for _, pair in ipairs({{0,"DESERT"},{249,"DESERT"},{250,"JUNGLE"},{499,"JUNGLE"},{500,"SNOW"},{750,"DESERT"}}) do
    duck.score = pair[1]; assert(duck:zone() == pair[2])
end
local middleChoices = {0.5, 0.2, 0.5, 0.5}
local middle = Game.new(function() return table.remove(middleChoices, 1) or 0.5 end)
middle.state, middle.time, middle.spawn = "running", 12, 0; middle:update(1/120)
assert(middle.obstacles[1].y == 48)
print("OK: duck collision, release, low birds, jump, landing, reset, middle bird spawn, zone thresholds")
