geometry = {}

function geometry.center(x, y, width, height, inner_width, inner_height)
    return x + (width - inner_width) / 2, y + (height - inner_height) / 2
end

return geometry
