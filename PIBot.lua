PIBot = { }

function PIBot:Setup()
    local frame = CreateFrame("FRAME")
    frame:RegisterEvent("CHAT_MSG_WHISPER")
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:SetScript("OnEvent", PIBot:EventHandler)
end

function PIBot:EventHandler(event)
    print(event)
end

PIBot:Setup()
