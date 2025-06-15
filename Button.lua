local images = require("images")
local texts = require("texts")
local geomtry = require("geometry")

all_buttons = {}

Button = {}

function Button:new(config)
    obj = {
        event_listeners = {
            left_click = {}
        },
        enabled = true
    }

    setmetatable(obj, self)
    self.__index = self

    local pos = config.pos or { x = 100, y = 100 }

    local btn_config = {
        pos = pos,
        size = config.size or {
            width = 60,
            height = 60
        },
        draggable = false,
        visible = true,
        color = { 255, 0, 255 },
    }

    obj.image = images.new(btn_config)
    obj.image:show()

    obj.label = texts.new()

    -- TODO what size is the font height/width? Do a rough calculation based on several values

    local label_x, label_y = geomtry.center(pos.x, pos.y, 60, 60, 50, 16)

    -- TODO add a move method for button that also moves the label.
    obj.label:pos(label_x, label_y)
    obj.label:color(0, 0, 0)
    obj.label:stroke_alpha(1)
    obj.label:bg_visible(false)
    obj.label:show()



    obj.hovering = false

    table.insert(all_buttons, obj)

    return obj
end

function Button:text(value)
    self.label:text(value)
end

function Button:move(x, y)
    self.x = x
    self.y = y
end

function Button:color(r, g, b)
    self.image:color(r, g, b)
end

function Button:add_event_listener(event, callback)
    -- TODO read about lua arrays and tables - best way to do this?
    -- event is a string

    if not self.event_listeners[event] then
        self.event_listeners[event] = {}
    end

    table.insert(self.event_listeners[event], callback)
end

windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    for _, button in pairs(all_buttons) do
        local hovering = button.image:hover(x, y)

        for _, click_event_listener in pairs(button.event_listeners["left_click"]) do
            -- Mouse release
            -- TODO only do this if the button has a click event listener
            if type == 1 and button.enabled and hovering then
                return true
            end

            if type == 2 and button.enabled and hovering then
                return click_event_listener(button)
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

return Button
