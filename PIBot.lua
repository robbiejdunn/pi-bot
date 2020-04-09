PIBot = { }

-- local chat_functions = {
--     ["CD"] = PIB
-- }

function PIBot:Setup()
    local frame = CreateFrame("FRAME")
    frame:RegisterEvent("CHAT_MSG_WHISPER")
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:SetScript("OnEvent", PIBot.EventHandler)
end

function PIBot:EventHandler(event, ...)
    if event == "CHAT_MSG_WHISPER" then
        PIBot:ChatEventHandler(...)
    end
end

function PIBot:ChatEventHandler(msg, sender, ...)
    -- store string in lowercase to avoid case sensitivity
    local msg_lowered = string.lower(msg)
    local msg_words = msg_lowered:gmatch("%w+")

    if string.match(msg, "^pi [a-z]+$") then
        if string.match(msg, " cd$") then
            SendChatMessage(PIBot:Cooldown(), "WHISPER", nil, sender)
        else
            SendChatMessage("Unknown command. Available commands are [cd].", "WHISPER", nil, sender)
        end
    end
end

-- TODO: this should fail gracefully if can't find / don't know spell
function PIBot:Cooldown()
    piStart, piDuration = GetSpellCooldown("Power Infusion")
    if piDuration == 0 then
        return "PI is currently off cooldown."
    else
        local piCD = string.format("%.2f", piStart + piDuration - GetTime())
        return "PI has a cooldown of " .. piCD .. " seconds."
    end
end

PIBot:Setup()
