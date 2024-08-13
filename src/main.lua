local convert = (function()
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
            ["dark"] = "40",
            ["clear"] = "0",
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
        local f = 0
        for a, b, c in string.gmatch(str, "&([a-zA-Z]+)%-([a-zA-Z]+)%-([a-zA-Z]+);") do
            local e = "&" .. a .. "-" .. b .. "-" .. c .. ";"
            local d = str:find(e,f+1,true)
            f = d
            table.insert(final,{d,e})
        end
        f = 0
        for a, b in string.gmatch(str, "&([a-zA-Z]+)%-([a-zA-Z]+);") do
            local e = "&" .. a .. "-" .. b .. ";"
            local d = str:find(e,f+1,true)
            f = d
            table.insert(final,{d,e})
        end
        f = 0
        for a in string.gmatch(str, "&([a-zA-Z]+);") do
            local e = "&" .. a .. ";"
            local d = str:find(e,f+1,true)
            f = d
            table.insert(final,{d,e})
        end

        table.sort(final,function(a,b)
            print(a[1])
            return a[1] < b[1]
        end)

        local matches = {}

        for _, v in pairs(final) do
            table.insert(matches, v[2])
        end

        return matches
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
                print(code_type,code,current[code_type])
            end
            
            local cmd = current["format"]..";"..current["background"]..";"..current["color"].."m"
            final = string.gsub(final,command:gsub("%-","%%%-"),magic_symbol..cmd,1)
        end
        return final
    end

    return convert
end)()
local messages = (function()
    local messages = {}

    messages.help_command = [[
    &bold-blue-light;[       Discord ANSI Formatter       ]&clear-reset;&white;
    For all your discord colored needs.

    &yellow-highlight;[               Help                 ]&clear-reset;&white;
    ds_af help - &blue-clear-bold;Shows this help panel&clear-reset-white;
    ds_af file &green;<file_path>&white; - &blue-clear-bold;Converts a file into .dsansi&clear-reset-white;
    ds_af preview &green;<text>&white; - &blue-clear-bold;Converts a file and prints back a preview&clear-reset-white;
    ds_af text &green;<text>&white; - &blue-clear-bold;Converts text and prints back a preview&clear-reset-white;

    &yellow-highlight;[              Credit                ]&clear-reset;&white;
    Created by guhw with lua using luvi
    ]]

    messages.no_file = "&red;File does not exist.&white;"

    return messages
end)()
local io = require("io")

if args[1] == "file" or args[1] == "preview" then
    local fn = table.concat(args," ",2)
    local file = io.open(fn,"r")
    if file then
        local content = file:read("a")
        file:close()

        local converted = convert(content)
        if args[1] == "file" then
            local writing = io.open(fn.."_conv.dsansi","w+")
            assert(writing,"that's not supposed to happen! check if you have permissions.")
            writing:write(converted)
            writing:close()
        else
            print(converted)
        end
    else
        print(convert(messages.no_file))
    end
elseif args[1] == "text" then
    print(convert(table.concat(args," ",2)))
else
    print(convert(messages.help_command)) -- ds_af help doesn't actually exist
end