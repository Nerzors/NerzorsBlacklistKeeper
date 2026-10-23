local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ptBR", {
    ["Group Finder warnings"]                              = "Avisos do Localizador de Grupos",
    ["Enable Group Finder warnings"]                       = "Ativar avisos no Localizador de Grupos",
    ["Flag blacklisted leaders in search results"]         = "Marcar líderes da lista negra nos resultados",
    ["Warn before applying to a blacklisted leader"]       = "Avisar antes de se candidatar com um líder da lista negra",
    ["Warn when a blacklisted player applies to my group"] = "Avisar quando um jogador da lista negra se candidatar ao meu grupo",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "O candidato |cff%s%s|r-%s está na lista negra (%s)",
})
