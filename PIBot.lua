PIBot = { }

function PIBot:EventHandler(self, event, ...)
    print(event)
end

function PIBot:Setup()
    local frame = CreateFrame("FRAME")
    frame:RegisterEvent("CHAT_MSG_WHISPER")
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:SetScript("OnEvent", PIBot.EventHandler)
end

PIBot:Setup()
