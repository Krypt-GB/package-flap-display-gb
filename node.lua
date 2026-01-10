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
------------------------------------------------------------
local Display = function(display_cols, display_rows, style_name)
    local style = styles[style_name]
    local t = resource.load_image(style.texture)

    local function make_mapping(cols, rows, tw, th)
        local chars = {}
        for i = 0, #style.charset * style.steps - 1 do
            local cw = tw / cols
            local ch = th / rows
            local x = (i % cols) * cw
            local y = math.floor(i / cols) * ch
            chars[#chars+1] = function(x1, y1, x2, y2)
                t:draw(x1, y1, x2, y2, 1.0,
                    x/tw, y/th, (x+cw)/tw, (y+ch)/th)
            end
        end
        return chars
    end

    local charmap = make_mapping(
        style.cols, style.rows, style.width, style.height
    )

    --------------------------------------------------------
    -- Single row
    --------------------------------------------------------
    local row = function(rowsize)
        local function mkzeros(n)
            local out = {}
            for i = 1, n do out[#out+1] = 0 end
            return out
        end

        local current = mkzeros(rowsize)
        local target  = mkzeros(rowsize)

        local function set(value)
            local len = utf8.len(value)
            if len < rowsize then
                value = value .. string.rep(" ", rowsize - len)
            end
            for i = 1, rowsize do
                local char = utf8.lower(utf8.sub(value, i, i))
                local pos = utf8.find(style.charset, char, 1, true)
                if not pos then pos = 1 end
                target[i] = (pos - 1) * style.steps
            end
        end

        local function tick()
            for i = 1, rowsize do
                if current[i] ~= target[i] then
                    current[i] = current[i] + 1
                    if current[i] >= utf8.len(style.charset) * style.steps then
                        current[i] = 0
                    end
                end
            end
        end

        local function draw(y, charh)
            local charw = WIDTH / rowsize
            local margin = 2
            for i = 1, rowsize do
                charmap[current[i] + 1](
                    (i-1)*charw + margin,
                    y + margin,
                    i*charw - margin,
                    y + charh - margin
                )
            end
        end

        return {
            set = set;
            tick = tick;
            draw = draw;
        }
    end

    -------------------------------------------------------
