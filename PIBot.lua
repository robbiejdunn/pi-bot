PIBot = { }

_G["sessionPICastsCount"] = 0

_G["sessionStats"] = {
    ["DamageSpellCasts"] = 0,
    ["TotalDamageIncrease"] = 0
}

-- the unit with PI currently active
PIBot.PICurrentUnit = nil

-- variables used to track statistics for the current PI cast
PIBot.PICurrentNumberCasts = 0
PIBot.PICurrentDamageTotal = 0
PIBot.PICurrentDamageOverkill = 0

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
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        PIBot:CombatLogEventHandler(...)
    end
end

function PIBot:ChatEventHandler(msg, sender, ...)
    -- store string in lowercase to avoid case sensitivity
    local msg_lowered = string.lower(msg)

    if string.match(msg_lowered, "^pi [a-z]+$") then
        if string.match(msg_lowered, " cd$") then
            SendChatMessage(PIBot:Cooldown(), "WHISPER", nil, sender)
        elseif string.match(msg_lowered, " stats$") then
            SendChatMessage(PIBot:StatsSession(), "WHISPER", nil, sender)
        else
            SendChatMessage("Unknown command. Available commands are cd stats.", "WHISPER", nil, sender)
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

function PIBot:CombatLogEventHandler(...)
    timestamp, event, hideCaster, srcGUID, srcName, srcFlags, sourceRaidFlags, dstGUID, dstName, dstFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg18, arg19, arg20 = CombatLogGetCurrentEventInfo()
    if srcName == "Dizia" and arg13 == "Inner Fire" and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
        PIBot:PICast(dstName)
    elseif srcName == PIBot.PICurrentUnit and event == "SPELL_DAMAGE" then
        PIBot:PISpellDamage(arg15, arg16)
    elseif event == 'SPELL_AURA_REMOVED' and srcName == PIBot.PICurrentUnit and arg13 == 'Inner Fire' then
        PIBot:PIEnded()
    end
end

function PIBot:PICast(target)
    PIBot.PICurrentUnit = target
    _G["sessionPICastsCount"] = _G["sessionPICastsCount"] + 1
    print("PI cast on " .. PIBot.PICurrentUnit .. "! Casts this session: " .. _G["sessionPICastsCount"])
end

function PIBot:PISpellDamage(damageTotal, damageOverkill)
    PIBot.PICurrentNumberCasts = PIBot.PICurrentNumberCasts + 1
    PIBot.PICurrentDamageTotal = PIBot.PICurrentDamageTotal + damageTotal
    PIBot.PICurrentDamageOverkill = PIBot.PICurrentDamageOverkill + damageOverkill
end

function PIBot:StatsSession()
    return "PI has been cast " .. _G["sessionPICastsCount"] .. " times this session. During this, " .. _G["sessionStats"]["DamageSpellCasts"] ..
        " damaging spells have been cast with PI providing " .. _G["sessionStats"]["TotalDamageIncrease"] .. " extra damage."
end

function PIBot:PIEnded()
    print("PI SESSION ENDED")

    local dmgDone = PIBot.PICurrentDamageTotal - PIBot.PICurrentDamageOverkill
    local piDamageContributed = dmgDone * 0.2
    _G["sessionStats"]["DamageSpellCasts"] = _G["sessionStats"]["DamageSpellCasts"] + PIBot.PICurrentNumberCasts
    _G["sessionStats"]["TotalDamageIncrease"] = _G["sessionStats"]["TotalDamageIncrease"] + piDamageContributed
end

PIBot:Setup()
