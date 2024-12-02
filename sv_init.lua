local SEATS = {
    [-1] = "Driver",
    [0] = "Shotgun",
    [1] = "Back Left",
    [2] = "Back Right"
}

function FirstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

-- function GetPlayerName( player )
--     return exports.sample_util:GetPlayerName( player )
-- end

function FormatLicenseType(_type)
    if _type == "ip" then
        _type = "IP"
    elseif _type == "fivem" then
        _type = "FiveM"
    elseif _type == "xbl" then
        _type = "Xbox Live"
    elseif _type == "live" then
        _type = "Windows Live"
    else
        _type = FirstToUpper(_type)
    end

    return _type
end

function GenerateConnection(src, title, description, color, isConnecting)
    local name = GetPlayerName(src)

    local content = {
        embeds = {
            {
                title = title:format(name, src),
                description = description:format(name, src),
                color = color
            }
        },
        username = isConnecting and CONNECTING_USERNAME or DISCONNECTED_USERNAME,
        avatar_url = isConnecting and CONNECTING_AVATAR or DISCONNECTED_AVATAR
    }

    local connect = content.embeds[1]

    for k, v in pairs(GetPlayerIdentifiers(src)) do
        local _type, identifier = v:match("(.+):(.+)")
        _type = FormatLicenseType(_type)

        connect.fields = connect.fields or {}

        table.insert(connect.fields, {
            name = _type,
            value = identifier,
            inline = false
        })
    end

    return json.encode(content)
end

AddEventHandler('playerConnecting', function()
    local player = source

    local content = GenerateConnection(player, "%s Connected", "%s has connected to the server.", "2096896", true)

    PerformHttpRequest(CONNECTING_WEBHOOK, function(err, text, headers) end, 'POST', content, { ['Content-Type'] = 'application/json' })

    -- TriggerClientEvent( 'chat:addMessage', -1, {
    --     args = { '[^2+^7] ^7' .. GetPlayerName( player ) .. ' has connected.' }
    -- })
end)

local joinTime = {}

AddEventHandler('playerJoining', function(source)
    local player = source
    local identifier = GetPlayerIdentifier(player)

    joinTime[identifier] = os.date('%Y-%m-%d %H:%M:%S')
    --print(joinTime[identifier])

end)

AddEventHandler('playerDropped', function(reason)
    local player = source

    local content = GenerateConnection(source, "%s [%s] Disconnected", "%s [%s] has disconnected from the server. ( " .. reason .. " )", "16711680", false)

    PerformHttpRequest(DISCONNECTED_WEBHOOK, function(err, text, headers) end, 'POST', content, { ['Content-Type'] = 'application/json' })


    local identifier = GetPlayerIdentifier(player)
    local username = GetPlayerName(player)
    local logintime = joinTime[identifier]
    --print(logintime)
    --print(joinTime[identifier])

    local disconnectime = os.date('%Y-%m-%d %H:%M:%S')
    MySQL.Async.execute("INSERT INTO playertime (username, identifier, logintime, disconnectime) VALUES (@username, @identifier, @logintime, @disconnectime)", {["@username"] = username, ["@identifier"] = identifier, ["@logintime"] = logintime, ["@disconnectime"] = disconnectime})

    joinTime[identifier] = nil
    -- TriggerClientEvent( 'chat:addMessage', -1, {
    --     args = { '[^1-^7] ^7' .. GetPlayerName( player ) .. ' has disconnected (' .. reason .. ').' }
    -- })
end)

AddEventHandler("chatMessage", function(player, name, message)
    local username = CHAT_USERNAME
    local text = message

    if username == nil or username == "" then
        username = GetPlayerName(player).. " ["..tostring(player).."]"
    else
        text = GetPlayerName(player).. " ["..tostring(player).."]"..": "..message
    end

    local content = json.encode {
        username = username,
        content = text,
        avatar_url = CHAT_AVATAR
    }

    PerformHttpRequest(CHAT_WEBHOOK, function(err, text, headers) end, 'POST', content, { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent("sample_logs:OnPlayerDied")
AddEventHandler("sample_logs:OnPlayerDied", function(_type, deathcoords)
    print "Dead"
end)

RegisterNetEvent("sample_logs:OnPlayerWasted")
AddEventHandler("sample_logs:OnPlayerWasted", function(_type, deathcoords)
    print "OnPlayerWasted"
end)

RegisterNetEvent("sample_logs:OnPlayerKilled")
AddEventHandler('sample_logs:OnPlayerKilled', function(killerId, weapon, vehicle, coords, street)
    local killerName = GetPlayerName(killerId) or ("Name Not Found (id: "..killerId..")")
    local deadName = GetPlayerName(source) or "UNKNOWN"

    --if vehicle then
    --    vehicle = NetToVeh(vehicle)
    --end

    local content = {
        embeds = {
            {
                title = source ~= killerId and killerName.." killed "..deadName or killerName.. " commited suicide",
                description = deadName.." was killed by "..killerName..".",
                color = "16711680",
                fields = {}
            }
        },
        username = KILL_USERNAME,
        avatar_url = KILL_AVATAR
    }

    table.insert(content.embeds[1].fields, {
        name = "Killer Driving",
        value = vehicle and "true" or "false",
        inline = false,
    })

    table.insert(content.embeds[1].fields, {
        name = "Weapon",
        value = weapon or "UNKNOWN",
        inline = false,
    })

    table.insert(content.embeds[1].fields, {
        name = "Street",
        value = street,
        inline = false
    })

    table.insert(content.embeds[1].fields, {
        name = "Coords",
        value = "`"..json.encode(coords).."`",
        inline = false
    })

    PerformHttpRequest(KILL_WEBHOOK, function(err, text, headers) end, 'POST', json.encode(content), { ['Content-Type'] = 'application/json' })
end)


RegisterCommand("test_connect", function(source)
    local content = GenerateConnection(source, "%s Connected", "%s has connected to the server.", "2096896", "Connection Logs")

    print(content)

    PerformHttpRequest(CONNECTING_WEBHOOK, function(err, text, headers) print(err, text, json.encode(headers)) end, 'POST', content, { ['Content-Type'] = 'application/json' })
end)
