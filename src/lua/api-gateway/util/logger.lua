local set = false

local function is_in_init_phase()
    return ngx.var.requestId
end

local function getLogFormat(level, debugInfo, ...)
    local status, result = pcall(is_in_init_phase)
    if status then
        return level, "[", debugInfo.short_src,
        ":", debugInfo.currentline,
        ":", debugInfo.name,
        "() req_id=", tostring(result),
        "] ", ...
    else
        return 'NOTICE', "[", debugInfo.short_src,
        ":", debugInfo.currentline,
        ":", debugInfo.name,
        "() req_id=",
        "] ", ...
    end
end

local function _decorateLogger()
    if not set then
        local oldNgx = ngx.log
        ngx.log = function(level, ...)
            local debugInfo =  debug.getinfo(2)
            pcall(function(...)
                oldNgx(getLogFormat(level, debugInfo, ...))
            end, ...)
        end
        set = true
    end
end

return {
    decorateLogger = _decorateLogger
}