-- key define
local hyper = { "ctrl", "alt", "cmd" }
local hyperShift = { "ctrl", "alt", "cmd", "shift" }

-- screen ratios
local WIDTH_RATIOS = { 0.75, 0.6, 0.5, 0.4, 0.25 }
local HEIGHT_RATIOS = { 0.75, 0.5, 0.25 }
local BASE_RATIOS = { 1.0, 0.9, 0.7, 0.5 }

-- ------
-- hello world
-- ------
hs.hotkey.bind(hyper, "W", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    hs.alert.show(string.format("Valid screen size: %d x %d", max.w, max.h))
end)

hs.hotkey.bind(hyperShift, "W", function()
    hs.notify.new({ title = "Hammerspoon", informativeText = "Hello World" }):send()
end)


-- ------
-- Center window
-- ------
hs.hotkey.bind(hyper, "C", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x + (max.w - f.w) / 2
    f.y = max.y + (max.h - f.h) / 2
    setWindowFrame(win, f)
end)

-- ------
-- Move to edges
-- ------
hs.hotkey.bind(hyper, "Home", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x
    f.y = f.y
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyper, "End", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x + (max.w - f.w)
    f.y = f.y
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyper, "PageUp", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = f.x
    f.y = max.y
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyper, "PageDown", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = f.x
    f.y = max.y + (max.h - f.h)
    setWindowFrame(win, f)
end)

-- ------
-- Move to another screen
-- ------
hs.hotkey.bind(hyper, "J", function()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():toEast()) end
end)

hs.hotkey.bind(hyper, "K", function()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():toWest()) end
end)

-- ------
-- Half screen
-- ------
-- vertical
hs.hotkey.bind(hyperShift, "Left", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyperShift, "Right", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    setWindowFrame(win, f)
end)

-- horizonal
hs.hotkey.bind(hyperShift, "Up", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h / 2
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyperShift, "Down", function()
    local win, f, max = getWindowFrame()
    if not win then return end

    f.x = max.x
    f.y = max.y + (max.h - f.h)
    f.w = max.w
    f.h = max.h / 2
    setWindowFrame(win, f)
end)

-- ------
-- Loops
-- ------
-- loop width ratios
hs.hotkey.bind(hyper, "Left", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    cycleRatios(f, max, WIDTH_RATIOS, true, false)
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyper, "Right", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    cycleRatios(f, max, WIDTH_RATIOS, true, true)
    setWindowFrame(win, f)
end)

-- loop height ratios
hs.hotkey.bind(hyper, "Up", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    cycleRatios(f, max, HEIGHT_RATIOS, false, false)
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyper, "Down", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    cycleRatios(f, max, HEIGHT_RATIOS, false, true)
    setWindowFrame(win, f)
end)

-- ------
-- Maximize window
-- ------
hs.hotkey.bind(hyperShift, "M", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    cycleFixedRatioWindow(f, max, max.w/max.h)
    setWindowFrame(win, f)
end)

hs.hotkey.bind(hyper, "M", function()
    local win, f, max = getWindowFrame()
    if not win then return end
    cycleFixedRatioWindow(f, max, 4/3)
    setWindowFrame(win, f)
end)

-- ------
-- window management utilities
-- ------
local function getWindowFrame()
    local win = hs.window.focusedWindow()
    if not win then return nil end
    return win, win:frame(), win:screen():frame()
end

local function setWindowFrame(win, f)
    if win then win:setFrame(f) end
end

local function cycleRatios(f, max, ratios, isWidth, alignRight)
    local size = isWidth and f.w or f.h
    local maxSize = isWidth and max.w or max.h

    for i, ratio in ipairs(ratios) do
        if size == math.floor(maxSize * ratio) then
            local nextRatio = ratios[i + 1] or ratios[1]
            if isWidth then
                f.w = math.floor(maxSize * nextRatio)
                f.x = alignRight and (max.x + math.floor(max.w * (1 - nextRatio))) or max.x
            else
                f.h = math.floor(maxSize * nextRatio)
                f.y = alignRight and (max.y + (max.h - f.h)) or max.y
            end
            return true
        end
    end

    if isWidth then
        f.w = math.floor(maxSize * ratios[1])
        f.x = alignRight and (max.x + math.floor(max.w * (1 - ratios[1]))) or max.x
    else
        f.h = math.floor(maxSize * ratios[1])
        f.y = alignRight and (max.y + (max.h - f.h)) or max.y
    end
    return true
end

local function cycleFixedRatioWindow(f, max, ratio)
    local basew = math.floor(max.h * ratio)
    local baseh = max.h

    f.x = max.x
    f.y = max.y

    for i, ratio in ipairs(BASE_RATIOS) do
        if f.w == math.floor(basew * ratio) then
            local nextRatio = BASE_RATIOS[i + 1] or BASE_RATIOS[1]
            f.w = math.floor(basew * nextRatio)
            f.h = math.floor(baseh * nextRatio)
            return true
        end
    end

    f.w = math.floor(basew * BASE_RATIOS[1])
    f.h = math.floor(baseh * BASE_RATIOS[1])
    return true
end
