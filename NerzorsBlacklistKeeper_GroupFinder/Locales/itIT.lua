local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("itIT", {
    ["Group Finder warnings"]                              = "Avvisi della Ricerca gruppi",
    ["Enable Group Finder warnings"]                       = "Attiva gli avvisi nella Ricerca gruppi",
    ["Flag blacklisted leaders in search results"]         = "Segnala i capogruppo in lista nera nei risultati",
    ["Warn before applying to a blacklisted leader"]       = "Avvisa prima di candidarti da un capogruppo in lista nera",
    ["Warn when a blacklisted player applies to my group"] = "Avvisa quando un giocatore in lista nera si candida al mio gruppo",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "Il candidato |cff%s%s|r-%s è nella lista nera (%s)",
})
