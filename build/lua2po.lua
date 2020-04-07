local output

local function convert(msgid, msgstr)
    output:write(string.format("msgid \"%s\"\n", msgid))
    output:write(string.format("msgstr \"%s\"\n\n", msgstr))
end

function LibGetText()
    return {settext = convert}
end

if(not arg[1]) then
    print("no source file specified")
elseif(not arg[2]) then
    print("no target file specified")
else
    print(string.format("convert %s and store in %s", arg[1], arg[2]))
    output = io.open(arg[2], "w+")
    if(output) then
        local loaded_chunk = assert(loadfile(arg[1]))
        loaded_chunk()
        print("conversion finished")
    else
        print("failed to create target file")
    end
end
