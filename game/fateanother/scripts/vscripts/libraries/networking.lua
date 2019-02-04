--- Replicates some arbitrary data to a net table, and returns a table that has a get() function to get that data.
--- Automatically cleans up once the returned table is garbage collected by LUA.
---@param data any
function NetworkReplicate(data)
    local key = DoUniqueString()
    local replicated_data = {}
    if IsServer() then
        CustomNetTables:SetTableValue("sync", key, { value = data })
        local proxy = newproxy(true)
        local proxy_mt = getmetatable(proxy)
        proxy_mt.__gc = function(self)
            print("NETWORK: Destroying unused data!")
            CustomNetTables:SetTableValue("sync", key, nil)
        end
        replicated_data.__gc = proxy
    end
    replicated_data.get = function(self)
        return CustomNetTables:GetTableValue("sync", key)
    end
    return replicated_data
end