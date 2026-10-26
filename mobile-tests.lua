local Game = require("game")
local originalNew, game = Game.new
Game.new = function(...) game = originalNew(...); return game end
local saved, focused = {}, false
local width, height = 2400, 1080
love = {
    _os = "Android",
    system = {getOS = function() return "Android" end},
    graphics = {
        setDefaultFilter = function() end,
        newFont = function() return {setFilter = function() end, setFallbacks = function() end} end,
        getDimensions = function() return width, height end,
    },
    filesystem = {
        read = function() return nil end,
        write = function(name, value) saved[name] = value; return true end,
    },
    keyboard = {setTextInput = function(value) focused = value end, isDown = function() return false end},
    math = {random = function(max) return max or 0.5 end},
}
dofile("conf.lua")
local config = {window = {}, modules = {}}
love.conf(config)
assert(config.window.fullscreen and not config.window.resizable, "Android must start fullscreen and stay in landscape before system modules load")
dofile("main.lua")
love.load()
local function touch(id, x, y)
    local scale = math.min(width / 1100, height / 680)
    love.touchpressed(id, (width - 1100 * scale) / 2 + x * scale,
        (height - 680 * scale) / 2 + y * scale)
end
love.touchpressed("margin", 0, height / 2)
assert(game.state == "ready", "Letterbox margins must not start the game")
touch("jump", 950, 630)
assert(game.state == "running" and game.player.vy == 720)
touch("duck", 100, 630)
assert(game.duckHeld, "A second finger must hold duck during a jump")
love.touchreleased("duck")
assert(not game.duckHeld and game.player.vy == 720, "Releasing duck must not cut the jump")
love.touchreleased("jump")
assert(game.player.vy == 330, "Releasing jump must shorten the jump")
game.player.y, game.player.vy = 0, 0
touch("duck1", 100, 630); touch("duck2", 110, 630)
love.touchreleased("duck1")
assert(game.player.ducking and game.duckHeld)
love.touchreleased("duck2")
assert(not game.player.ducking and not game.duckHeld)
touch("pause", 280, 630)
assert(game.state == "paused")
love.touchreleased("pause")
touch("resume", 550, 300)
assert(game.state == "running" and game.player.vy == 0, "Tap must resume without jumping")
touch("catalog", 100, 565)
assert(game.state == "paused" and not focused, "Browsing must not automatically show the software keyboard")
touch("search", 100, 125)
assert(focused)
love.textinput("52374")
touch("card", 100, 200)
assert(saved["skin.txt"] == require("skins")[52374].name and not focused)
love.keypressed("acback")
assert(not focused)
touch("resume2", 550, 300)
assert(game.state == "running", "Android Back must close the catalog")
touch("shop", 750, 630)
assert(game.state == "paused")
touch("close", 950, 615)
touch("resume3", 550, 300)
assert(game.state == "running", "Shop must close through touch")
touch("duck3", 100, 630)
love.touchmoved("duck3", 0, 0)
assert(not game.duckHeld, "Sliding off DUCK must release it")
touch("duck4", 100, 630)
love.visible(false)
assert(game.state == "paused" and not game.duckHeld, "Backgrounding must pause and clear held controls")
love.touchreleased("duck4")
touch("restart", 400, 630)
assert(game.state == "ready")
-- Check coordinate transforms on a second aspect ratio.
width, height = 1280, 800
touch("newjump", 950, 630)
assert(game.state == "running" and game.player.vy == 720)
love.touchreleased("newjump")
assert(game.player.vy == 330)
print("OK: Android touch scaling, margins, jump/release, multitouch duck, pause/resume, catalog/search, Back, shop, slide release, background, restart")
