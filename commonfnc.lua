

function addMessage (string)
    
    logText = logText .. "\n" ..  string
    logMsgCounter = logMsgCounter + 1
    if logMsgCounter > 16 then
        --messagesText:clear()
        logMsgCounter = 0
        logText = string
    end

    messagesText:set ( logText )

end

function addFeedback (string)
    feedbackMsgCounter = feedbackMsgCounter + 1
    if feedbackMsgCounter > 14 then
        feedbackMsgCounter = 0
        feedbackLog = round(currentTime, 1) ..": ".. string
    else
        feedbackLog = feedbackLog .. "\n" ..  round(currentTime, 1) ..": ".. string
    end

    feedbackText:set ( feedbackLog )

end



--------------------------------------------------------------------------------
------------------------------------------------------------------------- COPIED
--------------------------------------------------------------------------------

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end
