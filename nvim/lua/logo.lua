---@diagnostic disable-next-line
local logo1 = [[
 ███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓   
 ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒   
▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░   
▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██    
▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀██  ░██░▒██▒   ░██▒   
░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░      
░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░   
   ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░      
         ░    ░  ░    ░ ░        ░   ░         ░      
                                  ░                   
]]

---@diagnostic disable-next-line
local logo2 = [[
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQXXXQQQQXXQQXXXXXXQQQXXXXXQQQXXQQQQQQQXXQXXQQXXXQQQXXXQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQXXXXQQQXXQQXXQQQQQQXXQQQXXQQQXXQQQQQXXQQXXQQXXXXQXXXXQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQXXQXXQQXXQQXXXXQQQXXQQQQQXXQQQXXQQQXXQQQXXQQXXQXXXQXXQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQXXQQXXQXXQQXXQQQQQXXQQQQQXXQQQQXXQXXQQQQXXQQXXQQXQQXXQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQXXQQQXXXXQQXXQQQQQQXXQQQXXQQQQQQXXXQQQQQXXQQXXQQQQQXXQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQXXQQQQXXXQQXXXXXXQQQXXXXXQQQQQQQQXQQQQQQXXQQXXQQQQQXXQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQMIHAIFM
]]

local function randomUppercase()
    local char
    repeat
        char = string.char(math.random(65, 90))
    until char ~= 'Q'
    return char
end

local function replaceWithRandomUppercase(str)
  local result = ""
  for i = 1, #str do
    local char = str:sub(i, i)
    if char:match("Q") then
      result = result .. randomUppercase()
    elseif char:match("X") then
      result = result .. " "
    else
      result = result .. char
    end
  end
  return result
end

return replaceWithRandomUppercase(logo2)
