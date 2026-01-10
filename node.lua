-- vim: set fileencoding=utf8:

gl.setup(1920, 1080)
local utf8 = require "utf8"

-- give this node the alias 'display'
node.alias "display"

util.no_globals()

------------------------------------------------------------
-- Horizontal centering helper
------------------------------------------------------------
local function center_text(text, width)
    local len = utf8.len(text)
    if not len then
        return text
    end
    if len >= width then
        return utf8.sub(text, 1, width)
    end
    local pad = math.floor((width - len) / 2)
    return string.rep(" ", pad) .. text
end

------------------------------------------------------------
-- Styles
------------------------------------------------------------
local styles = {
    classic = {
        charset = ' abcdefghijklmnopqrstuvwxyzäöü0123456789@#-.,:?!()',
        texture = 'style-classic.png',
        rows = 13,
        cols = 20,
        width = 2000,
        height = 1950,
        steps = 5,
    },
    spanish1 = {
        charset = ' abcdefghijklmnopqrstuvwxyz0123456789ñáéíóú&@#?!/()\"\':=+-…,.',
        texture = 'style-spanish1.png',
        rows = 15,
        cols = 34,
        width = 2040,
        height = 1200,
        steps = 8,
    }
}

------------------------------------------------------------
-- Display object
---
