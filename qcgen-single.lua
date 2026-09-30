---@param text string|nil
---@return string|nil
local function capitalize_if_upper(text)
    if text == nil or text == "" then
        return nil
    end
    if text:upper() ~= text then
        return text
    end
    return (text:lower():gsub("(%a)([%w']*)", function(head, tail)
        return head:upper() .. tail
    end))
end

---@param parks QslPark[]
---@return string|nil
local function format_parks(parks)
    local lines = {}
    for _, park in ipairs(parks) do
        local name = park.name_ja or park.name_en
        if name ~= nil then
            table.insert(lines, park.reference .. " " .. name)
        else
            table.insert(lines, park.reference)
        end
    end
    if #lines == 0 then
        return nil
    end
    return "POTA: " .. table.concat(lines, ", ")
end

---@param jcx QslJapanJcx|nil
---@return string|nil
local function format_japan_address(jcx)
    if jcx == nil or jcx.name == nil then
        return nil
    end
    local prefecture = jcx.prefecture and jcx.prefecture.name or ""
    local city = jcx.city and jcx.city.name or ""
    return prefecture .. city .. jcx.name .. (jcx.town or "")
end

---@param location QslLocation
---@return string
local function format_address(location)
    local state = location.state and (location.state.name or location.state.code)
    local candidates = {
        capitalize_if_upper(location.city),
        state,
        capitalize_if_upper(location.country),
    }
    local parts = {}
    for i = 1, 3 do
        if candidates[i] ~= nil and candidates[i] ~= "" then
            table.insert(parts, candidates[i])
        end
    end
    return table.concat(parts, ", ")
end

---@param location QslLocation
---@return string
local function format_location(location)
    return format_japan_address(location.japan_jcx) or format_address(location)
end

---@param jcx QslJapanJcx|nil
---@return string
local function format_jcx(jcx)
    if jcx == nil or jcx.kind == "prefecture" then
        return ""
    end
    return jcx.code
end

---@param references QslReferences
---@return string
local function format_remarks(references)
    return format_parks(references.pota) or ""
end

---@param args table<string,string>
---@param entries QslCardEntry[]
local function generate(args, entries)
    local converted_entries = {}
    for i, e in ipairs(entries) do
        local bureau_call = e.qso.call
        local call = e.qso.call
        local call_suffix_index = call:find("/")
        local via = false
        local datetime = e.qso.datetime
        local timezone = "UTC"

        if e.qsl.via then
            bureau_call = e.qsl.via
            via = true
        elseif call_suffix_index ~= nil then
            bureau_call = bureau_call:sub(1, call_suffix_index - 1)
        end

        if e.qso.mode ~= "FT8" then
            datetime = datetime:to_offset("+09:00")
            timezone = "JST"
        end

        table.insert(converted_entries, {
            bureau_via = via,
            bureau_call = bureau_call,

            report_call = call,
            report_date = datetime.date_str,
            report_timezone = timezone,
            report_time = datetime.time_str,
            report_rst = e.exchange.tx_report or "",
            report_freq = e.qso.freq_str,
            report_mode = e.qso.mode,

            qsl_number = "",
            qsl_received = e.qsl.received,

            inst_rig = e.instrument.rig or "",
            inst_power = e.instrument.power and tostring(e.instrument.power) or "",
            inst_antenna = e.instrument.antenna or "",

            op_call = e.station.callsign or "",
            op_operator = e.operator.name or "",
            op_location = format_location(e.station.location),
            op_grid = e.station.location.grid or "",
            op_jcx = format_jcx(e.station.location.japan_jcx),

            remarks = format_remarks(e.station.references),
        })
    end

    return converted_entries
end

return {
    generate = generate,
}
