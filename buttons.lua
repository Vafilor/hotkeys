local images = require("images")

local meta = {}
saved_buttons = {}
local buttons = {}

_libs = _libs or {}
_libs.buttons = buttons

_meta = _meta or {}
_meta.Button = _meta.Button or {}
_meta.Button.__class = 'Button'
_meta.Button.__index = buttons

local set_value = function(t, key, value)
    local m = meta[t]
    m.values[key] = value
    m.images[key] = value ~= nil and (m.formats[key] and m.formats[key]:format(value) or tostring(value)) or m.defaults[key]
end

_meta.Button.__newindex = function(t, k, v)
    set_value(t, k, v)
end


function buttons.new(x, y)
    local t = {}
    local button = {}
    meta[t] = button

    local btn_config = {
        pos = { 
            x = x,
            y = y 
        },
        size= {
            width = 100,
            height = 100
        },
        draggable = false,
        visible = true,
        color = {255, 0, 255},
    }

    button.image = images.new(btn_config)
    button.image:show()

    button.hovering = false

    table.insert(saved_buttons, 1, t)

    return setmetatable(t, _meta.Button)
end


function buttons.add_event_listener(t, event, callback)
    if not meta[t] then
        return
    end

    meta[t].click_event_listener = callback
end


windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    for _, t in pairs(saved_buttons) do
        local button = meta[t]
        local hovering = button.image:hover(x,y)

        -- Mouse release
        if type == 1 and hovering then
            return true
        end

        if type == 2 and hovering then
            if button.click_event_listener then
                return button.click_event_listener(button)
            end
        end

        if hovering and not button.hovering then
            button.hovering = true
            button.image:color(200, 100, 100)
            -- TODO event
        end

        if not hovering and button.hovering then
            button.hovering = false
            button.image:color(195, 95, 95)
            -- TODO event
        end
    end

    return false
end)

return buttons