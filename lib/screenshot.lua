-- depends: imagemagick

local awful = require("awful")

local ss = {}
ss.directory = "~/screenshots"
ss.extension = "png"

function ss.take(region)
    local dir = string.gsub(ss.directory, "~", os.getenv("HOME"))
    local path = string.format("%s/%s.%s", dir, os.date("%F-%H-%M-%S"),
        ss.extension)
    awful.spawn(
        string.format("import %s %s", region and "" or "-window root", path))
end

return ss
