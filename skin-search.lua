local Search = {}
local I18n = require("i18n")
local function lower(text)
    for upper, small in pairs({["Ă"]="ă", ["Â"]="â", ["Î"]="î", ["Ș"]="ș", ["Ț"]="ț",
        ["Á"]="á", ["À"]="à", ["Ã"]="ã", ["É"]="é", ["È"]="è", ["Í"]="í", ["Ó"]="ó",
        ["Ò"]="ò", ["Õ"]="õ", ["Ú"]="ú", ["Ü"]="ü", ["Ñ"]="ñ", ["Ç"]="ç",
        ["Ä"]="ä", ["Ö"]="ö", ["ẞ"]="ß", ["Ê"]="ê", ["Ë"]="ë", ["Ï"]="ï", ["Ô"]="ô",
        ["Û"]="û", ["Ÿ"]="ÿ", ["Œ"]="œ", ["İ"]="i", ["Ğ"]="ğ", ["Ş"]="ş",
        ["Ą"]="ą", ["Ć"]="ć", ["Ę"]="ę", ["Ł"]="ł", ["Ń"]="ń", ["Ś"]="ś",
        ["Ź"]="ź", ["Ż"]="ż"}) do
        text = text:gsub(upper, small)
    end
    -- Turkish capital I has two lowercase forms; fold both for name searches.
    return text:lower():gsub("ı", "i")
end

-- Return original IDs so filtered cards still select and save the right skin.
function Search.find(skins, query)
    query = lower(query):match("^%s*(.-)%s*$")
    local id = query:match("^#?(%d+)$")
    if id then
        id = tonumber(id)
        return skins[id] and {id} or {}
    end
    local results = {}
    for index, skin in ipairs(skins) do
        -- Localized names are aliases; names and IDs used in saves stay stable.
        local localized = skin.fruit and lower(I18n.t(skin.name)) or ""
        if query == "" or skin.name:lower():find(query, 1, true)
            or localized:find(query, 1, true)
            or (skin.tags and skin.tags:lower():find(query, 1, true)) then
            results[#results + 1] = index
        end
    end
    return results
end

return Search
