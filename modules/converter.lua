local magic_symbol = "["

function split(inputstr, sep) sep=sep or '%s' local t={}  for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do table.insert(t,field)  if s=="" then return t end end end

local codes = {
    ["color"] = {
        ["black"] = "30",
        ["red"] = "31",
        ["green"] = "32",
        ["yellow"] = "33",
        ["blue"] = "34",
        ["pink"] = "35",
        ["aqua"] = "36",
        ["white"] = "37",
    },
    ["background"] = {
        ["clear"] = "0",
        ["dark"] = "40",
        ["light"] = "47",
        ["highlight"] = "45",
        ["warn"] = "41",
    },
    ["format"] = {
        ["reset"] = "0",
        ["bold"] = "1",
        ["under"] = "4",
    }
}

local function guess_code_type(code)
    if codes["color"][code] then
        return "color"
    elseif codes["background"][code] then
        return "background"
    elseif codes["format"][code] then
        return "format"
    end
end

local function capture_commands(str)
    local final = {}
    for a, b, c in string.gmatch(str, "&([a-zA-Z]+)%-([a-zA-Z]+)%-([a-zA-Z]+);") do
        table.insert(final,"&" .. a .. "-" .. b .. "-" .. c .. ";")
    end
    for a, b in string.gmatch(str, "&([a-zA-Z]+)%-([a-zA-Z]+);") do
        table.insert(final,"&" .. a .. "-" .. b .. ";")
    end
    for a in string.gmatch(str, "&([a-zA-Z]+);") do
        table.insert(final,"&" .. a .. ";")
    end
    return final
end

local function convert(str)
    local final = str

    local current = {
        ["format"] = codes["format"]["reset"],
        ["background"] = codes["background"]["clear"],
        ["color"] = codes["color"]["white"]
    }

    for _,command in pairs(capture_commands(str)) do
        for _,code in pairs(split(command:sub(2,command:len()-1),"%-")) do
            local code_type = guess_code_type(code)
            assert(code_type,"'"..code.."' is an invalid command.\n\n")
            current[code_type] = codes[code_type][code]
        end
        
        local cmd = current["format"]..";"..current["background"]..";"..current["color"].."m"
        final = string.gsub(final,command:gsub("%-","%%%-"),magic_symbol..cmd,1)
    end
    return final
end

return convert