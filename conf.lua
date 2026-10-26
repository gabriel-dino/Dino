function love.conf(t)
    t.identity = "dino-desert-run"
    t.version = "11.5"
    t.window.title = "DINO — Desert Run"
    t.window.width = 1100
    t.window.height = 680
    t.window.resizable = true
    t.window.minwidth = 640
    t.window.minheight = 420
    t.window.vsync = 1
    -- love.system is not loaded yet while LÖVE reads conf.lua.
    if love._os == "Android" then
        t.window.fullscreen = true
        t.window.resizable = false
    end
    t.modules.joystick = false
    t.modules.physics = false
end
