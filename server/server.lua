local current = nil

RegisterNetEvent('moped_doctor:checkin')
AddEventHandler('moped_doctor:checkin', function()
    local src = source
    if not current then
        if not Config.Standalone then
            if Config.Framework == 'vorp' then
                local VORP = exports.vorp_core:vorpAPI()
                local user = VORP.getCharacter(src)
                local money = user.money
                local newmoney = money - Config.Money
                if newmoney >= 0 then
                    if not current then
                        VORP.removeMoney(src, 0, Config.Money)
                        current = src
                        TriggerClientEvent('moped_doctor:start', src)
                    else
                        TriggerClientEvent('moped_doctor:occupied', src)
                    end
                else
                    TriggerClientEvent('moped_doctor:notenoughmoney', src, tostring(newmoney):gsub("-",""))
                end
            elseif Config.Framework == 'redemrp' then
                TriggerEvent('redemrp:getPlayerFromId', src, function(user)
                    local money = user.getMoney()
                    local newmoney = money - Config.Money
                    if newmoney >= 0 then
                        if not current then
                            user.removeMoney(Config.Money)
                            current = src
                            TriggerClientEvent('moped_doctor:start', src)                      
                        else
                            TriggerClientEvent('moped_doctor:occupied', src)
                        end
                    else 
                        TriggerClientEvent('moped_doctor:notenoughmoney', src, tostring(newmoney):gsub("-",""))
                    end
                end)
            end
        elseif Config.Standalone then
            if not current then
                current = src
                TriggerClientEvent('moped_doctor:start', src)
            else
                TriggerClientEvent('moped_doctor:occupied', src)
            end
        end
    else
        TriggerClientEvent('moped_doctor:occupied', src)
    end
end)

RegisterNetEvent('moped_doctor:checkout')
AddEventHandler('moped_doctor:checkout', function()
    local src = source
    if current == src then
        current = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if current == src then
        print('Player ' .. src .. ' dropped while doctor was taking care of them. Removing them from being the current pacient. (Reason: ' .. reason .. ')')
        current = nil
    end
end)