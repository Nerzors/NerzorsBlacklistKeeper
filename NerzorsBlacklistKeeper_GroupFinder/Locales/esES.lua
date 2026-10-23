local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("esES", {

    ["Warn before applying to a blacklisted leader"]       = "Avisar antes de apuntarte con un líder de la lista negra",
    ["Warn when a blacklisted player applies to my group"] = "Avisar cuando un jugador de la lista negra se apunte a mi grupo",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "El candidato |cff%s%s|r-%s está en la lista negra (%s)",
})
