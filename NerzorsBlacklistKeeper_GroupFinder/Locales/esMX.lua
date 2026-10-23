local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("esMX", {
    ["Group Finder warnings"]                              = "Avisos del buscador de grupos",
    ["Enable Group Finder warnings"]                       = "Activar avisos en el buscador de grupos",
    ["Flag blacklisted leaders in search results"]         = "Marcar a los líderes de la lista negra en los resultados",
    ["Warn before applying to a blacklisted leader"]       = "Avisar antes de postularte con un líder de la lista negra",
    ["Warn when a blacklisted player applies to my group"] = "Avisar cuando un jugador de la lista negra se postule a mi grupo",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "El postulante |cff%s%s|r-%s está en la lista negra (%s)",
})
