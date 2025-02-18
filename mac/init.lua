-- key define
local hyper = { "ctrl", "alt", "cmd" }
local hyperShift = { "ctrl", "alt", "cmd", "shift" }

-- screen ratios
local WIDTH_RATIOS = { 0.75, 0.6, 0.5, 0.4, 0.25 }
local HEIGHT_RATIOS = { 0.75, 0.5, 0.25 }
local BASE_RATIOS = { 1.0, 0.9, 0.7, 0.5 }

-- ----------------------------
-- window management utilities
-- ----------------------------
local function getWindowFrame()
    local win = hs.window.focusedWindow()
    if not win then return nil end
    return win, win:frame(), win:screen():frame()
end

local function setWindowFrame(win, f)
    if win then win:setFrame(f) end
end

-- ----------------------------
-- Key binding implementations
-- ----------------------------
local function getDebugInfo()
    local win, f, max = getWindowFrame()
    if not win then return "No window focused" end

    return string.format("Window ID: %s\nWindow Frame: [%d, %d, %d, %d]\nScreen Frame: [%d, %d, %d, %d]",
        win:id(),
        f.x, f.y, f.w, f.h,
        max.x, max.y, max.w, max.h)
end

local function moveToCenter()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x + (max.w - f.w) / 2
    f.y = max.y + (max.h - f.h) / 2
    setWindowFrame(win, f)
end

local function moveToEdge(edge)
    local win, f, max = getWindowFrame()
    if not win then return end

    if edge == "Left" then
        f.x = max.x
    elseif edge == "Right" then
        f.x = max.x + (max.w - f.w)
    elseif edge == "Top" then
        f.y = max.y
    elseif edge == "Bottom" then
        f.y = max.y + (max.h - f.h)
    end

    setWindowFrame(win, f)
end

local function toHalfScreen(edge)
    local win, f, max = getWindowFrame()
    if not win then return end

    if edge == "Left" then
        f.w = math.floor(max.w / 2)
        f.h = max.h
        f.x = max.x
        f.y = max.y
    elseif edge == "Right" then
        f.w = math.floor(max.w / 2)
        f.h = max.h
        f.x = max.x + (max.w - f.w)
        f.y = max.y
    elseif edge == "Top" then
        f.w = max.w
        f.h = math.floor(max.h / 2)
        f.x = max.x
        f.y = max.y
    elseif edge == "Bottom" then
        f.w = max.w
        f.h = math.floor(max.h / 2)
        f.x = max.x
        f.y = max.y + (max.h - f.h)
    end

    setWindowFrame(win, f)
end

local function loopWidth(edge)
    local win, f, max = getWindowFrame()
    if not win then return end

    local current = f.w / max.w
    local nextRatio = WIDTH_RATIOS[1]

    for i, ratio in ipairs(WIDTH_RATIOS) do
        if math.abs(current - ratio) < 0.01 then
            nextRatio = WIDTH_RATIOS[i + 1] or WIDTH_RATIOS[1]
            break
        end
    end

    f.w = math.floor(max.w * nextRatio)
    f.x = edge == "Right" and (max.x + (max.w - f.w)) or max.x

    setWindowFrame(win, f)
end

local function loopHeight(edge)
    local win, f, max = getWindowFrame()
    if not win then return end

    local current = f.h / max.h
    local nextRatio = HEIGHT_RATIOS[1]

    for i, ratio in ipairs(HEIGHT_RATIOS) do
        if math.abs(current - ratio) < 0.01 then
            nextRatio = HEIGHT_RATIOS[i + 1] or HEIGHT_RATIOS[1]
            break
        end
    end

    f.h = math.floor(max.h * nextRatio)
    f.y = edge == "Bottom" and (max.y + (max.h - f.h)) or max.y

    setWindowFrame(win, f)
end

local function loopFixedRatio(ratio)
    local win, f, max = getWindowFrame()
    if not win then return end

    local screenM = math.min(max.w, max.h)
    local baseW = math.floor(screenM * ratio)
    local baseH = screenM
    
    local current = f.w / baseW
    local nextRatio = BASE_RATIOS[1]

    for i, r in ipairs(BASE_RATIOS) do
        if math.abs(current - r) < 0.01 then
            nextRatio = BASE_RATIOS[i + 1] or BASE_RATIOS[1]
            break
        end
    end

    f.w = math.floor(baseW * nextRatio)
    f.h = math.floor(baseH * nextRatio)

    f.x = max.x + (max.w - f.w) / 2
    f.y = max.y + (max.h - f.h) / 2

    setWindowFrame(win, f)
end

-- ----------------------------
-- Actions
-- ----------------------------

-- hello world
hs.hotkey.bind(hyper, "W", function()
    hs.alert.show(getDebugInfo())
end)

hs.hotkey.bind(hyperShift, "W", function()
    hs.notify.new({ title = "Hammerspoon", informativeText = "Hello World" }):send()
end)

-- Center window
hs.hotkey.bind(hyper, "C", moveToCenter)
hs.hotkey.bind(hyperShift, "C", moveToCenter)
hs.hotkey.bind(hyper, "delete", moveToCenter)
hs.hotkey.bind(hyperShift, "delete", moveToCenter)
hs.hotkey.bind(hyper, "forwarddelete", moveToCenter)
hs.hotkey.bind(hyperShift, "forwarddelete", moveToCenter)

-- Move to edges
hs.hotkey.bind(hyper, "Home", function() moveToEdge("Left") end)
hs.hotkey.bind(hyperShift, "Home", function() moveToEdge("Left") end)
hs.hotkey.bind(hyper, "End", function() moveToEdge("Right") end)
hs.hotkey.bind(hyperShift, "End", function() moveToEdge("Right") end)
hs.hotkey.bind(hyper, "PageUp", function() moveToEdge("Top") end)
hs.hotkey.bind(hyperShift, "PageUp", function() moveToEdge("Top") end)
hs.hotkey.bind(hyper, "PageDown", function() moveToEdge("Bottom") end)
hs.hotkey.bind(hyperShift, "PageDown", function() moveToEdge("Bottom") end)

-- Move to another screen
hs.hotkey.bind(hyper, "J", function()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():toEast()) end
end)

hs.hotkey.bind(hyper, "K", function()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():toWest()) end
end)

-- Half screen
hs.hotkey.bind(hyperShift, "Left", function() toHalfScreen("Left") end)
hs.hotkey.bind(hyperShift, "Right", function() toHalfScreen("Right") end)
hs.hotkey.bind(hyperShift, "Up", function() toHalfScreen("Top") end)
hs.hotkey.bind(hyperShift, "Down", function() toHalfScreen("Bottom") end)

-- Loop 3/4, 3/5, 1/2, 2/5, 1/4 screen width
hs.hotkey.bind(hyper, "Left", function() loopWidth("Left") end)
hs.hotkey.bind(hyper, "Right", function() loopWidth("Right") end)

-- Loop 3/4, 1/2, 1/4 screen height
hs.hotkey.bind(hyper, "Up", function() loopHeight("Top") end)
hs.hotkey.bind(hyper, "Down", function() loopHeight("Bottom") end)

-- Maximize window
hs.hotkey.bind(hyperShift, "M", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    loopFixedRatio(max.w/max.h)
end)

hs.hotkey.bind(hyper, "M", function()
    loopFixedRatio(4/3)
end)
hs.hotkey.bind(hyper, "Return", function()
    loopFixedRatio(4/3)
end)
